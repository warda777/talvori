# Local Category Detail Neon UI State

## 1. Ausgangslage

Der lokale Offline-Flow funktioniert technisch:

`WordHub local -> CategoryDetail local -> Start -> LearnModeScreen local`

Der lokale CategoryDetail-Branch nutzt inzwischen wieder staerker bestehende UI-Bausteine, statt eine komplett eigene Ersatz-UI zu rendern:

- `CategoryHeaderCapsule`
- `LevelsCardView`
- `LevelSelectorButtonsView`
- `StageSwitchRowView`

Das Ziel dieses Umbaus war, den lokalen CategoryDetailScreen schrittweise von einer lokalen Minimal-/Ersatz-UI wegzufuehren und die bestehende CategoryDetail-Struktur mit lokaler Datenlogik zu verwenden.

## 2. Aktueller UI-Stand

Der aktuelle uncommitted Stand verwendet fuer den lokalen Levels-/Trainingsbereich einen Dark-Neon / Retro-Futuristic / Synthwave Look.

Sichtbare Struktur:

- Wiederholungsauswahl mit `Alle Stufen` und `Einzelstufe`
- Merkstufen-Switches mit Zahlen `0` bis `5`
- Lernmodus mit `Zeitplan`, `Limitlos`, `Kombiniert`
- Startbutton im Neon-Stil

`AUTO` ist sichtbar entfernt. `LevelSelectionMode.s0toS5` bleibt intern aber weiterhin erhalten und wird als Rueckweg in den Hauptmodus genutzt.

## 3. Technische Logik

Die lokale UI behaelt die bestehende technische Bedeutung der Auswahl bei:

- `Zeitplan` setzt `SrsSystem.time`
- `Limitlos` setzt `SrsSystem.adaptive`
- `Kombiniert` setzt `SrsSystem.hybrid`
- Lernmodus-Auswahl setzt zusaetzlich `LevelSelectionMode.s0toS5` und `selectingSingle=false`
- `Alle Stufen` setzt `LevelSelectionMode.s1toS5`
- `Einzelstufe` setzt `LevelSelectionMode.single`
- `Start` oeffnet `LearnModeScreen(useLocalOfflineFlow: true, localCategoryId: ...)`

## 4. Bewusst nicht geaendert

Bewusst nicht Teil dieses UI-Umbaus:

- keine Supabase-Logik
- kein WordHub-Umbau
- keine Alt-Code-Bereinigung
- Online-Flow soll erhalten bleiben
- kein internes Entfernen von `LevelSelectionMode.s0toS5`

## 5. Offene UI-Punkte

Noch offen beziehungsweise im Simulator final zu pruefen:

- Abstand der Ueberschrift `Merkstufen` muss noch final geprueft werden
- obere Pill `Health & Fitness` soll spaeter ggf. durch `category_wheel.dart` beziehungsweise einen provider-freien Wheel-View ersetzt werden
- `Vocabs`-Kachel, Plus-Button und Settings-Button wurden visuell angepasst, muessen aber ggf. weiter geprueft werden
- finaler Screenshot-/Simulator-Abgleich steht noch aus

## 6. Tests

Zuletzt wurden fuer diesen Bereich folgende Checks ausgefuehrt:

- `flutter test test/features/learning_mode_selector_view_test.dart`
- `flutter test test/features/srs_mode_controller_test.dart`
- `flutter test test/features/category_detail_screen_local_branch_test.dart`
- `flutter test test/features/word_hub_screen_local_branch_test.dart`
- `flutter analyze` fuer die geaenderten Dart-Dateien
