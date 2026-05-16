# 119 Local LearnMode Visual Alignment Plan

Stand: 2026-05-16

## 1. Ziel

`LocalLearnModeScreen` soll optisch naeher an die bestehende Talvori-`LearnModeScreen`-UI ruecken.

Die lokale Offline-first-Logik bleibt dabei unveraendert:

- `localLearningViewModelProvider`
- `LocalLearnModeUiAdapter`
- `LearnModeCardPresenter`
- `LearnModeCardView`
- `LocalLearningController`

Die optische Angleichung darf keine alte Controller-, Provider-, Queue- oder Supabase-Logik uebernehmen.

Ziel ist ein lokaler Lernscreen, der sich mehr wie Talvori anfuehlt, aber weiterhin isoliert, testbar und offline-first bleibt.

## 2. Relevante Bestehende Visuelle Elemente

Aus der bestehenden `LearnModeScreen`-UI sind vor allem diese visuellen Elemente relevant:

- Kartenlayout
  - zentrale Lernkarte
  - klare Vorder-/Rueckseiten-Texthierarchie
  - optionaler Bereich fuer Beispielsatz und Notizen
  - abgesetzter Kartencontainer statt einfacher Textliste

- Farben
  - bestehende Words-Theme-Erweiterung ueber `WordsColors`
  - `surfaceBg` fuer den Screen-Hintergrund
  - `cardBg` fuer Kartenflaechen
  - bestehende Stage-Farbwelt aus den Stage-/Levels-Komponenten als Inspiration

- Stage-Anzeige
  - einfache Stage-Information ist schon ueber `stageLabel` vorhanden
  - visuell spaeter naeher an die Stage-Switch-/Level-Sprache ruecken
  - keine technische T-/A-/Hybrid-Logik uebernehmen

- Fortschrittsanzeige
  - `progressLabel` existiert bereits
  - kann spaeter prominenter und ruhiger positioniert werden
  - kein Zugriff auf alte Queue-Felder noetig

- Buttons
  - `Richtig`, `Falsch`, `Starten/Fortsetzen`, `Session abschliessen`
  - visuell naeher an bestehende Start-/Action-Buttons bringen
  - Logik bleibt ueber lokale Callbacks oder lokalen Controller

- Abstaende
  - `WordsLayout` liefert vorhandene Spacing-Konstanten
  - `gapBelowTop`, `gapAboveBottom`, `pageBottomPadding` und verwandte Werte koennen als Orientierung dienen
  - keine pixelgenaue Kopie des alten Screens im ersten Schritt

- Hintergrund
  - lokaler Screen kann `WordsColors.surfaceBg` nutzen, falls im Theme vorhanden
  - Fallback bleibt normales Theme, damit Tests robust bleiben

- Animationen
  - Plasma-Link, Pulse, Swipe-Animationen und Fireworks bleiben spaeteren Schritten vorbehalten
  - im ersten visuellen Schritt keine Animationen uebernehmen

## 3. Nicht Uebernehmen

Ausdruecklich nicht uebernommen werden:

- `LearnModeController`
- `LearnModeState`
- `WordUserView`
- `currentWordProvider`
- `SupabaseWordRepository`
- alte Queue-Logik
- Timer-Logik
- Hybrid-/T-SRS-/A-SRS-Umschaltung
- Final-Round-Logik
- Plasma-Link-Positionslogik
- Fireworks-/Arrow-Fly-Services
- Stage-Switch-Provider-Zugriffe
- direkte Reads aus `word_providers.dart`

Die bestehende UI dient zuerst als visuelle Referenz, nicht als Logikquelle.

## 4. Empfohlene Reihenfolge Der Anpassung

### Schritt 1: `LearnModeCardView` optisch verbessern

Der kleinste sichere Einstieg ist die CardView.

Warum:

- sie ist bereits controller-neutral
- sie liest keine Provider
- sie kennt kein Supabase
- sie nutzt nur `LearnModeCardPresenterState`
- sie ist mit Widget-Tests gut abzusichern

Moegliche Anpassungen:

- Kartencontainer mit `Card` oder `Container` plus `BoxDecoration`
- groessere, klarere Typografie fuer `frontText`
- ruhigere Hierarchie fuer `backText`, `exampleSentence`, `notes`
- Stage-/Progress-Zeile als kleine Meta-Zeile
- konsistente Innenabstaende
- Hintergrund-/Kartenfarben aus Theme, falls vorhanden

### Schritt 2: Button-Anordnung verbessern

Danach sollten `Richtig` und `Falsch` naeher an die bestehende Lerninteraktion ruecken.

Moeglich:

- getrennte Primaer-/Sekundaer-Gewichtung
- feste Buttonhoehen
- konsistente Abstaende
- keine neuen Aktionen
- keine Swipe-Logik

### Schritt 3: Stage-/Progress-Anzeige verfeinern

Erst danach sollte die Stage-/Progress-Darstellung verfeinert werden.

Moeglich:

- kompakte Stage-Pill fuer `stageLabel`
- Progress-Pill oder kleiner Fortschrittsbereich
- spaeter neutraler Mini-Stage-Indikator

Wichtig:

- `StageSwitchRow` ist visuell interessant, aber aktuell an alte Provider und alte State-Modelle gekoppelt
- sie sollte nicht direkt in den lokalen Screen kopiert werden
- falls noetig, spaeter separat einen controller-neutralen Stage-Indikator planen

### Schritt 4: Animationen spaeter

Animationen erst spaeter und isoliert planen.

Grund:

- bestehende Animationen haengen stark an Keys, Drag-/Swipe-Logik, alter Queue und Stage-Provider-Logik
- Tests wuerden sonst frueh fragil
- der lokale Screen braucht zuerst stabile visuelle Struktur

## 5. Tests, Die Erhalten Bleiben Muessen

Bestehende Tests duerfen fachlich nicht geschwaecht werden:

- aktive Karte sichtbar
- `Richtig` ruft den Correct-Callback
- `Falsch` ruft den Wrong-Callback
- `Starten/Fortsetzen` ruft Start-/Resume-Callback
- Completed-State bleibt sichtbar
- `Session abschliessen` ruft Completion-Callback
- Loading-State bleibt sichtbar
- Error-State bleibt sichtbar
- Empty-State bleibt sichtbar
- `LearnModeCardView` zeigt keine Karte bei `hasCard == false`
- kein Supabase noetig
- kein `WordUserView` noetig
- keine Provider im `LearnModeCardView`
- keine automatische Session beim Build
- kein automatischer Import beim Build

Optische Tests sollten weiterhin auf sichtbare Texte und Callback-Verhalten zielen, nicht auf fragile Pixelwerte.

## 6. Risiken

- Alte Logik wird aus Versehen mitkopiert, weil sie im bestehenden `LearnModeScreen` eng mit der Optik verwoben ist.
- `StageSwitchRow` wirkt wiederverwendbar, bringt aber Provider- und alte State-Abhaengigkeiten mit.
- Das lokale UI-Design koennte zu frueh an alte State-Felder gekoppelt werden.
- Animationen koennen Tests fragil machen, wenn sie vor der stabilen Struktur eingefuehrt werden.
- Zu starke optische Kopie ohne neutrale Zwischenkomponenten koennte spaeter den echten `LearnModeScreen`-Umbau erschweren.
- Technische Stage-Labels wie `s0` koennten zu frueh als finale Produktlabels verfestigt werden.

## 7. Erster Konkreter UI-Schritt

Empfohlener erster TDD-Schritt:

`LearnModeCardView` bekommt ein Talvori-naeheres Kartenlayout, ohne seine API zu aendern.

Konkret:

- weiterhin Eingabe nur `LearnModeCardPresenterState`
- weiterhin optionale `onCorrect`-/`onWrong`-Callbacks
- kein Provider
- kein Controller
- kein `WordUserView`
- kein Supabase
- kein Swipe
- keine Animation

Der erste Test sollte bestehende Sichtbarkeit weiter absichern, z. B.:

- `learnmode_card_view_shows_active_card_with_visual_container`

Dabei reicht es, stabil zu pruefen:

- aktive Karte ist sichtbar
- `frontText`, `backText`, `exampleSentence`, `notes`, `stageLabel`, `progressLabel` bleiben sichtbar
- `Richtig` und `Falsch` bleiben sichtbar, wenn `canSubmitAnswer == true`
- bei `hasCard == false` bleibt der View leer

Dieser Schritt verbessert die Optik an der sichersten Stelle und laesst die lokale Offline-first-Kette unveraendert.
