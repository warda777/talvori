# SRS-Systeme in Talvori: **T‑SRS**, **A‑SRS** und **Hybrid**

> Hinweis: Wenn du eine **reine Nutzer-Erklärung** (ohne Technik) suchst, lies zuerst  
> `docs/SRS_MODI_FUER_NUTZER.md`.

Dieser Bericht beschreibt **den Ist‑Zustand** der Implementierung in Flutter + Supabase: welche Daten wo liegen, welche RPCs aufgerufen werden und wie aus „Queue → Karte → Swipe → Datenbank → Switch‑Zähler“ der Ablauf entsteht.

---

## Gemeinsame Grundlagen

### Begriffe
- **Stage**: S0…S5 (UI: Switches).
- **due**: ein Wort ist „fällig“, wenn `next_due_at <= now()` (wird je nach Modus unterschiedlich stark genutzt).
- **Queue**: serverseitige Liste/IDs, die die App lädt.
- **Deck**: clientseitig gebaute Teilmenge, die in der aktuellen Session ausgespielt wird (v.a. T‑SRS/Hybrid).

### Zentrale DB-Objekte
- **`public.user_word_srs`**: *mode‑spezifischer* Zustand pro Wort+Kategorie+User (Stage, streak, next_due_at, …).  
  Diese Tabelle ist für **A‑SRS / T‑SRS / Hybrid** die wichtigste gemeinsame „Stage‑Quelle“.
- **`public.word_categories`**: Zuordnung *Wort ↔ Kategorie* (liefert alle Wörter einer Kategorie).
- **`public.v_words_user_srs`** (View): liefert Word‑Details + User‑Flags + SRS‑Felder für die App.  
  Wichtig: enthält **3 UNION‑Branches**: `'adaptive'`, `'time'`, `'hybrid'` (siehe Migration `supabase/migrations/20260206194223_fix_view_v_words_user_srs_add_hybrid.sql`).
- **`public.user_requeue`**: Requeue‑Mechanismus (Wörter werden „später nochmal“ eingestreut).

Weitere (hauptsächlich A‑SRS):
- **`public.a_refill_state`**: `refill_counter` für Eligibility/Cooldown (Keys sind in deinem Schema TEXT).
- **`public.a_deck_state`**: `last_queued_counter` pro Wort, um „pro Refill‑Zyklus nur einmal“ zu queue’n (ohne `updated_at`).

### Category-Progress / Switch-Zähler
Die Switch‑Zähler in UI kommen über:

- Flutter: `SupabaseWordRepository.fetchCategoryProgress()` (`lib/features/words/data/supabase_word_repository.dart`)
- Supabase: `public.fn_user_category_progress(p_category, p_mode, p_user)` (`remote_public_dump.sql`)

Die SQL‑Funktion zählt pro Kategorie alle `word_categories`‑Wörter und left‑joint `user_word_srs` für den gewählten Modus:

- **Stage** ist `coalesce(uws.stage, 0)` → ein fehlender `user_word_srs`‑Row bedeutet „S0“ für diesen Modus.
- **due_today** zählt `stage > 0` und `next_due_at <= now()`.

---

## Flutter-Architektur (wo passiert was?)

### Datenzugriff
- **Repository**: `lib/features/words/data/supabase_word_repository.dart`
  - lädt Queues/Details, sendet Reviews, lädt Progress.

### Learn-Session Steuerung
- **Controller**: `lib/features/words/application/learn_mode_controller.dart`
  - `_loadWords()` entscheidet *modusabhängig*, wie die Queue geladen und wie ein Deck gebaut wird.
  - `_handleAnswer()` sendet das Review (oder macht A‑SRS S0‑Sonderlogik) und synchronisiert UI/Counts.

---

## T‑SRS (Time‑based SRS)

### 1) Queue laden
Flutter ruft:

- `fetchLearnQueueForMode(...)` → Supabase RPC `fetch_learn_queue_for_mode`

Details:
- RPC kommt aus `supabase/migrations/20260206193623_fix_hybrid_fetch_learn_queue_for_mode_returns_all_when_no_stage.sql` (gleiches Muster für `time` und `hybrid`).
- Die App lädt danach Details aus **`v_words_user_srs`** mit Filter `.eq('srs_mode', 'time')`.

### 2) Deck bauen (clientseitig)
In `_loadWords()` (T‑SRS/Hybrid‑Zweig) wird aus der gesamten Queue ein **Deck bis max. 200 Karten** gebaut und stage‑basiert gemischt (Quota/Interleave).  
Das ist reine UI‑/Session‑Logik und ändert nichts in der DB.

### 3) Swipe/Review speichern
Flutter: `submitReview(..., srsSystem: SrsSystem.time)`

- RPC: `public.fn_user_review_time_mode(p_word, p_category, p_result, p_user)`
- Diese Funktion:
  - nutzt intern die bestehende TIME‑Logik `public.fn_user_review(p_word, p_result)` (liefert `srs_stage`, `next_due_at`)
  - **mirrored** das Ergebnis in `user_word_srs` als `mode='time'`

Ergebnis:
- `user_word_srs(mode='time')` wird zur Quelle für Progress/Switch‑Zähler und für `v_words_user_srs`.

---

## Hybrid

Hybrid ist in dieser Codebase (Stand jetzt) **TIME‑Logik + Hybrid‑Budget‑Mechanik**.

### 1) Queue laden
Gleich wie T‑SRS, aber:

- `fetchLearnQueueForMode(...)` → `fetch_learn_queue_for_mode` mit `p_mode='hybrid'`
- Details aus `v_words_user_srs` mit Filter `.eq('srs_mode', 'hybrid')`

Wichtige Fixes, damit Hybrid nicht „leer“ ist:
- `v_words_user_srs` **muss** Hybrid enthalten (Migration `20260206194223_fix_view_v_words_user_srs_add_hybrid.sql`)
- `fetch_learn_queue_for_mode` darf bei `p_stage = NULL` **nicht** auf `fn_hybrid_next_stage` verengen (Migration `20260206193623_fix_hybrid_fetch_learn_queue_for_mode_returns_all_when_no_stage.sql`)

### 2) Deck bauen
Wie T‑SRS (clientseitig).

### 3) Swipe/Review speichern (**entscheidend**)
Hybrid darf **nicht** über A‑SRS Review laufen (weil A‑SRS Stage 0 nicht reviewbar ist und „enrolled“ voraussetzt).

Aktueller Ist‑Pfad:
- Flutter: `submitReview(..., srsSystem: SrsSystem.hybrid)`
- RPC: `public.fn_user_review_hybrid_mode(...)`  
  (Migration `supabase/migrations/20260206194650_fix_hybrid_review_persists_user_word_srs.sql`)

Was die RPC macht:
- konsumiert Hybrid‑Budget über `public.fn_hybrid_consume_budget(...)`
- berechnet Stage+Due über die TIME‑Funktion `public.fn_user_review(p_word, p_result)`
- persistiert danach in `user_word_srs` als `mode='hybrid'`

Ergebnis:
- `fn_user_category_progress(..., 'hybrid')` zeigt Stage‑Verschiebungen sofort korrekt

---

## A‑SRS (Adaptive SRS, „Contract‑Logik“)

A‑SRS ist in dieser Codebase bewusst *anders* als Time/Hybrid:
- die App lädt **nicht** „alle Wörter“, sondern eine **serverseitige adaptive Queue** (typisch: 20).
- Stage 0 ist **kein Review‑State** (Stage 0 → Stage 1 passiert über *Enroll/Refill* oder über den S0‑Sonder‑Swipe‑Pfad).

### 1) Queue laden (serverseitig)
Flutter:
- `_loadWords()` erkennt `SrsSystem.adaptive` und lädt **immer**:
  - `fetchAdaptiveQueue(userId, categoryId, limit: 20)`

Supabase:
- `public.fn_user_learn_queue_adaptive(...)` → `public.fn_user_learn_queue_adaptive_impl(...)`
- Implementierung (siehe u.a. `supabase/migrations/20260206192128_fix_asrs_queue_a_deck_state_no_updated_at.sql`):
  - Eligibility‑Filter basiert auf:
    - `a_refill_state.refill_counter`
    - `a_deck_state.last_queued_counter`
    - Regel: **`last_queued_counter < refill_counter`**
  - priorisiert Stage‑Buckets (aktuell): **S2 > S3 > S1 > S0 > S4 > S5** (S5 limitiert)
  - mischt Requeue‑Wörter ein und schreibt `a_deck_state.last_queued_counter = refill_counter`

Wichtig:
- Bei leerer Queue crasht Flutter nicht mehr (es setzt leeren State).

### 2) Refills / „Nachschub“
In Flutter existiert der Refill‑Mechanismus über:
- `SupabaseWordRepository.nextRefillCounter()` → `public.fn_a_srs_next_refill_counter(...)`
- plus serverseitige Enroll/Refill‑Funktionen (`fn_a_srs_refill_enroll`, `fn_enroll_user_category_mode`, …), je nach aktuellem Stand deiner Migrationen.

Kernidee des Designs:
- `refill_counter` steigt pro neuem „Deck/Refill‑Zyklus“
- Queue liefert nur Wörter, die in diesem Zyklus noch nicht gequeued wurden

### 3) Swipe/Review speichern (zwei Pfade)

#### A) Stage 1–5: „echtes Review“
Flutter:
- `submitReview(..., srsSystem: SrsSystem.adaptive)`

Supabase:
- `public.fn_user_review_mode(...)` → `public.fn_user_review_mode_text(...)`
- Contract‑artige Regeln (Ist‑Implementierung aus Dump):
  - **wenn Row fehlt**: Exception „word not enrolled“
  - **wenn `stage = 0`**: Exception „stage 0 is not reviewable“
  - Promotion über Thresholds:
    - S1: 2, S2: 2, S3: 2, S4: 3, S5: 3
  - bei falsch: streak reset; S1 bleibt S1; S2–S5 bounce −1
  - `next_due_at` wird aktuell auf `now()` gesetzt (direkt fällig)

#### B) Stage 0: „kein Review“ (Sonderfall)
Flutter implementiert für A‑SRS explizit:

- **korrekt in S0** → RPC `public.fn_a_srs_s0_correct(p_user, p_category, p_word)`  
  (siehe `supabase/migrations/20260206191318_add_asrs_s0_correct_rpc.sql`)
  - guard: S1 Band‑Max = 20
  - sorgt notfalls für den `user_word_srs`‑Row
  - macht **S0 → S1** für genau dieses Wort
- **falsch in S0** → RPC `public.fn_requeue_s0_fail(...)` (Requeue, Stage bleibt 0)

Das ist die zentrale Stelle, an der A‑SRS „S0 ist nicht reviewbar“ **trotzdem** ein UI‑Swipe erlaubt.

---

## „Gelernt“-Counter in S5 (Stage 5)

Aktueller Code zählt „gelernt“ über:
- `SupabaseWordRepository.countLearnedInStage5(...)`
  - Filter: `stage = 5` und `streak >= 3` (über `v_words_user_srs` oder `user_word_srs`)

Wichtiger Hinweis (Ist‑Verhalten):
- In der aktuellen A‑SRS Review‑SQL wird bei Erreichen des S5‑Thresholds (`3`) der `streak` wieder auf **0** gesetzt.  
  Damit könnte `streak >= 3` in Stage 5 in A‑SRS **nie stabil** erreicht werden, obwohl man „3× richtig“ gemacht hat.
- Wenn du für A‑SRS wirklich „Completed/Learned“ brauchst, ist in der DB typischerweise eine **separate Markierung** nötig (z.B. `is_mastered` oder `mastered_at`) oder eine andere Streak‑Definition.

---

## Schnellübersicht: Welche RPCs/Views pro Modus?

### Queue (Learn Mode)
- **T‑SRS**: `fetch_learn_queue_for_mode` + `v_words_user_srs(srs_mode='time')`
- **Hybrid**: `fetch_learn_queue_for_mode` + `v_words_user_srs(srs_mode='hybrid')`
- **A‑SRS**: `fn_user_learn_queue_adaptive(_impl)` + `v_words_user_srs(srs_mode='adaptive')`

### Review (Swipe)
- **T‑SRS**: `fn_user_review_time_mode`
- **Hybrid**: `fn_user_review_hybrid_mode`
- **A‑SRS**:
  - S1–S5: `fn_user_review_mode` → `fn_user_review_mode_text`
  - S0 korrekt: `fn_a_srs_s0_correct`
  - S0 falsch: `fn_requeue_s0_fail`

### Progress / Switch-Zähler
- **alle**: `fn_user_category_progress(p_category, p_mode, p_user)` (Stage‑Quelle: `user_word_srs`)


