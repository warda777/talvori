# Bericht: Lokaler Wörter-prüfen-Flow und Home-Feinschliff

## 1. Ausgangspunkt

- Der V-Button oben links im HomeScreen war ursprünglich mit der alten
  Supabase-/`VocabSortScreen`-Logik verbunden.
- Ziel war der Umbau auf lokale Datenbanklogik und lokale
  Membership-Status.
- Zusätzlich wurden HomeScreen, Tali/Vori und Companion-UI weiter verfeinert.

## 2. Wörter prüfen

- Der V-Button öffnet jetzt die lokale Wörter-prüfen-UI.
- Der Screen ist `LocalKnownReviewScreen`.
- Die lokale Steuerung läuft über `LocalKnownReviewController`.
- Wörter bleiben immer in ihrer ursprünglichen Wortwelt.
- Es gibt keine echte Verschiebung in andere Kategorien.

## 3. Kenn ich

- `Kenn ich` basiert auf `word_world_memberships.is_known`.
- Der Plus-Button markiert das aktuell mittige Wort in der Wheel.
- Das Wort erscheint danach in der Filteransicht `Wörter, die ich kenne`.
- Das Wort bleibt in der ursprünglichen Wortwelt sichtbar, wird aber aus
  Practice/Lernmodus herausgefiltert.
- Aktivieren setzt `is_known = false` und macht das Wort wieder lernbar.

## 4. Noch lernen

- `Noch lernen` basiert auf
  `word_world_memberships.is_reviewed_for_learning`.
- Wörter werden als geprüft markiert, bleiben aber aktiv im Lernstoff.
- `Noch zu lernen` ist eine reine Filter-/Vocabs-Ansicht.
- Dadurch wird kein SRS-Fortschritt verändert.

## 5. Filteransichten

- `Wörter, die ich kenne` ist eine reine Vocabs-/Filteransicht.
- `Noch zu lernen` ist ebenfalls eine reine Vocabs-/Filteransicht.
- Beide Ansichten sind keine CategoryDetail-Seiten.
- Beide Ansichten haben keinen eigenen Lernmodus.
- Sie dienen nur zur Übersicht und Reaktivierung.

## 6. Kategorie-/Review-Zustand

- Der Review-Zustand wird pro Wortwelt beziehungsweise Membership geführt.
- Bereits bearbeitete Wörter sollen nicht wieder als unbearbeitet erscheinen.
- Der Reset wirkt nur auf die aktuell ausgewählte Wortwelt.

## 7. HomeScreen-Feinschliff

- Der Bilderrahmen wurde als ruhiges Talvori-Portal gestaltet.
- Der Counter wurde aus dem Bilderrahmen entfernt.
- Der Wheel-Counter erscheint nur temporär beim Bewegen der Word-Wheel.
- Die TopBar-/Home-Glow-Kante wurde untersucht.
- Die harte Kante wurde auf Clipping im `SingleChildScrollView`
  zurückgeführt.
- `clipBehavior: Clip.none` verhindert dort abgeschnittene Glows.
- Der spätere Versuch, das Prinzip pauschal auf weitere Screens zu
  übertragen, wurde verworfen beziehungsweise zurückgenommen. Künftige
  Glow-Fixes sollten pro Screen gezielt geprüft werden.

## 8. Tali / Vori

- Tali-/Vori-Varianten wurden vorbereitet.
- Der Companion-Name soll abhängig von der ausgewählten Figur sein:
  - `Tali`
  - `Vori`
- Langfristig sollen Tali und Vori getrennte Companion-Identitäten und
  getrennte Chatverläufe haben.

## 9. Tests

- Relevante Tests wurden mehrfach ausgeführt.
- `flutter test` war grün.
- `git diff --check` war sauber.
- Nach der letzten Rücknahme wurden in diesem Dokumentationsschritt keine
  Tests erneut ausgeführt, weil keine Codeänderung vorgenommen wurde.

## 10. Offene Punkte

- Wörter-prüfen-Flow auf Gerät weiter feinprüfen.
- Wheel-Flüssigkeit und Linienübertritt weiter testen.
- Noch-lernen-Zähler bei Grenzfällen beobachten.
- Tali/Vori getrennte Chatverläufe noch final prüfen.
- Home-Glow nicht pauschal auf andere Screens übertragen, sondern pro Screen
  einzeln prüfen.
- Alte Supabase-/`VocabSortScreen`-UI später entfernen oder vollständig lokal
  ablösen.
