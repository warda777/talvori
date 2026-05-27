# Companion-Browser-Share-Hinweis

## 1. Ausgangsproblem

Der alte Hinweis „Markiere ein Wort im Browser und teile es mit Talvori.“ wurde früher im Word-Wheel/Home-Empty-State angezeigt.

Nach dem Companion-Einbau war dieser Hinweis als normaler Home-Text redundant und störte visuell. Der Hinweis sollte daher vom Talvori Companion übernommen werden.

## 2. Ziel

Der Browser-Share-Hinweis soll über den Talvori Companion erscheinen.

Home/Wheel soll keinen eigenen großen Empty-State-Text mehr anzeigen. Der Companion soll den Nutzer kurz und kontextbezogen auf die Browser-Share-Funktion hinweisen.

## 3. Umsetzung

Relevante Dateien:

- `lib/features/words/ui/widgets/word_wheel_core.dart`
- `test/features/word_wheel_core_test.dart`
- `lib/features/home/ui/screens/home_screen.dart`
- `lib/features/home/ui/widgets/talvori_companion_card.dart`
- `test/features/home_screen_layout_test.dart`

`WordWheelCore` zeigt den alten Browser-Share-Hinweis nicht mehr selbst an. Die Entscheidung, ob der Companion den Hinweis zeigt, liegt im Home Screen.

## 4. Companion-Verhalten

Wenn „Meine Wörter“ leer ist, zeigt der Companion den Browser-Share-Hinweis:

„Markiere ein Wort im Browser und teile es mit Talvori.“

Der Hinweis wird nur einmal pro `HomeScreen`-Instanz ausgelöst. Der Guard dafür ist `_didShowBrowserShareHintForEmptyMyWords`.

Der Home Screen nutzt dafür `CompanionController.showBrowserShareHint()`. Danach läuft weiter die bestehende Idle-/Compact-Logik.

## 5. Bubble-Verhalten

Die Companion-Bubble ist dynamischer geworden:

- Breite bis ca. 260 px
- Message darf 3 Zeilen nutzen
- Text wird nicht mehr früh abgeschnitten
- Bubble sitzt höher über dem Mascot, mit mehr Abstand
- Bubble darf bei längerem Text nach oben wachsen

## 6. Sicherheitsregeln

- `WordWheelCore` bleibt von Companion/Riverpod entkoppelt.
- Keine KI-Anbindung in diesem Schritt.
- Keine Chat-Persistenz.
- Keine Import-/SRS-/Supabase-Änderungen.
- Home Screen bleibt nicht scrollbar.

## 7. Tests

Gelaufene Tests und Checks:

- `flutter test test/features/home_screen_layout_test.dart --reporter compact`
- `flutter test test/features/word_wheel_core_test.dart --reporter compact`
- `flutter test test/features/companion/companion_controller_test.dart --reporter compact`
- `flutter test`
- `git diff --check`

## 8. Aktueller Stand

Der Browser-Share-Hinweis ist jetzt Companion-Aufgabe.

Der alte große Empty-State-Hinweis ist entfernt. Der Companion übernimmt damit die erste echte kontextbezogene Nutzerführung.
