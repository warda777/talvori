# Lokales Wortmodell RFC

Stand: 2026-05-24

Dieses Dokument ist ein technischer RFC. Es beschreibt ein lokales Zielmodell
fuer Wortdaten, fuehrt aber keine Migration aus, erhoeht keine SQLite-Version
und veraendert keine Daten.

## 1. Ziel

Das lokale Wortmodell soll fachlich an die bereits analysierte Zielstruktur
herangefuehrt werden:

- Wortwelten sind Themen, zum Beispiel `Travel`, `Food & Cooking`,
  `Work & Careers` oder `Health & Fitness`.
- `A1` bis `C2` sind Level, keine Wortwelten.
- Ein Wort kann mehreren Wortwelten angehoeren.
- `Top 500 Words` ist ein Paket oder Set, keine Wortwelt.
- SRS-Fortschritt darf durch diese Modellierung nicht beschaedigt werden.

Remote/Supabase kann bereits mehr als das lokale Modell:

- `words.level`
- `words.tags`
- `word_categories` als Many-to-many

Lokal haengt ein Wort aktuell noch an genau einer `category_id`. Das reicht
nicht aus, wenn ein Wort gleichzeitig in mehreren Wortwelten liegen und ein
separates Level tragen soll.

## 2. Ist-Zustand lokal

Die lokale SQLite-Struktur ist in
`lib/core/local_database/local_database_schema.dart` dokumentiert.

Relevante Tabellen:

- `words`
  - enthaelt `category_id`
  - enthaelt Begriff, Uebersetzung, Sprachen, Status, Beispiel, Notizen und
    Archivstatus
  - hat aktuell kein eigenes `level`
  - hat aktuell keine `tags`
  - hat aktuell keine Many-to-many-Struktur fuer mehrere Wortwelten

- `categories`
  - enthaelt lokale Kategorien
  - wird aktuell als direkte Zielkategorie ueber `words.category_id` genutzt

- `word_progress`
  - enthaelt SRS-/Lernfortschritt
  - arbeitet mit `word_id`, `category_id`, `mode_id` und Feldern wie
    `stage`, `pass_count`, `next_due_at`, `is_mastered`
  - darf in diesem Umbau nicht veraendert werden

- `word_sources`
  - speichert Import-/Share-Quellen pro Wort
  - bleibt fachlich getrennt von Wortwelten, Leveln und SRS

Fehlende lokale Strukturen:

- optionales `level`-Feld am Wort
- lokale `tags`
- Many-to-many fuer Wortwelt-Mitgliedschaften
- getrennte Paket-/Set-Struktur fuer `Top 500 Words`
- optionales Modell fuer mehrere Bedeutungen eines Wortes

## 3. Zielmodell lokal

### `words`

`words` bleibt die zentrale Worttabelle.

`words.category_id` bleibt vorerst aus Kompatibilitaetsgruenden bestehen.
Es dient weiter als Fallback fuer bestehende Logik und Tests.

Neues optionales Feld:

- `level TEXT NULL`

Optional spaeter:

- `pos TEXT NULL`
- `tags TEXT NULL`

`tags` koennte als JSON-String gespeichert werden, wenn keine separate
Tag-Tabelle noetig ist. Diese Entscheidung bleibt offen.

### Neue Tabelle: `word_world_memberships`

Vorschlag:

```sql
CREATE TABLE word_world_memberships (
  word_id TEXT NOT NULL,
  category_id TEXT NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (word_id, category_id)
);
```

Zweck:

- Ein Wort kann mehreren thematischen Wortwelten zugeordnet werden.
- Level-Kategorien wie `A1` bis `C2` werden hier nicht gespiegelt.
- Pakete wie `Top 500 Words` werden hier nicht gespiegelt.

Optionale spaetere Tabellen:

- `word_packages`
- `word_package_memberships`
- `word_meanings`

## 4. Warum `category_id` vorerst bleiben soll

`words.category_id` sollte zunaechst erhalten bleiben:

- Bestehende `LocalWord`-Logik erwartet dieses Feld.
- Bestehende Screens, Importe und Tests koennen weiter funktionieren.
- `word_progress` enthaelt ebenfalls `category_id`; eine direkte Aenderung
  waere riskant.
- Eine additive Migration ist deutlich risikoaermer.
- UI und Picker koennen schrittweise auf Memberships wechseln.

Das Ziel ist kein harter Schnitt, sondern eine additive Struktur:

- alte Logik bleibt lauffaehig,
- neue Wortwelt-Logik kann Memberships lesen,
- Fallback auf `category_id` bleibt moeglich.

## 5. SRS-Sicherheit

Klare Regeln:

- `word_progress` bleibt unveraendert.
- Keine `word_id` wird geaendert.
- Keine `category_id` in `word_progress` wird geaendert.
- Keine Felder wie `stage`, `pass_count`, `is_mastered` oder
  `next_due_at` werden veraendert.
- `word_world_memberships` ist eine zusaetzliche Lesestruktur.
- Eine SRS-Migration findet nur spaeter statt und nur, wenn sie fachlich
  notwendig ist.

Das bedeutet:

- Bestehender Lernfortschritt bleibt stabil.
- Wortspiele und Picker koennen besser filtern, ohne SRS umzubauen.
- Alte Daten bleiben interpretierbar.

## 6. Migrationsstrategie in Phasen

### Phase 1: Schema vorbereiten

- Migration nur als Entwurf planen.
- Noch nicht produktiv ausfuehren.
- Keine SQLite-Version in diesem RFC erhoehen.
- Tests fuer das Zielverhalten entwerfen.

### Phase 2: Bestehende Kategorie spiegeln

- Bestehende `words.category_id` in `word_world_memberships` spiegeln.
- Nur spiegeln, wenn die Kategorie eine echte thematische Wortwelt ist.
- Level-Kategorien `A1` bis `C2` nicht als Wortwelt spiegeln.
- `Top 500 Words` nicht als Wortwelt spiegeln.

### Phase 3: UI/Picker liest Memberships

- Wortwelt-Picker und Wortspiele koennen Memberships lesen.
- `words.category_id` bleibt Fallback.
- Empty States bleiben stabil.

### Phase 4: Importlogik normalisieren

- Neue Woerter nutzen einen normalisierten Key, um Dubletten zu vermeiden.
- Wortwelt wird als Membership ergaenzt.
- Level wird in `words.level` gespeichert.
- Share-/Browser-Import bleibt SRS-neutral.

### Phase 5: Pakete separat modellieren

- `Top 500 Words` wird nicht als Wortwelt genutzt.
- Pakete werden separat modelliert, zum Beispiel mit:
  - `word_packages`
  - `word_package_memberships`
- Paketlogik wird getrennt von Wortwelten und Leveln behandelt.

## 7. Risiken

- Verwaister Fortschritt, wenn `word_id` oder `word_progress.category_id`
  versehentlich geaendert werden.
- Doppelte Woerter durch unzureichende Normalisierung.
- Falsche Kategorieuebernahme, wenn Level oder Pakete als Wortwelt gespiegelt
  werden.
- `A1` bis `C2` tauchen wieder in Wortwelt-Pickern auf.
- Lokales Modell und Remote/Supabase laufen auseinander.
- Tests, die alte `category_id`-Logik voraussetzen, brechen.
- Mehrere Bedeutungen eines Wortes werden weiterhin nur unzureichend
  modelliert, solange `word_meanings` fehlt.

## 8. Offene Entscheidungen

- Tags lokal als JSON-String oder als separate Tabelle?
- Soll `pos` lokal direkt aufgenommen werden?
- `word_meanings` jetzt planen oder erst nach Wortwelt-/Level-Migration?
- Sind Level pro Wort oder pro Bedeutung?
- Wie werden Pakete technisch modelliert?
- Wie wird Remote-zu-Local-Sync spaeter angepasst?
- Soll `category_id` langfristig entfernt oder dauerhaft als
  Haupt-/Fallback-Kategorie behalten werden?

## 9. Akzeptanzkriterien fuer eine spaetere Umsetzung

- App startet ohne lokale DB-Probleme.
- Bestehende Woerter bleiben sichtbar.
- Bestehender SRS-Fortschritt bleibt unveraendert.
- `word_progress` enthaelt dieselben `word_id`- und `category_id`-Beziehungen
  wie vor der Migration.
- Wortspiele koennen Wortwelten weiterhin laden.
- `A1` bis `C2` erscheinen nicht als Wortwelten.
- `Top 500 Words` erscheint nicht als Wortwelt.
- Tests decken Schema-Migration, Membership-Spiegelung und Fallback auf
  `category_id` ab.
- Share-/Import-Flows erzeugen keine neuen Dubletten.

## 10. Naechster Schritt

Empfehlung:

1. Dieses RFC committen.
2. Danach eine echte Schema-v4-Migration als separaten kleinen Block
   entwerfen.
3. Migration zuerst lokal und testbar halten.
4. Noch keine produktiven Supabase-Daten anfassen.
5. SRS-/User-Daten in dieser Migration weiterhin unveraendert lassen.

