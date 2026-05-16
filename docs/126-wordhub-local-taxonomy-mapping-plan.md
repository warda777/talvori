# WordHub Local Taxonomy Mapping Plan

## 1. Ausgangslage

Der lokale WordHub zeigt aktuell lokale DB-Kategorien wie `Basics` als sichtbare Struktur.

Das ist falsch für das Ziel, die bestehende WordHub-UI zu behalten. Der lokale Offline-Flow soll nicht eine neue lokale Kategorienliste als Produkt-WordHub anzeigen.

Die alte Produktstruktur kommt aus `word_hub_taxonomy.dart`:

- `hubSections`
- `HubSection`
- `HubSubcat`

Diese statische Taxonomie beschreibt die sichtbaren Bereiche und Kacheln des WordHub.

## 2. Ziel

`WordHubScreen(useLocalOfflineFlow: true)` soll dieselben Sections und Kacheln anzeigen wie der alte WordHub, aber ohne Supabase-Zugriffe.

Für die sichtbare UI gilt:

```text
hubSections bleiben die Quelle der Wahrheit.
```

Für lokale Daten gilt:

```text
HubSubcat muss kontrolliert auf eine lokale categoryId gemappt werden.
```

Der lokale Branch soll:

- alte WordHub-Taxonomie sichtbar behalten
- keine Supabase-Provider lesen
- eine provider-freie lokale Taxonomie-Kachel statt `CategoryCard` verwenden
- Tap nur dann zu `CategoryDetailScreen(useLocalOfflineFlow: true)` führen, wenn ein explizites lokales Mapping existiert

## 3. Sichtbare Struktur

Die sichtbare Struktur kommt weiterhin aus:

- `hubSections`
- `section.title`
- `section.subcats`
- `sub.label`
- `sub.key`

Beispiele:

- `Life & Daily Flow`
- `Health & Fitness`
- `Home & Living`
- `Food & Cooking`
- `Style & Fashion`
- `Money & Shopping`
- `Productivity`

Der lokale WordHub soll diese Struktur nicht durch lokale DB-Kategorien ersetzen.

## 4. Lokales Mapping

Für lokale Daten braucht es eine sichere Mapping-Strategie.

Regeln:

- kein globaler Fallback auf `basics`
- keine automatische falsche Zuordnung
- zunächst explizite Mapping-Tabelle oder Resolver verwenden
- unbekannte Kacheln bleiben kontrolliert nicht lokal verfügbar

Ein mögliches erstes Test-/Start-Mapping wäre:

```text
health_fitness -> basics
```

Diese Zuordnung darf nur als klar dokumentierter Startpunkt gelten. Sie ist kein globaler Fallback und darf nicht auf andere unbekannte Kacheln übertragen werden.

Langfristig sollte das Mapping aus echten lokalen Asset-Kategorien entstehen, z. B. wenn mehrere lokale Kategorien importiert und eindeutig mit `HubSubcat.key` verbunden sind.

## 5. Verhalten Bei Nicht Gemappten Kacheln

Wenn eine sichtbare Taxonomie-Kachel kein lokales Mapping hat:

- keine Supabase-Abfrage
- kein LearnMode-Direktstart
- kein falscher `basics`-Fallback
- keine automatische lokale Kategorie-Erzeugung

Mögliche UI-Reaktion:

- deaktivierte Kachel
- Snackbar: `Noch nicht lokal verfügbar`
- später Import-Hinweis oder lokaler Verfügbarkeitsstatus

Für den ersten Schritt reicht eine kontrollierte Snackbar oder ein deaktivierter Zustand.

## 6. Geplanter Umbau In WordHubScreen

`useLocalOfflineFlow` bleibt erhalten.

Der lokale Branch soll nicht lokale DB-Kategorien als sichtbare Liste anzeigen, sondern `hubSections` verwenden.

Geplante Struktur:

1. Lokaler Branch nutzt `hubSections`.
2. Für jede Section wird der bestehende Section-Aufbau verwendet.
3. Für jede `HubSubcat` wird eine lokale provider-freie Kachel gerendert, z. B. `_LocalTaxonomyCategoryCard`.
4. `CategoryCard` wird im lokalen Branch nicht verwendet.
5. Mapping von `HubSubcat` zu lokaler categoryId erfolgt explizit.

Im lokalen Branch nicht verwenden:

- `CategoryCard`
- `ensureAllProgressProvider`
- `wordHubControllerProvider.notifier.repo`
- `categoryProgressProvider`
- `findCategoryIdByName(...)`
- `_categoryIdForSubProvider`
- `supabaseWordRepositoryProvider`

Tap bei gemappter Kachel:

```text
CategoryDetailScreen(
  useLocalOfflineFlow: true,
  localCategoryId: mappedLocalCategoryId,
  categoryId: mappedLocalCategoryId,
  title: sub.label,
)
```

Tap bei nicht gemappter Kachel:

```text
Noch nicht lokal verfügbar
```

## 7. Tests

Die lokalen WordHub-Tests sollen angepasst werden.

Abzusichern:

- lokaler WordHub zeigt `Life & Daily Flow`
- lokaler WordHub zeigt `Health & Fitness`
- lokale DB-Kategorie `Basics` ist nicht mehr die alleinige sichtbare Struktur
- gemappte Kachel öffnet `CategoryDetailScreen(useLocalOfflineFlow: true)`
- nicht gemappte Kachel triggert kein Supabase und keinen LearnMode-Direktstart

Bestehender Test:

```text
test/features/word_hub_screen_local_branch_test.dart
```

## 8. Nicht-Ziele

Dieser Schritt soll ausdrücklich nicht enthalten:

- kein Online-Flow-Umbau
- keine `CategoryCard`-Änderung
- keine Supabase-Entfernung
- kein `CategoryDetailScreen`-Umbau
- keine Alt-Code-Bereinigung
