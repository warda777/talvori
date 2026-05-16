# CategoryDetail Local Design Restoration Plan

## 1. Ausgangslage

Der lokale Offline-Flow funktioniert technisch:

- `WordHubScreen(useLocalOfflineFlow: true)` kann lokale Kategorien öffnen.
- Der lokale WordHub navigiert zu `CategoryDetailScreen(useLocalOfflineFlow: true, localCategoryId: ...)`.
- Der lokale Startbutton öffnet `LearnModeScreen(useLocalOfflineFlow: true, localCategoryId: ...)`.

Die lokale CategoryDetail-Ansicht nutzt aktuell aber eine eigene Minimal-UI. Das ist nicht das Ziel der aktuellen Projektphase. Ziel ist die bestehende Talvori-UI mit lokaler Offline-first-Datenlogik darunter.

## 2. Problem

Im `build` von `CategoryDetailScreen` wird im lokalen Modus früh zu `_buildLocalOfflineFlow(context)` verzweigt. Dadurch wird die bestehende CategoryDetail-UI komplett umgangen.

Die lokale Ansicht ersetzt die alte UI aktuell durch eigene Minimal-Widgets:

- `_LocalCategoryHeader`
- `_LocalCircleButton`
- `_LocalStageBadge`

Diese Ersatz-UI ist technisch sicher, weicht aber visuell und strukturell vom bestehenden CategoryDetail-Erlebnis ab.

## 3. Zu Erhaltende Alte UI-Bausteine

Die lokale Ansicht soll sich wieder an den bestehenden CategoryDetail-Bausteinen orientieren:

- `CategoryHeaderCapsule`
- `LearningStatusPanel`
- `CategoryDetailHintBubble`
- `LevelsCard`-Optik
- `LevelSelectorButtons`-Optik
- `StageSwitchRow`-Optik
- `SrsModeToggleWithHint`-Optik
- bestehende Startbutton-Struktur

Diese Bausteine sind nicht alle direkt wiederverwendbar, weil einige intern alte Provider lesen. Die visuelle Struktur bleibt aber die Vorlage.

## 4. Problematische Provider-Kopplungen

Im lokalen Branch müssen weiterhin Online-/Alt-Provider und alte Startlogik vermieden werden:

- `categoryDetailControllerProvider`
- `categoryProgressProvider`
- `learnModeControllerProvider`
- `srsModeControllerProvider`
- `s0LockedProvider`
- `singleStageProvider`
- `levelSelectionProvider`
- `learnedInStage5Provider`
- `seedForStart(...)`
- Online-Invalidate/Reload nach Rückkehr aus dem Lernscreen

Diese Kopplungen dürfen im lokalen Branch nicht indirekt über bestehende Widgets wieder eingeführt werden.

## 5. Geplanter Umbau

Der lokale Branch bleibt früh genug, um Online-Provider zu vermeiden. Statt einer neuen Minimal-UI soll er aber einen gemeinsamen CategoryDetail-UI-Rahmen verwenden.

Erster kleiner Schritt:

- `_LocalCategoryHeader` durch den echten `CategoryHeaderCapsule` ersetzen.
- Lokale Props verwenden:
  - `title`
  - `localCategoryId`
  - `vocabsCount: 0`
  - `stages: [0, 0, 0, 0, 0, 0]`
  - lokale/no-op Actions für nicht angebundene Funktionen

`LevelsCard` soll nicht direkt im lokalen Branch wiederverwendet werden, solange es intern alte Provider liest. Stattdessen soll später ein provider-freier lokaler Levels-/Startbereich aus der bestehenden Optik abgeleitet werden.

Langfristig ist ein gemeinsamer UI-Rahmen sinnvoll, in den der Online-Branch echte Online-Daten und der lokale Branch lokale/statische Daten einspeist.

## 6. Startbutton

Der Startbutton bleibt im lokalen Branch lokal verdrahtet:

- kein `seedForStart(...)`
- keine Supabase-Vorbereitung
- keine Online-Invalidate-/Reload-Logik nach Rückkehr
- öffnet `LearnModeScreen(useLocalOfflineFlow: true, localCategoryId: ...)`

## 7. Nicht-Ziele

Dieser Umbau soll nicht Folgendes tun:

- kein Online-Flow-Umbau
- keine Supabase-Entfernung
- keine Alt-Code-Bereinigung
- kein WordHub-Umbau
- kein direkter Einsatz von provider-gekoppelten Widgets im lokalen Branch

## 8. Tests

Bestehende lokale Tests müssen erhalten bleiben und gezielt erweitert werden:

- `CategoryDetailScreen` local branch Test bleibt grün.
- Prüfen, dass die alte Header-Struktur im lokalen Branch sichtbar ist.
- Prüfen, dass der Startbutton weiterhin `LearnModeScreen` im lokalen Offline-Modus öffnet.
- `flutter analyze lib/features/words/ui/screens/category_detail_screen.dart`

