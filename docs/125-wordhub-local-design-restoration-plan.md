# WordHub Local Design Restoration Plan

## 1. Ausgangslage

`WordHubScreen` hat bereits den opt-in Parameter `useLocalOfflineFlow`.

Das Category-Popup öffnet aktuell:

```text
WordHubScreen(useLocalOfflineFlow: true)
```

Der lokale WordHub lädt lokale Kategorien über die lokale Provider-Kette ohne Supabase. Ein Tap auf eine lokale Kategorie öffnet inzwischen den lokalen `CategoryDetailScreen`:

```text
CategoryDetailScreen(useLocalOfflineFlow: true)
```

Der technische Flow funktioniert damit:

```text
Home
-> Category-Popup
-> WordHub local
-> CategoryDetailScreen local
-> Start
-> LearnModeScreen local
```

Das Design weicht aber vom bestehenden WordHub ab, weil der lokale Branch aktuell eine eigene vereinfachte Ersatz-UI rendert.

## 2. Problem

Im lokalen Modus verzweigt `WordHubScreen` früh zu `_buildLocalOfflineFlow(...)`.

Dadurch werden bestehende WordHub-Strukturen umgangen:

- Header/AppBar
- Suchfeld
- Unlock-/Glow-Controls
- Section-Struktur
- `GridSection`
- bestehende Kacheloptik
- spätere Palette-/Highlight-Struktur

Die aktuelle lokale Ansicht ist technisch nützlich, aber nicht das Ziel der Produktintegration.

## 3. Ziel

Der lokale WordHub soll den bestehenden WordHub-Rahmen wiederverwenden.

Nur Online-Datenquellen sollen im lokalen Flow ersetzt werden:

- lokale Kategorien statt Online-Kategorien/Progress
- provider-freie lokale Kachel statt `CategoryCard`
- lokale Navigation zu `CategoryDetailScreen(useLocalOfflineFlow: true)`

Im lokalen Branch dürfen keine Supabase-Provider benötigt werden.

`CategoryCard` soll im lokalen Branch nicht verwendet werden, solange sie intern Supabase-/Progress-Provider liest.

Die lokale Kategorie-Kachel soll optisch an `CategoryCard` angelehnt sein, aber provider-frei bleiben.

## 4. Zu Erhaltende UI-Struktur

Der lokale WordHub soll möglichst viel vom bestehenden WordHub-Rahmen behalten:

- `Scaffold` mit dunklem Hintergrund
- bestehende AppBar-/Header-Struktur
- Search-Bereich
- Unlock-/Glow-Controls, soweit ohne Online-Daten nutzbar
- `SectionHeader`
- `GridSection`-/`SliverGrid`-Struktur
- bestehende Abstände
- dunkler Kachel-Hintergrund
- Border-/Glow-Stil
- Navigation zu lokalem `CategoryDetailScreen`

Der lokale Branch soll also nicht wie eine separate Debug-Seite wirken.

## 5. Zu Vermeidende Online-Kopplungen

Im lokalen Branch müssen diese Kopplungen vermieden werden:

- `ensureAllProgressProvider`
- `wordHubControllerProvider.notifier.repo`
- `CategoryCard`
- `_categoryIdForSubProvider`
- `supabaseWordRepositoryProvider`
- `categoryProgressProvider`
- `findCategoryIdByName(...)`

Diese Teile gehören zum Online-/Supabase-Flow und dürfen nicht durch das Öffnen des lokalen WordHub ausgelöst werden.

## 6. Geplanter Umbau

`_buildLocalOfflineFlow(...)` soll nicht länger als komplett eigene Ersatzseite verwendet werden.

Stattdessen soll ein lokaler Datenzweig in den bestehenden WordHub-Aufbau integriert werden:

1. `useLocalOfflineFlow` entscheidet weiterhin den Datenpfad.
2. Im lokalen Datenpfad wird `localCategoriesProvider` gelesen.
3. `LocalWordHubDebugEntryPresenter` kann weiter genutzt oder durch ein UI-näheres Mapping ergänzt werden.
4. Lokale Kategorien werden in eine bestehende Section-/Grid-Struktur gegeben.
5. Eine lokale provider-freie Kachel ersetzt `CategoryCard` im lokalen Branch.
6. Die lokale Kachel orientiert sich optisch an `CategoryCard`, liest aber keine Provider.
7. Tap bleibt:

```text
CategoryDetailScreen(
  useLocalOfflineFlow: true,
  localCategoryId: item.categoryId,
  categoryId: item.categoryId,
  title: item.label,
)
```

Damit bleibt die Nutzerführung:

```text
WordHub
-> Kategorie
-> CategoryDetailScreen
-> Start
-> LearnModeScreen
```

## 7. Nicht-Ziele

Dieser Schritt soll ausdrücklich nicht enthalten:

- kein Online-Flow-Umbau
- keine Supabase-Entfernung
- kein `CategoryCard`-Umbau
- keine Alt-Code-Bereinigung
- keine CategoryDetail-Reparatur

## 8. Tests

Der bestehende `word_hub_screen_local_branch_test` muss angepasst oder erhalten bleiben.

Abzusichern ist:

- lokale Kategorien sind sichtbar
- Tap auf eine lokale Kategorie führt zu `CategoryDetailScreen(useLocalOfflineFlow: true)`
- der lokale Branch benötigt keine Supabase-Provider
- kein direkter Sprung vom lokalen WordHub in den `LearnModeScreen`

## 9. Nächster Schritt

Danach sollte `WordHubScreen` so umgebaut werden, dass `useLocalOfflineFlow` den bestehenden WordHub-Rahmen nutzt und nur die Daten-/Kachelquelle lokal ersetzt.
