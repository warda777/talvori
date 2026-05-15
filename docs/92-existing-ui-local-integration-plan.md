# 92 Existing UI Local Integration Plan

Stand: 2026-05-14

## 1. Ziel

Ziel ist eine kontrollierte Anbindung der bestehenden Talvori-UI an die neue lokale Offline-first-Lernkette.

Die Integration soll:

- bestehende UI weiterverwenden
- neue lokale Lernlogik darunter anschliessen
- keine komplett neue Produkt-UI bauen
- bestehende Supabase-Flows nicht sofort entfernen
- alte und neue Lernkette kontrolliert trennbar halten
- lokale Integration in kleinen, testbaren Schritten vorbereiten

Die neue lokale Kette ist vorhanden:

`SRS-Engine -> SQLite -> Repositorys -> Facade -> LocalLearningController -> ViewModel -> ScreenContract`

Die bestehende Produkt-UI bleibt aktuell noch auf:

- `LearnModeController`
- `SupabaseWordRepository`
- `WordUserView`
- alte SRS-Modus-/Stage-Logik

Deshalb darf die Anbindung nicht als direkter Umbau des alten Lernflows starten.

## 2. Bestehende UI, Die Erhalten Bleiben Soll

Erhalten bleiben sollen:

- `HomeScreen`
- Category popup / WordHub
- `CategoryDetailScreen`
- `LearnModeScreen`
- `LevelsCard`
- `StageSwitchRow`
- vorhandene Animationen
- vorhandenes visuelles Layout
- bestehende Navigation fuer normale Nutzer
- bestehender Supabase-basierter Lernflow als Rueckfall

Besonders wertvoll sind:

- Kategorieauswahl und WordHub-Struktur
- bestehender Category-Detail-Startpunkt
- vorhandenes Lernkarten-Layout
- bestehende Stage-/Progress-Visualisierung
- bestehende App-Aesthetik

Die lokale Integration soll diese UI nicht ersetzen, sondern schrittweise unterfuettern.

## 3. Problematische Alte Logik

### LearnModeController

`learn_mode_controller.dart` ist aktuell die groesste Kopplungsstelle.

Problematisch:

- sehr grosser Controller
- nutzt `SupabaseWordRepository`
- nutzt Supabase direkt
- haelt Queue, Timer, Stage-Counts, Hybrid-Zustand, Swipe-Submit und UI-nahe Flags
- arbeitet mit `WordUserView`
- enthaelt alte SRS-Regeln
- vermischt Datenquelle, Fachlogik, UI-State und Persistenz

Direkter Umbau waere riskant.

### SupabaseWordRepository

Problematisch:

- zentrale alte Datenquelle
- enthaelt alte SRS-/RPC-/Review-Methoden
- liefert `WordUserView`
- haengt an Supabase-IDs und alten Progress-Feldern
- sollte nicht nebenbei entfernt oder umgeschrieben werden

### WordUserView

Problematisch:

- bestehende UI erwartet `WordUserView`
- neue lokale Kette liefert `LocalLearningViewModelState`
- Felder und Semantik passen nicht 1:1
- lokale SRS-Stufen und alte Stage-/PassCount-Logik duerfen nicht unkontrolliert gemischt werden

### Alte SRS-Logik

Problematisch:

- `srs_logic.dart`
- `srs_config.dart`
- `srs_mode_controller.dart`
- alte A-SRS/T-SRS/Hybrid-Begriffe
- Longpress-Hybrid-Logik
- technische Stage-Prefixe wie T/A/H
- alte Progress-/Due-Regeln

Diese Logik widerspricht teilweise den neuen V1-Regeln.

### T-SRS/A-SRS/Hybrid-Switch

Die bestehende UI zeigt alte technische Modusbegriffe und Umschaltlogik.

Fuer die lokale V1-Schicht gelten nutzerfreundlichere Begriffe:

- `time`
- `adaptive`
- `hybrid`

Sichtbar sollten spaeter nicht T-SRS/A-SRS als Hauptbegriffe sein.

## 4. Integrationsstrategien

### A) Bestehenden LearnModeController Umbauen

Beschreibung:

- `LearnModeController` direkt auf lokale Kette umstellen
- alte Supabase-Pfade im Controller ersetzen oder verzweigen

Risiko:

- sehr hoch
- viele Seiteneffekte
- bestehender Lernflow koennte brechen
- schwerer Rueckbau
- Regressionen wahrscheinlich

Aufwand:

- hoch

Erhalt bestehender UI:

- hoch, aber teuer erkauft

Testbarkeit:

- niedrig bis mittel wegen grosser Kopplung

Rueckbaubarkeit:

- niedrig

Bewertung:

- nicht als naechster Schritt geeignet

### B) Neuen LocalLearnModeController Parallel Zur Alten UI Bauen

Beschreibung:

- neuer lokaler Controller mit aehnlicher UI-API wie `LearnModeController`
- bestehende UI kann spaeter zwischen altem und lokalem Controller umgeschaltet werden

Risiko:

- mittel
- alte UI-Kopplungen muessen verstanden und teilweise gespiegelt werden
- Gefahr, den alten Controller nachzubauen

Aufwand:

- mittel bis hoch

Erhalt bestehender UI:

- gut

Testbarkeit:

- gut, wenn UI-neutrale Adapter vorangestellt werden

Rueckbaubarkeit:

- gut, solange parallel und nicht ersetzend

Bewertung:

- sinnvoll, aber nicht der allererste Schritt

### C) Adapter Zwischen LocalLearningViewModelState Und Bestehender LearnModeScreen-UI

Beschreibung:

- UI-neutrale Adapter-Schicht plant, welche bestehenden UI-Daten lokal geliefert werden koennen
- lokale State-Felder werden in eine Form gebracht, die bestehende UI spaeter konsumieren kann
- zunaechst ohne `LearnModeScreen` zu veraendern

Risiko:

- niedrig bis mittel
- keine direkte UI-Aenderung noetig
- gute Vorarbeit fuer spaetere Controller-/Screen-Anbindung

Aufwand:

- niedrig bis mittel

Erhalt bestehender UI:

- gut

Testbarkeit:

- sehr gut

Rueckbaubarkeit:

- sehr gut

Bewertung:

- beste technische Vorbereitung nach dem Kategorie-Mapping

### D) Neuen Lokalen Produkt-Lernscreen Aus Debugscreen Entwickeln

Beschreibung:

- `LocalLearningTestScreen` als Basis fuer einen neuen lokalen Produkt-Lernscreen ausbauen

Risiko:

- niedrig fuer lokale Kette
- mittel fuer Produkt, weil bestehendes Design dupliziert oder verlassen wird

Aufwand:

- mittel

Erhalt bestehender UI:

- niedrig

Testbarkeit:

- gut

Rueckbaubarkeit:

- gut

Bewertung:

- geeignet als Fallback, aber nicht als Ziel, wenn bestehende Talvori-UI erhalten bleiben soll

## 5. Empfehlung

Empfohlen wird:

1. Nicht `LearnModeController` direkt umbauen.
2. Nicht `learn_mode_screen.dart` direkt anfassen.
3. Zuerst die Kategorie-ID-Bruecke zwischen bestehender UI und lokaler Datenbank planen und testen.
4. Danach einen UI-neutralen Adapter fuer bestehende LearnMode-Datenanforderungen planen.
5. Erst danach eine parallele lokale Controller-Schicht oder gezielte Startpfad-Anbindung planen.

Kurz:

- zuerst Mapping
- dann Adapter
- dann parallel lokaler Controller/Startpfad
- erst sehr spaet bestehende UI anbinden

Diese Reihenfolge erhaelt Rueckbaubarkeit und schuetzt den bestehenden Supabase-Flow.

## 6. Erster Konkreter Integrationsschnitt

Der erste konkrete Integrationsschnitt sollte noch nicht `LearnModeScreen` sein.

Empfohlen:

- lokale Kategorie-Zuordnung als isolierte Schicht planen
- Beispiel: `LocalCategoryMappingService` oder `LocalCategoryIdResolver`
- Eingabe:
  - bestehende UI-Kategorieinformationen
  - `categoryId`
  - `categorySlug`
  - `word_hub_taxonomy.key`
- Ausgabe:
  - lokale `categoryId` fuer `LocalLearningController.startOrResume(...)`

Warum zuerst Mapping:

- `CategoryDetailScreen` startet aktuell mit `currentId`, meistens Supabase-ID
- lokale Asset-Daten nutzen stabile lokale IDs wie `basics`
- ohne Mapping kann die lokale Session nicht zuverlaessig wissen, welche lokale Kategorie gemeint ist
- ein falsches Mapping fuehrt zu leeren Sessions oder Fehlern

Noch nicht:

- kein Umbau von `CategoryDetailScreen`
- kein Umbau von `LearnModeScreen`
- keine Ersetzung des alten Startbuttons
- keine Supabase-Entfernung

## 7. Zentrale Offene Frage: Kategorie-Mapping

Die wichtigste offene Frage ist:

Wie wird eine bestehende Kategorie aus der UI auf eine lokale `categoryId` gemappt?

### basics Als Erster Debug-Fall

Vorteile:

- bereits importierbar
- bereits durch Debug-Import vorbereitet
- einfache erste Tests

Nachteile:

- keine echte WordHub-Kategorie
- nicht ausreichend fuer Produktintegration

Bewertung:

- gut fuer erste End-to-End-Probe, nicht fuer finales Mapping

### word_hub_taxonomy.key

Vorteile:

- stabile sprechende Keys
- nahe an bestehender Kategorie-Struktur
- kein Supabase-ID-Zwang
- gut fuer lokale Asset-Dateien geeignet

Nachteile:

- bestehende UI nutzt teils `supabaseId`
- lokale Assets muessen diese Keys konsequent verwenden
- Mapping muss zwischen `categorySlug`, Taxonomie-Key und lokaler ID klaeren

Bewertung:

- wahrscheinlich beste langfristige Grundlage

### Supabase-ID-Mapping

Vorteile:

- direkte Bruecke zur bestehenden App
- CategoryDetail nutzt aktuell oft Supabase-Kategorie-IDs

Nachteile:

- lokale DB wuerde an Supabase-IDs gekoppelt
- erschwert Offline-first-Unabhaengigkeit
- riskant bei spaeterem Supabase-Export/Import

Bewertung:

- nur als optionale Mapping-Spalte/Diagnose, nicht als primaere lokale ID

### Lokale Kategorien Aus Asset-Import

Vorteile:

- kontrollierte lokale IDs
- offline geeignet
- testbar

Nachteile:

- Produktdaten muessen gepflegt werden
- bestehende UI muss wissen, welche lokale Kategorie existiert

Bewertung:

- Zielbild fuer Offline-first

## 8. Was Weiterhin Nicht Passieren Darf

Nicht erlaubt:

- kein kompletter Umbau von `learn_mode_controller.dart`
- keine direkte Ersetzung von `learn_mode_screen.dart`
- keine Supabase-Entfernung nebenbei
- keine Aenderung am alten Lernflow ohne Rueckbaupfad
- keine automatische Datenmigration
- kein Zugriff auf `local_word_database.dart`
- keine technische UI-Begriffe als finale Produktlabels
- kein unkontrollierter Import beim App-Start
- keine automatische Session beim Oeffnen von Screens
- keine Vermischung alter A-SRS-Mirror-Daten mit `talvori_local_v1.db`

## 9. Spaeter Noetige Tests

Spaeter noetige Tests:

- Adapter-Test:
  - lokale ViewModel-Daten werden in UI-nahe LearnMode-Daten uebersetzt
- Startpfad-Test:
  - CategoryDetail-Start kann lokale Kategorie-ID uebergeben
- lokale Kategorie-Mapping-Tests:
  - `basics` wird korrekt erkannt
  - Taxonomie-Key wird korrekt auf lokale Kategorie-ID gemappt
  - unbekannte Kategorie liefert kontrollierten Fehler
- Widget-Test mit bestehender UI und lokalen Daten:
  - bestehende UI kann lokale aktive Karte anzeigen
  - Buttons loesen lokale Controller-Aktionen aus
- Regressionstest fuer alten Supabase-Flow:
  - bestehender Startpfad nutzt weiterhin alten Flow, solange lokale Integration nicht bewusst aktiviert ist
- Kein-Automatik-Test:
  - keine lokale Session beim Screen-Build
  - kein Import beim App-Start

## 10. Kleinster Naechster TDD-Schritt

Empfohlener kleinster naechster TDD-Schritt:

1. Einen isolierten Plan fuer lokales Kategorie-Mapping erstellen.
2. Danach eine kleine Mapping-Klasse testen, z. B.:
   - `LocalCategoryIdResolver`
3. Erster Test:
   - `local_category_id_resolver_maps_basics_debug_category`
4. Danach Tests fuer:
   - Taxonomie-Key
   - Kategorie-Slug
   - unbekannte Kategorie

Der naechste Implementierungsschritt sollte also nicht UI sein.

Empfehlung:

- zuerst lokale `categoryId`-Zuordnung stabilisieren
- dann Adapter fuer bestehende `LearnModeScreen`-Daten planen
- erst danach Produkt-UI in kleinen, reversiblen Schritten anbinden
