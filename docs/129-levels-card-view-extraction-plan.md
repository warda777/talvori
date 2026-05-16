# LevelsCard View Extraction Plan

## 1. Problem

`CategoryDetailScreen(useLocalOfflineFlow: true)` nutzt inzwischen denselben äußeren Frame und den echten `CategoryHeaderCapsule`. Der Body sieht aber weiterhin wie eine lokale Ersatz-UI aus.

Der alte CategoryDetail-Look steckt stark in:

- `LevelsCard`
- `LevelSelectorButtons`
- `StageSwitchRow`
- Startbutton-Struktur
- S0-Lock-/Stage-Anzeige
- bestehenden Abständen und Layout-Knobs

`LevelsCard` direkt im lokalen Branch wiederzuverwenden ist gefährlich, weil das Widget intern alte Provider liest. Dadurch könnte der lokale Offline-Flow wieder Supabase-/Online-/Alt-State auslösen.

## 2. Kritische Provider

Für den lokalen Branch kritisch sind insbesondere:

- `srsModeControllerProvider`
- `s0LockedProvider`
- `singleStageProvider`
- `levelSelectionProvider`
- `s0LockServiceProvider`
- `learnModeControllerProvider`
- `learnedInStage5Provider`
- ggf. `stagesProvider`

Einige dieser Provider sind direkt oder indirekt mit Supabase, altem LearnMode-State oder alten SRS-Regeln gekoppelt.

## 3. Zielarchitektur

`LevelsCard` soll nicht kopiert, sondern in zwei Schichten getrennt werden:

1. `LevelsCard` bleibt als bestehender provider-gekoppelter Online-Wrapper bestehen.
2. Ein neuer props-basierter `LevelsCardView` enthält die visuelle alte Optik und liest selbst keine Provider.

Geplanter Datenfluss:

- Online-Wrapper liest weiterhin bestehende Provider.
- Online-Wrapper sammelt die benötigten Werte.
- Online-Wrapper übergibt Props an `LevelsCardView`.
- Local-Branch nutzt `LevelsCardView` direkt mit lokalen/statischen Daten.

So bleibt der Online-Flow erhalten, während der lokale Branch die alte Optik nutzen kann, ohne alte Provider zu lesen.

## 4. Props Für LevelsCardView

Mögliche Props für einen provider-freien `LevelsCardView`:

- `stages` / `stageCounts`
- `mode` / `selectionMode`
- `selectingSingle`
- `visibleMask`
- `srsMode`
- `s0Locked`
- `learnedInStage5`
- `onStartPressed`
- `onModeChanged`
- `onStageTap`
- `onS0LockTapped`
- `onBeforeLockTap`
- `titleOffsetY`
- weitere Layout-Parameter, falls nötig

Wichtig: Der View darf diese Werte nur anzeigen und Callbacks auslösen. Er darf keine Provider lesen.

## 5. Lokale Nutzung

Der lokale Branch von `CategoryDetailScreen` kann den neuen `LevelsCardView` direkt nutzen:

- `stageCounts: [0, 0, 0, 0, 0, 0]`
- lokale Selection-/Mode-Werte als sichere Defaults
- lokale Startaction öffnet `LearnModeScreen(useLocalOfflineFlow: true, localCategoryId: ...)`
- kein Supabase
- kein `seedForStart(...)`
- keine alten LearnMode-/Progress-Provider

Damit kann die lokale Ansicht optisch näher an den alten CategoryDetail-Body rücken, ohne lokale Ersatz-Widgets weiter auszubauen.

## 6. Nicht-Ziele

Nicht Teil dieses Schritts:

- kein Online-Flow-Umbau
- keine Supabase-Entfernung
- keine Alt-Code-Bereinigung
- kein WordHub-Umbau
- `StageSwitchRow`/`LevelSelectorButtons` nur so weit anfassen, wie für einen provider-freien View nötig

Der erste Schritt soll die Architektur vorbereiten, nicht alle visuellen Feinheiten oder lokalen Progress-Daten final lösen.

## 7. Tests

Erwartete Absicherung:

- bestehende Online-Tests dürfen nicht brechen
- `category_detail_screen_local_branch_test` bleibt grün
- lokaler Branch zeigt eine `LevelsCard`-ähnliche alte Optik
- Start öffnet weiterhin `LearnModeScreen` im lokalen Offline-Modus
- Analyzer für betroffene Dateien

