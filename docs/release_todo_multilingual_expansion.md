# Ergänzungsanalyse: Mehrsprachigkeitsstrategie für den Release-Plan

Stand: 30.05.2026

Diese Datei ergänzt `docs/release_todo_analysis.pdf`. Sie ersetzt die bestehende Release-ToDo-Analyse nicht, sondern erweitert sie um eine breitere Strategie für App-Sprache, Muttersprache, Lernsprache, Übersetzungsrichtungen und mehrsprachige Content-Qualität.

## 1. Strategische Bewertung

Talvori sollte langfristig nicht auf Deutsch, Englisch, Spanisch und Französisch begrenzt geplant werden. Diese vier Sprachen sind sinnvoll für einen ersten markt nahen Scope, aber die technische und redaktionelle Grundlage muss so angelegt werden, dass später weitere große Zielmärkte dazukommen können, zum Beispiel Chinesisch, Hindi, Japanisch, Russisch und perspektivisch auch RTL-Sprachen.

Die wichtigste Entscheidung ist dabei nicht, sofort viele Sprachen vollständig zu bauen. Wichtig ist, jetzt keine Architektur zu verfestigen, die Deutsch/Englisch als feste Achse voraussetzt. Sonst entsteht später teurer Umbau in UI, Import, lokaler Datenbank, Supabase-Sync, Vokabelprüfung und Tests.

**Kernprinzip:** App-Sprache, Muttersprache, Lernsprache, Übersetzungsrichtung und Content-Sprache müssen getrennte Konzepte sein.

## 2. Warum Talvori nicht auf DE/EN/ES/FR begrenzt werden sollte

Deutsch, Englisch, Spanisch und Französisch sind gute Startsprachen, aber sie decken nur einen Teil des möglichen Marktes ab. Wenn Talvori als internationale Sprachlern-App gedacht ist, müssen spätere Nutzergruppen möglich sein:

- deutschsprachige Nutzer lernen Englisch
- englischsprachige Nutzer lernen Spanisch
- englischsprachige Nutzer lernen Französisch
- spanischsprachige Nutzer lernen Englisch
- französischsprachige Nutzer lernen Englisch
- chinesischsprachige Nutzer lernen Englisch
- Hindi-sprachige Nutzer lernen Englisch
- japanischsprachige Nutzer lernen Englisch
- russischsprachige Nutzer lernen Englisch

Dafür reicht es nicht, nur einzelne UI-Labels zu übersetzen. Die App braucht eine skalierbare Sprachmodellierung:

- UI-Sprache: In welcher Sprache sieht der Nutzer die App?
- Muttersprache: In welcher Sprache werden Erklärungen, Übersetzungen und Hilfen bevorzugt?
- Lernsprache: Welche Sprache wird gelernt?
- Übersetzungsrichtung: Aus welcher Sprache in welche Sprache wird ein Vokabelpaar gezeigt?
- Content-Sprache: In welcher Sprache liegen Wort, Übersetzung, Beispielsatz, Meaning-Note und Kategorie-Label vor?

## 3. Aktuelle technische Beobachtungen

Die App hat bereits einzelne gute Grundlagen, aber noch keine durchgehend skalierbare Mehrsprachigkeitsarchitektur.

Vorhanden:

- Lokale Wörter haben `source_language` und `target_language`.
- Übersetzungsclients akzeptieren `sourceLanguage` und `targetLanguage`.
- Supabase-Import normalisiert Sprachcodes.
- ProfilePreferences speichern App-Sprache und Muttersprache.
- Manche Spiele und KI-Kontexte reichen Sprachcodes weiter.

Problematisch oder noch unfertig:

- Viele Tests und Pfade gehen faktisch von `en`/`de` aus.
- `pending_translation_processor` fällt auf `en`/`de` zurück.
- `shared_text_import_service` importiert aktuell hart mit `sourceLanguage: 'en'` und `targetLanguage: 'de'`.
- `share_ingest_service` sendet `fromLang: 'EN'` und `toLang: 'DE'`.
- `local_known_review_controller` nutzt an mehreren Stellen deutsche/native Label-Annahmen.
- Die sichtbaren UI-Texte sind überwiegend hartcodiert und deutsch.
- In `pubspec.yaml`/`lib/main.dart` ist keine erkennbare Flutter-l10n/ARB-Struktur mit `supportedLocales` vorbereitet.
- `word_world_display_names.dart` ist ein lokaler Display-Name-Resolver, aber keine vollständige mehrsprachige Lokalisierungsschicht.

## 4. Zentrale Trennung der Sprachkonzepte

### App-Sprache / UI-Sprache

Die App-Sprache steuert Menüs, Buttons, Fehlermeldungen, Onboarding, Einstellungen und Systemtexte. Sie sollte über Flutter-l10n/ARB oder eine ähnlich zentrale Struktur verwaltet werden.

Für den MVP reicht eine kleine, saubere Startmenge:

- Deutsch
- Englisch

Spanisch und Französisch können als UI-Sprachen vorbereitet werden, müssen aber nur dann vollständig sein, wenn sie im Release sichtbar auswählbar sind.

Spätere UI-Sprachen:

- Spanisch
- Französisch
- Chinesisch
- Hindi
- Japanisch
- Russisch
- weitere große Zielmärkte

RTL-Sprachen müssen nicht sofort umgesetzt werden, sollten aber architektonisch nicht blockiert werden. Das bedeutet: keine Layouts, die zwingend LTR voraussetzen, und keine hart eingebauten Pfeil-/Textflussannahmen ohne spätere Anpassungsmöglichkeit.

### Muttersprache

Die Muttersprache ist die bevorzugte Erklärungssprache des Nutzers. Sie kann mit der App-Sprache identisch sein, muss es aber nicht. Ein Nutzer kann zum Beispiel eine englische UI verwenden, aber deutsche Übersetzungen bevorzugen.

### Lernsprache

Die Lernsprache ist die Sprache, die trainiert wird. Sie darf nicht implizit Englisch sein. Talvori muss später sowohl Englisch als Lernsprache als auch Spanisch, Französisch und weitere Lernsprachen unterstützen können.

### Übersetzungsrichtung

Die Übersetzungsrichtung beschreibt konkrete Lernpaare, zum Beispiel:

- `en -> de`
- `en -> es`
- `en -> fr`
- `de -> en`
- `es -> en`
- `fr -> en`
- `zh -> en`
- `hi -> en`
- `ja -> en`
- `ru -> en`

Diese Richtung darf nicht aus UI-Sprache oder Muttersprache geraten werden. Sie muss im Profil, Lernziel oder Kurskontext eindeutig gespeichert sein.

### Content-Sprache

Content-Sprache betrifft die Daten selbst: Wort, Übersetzung, Beispiel, Meaning-Note, Kategorie-Label und Level. Ein Wortschatzdatensatz muss perspektivisch mehrere Übersetzungen und Notizen pro Sprache tragen können.

## 5. Mehrsprachiger Vokabel-Review

Die bestehende Release-Analyse fordert bereits: Alle vorhandenen Vokabeln müssen Wort für Wort geprüft werden.

Diese Prüfung sollte nicht als rein deutsch-englische Einmalaktion geplant werden. Wenn der englische Bestand ohnehin geprüft wird, sollte direkt ein Review-Format entstehen, das parallele Zielsprachen aufnehmen kann.

### Ziel

Beim Prüfen eines englischen Basiswortes werden nicht nur deutsche Übersetzungen geprüft, sondern strukturell auch weitere Zielsprachen vorbereitet:

- Deutsch
- Spanisch
- Französisch
- später Japanisch, Chinesisch, Hindi, Russisch und weitere

So müssen Kategorien, Level, Wortwelten, Bedeutungsvarianten und Basiswortschatz nicht für jede Sprache neu erfunden werden.

### Empfohlenes Review-Format

Eine Review-Tabelle sollte mindestens folgende Spalten enthalten:

| Spalte | Bedeutung |
| --- | --- |
| `word_key` | stabile ID für das Basiswort oder die Bedeutungsvariante |
| `base_language` | Ausgangssprache, z. B. `en` |
| `base_term` | Basiswort, z. B. `bank` |
| `meaning_id` | ID der Bedeutungsvariante |
| `meaning_note` | kurze Erklärung, z. B. `financial institution` vs. `river edge` |
| `part_of_speech` | Wortart |
| `category` | Wortwelt/Kategorie |
| `level` | Lernlevel, z. B. A1-C2 |
| `de` | deutsche Übersetzung |
| `es` | spanische Übersetzung |
| `fr` | französische Übersetzung |
| `ja` | japanische Übersetzung |
| `zh` | chinesische Übersetzung |
| `hi` | Hindi-Übersetzung |
| `ru` | russische Übersetzung |
| `example_en` | Beispielsatz in der Basis-/Lernsprache |
| `example_de` | lokalisierte Erklärung oder Übersetzung |
| `translation_note` | Hinweise zu Register, Kontext, falschen Freunden |
| `review_status` | `raw`, `ai_suggested`, `human_reviewed`, `approved`, `rejected` |
| `reviewer` | Prüfer oder Quelle |
| `last_reviewed_at` | Datum der letzten Prüfung |

### Bedeutungsvarianten

Bedeutungsvarianten dürfen nicht durch einfache Dublettenbereinigung zerstört werden. Ein Wort wie `bank`, `charge`, `rest`, `move` oder `incident` kann mehrere Bedeutungen haben. Für internationale Skalierung sollte nicht nur das Wort, sondern die Bedeutungsvariante geprüft werden.

Empfehlung:

- `word_key` für die Wortfamilie
- `meaning_id` für die konkrete Bedeutung
- Übersetzungen je `meaning_id`
- Kategorie und Level je Bedeutungsvariante, wenn nötig
- Meaning-Note als Pflichtfeld bei mehrdeutigen Wörtern

### KI-Übersetzung nur als Vorschlag

KI-Übersetzung kann den Prozess beschleunigen, darf aber nicht ungeprüft produktiv übernommen werden.

Qualitätsstufen:

- `raw`: ungeprüfter Import oder Rohdaten
- `ai_suggested`: maschinell vorgeschlagen
- `human_reviewed`: von Mensch geprüft, aber noch nicht final freigegeben
- `approved`: releasefähig
- `rejected`: bewusst ausgeschlossen

Für den Marktstart sollten nur `approved` Inhalte in produktiven Seeds oder sichtbaren Wortwelten landen.

## 6. Spanisch und Französisch nicht separat neu starten

Spanische und französische Lerninhalte sollten nicht später als komplett getrennte Projekte entstehen, wenn der englisch-deutsche Bestand ohnehin geprüft wird.

Stattdessen sollte die Content-Pipeline direkt mehrsprachig geplant werden:

1. englisches Basiswort prüfen
2. Bedeutungsvariante klären
3. deutsche Übersetzung korrigieren
4. spanische Übersetzung ergänzen
5. französische Übersetzung ergänzen
6. weitere Sprachen optional vorbereiten
7. Kategorien, Level und Wortwelten einmal sauber pflegen
8. Übersetzungen je Sprache separat validieren

Dadurch bleiben Wortwelten und Level konsistent, während Übersetzungen sprachspezifisch geprüft werden.

## 7. Angepasste Aufgaben aus der bestehenden Release-ToDo-Analyse

Die bestehende Analyse sollte gedanklich wie folgt angepasst werden:

- Aus „Deutsch, Englisch, Spanisch, Französisch lokalisieren“ wird: skalierbare l10n-Struktur einführen, MVP-Sprachen festlegen, spätere Sprachen vorbereiten.
- Aus „Spanische und französische Lerninhalte erstellen“ wird: mehrsprachige Content-Pipeline auf Basis geprüfter Bedeutungsvarianten erstellen.
- Aus „Vokabelqualität prüfen“ wird: mehrsprachiges Review-Format mit Bedeutungsvarianten, Qualitätsstatus und Übersetzungen je Zielsprache.
- Aus „Lernsprache und Muttersprache trennen“ wird ein Release-Blocker, weil spätere Internationalisierung sonst zu teuer wird.
- Aus „hardcodierte Texte entfernen“ wird eine systematische l10n-Migration mit ARB/Flutter-l10n oder vergleichbarer zentraler Lösung.

## 8. Priorisierte ToDo-Liste

### A. Muss vor Release

#### 1. Sprachmodell fachlich festziehen

- **Bereich:** Architektur / Produktmodell
- **Warum wichtig:** Ohne klare Trennung von App-Sprache, Muttersprache, Lernsprache und Übersetzungsrichtung entsteht später ein teurer Umbau.
- **Release-Priorität:** Muss
- **Aufwand:** mittel
- **Risiko:** hoch
- **Abhängigkeiten:** Produktentscheidung zu MVP-Sprachen und Lernpaaren
- **Betroffene Dateien/Ordner:** `lib/features/home/application/profile_preferences_controller.dart`, `lib/core/local_database`, `lib/features/words`, `lib/features/home`, `test/`
- **Umsetzungsidee:** Zentrale Sprach-/Kurskonfiguration definieren, zum Beispiel `appLocale`, `nativeLanguage`, `learningLanguage`, `sourceLanguage`, `targetLanguage`, `courseId`.
- **Empfohlene Reihenfolge:** 1
- **Marker:** Kritischer Blocker, Lokalisierung, neue Inhalte, Tests

#### 2. Skalierbare UI-Lokalisierung vorbereiten

- **Bereich:** UI / l10n
- **Warum wichtig:** Sichtbare UI-Texte sind stark deutsch geprägt und nicht zentral lokalisiert.
- **Release-Priorität:** Muss
- **Aufwand:** groß
- **Risiko:** hoch
- **Abhängigkeiten:** Entscheidung für Flutter-l10n/ARB oder Alternative
- **Betroffene Dateien/Ordner:** `pubspec.yaml`, `lib/main.dart`, `lib/features/**`, optional `lib/l10n` oder `l10n`
- **Umsetzungsidee:** Flutter-l10n/ARB einführen, `supportedLocales` definieren, harte Strings priorisiert in zentrale Ressourcen überführen.
- **Empfohlene Reihenfolge:** 2
- **Marker:** Kritischer Blocker, Lokalisierung, UI/UX, Tests

#### 3. Kritische en/de-Annahmen aus produktiven Pfaden entfernen

- **Bereich:** Import / lokale Daten / Practice / Spiele
- **Warum wichtig:** Harte `en`/`de` Defaults verhindern skalierbare Lernrichtungen.
- **Release-Priorität:** Muss
- **Aufwand:** mittel
- **Risiko:** hoch
- **Abhängigkeiten:** Sprachmodell
- **Betroffene Dateien/Ordner:** `lib/core/local_database/services/pending_translation_processor.dart`, `lib/core/local_database/services/shared_text_import_service.dart`, `lib/features/home/data/share_ingest_service.dart`, `lib/features/home/ui/screens/word_game_arcade_screen.dart`, `test/`
- **Umsetzungsidee:** Defaults nur aus aktuellem Kurs-/Profilkontext ableiten, nicht hart aus `en`/`de`.
- **Empfohlene Reihenfolge:** 3
- **Marker:** Kritischer Blocker, Lokalisierung, Tests

#### 4. Mehrsprachiges Vokabel-Review-Format planen

- **Bereich:** Content / Datenqualität
- **Warum wichtig:** Der ohnehin nötige Vokabel-Audit soll nicht später komplett neu begonnen werden.
- **Release-Priorität:** Muss
- **Aufwand:** mittel
- **Risiko:** mittel
- **Abhängigkeiten:** Entscheidung zu Basis- und Zielsprachen
- **Betroffene Dateien/Ordner:** `docs/word-review`, `assets/local_import`, Supabase-Wortdaten, zukünftige Review-Exports
- **Umsetzungsidee:** Review-CSV oder Sheet mit `word_key`, `meaning_id`, `base_language`, `de`, `es`, `fr`, `ja`, `zh`, `hi`, `ru`, `review_status` definieren.
- **Empfohlene Reihenfolge:** 4
- **Marker:** Datenqualität, neue Inhalte, Lokalisierung

### B. Sollte vor Release

#### 5. Deutsch und Englisch als UI-Sprachen sauber machen

- **Bereich:** UI / l10n
- **Warum wichtig:** Für einen realistischen MVP sind zwei solide UI-Sprachen wertvoller als vier halbfertige.
- **Release-Priorität:** Sollte
- **Aufwand:** mittel
- **Risiko:** mittel
- **Abhängigkeiten:** l10n-Struktur
- **Betroffene Dateien/Ordner:** `lib/features/home`, `lib/features/words`, `lib/features/companion`, `lib/features/chat`, `lib/l10n` oder `l10n`
- **Umsetzungsidee:** Deutsch und Englisch vollständig redaktionell prüfen; Spanisch/Französisch als spätere Locales vorbereiten, aber nicht sichtbar machen, wenn unvollständig.
- **Empfohlene Reihenfolge:** 5
- **Marker:** Lokalisierung, UI/UX, Tests

#### 6. Englisch -> Deutsch Bestand releasefähig prüfen

- **Bereich:** Vokabelqualität
- **Warum wichtig:** Der existierende Bestand ist der wichtigste kurzfristige Content-Kandidat.
- **Release-Priorität:** Sollte
- **Aufwand:** groß
- **Risiko:** hoch
- **Abhängigkeiten:** Review-Format
- **Betroffene Dateien/Ordner:** `docs/word-review`, `assets/local_import`, Supabase-Wortdaten
- **Umsetzungsidee:** Wort-für-Wort-Prüfung durchführen, Bedeutungsvarianten und Dubletten sauber markieren, nur approved Inhalte exportieren.
- **Empfohlene Reihenfolge:** 6
- **Marker:** Datenqualität, Tests

#### 7. Englisch -> Spanisch und Englisch -> Französisch strukturell vorbereiten

- **Bereich:** Neue Inhalte
- **Warum wichtig:** Diese Sprachen sollen nicht später als isolierte Parallelwelt entstehen.
- **Release-Priorität:** Sollte
- **Aufwand:** mittel
- **Risiko:** mittel
- **Abhängigkeiten:** Mehrsprachiges Review-Format
- **Betroffene Dateien/Ordner:** `docs/word-review`, zukünftige Content-Exports, `assets/local_import`
- **Umsetzungsidee:** Spalten und Qualitätsstatus für ES/FR direkt im Review-Prozess mitführen; initiale Vorschläge nur als nicht produktive Drafts.
- **Empfohlene Reihenfolge:** 7
- **Marker:** Neue Inhalte, Datenqualität, Lokalisierung

#### 8. Wortwelt- und Kategorie-Labels internationalisierbar machen

- **Bereich:** Wortwelten / UI
- **Warum wichtig:** Wortwelten dürfen nicht nur über deutsche oder englische Display-Name-Maps funktionieren.
- **Release-Priorität:** Sollte
- **Aufwand:** mittel
- **Risiko:** mittel
- **Abhängigkeiten:** l10n-Struktur und Content-Modell
- **Betroffene Dateien/Ordner:** `lib/features/words/data/word_world_display_names.dart`, `lib/core/local_database/models/local_category.dart`, `lib/features/words/ui`
- **Umsetzungsidee:** Kategorie-IDs stabil halten, Display-Namen je UI-Sprache über l10n oder Content-Metadaten ausgeben.
- **Empfohlene Reihenfolge:** 8
- **Marker:** Lokalisierung, UI/UX, neue Inhalte

### C. Kann nach Release kommen

#### 9. Weitere UI-Sprachen ergänzen

- **Bereich:** l10n / Markt-Erweiterung
- **Warum wichtig:** Chinesisch, Hindi, Japanisch und Russisch sind große Zielmärkte, aber nicht zwingend für MVP.
- **Release-Priorität:** Später
- **Aufwand:** groß
- **Risiko:** mittel
- **Abhängigkeiten:** stabile l10n-Struktur
- **Betroffene Dateien/Ordner:** `l10n`/ARB, UI-Tests, Store-Texte
- **Umsetzungsidee:** Nach MVP schrittweise Locales ergänzen, pro Sprache native Review und Layout-QA durchführen.
- **Empfohlene Reihenfolge:** 9
- **Marker:** Lokalisierung, UI/UX

#### 10. Weitere Lernrichtungen produktiv ausrollen

- **Bereich:** Content / Kurse
- **Warum wichtig:** Internationale Skalierung entsteht durch mehrere Lernpaare, nicht nur durch UI-Übersetzung.
- **Release-Priorität:** Später
- **Aufwand:** groß
- **Risiko:** hoch
- **Abhängigkeiten:** Content-Pipeline, Review-Prozess, Sprachmodell
- **Betroffene Dateien/Ordner:** `assets/local_import`, Supabase-Wortdaten, `lib/core/local_database`, `lib/features/words`
- **Umsetzungsidee:** Priorisierte Kurse nach Marktgröße ausrollen: EN->ES, EN->FR, ES->EN, FR->EN, ZH->EN, HI->EN, JA->EN, RU->EN.
- **Empfohlene Reihenfolge:** 10
- **Marker:** Neue Inhalte, Datenqualität, Tests

#### 11. RTL-Unterstützung vorbereiten

- **Bereich:** UI / Internationalisierung
- **Warum wichtig:** Arabisch, Hebräisch, Urdu und weitere Märkte benötigen RTL-taugliche Layouts.
- **Release-Priorität:** Später
- **Aufwand:** mittel
- **Risiko:** mittel
- **Abhängigkeiten:** l10n-Struktur
- **Betroffene Dateien/Ordner:** `lib/features/**`, Theme/Layout-Komponenten
- **Umsetzungsidee:** Directionality-Tests, Icons/Pfeile prüfen, harte left/right-Abstände langfristig auf start/end umstellen.
- **Empfohlene Reihenfolge:** 11
- **Marker:** Lokalisierung, UI/UX, Tests

#### 12. Community- oder Experten-Review-System planen

- **Bereich:** Content Operations
- **Warum wichtig:** Mehrsprachige Qualität skaliert langfristig nur mit systematischem Review.
- **Release-Priorität:** Später
- **Aufwand:** groß
- **Risiko:** mittel
- **Abhängigkeiten:** Review-Statusmodell und Admin-Workflow
- **Betroffene Dateien/Ordner:** `docs/word-review`, Supabase/Admin-Tools, zukünftige Review-UI
- **Umsetzungsidee:** Rollen, Review-Status, Änderungshistorie und Freigabeprozess für Übersetzungen definieren.
- **Empfohlene Reihenfolge:** 12
- **Marker:** Datenqualität, neue Inhalte

### D. Größere spätere Ausbaustufen

#### 13. Vollwertige mehrsprachige Content-Pipeline

- **Bereich:** Content Platform
- **Warum wichtig:** Für viele Sprachen braucht Talvori einen reproduzierbaren Weg von Rohdaten zu geprüften App-Exports.
- **Release-Priorität:** Ausbaustufe
- **Aufwand:** groß
- **Risiko:** hoch
- **Abhängigkeiten:** Review-Format, Qualitätsstatus, Content-Modell
- **Betroffene Dateien/Ordner:** `docs/word-review`, `tools`, `assets/local_import`, Supabase-Datenmodell
- **Umsetzungsidee:** Pipeline mit Import, Normalisierung, KI-Vorschlägen, menschlicher Prüfung, Qualitätschecks und Export pro Sprachpaar.
- **Empfohlene Reihenfolge:** 13
- **Marker:** Neue Inhalte, Datenqualität, Tests

#### 14. KI-gestützte Übersetzungsvorschläge mit menschlicher Prüfung

- **Bereich:** KI / Content QA
- **Warum wichtig:** KI kann viele Sprachen beschleunigen, darf aber nicht ungeprüft produktiv werden.
- **Release-Priorität:** Ausbaustufe
- **Aufwand:** groß
- **Risiko:** hoch
- **Abhängigkeiten:** Review-Workflow und Qualitätsstatus
- **Betroffene Dateien/Ordner:** `lib/core/ai`, `lib/core/local_database/translation`, Supabase Edge Functions, Review-Tools
- **Umsetzungsidee:** KI generiert Vorschläge mit Kontext und Meaning-Note; Human-Review entscheidet `approved` oder `rejected`.
- **Empfohlene Reihenfolge:** 14
- **Marker:** Neue Inhalte, Datenqualität, KI, Tests

#### 15. Bedeutungsvarianten pro Sprache modellieren

- **Bereich:** Datenmodell
- **Warum wichtig:** Mehrsprachige Übersetzung ist nicht 1:1. Eine Bedeutung kann je Sprache andere Formen, Register oder mehrere Übersetzungen haben.
- **Release-Priorität:** Ausbaustufe
- **Aufwand:** groß
- **Risiko:** hoch
- **Abhängigkeiten:** Content-Review und Datenmodellentscheidung
- **Betroffene Dateien/Ordner:** `lib/core/local_database/local_database_schema.dart`, Supabase-Wortdaten, `docs/word-review`
- **Umsetzungsidee:** Meaning-Variant-Entität einführen, Übersetzungen und Beispiele daran hängen, Kategorien/Level ggf. pro Variante pflegen.
- **Empfohlene Reihenfolge:** 15
- **Marker:** Datenqualität, neue Inhalte, Tests

#### 16. Release-Exports pro Sprachpaar

- **Bereich:** Distribution / lokale Seeds
- **Warum wichtig:** Je Markt und Lernpaar sollen nur geprüfte, relevante Inhalte ausgeliefert werden.
- **Release-Priorität:** Ausbaustufe
- **Aufwand:** mittel
- **Risiko:** mittel
- **Abhängigkeiten:** Content-Pipeline und Qualitätsstatus
- **Betroffene Dateien/Ordner:** `assets/local_import`, `lib/core/local_database/seed`, Supabase Export-Tools
- **Umsetzungsidee:** Pro Sprachpaar exportierbare Pakete mit `approved` Content, Kategorie-Metadaten und Versionsnummern erzeugen.
- **Empfohlene Reihenfolge:** 16
- **Marker:** Neue Inhalte, Datenqualität, Tests

## 9. Empfohlene Reihenfolge

1. MVP-Sprachscope entscheiden: Welche UI-Sprachen und welche Lernpaare sind im ersten Release wirklich sichtbar?
2. Sprachmodell dokumentieren und im Code als zentrale Konfiguration vorbereiten.
3. Flutter-l10n/ARB oder vergleichbare l10n-Struktur einführen.
4. Harte `en`/`de` Annahmen in kritischen Import-, Practice- und Content-Pfaden identifizieren und priorisiert entfernen.
5. Mehrsprachiges Review-Format für den Vokabelbestand festlegen.
6. Englisch-deutschen Bestand mit Bedeutungsvarianten prüfen.
7. Spanisch und Französisch im Review-Prozess strukturell mitführen, aber nur approved Content sichtbar machen.
8. Nach MVP weitere UI-Sprachen und Lernrichtungen schrittweise ausrollen.

## 10. Offene Fragen

- Welche UI-Sprachen sollen im ersten Release wirklich sichtbar sein?
- Ist der erste Release primär für deutschsprachige Nutzer gedacht oder direkt international?
- Welche Lernpaare sind für den MVP verpflichtend?
- Soll Englisch die erste Basis-/Pivot-Sprache für Content bleiben?
- Wie wird entschieden, ob eine Übersetzung `approved` ist?
- Wer prüft Spanisch, Französisch und spätere Sprachen fachlich?
- Soll die lokale Datenbank kurzfristig bei `source_language`/`target_language` bleiben oder mittelfristig Meaning-Variants und Translation-Records trennen?
- Dürfen KI-Vorschläge intern gespeichert werden, solange sie nicht produktiv sichtbar sind?
- Wann werden RTL-Sprachen offiziell in die Roadmap aufgenommen?

## 11. Fazit

Für den schnellsten Marktstart müssen nicht sofort Chinesisch, Hindi, Japanisch, Russisch und viele weitere Sprachen vollständig umgesetzt werden. Talvori sollte aber ab jetzt so geplant werden, dass neue Sprachen später nicht zu einem Architekturbruch führen.

Die wichtigsten kurzfristigen Maßnahmen sind:

- Sprachmodell sauber trennen
- UI-Lokalisierung skalierbar vorbereiten
- kritische `en`/`de` Defaults entfernen
- Vokabel-Review mehrsprachig strukturieren
- Spanisch und Französisch nicht als späteres separates Projekt behandeln

Damit bleibt der MVP realistisch klein, aber die Grundlage wird international skalierbar.
