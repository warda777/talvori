# MVP-Content-Scope

Stand: 2026-05-31

Dieses Dokument legt den Content-Scope fuer den ersten oeffentlichen Talvori-MVP als Entwurf fest. Es wurden keine Supabase-Daten, keine Imports, keine SQLite-/App-Vokabeldaten, keine SRS-Daten und kein `word_progress` geaendert.

## 1. Ziel

Der erste oeffentliche MVP soll nicht den gesamten vorhandenen Wortbestand als releasefertig darstellen.

Die aktuelle Review-Basis umfasst 13.629 Englisch-Deutsch-Zeilen. Der Review-Workflow, die Kandidatenlisten und erste Overlays sind vorbereitet, aber der komplette Bestand ist noch nicht Wort fuer Wort fachlich freigegeben. Fuer den Marktstart ist deshalb wichtiger, dass die direkt sichtbaren Inhalte sauber wirken:

- erste Wortwelten
- erster Lernmodus
- Wortspiele mit kleinem Wortbestand
- Store-Screenshots
- Onboarding- und Home-Pfade

Store-Screenshots duerfen nur gepruefte oder bewusst unkritische Inhalte zeigen. Talvori soll im MVP ehrlich als stabile lokale Sprachlern-App mit Wortwelten, Wiederholung und Wortspielen auftreten, nicht als vollstaendig gepruefte 13k-Wortdatenbank.

## 2. Empfohlene Hauptsprache

Der erste Content-Fokus ist:

- Lernsprache: Englisch
- Muttersprache/Uebersetzungssprache: Deutsch
- Content-Richtung: Englisch -> Deutsch

Spanisch und Franzoesisch bleiben strategisch vorbereitet, duerfen aber nicht als vollstaendige Release-Inhalte beworben werden. Weitere Sprachen, Content-Pakete und Sprachpaare bleiben nachgelagerte Ausbaustufen.

## 3. Sichtbare Content-Pfade

Gepruefte Pfade:

- Home: Einstieg in Woerter pruefen, Wortwelten, Lernmodus, Wortspiele und Browser/Import.
- WordHub/Wortwelten: thematische Hub-Struktur aus `word_hub_taxonomy.dart`.
- Learn Mode: nutzt lokale Kategorien/Wortwelten und lokale Lernfortschritte.
- Wortspiele: nutzen lokale Wortquellen und muessen auch mit kleinem Wortbestand sauber reagieren.
- Lokale Seed-/Fallback-Daten: `local_seed_data.dart` und `assets/local_import/default_words_v1.json`.
- Review-Daten: `docs/word-review/supabase_words_review.csv` und daraus abgeleitete Reports/Kandidatenlisten.

Aktuell sichtbare thematische WordHub-Gruppen:

- Life & Daily Flow
- People & Mind
- Society & Systems
- Nature & Beyond
- Action & Adventure
- Culture & Creativity

Aktuell sichtbare oder naheliegende thematische Wortwelten:

- Health & Fitness
- Home & Living / Zuhause & Alltag
- Food & Cooking
- Style & Fashion
- Money & Shopping
- Productivity
- Personality
- Feelings
- Relationships
- Thoughts
- Tech & Innovation
- Work & Careers
- School & Studies
- Media & News
- Law & Politics
- Environment
- Animals
- Nature
- Space
- Science
- Sports
- Travel
- Gaming
- Transport
- Music & Entertainment
- Art & Literature

Nicht als normale Wortwelt behandeln:

- A1, A2, B1, B2, C1, C2: Lernlevel
- Top 500 Words: Content-Paketfamilie
- Phrases & Idioms, Irregular Verbs, Grammar & Syntax: Speziallisten/Pakete, nicht Screenshot-Kern fuer den ersten MVP

## 4. MVP-Wortwelt-Empfehlung

Fuer den ersten oeffentlichen Release sollten nur 3 bis 5 Wortwelten als sichtbarer Kernbestand priorisiert werden.

Empfohlene erste Auswahl:

1. Travel / Reisen
   - Nutzerwert: hoch, sofort verstaendlich.
   - Uebersetzungsrisiko: niedrig bis mittel.
   - Screenshot-Tauglichkeit: hoch.
   - Pruefaufwand: gut begrenzbar.

2. Food & Cooking / Essen & Kochen
   - Nutzerwert: hoch, alltagsnah.
   - Uebersetzungsrisiko: niedrig bis mittel.
   - Screenshot-Tauglichkeit: hoch.
   - Pruefaufwand: gut begrenzbar.

3. Home & Living / Zuhause & Alltag
   - Nutzerwert: hoch fuer erste Lernmomente.
   - Uebersetzungsrisiko: niedrig bis mittel.
   - Screenshot-Tauglichkeit: hoch.
   - Pruefaufwand: gut begrenzbar.

4. Work & Careers / Arbeit & Karriere
   - Nutzerwert: hoch fuer erwachsene Nutzer.
   - Uebersetzungsrisiko: mittel, weil Business-Begriffe kontextabhaengig sein koennen.
   - Screenshot-Tauglichkeit: gut, aber nur mit geprueften Begriffen.
   - Pruefaufwand: mittel.

5. Health & Fitness / Gesundheit & Fitness
   - Nutzerwert: hoch.
   - Uebersetzungsrisiko: mittel, weil medizinische Begriffe sensibel sein koennen.
   - Screenshot-Tauglichkeit: gut, aber riskantere Begriffe vermeiden.
   - Pruefaufwand: mittel.

Screenshot-Kern fuer den ersten Store-Durchlauf:

- Travel
- Food & Cooking
- Home & Living

Work & Careers und Health & Fitness sind gute zweite Kandidaten, sollten aber besonders auf Mehrdeutigkeiten, Fachbegriffe und sensible Woerter geprueft werden.

## 5. Minimaler Wortumfang

Empfohlene Groessenordnung:

- 100 bis 200 gepruefte Englisch-Deutsch-Woerter fuer den ersten sichtbaren MVP-Kern.
- Alternativ: 30 bis 50 gepruefte Woerter je priorisierter Wortwelt.
- Fuer Store-Screenshots reichen weniger Woerter, aber jedes sichtbare Wort muss geprueft sein.

Diese Groesse reicht fuer den MVP, weil:

- der erste Release die App-Struktur beweisen soll, nicht Vollstaendigkeit;
- Wortspiele und Lernmodus mit kleinem Bestand bereits sinnvoll demonstrierbar sind;
- der Review-Aufwand realistisch bleibt, solange Google Play Identitaetspruefung laeuft;
- falsche oder mehrdeutige Uebersetzungen im Store-Screenshot ein groesseres Risiko waeren als ein bewusst kleiner Scope.

## 6. Content-Risiken

Aus dem Review-Report:

- 13.629 Review-Zeilen insgesamt.
- Alle Zeilen sind `needs_review` und `release_ready = false`.
- 992 Faelle mit gleichem `base_term` und `de_translation`.
- 32 exakte Dubletten-Kandidaten.
- 30 Case-Varianten.
- 16 moegliche Bedeutungsvarianten.
- 25 fehlende Level.
- 16 fehlende Kategorien/Wortwelten.
- 6.096 Strukturissue-Kandidaten.
- 5.539 A1-C2-Strukturverdachte.
- 500 Top-500-Strukturverdachte.

Inhaltliche Risiken:

- ungepruefte oder zu direkte Uebersetzungen
- gleiche englische/deutsche Schreibweise ohne Hinweis, z. B. Internationalismen
- Bedeutungsvarianten ohne `meaning_note`
- Level, Paket und Wortwelt vermischt
- Phrases/Idioms/Grammar als normale Wortwelten missverstanden
- Spanisch/Franzoesisch unvollstaendig
- KI- oder automatisch erzeugte Vorschlaege duerfen nicht ungeprueft produktiv werden

## 7. Release-Regeln

- Nur gepruefte Woerter in Store-Screenshots zeigen.
- Keine Aussage, dass alle 13k Woerter geprueft sind.
- Keine Werbung fuer vollstaendige Sprachabdeckung.
- Keine Werbung fuer vollstaendige Spanisch-/Franzoesisch-Inhalte.
- Keine TOEFL-/IELTS-/Cambridge-Werbung.
- Keine ungeprueften Remote-Pakete im Release-Autostart.
- Keine `approved`- oder `release_ready=true`-Aussage ohne menschlichen Review.
- Sichtbare MVP-Wortwelten muessen mindestens fuer den Screenshot- und Startbestand vollstaendig geprueft sein.
- Wenn eine Wortwelt sichtbar viele ungepruefte Eintraege enthaelt, darf sie nicht prominent in Store-Screenshots erscheinen.
- Content-Paketstruktur und Supabase-Sync bleiben vorbereitet, aber fuer den MVP nicht als produktive Content-Versorgung bewerben.

## 8. Naechste Review-Batches

Empfohlene Reihenfolge:

1. MVP-Wortwelt-Batch 1
   - Fokus: Travel, Food & Cooking, Home & Living.
   - Ziel: 30 bis 50 Woerter je Wortwelt fachlich pruefen.
   - Ergebnis: screenshot- und onboarding-tauglicher Kernbestand.

2. Screenshot-Content-Batch
   - Fokus: alle Woerter, die in geplanten Store-Screens sichtbar sein koennen.
   - Ziel: keine missverstaendlichen, sensiblen oder ungeprueften Begriffe im Store-Material.

3. Sichtbare gleiche `base_term`/`de_translation`-Faelle
   - Fokus: nur Faelle aus priorisierten Wortwelten.
   - Ziel: klaeren, ob Internationalismus, Eigenname, Lehnwort oder Fehler.

4. Strukturissue-Batch fuer sichtbare Wortwelten
   - Fokus: Level/Paket/Wortwelt-Trennung in Travel, Food & Cooking, Home & Living.
   - Ziel: A1-C2 und Top 500 nicht als normale Wortwelt behandeln.

5. Erweiterungsbatch Work & Careers / Health & Fitness
   - Fokus: Begriffe mit mittlerem Uebersetzungs- und Sensibilitaetsrisiko.
   - Ziel: zweite Screenshot-/Release-Wortweltgruppe vorbereiten.

6. Spanisch/Franzoesisch spaeter parallel
   - erst nach stabiler englischer Bedeutungsbasis;
   - keine ungeprueften KI-Uebersetzungen produktiv uebernehmen.

## 9. Erste MVP-Review-Arbeitsliste

Die erste gezielte Arbeitsliste wurde erzeugt:

- Datei: `docs/word-review/mvp_content_first_review_batch.csv`
- Tool: `tool/export_mvp_content_review_batch.dart`
- Quelle: `docs/word-review/supabase_words_review.csv`
- Filter: `from_lang=en`, `to_lang=de`, Wortwelten Travel, Food & Cooking, Home & Living
- Umfang: 150 Review-Zeilen plus Header
- Verteilung: 50 Travel, 50 Food & Cooking, 50 Home & Living

Die Datei ist nur eine Review-Arbeitsliste. Sie enthaelt keine Freigabe, kein `approved`, kein `release_ready=true` und keine produktive Datenkorrektur. `review_decision` und `review_note` bleiben leer, bis der manuelle Review durchgefuehrt wird.

Markierte Risikotypen im Batch:

- `standard_review`: 85
- `structure_issue`: 55
- `same_base_and_translation`: 10

Manueller Review-Abschluss:

- Arbeitskopie: `docs/word-review/mvp_content_first_review_batch_working.csv`
- Report: `docs/word-review/mvp_content_first_review_batch_report.md`
- Overlay: `docs/word-review/mvp_content_first_review_overlay.csv`
- Gesamtzeilen: 150
- Gefuellte Entscheidungen: 150
- Leere Entscheidungen: 0
- Validierungsprobleme: 0
- Overlay-Zeilen: 150 plus Header

Entscheidungen im Overlay:

- `approved_for_mvp`: 115
- `fix_translation_later`: 24
- `reject_for_mvp`: 6
- `move_out_of_mvp`: 3
- `needs_context`: 2

Das Overlay ist nur eine Review-Entscheidungsliste. Es ist kein Import, keine Produktivdatenkorrektur, keine Freigabe in App-/SQLite-/Supabase-Daten und kein `release_ready=true`.

Offene Risiken:

- `fix_translation_later`, `needs_context`, `reject_for_mvp` und `move_out_of_mvp` muessen vor Store-Screenshots beachtet werden.
- Screenshot-Woerter sollten aus den `approved_for_mvp`-Zeilen gewaehlt werden.
- Strukturissues bleiben Review-Hinweise; A1-C2 und Top 500 duerfen weiterhin nicht als normale Wortwelten behandelt werden.
