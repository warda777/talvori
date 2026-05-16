# CategoryDetail Shared Frame Plan

## 1. Problem

Der lokale Branch von `CategoryDetailScreen` nutzt aktuell weiterhin eine separate Ersatzseite:

```dart
if (widget.useLocalOfflineFlow) return _buildLocalOfflineFlow(context);
```

Dadurch landet der lokale Flow nicht im alten vollständigen CategoryDetail-Aufbau, sondern in einer eigenen lokalen UI. Der letzte Umbau hat nur den Header innerhalb dieser Ersatzseite durch `CategoryHeaderCapsule` ersetzt. Das reicht nicht für das Ziel der aktuellen Projektphase.

Das Ziel ist nicht, die lokale Ersatz-UI weiter nachzubauen. Ziel ist, die bestehende CategoryDetail-UI zu erhalten und nur die Daten-/Providerlogik für den lokalen Offline-Flow zu ersetzen.

## 2. Alter UI-Aufbau

Der bestehende Online-Aufbau von `CategoryDetailScreen` besteht im Kern aus:

- `Scaffold`
- `SafeArea`
- `Stack`
- `Listener`
- `Column`/Layout-Struktur
- `CategoryHeaderCapsule`
- `_buildHintOrProgress(...)`
- `LevelsCard(...)`
- optionalem Debug-Button
- Startbutton innerhalb von `LevelsCard`

Diese Struktur ist die visuelle Zieloberfläche für den lokalen Branch.

## 3. Benötigte UI-Daten

Der gemeinsame UI-Rahmen braucht eine klar abgegrenzte Menge an UI-Daten:

- `title`
- `categories`
- `selectedIndex`
- `currentId`
- `vocabsTotal`
- `stageCounts` S0-S5
- `totalWords`
- Progress-Werte
- Level-Selection-State
- sichtbare Stage-Maske
- SRS-Modus
- Start-Callback
- Header-Callbacks

Der Online-Branch kann diese Daten weiterhin aus den vorhandenen Providern ableiten. Der lokale Branch soll lokale oder statische Werte liefern.

## 4. Online-Datenquellen

Der heutige Online-Branch bezieht seine Daten und Aktionen unter anderem aus:

- `categoryDetailControllerProvider`
- `categoryProgressProvider`
- `learnModeControllerProvider`
- `srsModeControllerProvider`
- `levelSelectionProvider`
- `allowedStagesProvider`
- `singleStageProvider`
- `learnedInStage5Provider`
- `s0LockedProvider`
- `seedForStart(...)`
- Online-Invalidate/Reload nach Rückkehr aus dem Lernscreen

Diese Quellen dürfen im lokalen Branch nicht versehentlich gelesen oder ausgelöst werden.

## 5. Provider-Gekoppelte Widgets

Einige sichtbare Widgets sind aktuell nicht direkt im lokalen Branch wiederverwendbar, weil sie intern alte Provider oder alte Controllerlogik lesen:

- `LevelsCard`
- `StageSwitchRow`
- `LevelSelectorButtons`
- `CategoryDetailHintBubble`
- `SrsModeToggleWithHint`

Diese Widgets können visuell als Vorlage dienen, sollten aber im lokalen Branch erst dann direkt eingesetzt werden, wenn ihre Provider-Kopplung entfernt oder parametrisiert wurde.

## 6. Wiederverwendbare UI-Bausteine

Direkt oder weitgehend sicher wiederverwendbar sind:

- `CategoryHeaderCapsule`
- `LearningStatusPanel`
- äußere `Scaffold`/`SafeArea`/`Column`-Struktur
- bestehende Spacing-/Theme-/Layout-Werte
- später die visuelle Optik von `LevelsCard` als provider-freie lokale Variante

Der lokale Branch soll dieselbe äußere Struktur nutzen und nur an den Stellen provider-freie Slots einsetzen, an denen die alten Widgets aktuell noch Online-State lesen.

## 7. Geplanter Umbau

Es soll ein gemeinsamer Helper entstehen, zum Beispiel:

```dart
_buildCategoryDetailFrame(...)
```

Der Helper kapselt den gemeinsamen äußeren CategoryDetail-Rahmen.

Geplanter Datenfluss:

- Online-Branch liefert echte Online-Daten und nutzt weiterhin bestehende Body-Widgets.
- Local-Branch liefert lokale/statische Daten.
- Local-Branch nutzt denselben äußeren Frame.
- Provider-gekoppelte Body-Widgets werden lokal durch provider-freie Slots ersetzt.
- `_buildLocalOfflineFlow` soll langfristig nicht als komplette Ersatzseite bestehen bleiben.

## 8. Erster Sicherer Code-Schritt

Der erste Code-Schritt sollte klein bleiben:

- nur den äußeren `Scaffold`/`SafeArea`/`Column`-Rahmen extrahieren
- Online-Branch optisch unverändert lassen
- Local-Branch denselben Frame nutzen lassen
- Body im lokalen Branch weiterhin provider-frei halten
- keine Provider versehentlich im lokalen Branch lesen

Dieser Schritt verschiebt den lokalen Branch weg von einer Ersatzseite, ohne sofort `LevelsCard` oder andere provider-gekoppelte Widgets lokal zu verwenden.

## 9. Nicht-Ziele

Nicht Teil dieses Schritts:

- kein Online-Flow-Umbau
- keine Supabase-Entfernung
- keine Alt-Code-Bereinigung
- kein WordHub-Umbau
- `LevelsCard` noch nicht direkt lokal wiederverwenden

## 10. Tests

Für den ersten gemeinsamen Frame-Schritt:

- `category_detail_screen_local_branch_test` bleibt grün.
- Start öffnet weiter `LearnModeScreen` im lokalen Offline-Modus.
- `flutter analyze lib/features/words/ui/screens/category_detail_screen.dart`
- später Screenshot/manueller Vergleich alte vs. lokale UI

