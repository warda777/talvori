# CategoryDetail Local Offline Branch

## 1. Ausgangslage

Der `LearnModeScreen` unterstützt bereits den lokalen Offline-Branch über `useLocalOfflineFlow` und `localCategoryId`.

Der `CategoryDetailScreen` kann inzwischen ebenfalls optional lokal/offline geöffnet werden. Damit ist die notwendige Zwischenstation für den gewünschten lokalen Lernfluss vorbereitet.

Der lokale `WordHubScreen` funktioniert technisch ohne Supabase, springt aktuell aber noch direkt in den `LearnModeScreen`. Das ist nur ein Übergangsstand.

Der gewünschte finale Flow ist:

```text
WordHub
-> CategoryDetailScreen
-> Startbutton
-> LearnModeScreen
```

## 2. Problem

Der normale `CategoryDetailScreen` liest im bestehenden Online-Flow mehrere Online- und Alt-Provider. Wenn der lokale WordHub eine Kategorie direkt in den normalen Detail-Screen öffnen würde, könnte dort wieder Supabase-/Progress-Logik feuern.

Relevante Kopplungen im normalen Branch sind unter anderem:

- `categoryDetailControllerProvider`
- `categoryProgressProvider`
- `learnModeControllerProvider`
- alte SRS-/Mode-Provider
- `seedForStart(...)`
- Online-Invalidate-/Reload-Logik nach Rückkehr aus dem Lernscreen

Für den lokalen Offline-Flow musste deshalb zuerst ein isolierter Branch im `CategoryDetailScreen` entstehen.

## 3. Lokaler Branch

Der lokale Branch wird über folgende Parameter aktiviert:

- `useLocalOfflineFlow`
- `localCategoryId`

Wenn `useLocalOfflineFlow == true`, verzweigt der Screen früh in einen lokalen Render-Pfad, bevor Online-/Alt-Provider im `build` gelesen werden.

Im lokalen Modus gilt:

- keine `categoryDetailControllerProvider`-Subscription
- kein `categoryDetailControllerProvider.init(...)`
- kein `categoryProgressProvider`
- kein `learnModeControllerProvider`
- kein `seedForStart(...)`
- keine Online-Invalidate-/Reload-Logik nach Rückkehr aus dem `LearnModeScreen`

Wenn `useLocalOfflineFlow == false`, bleibt der bestehende Online-/Supabase-Flow unverändert.

## 4. Lokale Darstellung

Der lokale Branch zeigt eine lokale Header-/Stage-/Start-Ansicht.

Die Stage-Werte sind zunächst sichere `0`-Platzhalter, weil noch keine echte lokale Progress-Anbindung für die CategoryDetail-Ansicht existiert.

`CategoryHeaderCapsule` wurde im lokalen Branch nicht direkt verwendet, weil es im Widget-Test durch seine eingebettete Tile-Struktur einen Layout-Overflow erzeugt hat. Stattdessen nutzt der lokale Branch eine kleine lokale Header-Variante ohne Online-Provider.

Der Online-Branch nutzt weiterhin den echten bestehenden Header.

## 5. Startbutton

Der lokale Startbutton öffnet den bestehenden `LearnModeScreen` im lokalen Offline-Modus:

```text
LearnModeScreen(
  useLocalOfflineFlow: true,
  localCategoryId: ...
)
```

Vor dem Start läuft keine Supabase-Vorbereitung und kein `seedForStart(...)`.

## 6. Nicht-Ziele

Dieser Schritt hat bewusst nicht umgesetzt:

- keine Supabase-Entfernung
- keine Alt-Code-Bereinigung
- kein `CategoryCard`-Umbau
- kein WordHub-Tap-Umbau
- keine echte lokale Progress-Anbindung

## 7. Tests

Der Stand wurde mit folgenden Checks geprüft:

```bash
flutter test test/features/category_detail_screen_local_branch_test.dart
flutter test test/features/local_learning_debug/
flutter test test/features/learn_mode_screen_local_branch_test.dart
flutter analyze lib/features/words/ui/screens/category_detail_screen.dart
```

Ergebnis:

- CategoryDetail local branch: grün
- local learning debug tests: grün
- LearnModeScreen local branch: grün
- gezielter Analyzer für `category_detail_screen.dart`: grün

## 8. Nächster Schritt

Der nächste sinnvolle Schritt ist der lokale WordHub-Tap:

```text
WordHubScreen(useLocalOfflineFlow: true)
-> lokale Kategorie antippen
-> CategoryDetailScreen(useLocalOfflineFlow: true, localCategoryId: ...)
```

Damit ersetzt der lokale WordHub den aktuellen direkten Sprung in den `LearnModeScreen` durch den gewünschten Produktfluss über den `CategoryDetailScreen`.
