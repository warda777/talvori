# 122 LearnModeScreen Direct Local Integration Analysis

Stand: 2026-05-16

## 1. Direkt Gelesene Provider Und Controller

`LearnModeScreen` ist aktuell nicht nur eine View. Der Screen liest und steuert selbst mehrere alte Lern-Provider.

Direkt im Screen verwendet:

- `learnModeControllerProvider`
  - `ref.watch(...)` im `build`
  - `ref.read(...notifier)` in `initState`, Swipe-Commit, Back-Navigation und Effects
  - `ref.listen(...)` fuer `categoryMastered`
  - `ref.listenManual(...)` fuer Stage-Aenderungen
- `currentWordProvider`
  - gelesen fuer Swipe-/Stage-/Plasma-Link-Logik
  - als `WordUserView?` in einem Listener beobachtet
- `levelSelectionProvider`
  - steuert Normal-/Single-Modus
- `allowedStagesProvider`
  - erzeugt `visibleMask` fuer Stage-Switches
- `singleStageProvider`
  - Single-Modus Stage
- `singleSessionCountsProvider`
  - Single-Modus SRC/R1/R2 Counts
- `srsModeControllerProvider`
  - bestimmt T-/A-/Hybrid-Labels, Farben und Stage-Regeln
- `s0LockedProvider(widget.categoryId)`
  - steuert S0-Lock-Anzeige in `StageSwitchRow`

Der Screen haelt ausserdem direkte Instanzen bzw. Controller:

- `LearnModeController _controller`
- `StageSwitchRowController _switchCtrl`
- mehrere `AnimationController`
- mehrere `GlobalKey`s fuer Karte, Stage-Switches, PassCount und FX-Overlays

Wichtig: Schon `initState` startet alte Logik:

- `_controller.setInLearnScreen(true)` nach Microtask
- `_controller.init(...)` nach dem ersten Frame
- spaeter bei `dispose`: `_controller.setInLearnScreen(false)`

Ein lokaler Offline-Modus darf diese alte Initialisierung nicht automatisch ausfuehren.

## 2. Provider Und Controller In Child-Widgets

Mehrere sichtbare Child-Widgets lesen weitere Provider selbst.

### `HeaderBar`

Liest:

- `isLoadingProvider`
- `categoriesProvider`
- `learnModeControllerProvider`

Aktionen:

- ruft `selectCategoryIndex(...)` am alten `LearnModeController` auf

Einschaetzung:

- Visuelle Struktur ist wertvoll.
- Das Widget ist nicht lokal-neutral, solange es Kategorien und Controller selbst liest.

### `CardArea`

Liest:

- `currentWordProvider`
- `isPausedProvider`
- `learnModeControllerProvider`
- `primaryLanguageProvider`

Aktionen:

- ruft `setShowTranslation(false)`
- ruft `toggleFlip()`
- nutzt `SwipeableWordCard`

Einschaetzung:

- Kartenplatzierung ist wiederverwendbar.
- Daten- und Controller-Anbindung sind alt gekoppelt.

### `BottomControls`

Liest:

- `isPlayingProvider`
- `learnModeControllerProvider`
- Tooltip-Provider

Aktionen:

- `startTimer`
- `pauseTimer`
- `resumeTimer`
- `cancelTimer`
- `performReset`
- `startFinalPass`
- `resetAdaptiveCategory`

Einschaetzung:

- Visuelle Button-Anordnung ist wertvoll.
- Fachlich ist das Widget stark an alte Timer-/FinalRound-/Reset-Logik gekoppelt.

### `StageSwitchRow`

Kann teilweise mit Props betrieben werden, liest aber intern trotzdem:

- `stagesProvider`, wenn keine `counts` uebergeben werden
- `learnModeControllerProvider`
- `srsModeControllerProvider`
- `learnedInStage5Provider(...)`

Aktionen:

- Drag/Drop zwischen Stages
- Stage-Tap
- Learned-Counter aus Supabase-nahem Provider

Einschaetzung:

- Visuelle Switch-Optik ist wertvoll.
- Direktes Wiederverwenden ist nur sicher, wenn alle alten Provider-Pfade deaktiviert oder neutralisiert werden.

### `LevelSelectorButtons`

Liest:

- `srsModeControllerProvider`

Einschaetzung:

- Das Widget ist fast props-basiert, aber das Label fuer T/A/H wird noch aus altem Provider gelesen.
- Fuer lokal-neutralen Einsatz braucht es entweder ein explizites Label oder einen lokalen Wrapper.

### `LevelsCard`

Liest:

- `srsModeControllerProvider`
- `s0LockedProvider`
- `singleStageProvider`
- `levelSelectionProvider`

Aktionen:

- S0-Lock-Service
- StageWordsDialog
- alte SRS-Popup-Mappings

Einschaetzung:

- Fuer den direkten LearnModeScreen-Schnitt weniger relevant als `StageSwitchRow`.
- Nicht direkt lokal-neutral.

### `SwipeableWordCard`

Das Widget selbst bekommt Wortdaten und Swipe/Flip-Callbacks als Props.

Gekoppelte Stellen:

- `_CardShell` liest `cardGlowSettingsProvider`
- visuelle Hilfen wie `LevelBadge`, PassCount und Streak sind intern
- Swipe/Flip ist lokal per Callback moeglich

Einschaetzung:

- Das ist der interessanteste direkte Wiederverwendungs-Kandidat fuer die echte Kartenoptik.
- Der Provider fuer Glow-Settings ist UI-nah und nicht Supabase, aber fuer saubere Neutralitaet sollte er separat bewertet werden.

### `CategoryHeaderCapsule`

Ist weitgehend props-basiert:

- Kategorien werden als `List<String>` uebergeben
- `selectedIndex` und Callbacks werden uebergeben
- Actions werden als Callbacks uebergeben

Einschaetzung:

- Direkt wiederverwendbar oder sehr gut als Vorlage geeignet.
- Keine direkte Supabase- oder LearnModeController-Abhaengigkeit im Widget.

## 3. Reine UI/Layout/Design-Teile

Rein visuell bzw. mit kontrollierbaren Props nutzbar:

- Grundlayout im `LearnModeScreen`:
  - `Scaffold`
  - `SafeArea`
  - `Stack`
  - `Column`
  - Header oben
  - Kartenbereich als `Expanded`
  - Stage-Switches
  - Abstand
  - Bottom Controls
- Farben, Abstaende und Groessen aus:
  - `WordsUIConstants`
  - `WordsLayout`
  - Theme-Konstanten aus `features/words/ui/theme`
- `CategoryWheel` als visuelles Rad, sofern Labels und Auswahl per Props kommen
- `CategoryHeaderCapsule` als props-basierter Header-Baustein
- `VerticalStageSwitch` ueber `StageSwitchRow` als visuelle Stage-Grundlage
- `SingleModeSwitchRow`, sofern nur Props genutzt werden
- `SwipeableWordCard` als Kartenoptik, wenn alte `WordUserView`-Quelle ersetzt wird
- FX-Widgets/Painter sind visuell, aber ihr Triggering ist aktuell an alte Stage- und Swipe-Logik gekoppelt

## 4. Alte Datenlogik Im Screen

Alte Datenlogik steckt nicht nur im Controller, sondern auch im Screen:

- `LearnModeScreen.initState` startet den alten Controller ueber `_controller.init(...)`
- `currentWordProvider` setzt `WordUserView` als Kartenquelle voraus
- `s.shuffledWordIds`, `s.wordQueue` und `s.index` definieren die alte Queue
- `s.stages`, `s.deckStages`, `activeStage`, `finalPassActive`, `categoryMastered` und `showFinalStartButton` steuern alte SRS-Zustaende
- Swipe-Commit ruft `_controller.onSwipeRight()` bzw. `_controller.onSwipeLeft()`
- Bounce-/Link-Berechnungen verwenden alte T-/A-/Hybrid-Regeln
- Back-Navigation liest alte Kategorien aus `LearnModeState`
- Timer-/Play-/Reset-/FinalRound-Logik lebt in `BottomControls`

Diese Logik darf nicht in den lokalen Offline-Pfad uebernommen werden.

## 5. Supabase-/WordUserView-/LearnModeController-Kopplung

Direkte Kopplungen:

- `LearnModeScreen` importiert `WordUserView` aus `supabase_word_repository.dart`
- `currentWordProvider` gibt `WordUserView?` zurueck
- `LearnModeState.wordQueue` ist `List<WordUserView>`
- `LearnModeController` importiert:
  - `supabase_word_repository.dart`
  - `supabase_flutter`
  - alte SRS-Logik und alte Provider
- `learnedInStage5Provider` ruft `SupabaseWordRepository.countLearnedInStage5(...)`
- Stage-/Dialog-Widgets referenzieren Supabase-nahe `WordUserView`-Listen

Indirekte Kopplungen:

- `HeaderBar` und `CardArea` wirken optisch harmlos, lesen aber alte Provider.
- `BottomControls` wirkt als UI-Widget, fuehrt aber alte Controller-Aktionen aus.
- `StageSwitchRow` kann Props annehmen, liest aber weiterhin alte Provider fuer Hybrid/Frozen/Learned-Counter.

## 6. Direkt Wiederverwendbare Widgets

Direkt oder fast direkt wiederverwendbar:

- `CategoryHeaderCapsule`
  - props-basiert
  - gute Vorlage fuer Header/Wheel/Kapsel
- `CategoryWheel`
  - bekommt Labels und Callback
  - keine offensichtliche Supabase-Kopplung im LearnMode-Kontext
- `SingleModeSwitchRow`
  - stateless und props-basiert
  - sinnvoll als visuelle Referenz fuer lokale Single-/Stage-Anzeige
- `VerticalStageSwitch`
  - visuelle Stage-Komponente
  - gut fuer lokale Stage-Reihe geeignet, wenn direkt mit Props verwendet
- `SwipeableWordCard`
  - bekommt Kartentexte und Swipe-Callbacks als Props
  - kann perspektivisch die echte Kartenoptik liefern
  - Achtung: `_CardShell` liest `cardGlowSettingsProvider`

Mit Vorsicht wiederverwendbar:

- `StageSwitchRow`
  - akzeptiert viele Props, liest aber intern alte Provider
  - fuer lokale Nutzung erst entkoppeln oder einen neutralen lokalen Wrapper/Branch bauen
- `LevelSelectorButtons`
  - UI ist wiederverwendbar, Label-Quelle ist aktuell alter SRS-Provider

## 7. Nicht Direkt Wiederverwendbare Widgets

Nicht direkt lokal-neutral:

- `HeaderBar`
  - liest `isLoadingProvider`, `categoriesProvider`, `learnModeControllerProvider`
  - ruft alten Controller bei Wheel-Change
- `CardArea`
  - liest `currentWordProvider`, `learnModeControllerProvider`, `primaryLanguageProvider`
  - steuert Flip ueber alten Controller
- `BottomControls`
  - liest alte Timer-/Controller-Provider
  - fuehrt alte Timer-, Reset- und FinalRound-Aktionen aus
- `LevelsCard`
  - liest alte SRS-/Lock-/Single-Provider
  - startet Dialoge und alte Stage-Logik
- `StageSwitchRow` im aktuellen Zustand
  - visuell nah am Ziel, aber intern nicht komplett neutral

Diese Widgets sollten nicht blind im lokalen Pfad verwendet werden.

## 8. Moeglicher Lokaler Modus Im Bestehenden Screen

Ein lokaler Modus koennte technisch im `LearnModeScreen` an drei Stellen eingefuehrt werden.

### Option 1: Branch Direkt Im `build`

Moeglich:

- `LearnModeScreen(useLocalOfflineFlow: true, localCategoryId: 'basics', ...)`
- Im lokalen Branch:
  - `localLearningViewModelProvider` lesen
  - `LocalLearnModeUiAdapter` nutzen
  - `LearnModeCardPresenter` nutzen
  - lokale Start/Correct/Wrong/Complete-Aktionen ueber `localLearningControllerProvider`
  - die bestehende Layout-Struktur beibehalten

Problem:

- `initState` fuehrt aktuell alte Controller-Initialisierung aus.
- Fuer einen lokalen Modus muss schon `initState` gegated werden.
- Auch `dispose`, Listener, FX-Trigger und Back-Navigation muessen getrennt werden.

### Option 2: Lokale Child-Widgets Im Bestehenden Layout

Moeglich:

- `LearnModeScreen` bekommt lokalen Branch nur fuer Datenbindung.
- Die sichtbaren Bereiche werden ueber lokale, props-basierte Child-Widgets gerendert:
  - lokaler Header aus bestehender Header-Optik
  - lokale Stage-Reihe aus `VerticalStageSwitch`/neutraler Stage-Komponente
  - `SwipeableWordCard` oder neutralisierte Karten-View
  - lokale Bottom Controls

Vorteil:

- Bestehende Screen-Komposition bleibt Ziel.
- Alte Provider bleiben aus lokalen Child-Widgets heraus.

Nachteil:

- Es ist trotzdem eine kontrollierte Aufteilung noetig.

### Option 3: Separater Wrapper Mit Bestehenden Widgets

Moeglich:

- Neuer Wrapper nutzt dieselben visuellen Widgets/Komponenten.
- `LearnModeScreen` bleibt zunaechst unveraendert.

Nachteil:

- Gefahr, wieder eine Ersatz-UI als Hauptweg zu bauen.
- Passt nicht zur neuen Entscheidung, wenn der Wrapper dauerhaft neben dem echten Screen laeuft.

## 9. Sinnvolle Neue Parameter

Ein direkter Integrationsschnitt koennte so aussehen:

- `bool useLocalOfflineFlow = false`
- `String? localCategoryId`

Weitere spaetere Parameter:

- `DateTime Function()? nowProvider` fuer Tests
- lokale Kategorieanzeige bzw. `localTitle`
- optionaler lokaler Mode/TrainingArea, falls nicht immer Adaptive/All

Regeln:

- Default bleibt alter Flow.
- Ohne `useLocalOfflineFlow` darf sich nichts am bisherigen Supabase-Flow aendern.
- Wenn `useLocalOfflineFlow == true`, darf `_controller.init(...)` nicht laufen.
- Wenn `useLocalOfflineFlow == true`, duerfen `currentWordProvider`, `WordUserView`, `learnModeControllerProvider` und alte Timer-/FinalRound-Aktionen fuer den Lerninhalt nicht verwendet werden.
- `localCategoryId` darf nicht implizit auf `basics` fallen.

## 10. Risiken Eines Direkten Branches

Risiken:

- `initState` startet versehentlich weiter den alten Supabase-/Controller-Flow.
- Alte Listener bleiben aktiv und reagieren auf lokale UI-Zustaende.
- `dispose` setzt alten LearnModeController-State, obwohl lokaler Modus genutzt wurde.
- `HeaderBar`, `CardArea` oder `BottomControls` lesen weiter alte Provider.
- `StageSwitchRow` zieht ueber `learnedInStage5Provider` wieder Supabase hinein.
- `WordUserView` wird als Fake-Adapter nachgebaut, um alte UI zufriedenzustellen.
- Alte T-/A-/Hybrid-Regeln werden mit lokaler SRS-Engine vermischt.
- Back-Navigation veraendert alte Category-/QuickSets-Flows.
- Tests muessen beide Pfade absichern, sonst wird der alte Flow leicht regressiv.

## 11. Minimale Schritte Fuer Lokale Daten Im LearnModeScreen

Kleinster sicherer Pfad:

1. `LearnModeScreen` bekommt nur einen passiven Modus-Schalter:
   - `useLocalOfflineFlow`
   - `localCategoryId`
   - noch kein Produkt-Routing
2. Tests sichern:
   - Default-Konstruktion bleibt alter Flow
   - lokaler Modus startet `_controller.init(...)` nicht
3. Ein kleiner lokaler State-Selector wird im Screen vorbereitet:
   - `localLearningViewModelProvider`
   - `LocalLearnModeUiAdapter`
   - `LearnModeCardPresenter`
4. Lokaler Branch rendert zunaechst nur einen sehr kleinen Ausschnitt der echten Struktur:
   - bestehender Header-/Karten-/Bottom-Bereich als Zielstruktur
   - keine alte Controller-Aktion
5. Danach wird ein erstes echtes visuelles Element angebunden:
   - bevorzugt `SwipeableWordCard` mit lokalen Props und lokalen `submitCorrect/submitWrong`-Callbacks
   - alternativ erst ein neutraler `LearnModeCardSlot`, falls `SwipeableWordCard` wegen Provider/Glow/Swipe zu riskant ist

Wichtig:

- Keine automatische Session im Build.
- Start muss explizit bleiben.
- Keine automatische Migration.
- Kein Import.
- Kein Supabase im lokalen Branch.

## 12. Empfehlung

Nicht sofort den gesamten `LearnModeScreen` hart verzweigen.

Empfehlung:

1. Zuerst Child-Widgets bzw. UI-Bereiche neutralisieren, die fuer die echte UI gebraucht werden.
2. Danach einen kleinen lokalen Branch im bestehenden `LearnModeScreen` einfuehren.
3. Den alten Flow als Default unveraendert lassen.

Konkrete Bewertung:

- Direkter Branch im bestehenden `LearnModeScreen`:
  - schnell sichtbar
  - aber hohes Risiko wegen `initState`, Listenern, `dispose`, Back-Navigation und FX
- Zuerst Child-Widgets neutralisieren:
  - sicherer
  - bessere Tests
  - verhindert `WordUserView`-Fakes
  - passt zur neuen Phase
- Separater Wrapper mit bestehenden Widgets:
  - als Uebergang testbar
  - aber nicht als Hauptweg empfehlen, weil Ziel die echte UI ist
- Alten Controller ersetzen:
  - aktuell zu riskant
  - erst sinnvoll, wenn lokale UI-Schnittstellen stabil sind

Beste Empfehlung:

Zuerst einen controller-neutralen Karten-Schnitt fuer die echte Kartenoptik schaffen. Danach `LearnModeScreen` mit einem kleinen lokalen Branch versehen, der nur diesen neutralen Bereich nutzt und den alten Controller nicht initialisiert.

## 13. Kleinster Naechster Implementierungsschritt

Kleinster konkreter TDD-Schritt:

`SwipeableWordCard` nicht umbauen, sondern zuerst einen kleinen props-basierten Adapter/Wrapper fuer den Kartenbereich planen und testen.

Moeglicher erster Schritt:

- Neue Analyse/Planung fuer einen `LearnModeLocalCardArea` oder `LearnModeCardAreaAdapter`.
- Ziel:
  - lokale Kartendaten aus `LearnModeCardPresenterState`
  - Darstellung ueber bestehende Kartenoptik oder deren neutralen Kern
  - Callbacks fuer `onCorrect`, `onWrong`, `onFlip`
  - kein `currentWordProvider`
  - kein `WordUserView`
  - kein `LearnModeController`
  - kein Supabase

Erster Code-Schritt danach:

- Einen kleinen testbaren, props-basierten Kartenbereich im bestehenden Words-UI-Kontext erstellen oder vorhandene Kartenkomponente so erweitern, dass sie lokale Props akzeptiert.
- Bestehende `LearnModeScreen`-Datei noch nicht anfassen, bis der Kartenbereich neutral abgesichert ist.

Damit bleibt das Ziel die echte UI, aber der riskanteste Teil der alten Datenkopplung wird zuerst kontrolliert geloest.
