# 🔒 S0 Lock Feature - Vollständige Dokumentation

> **Erstellt:** Januar 2025  
> **Version:** 1.0  
> **Status:** ✅ Implementiert und produktiv

## 📋 Übersicht

Das S0-Lock-Feature ermöglicht es Benutzern, die S0-Stufe (New/Neue Karten) zu sperren, um zu verhindern, dass neue Karten in die Lern-Queue aufgenommen werden. Dies ist nützlich, wenn Benutzer nur Wiederholungen üben möchten, ohne neue Karten hinzuzufügen.

---

## 📁 Erstellte/Modifizierte Dateien

### 1. `lib/features/words/application/s0_lock_provider.dart` (NEU)

**Typ:** State Provider (Riverpod)  
**Zweck:** Zentrale State-Verwaltung für den S0-Lock-Status

```dart
final s0LockedProvider = StateProvider<bool>((ref) => false);
```

**Funktionalität:**

- Speichert den Lock-Status als Boolean (true = gesperrt, false = entsperrt)
- Wird von beiden Screens (Category Detail & Learn Mode) gemeinsam genutzt
- Zustand ist global und synchronisiert zwischen allen Consumer-Widgets

**Verwendung:**

```dart
// Lesen
final isLocked = ref.watch(s0LockedProvider);

// Schreiben
ref.read(s0LockedProvider.notifier).state = true;
```

---

### 2. `lib/features/words/ui/widgets/vertical_stage_switch.dart` (MODIFIZIERT)

**Typ:** Stateless Widget  
**Zweck:** Einzelner Stage-Switch mit Lock-Overlay

**Neue Props:**

- `isLocked` (bool, default: false) - Lock-Status
- `onTap` (VoidCallback?) - Tap-Handler für Lock-Toggle

**Neue Funktionalität:**

- **Opacity-Bleaching:** Bei Lock wird die Switch auf 45% Opacity reduziert
- **Lock-Overlay:** Weißes Schloss-Icon (36px) zentriert über der Switch
- **Gesture Handling:** `GestureDetector` mit `onTap` Callback
- **Stack-Layout:** Lock-Overlay liegt außerhalb des Opacity-Wrappers für maximale Sichtbarkeit

**Architektur-Details:**

```dart
Stack(
  children: [
    // Switch mit Opacity (wird ausgebleicht)
    Opacity(opacity: isLocked ? 0.45 : 1.0, child: Container(...)),

    // Lock-Overlay (immer sichtbar, außerhalb Opacity)
    if (isLocked) Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Icon(Icons.lock_rounded, size: 36, color: Colors.white),
        ),
      ),
    ),
  ],
)
```

**Wichtige Design-Entscheidungen:**

- Lock-Overlay ist `IgnorePointer` um Taps nicht zu blockieren
- Stack-Layout stellt sicher, dass Lock-Icon über ausgebleichter Switch liegt
- Zentrierung durch `Center` Widget innerhalb `Positioned.fill`

---

### 3. `lib/features/words/ui/widgets/stage_switch_row.dart` (MODIFIZIERT)

**Typ:** Stateful Widget  
**Zweck:** Zeile von Stage-Switches mit S0-Lock-Unterstützung

**Neue Props:**

- `s0Locked` (bool?) - Lock-Status für S0
- `onTapS0` (VoidCallback?) - Tap-Handler für S0

**Neue Funktionalität:**

- **S0-Block-Anpassung:** S0-Switch erhält `isLocked` und `onTap` Props
- **Controller-Methode:** `blinkS0Once()` für Blink-Effekt beim Entsperren

**Modifizierte Methoden:**

```dart
// StageSwitchRowController erweitert
Future<void> blinkS0Once() async => _state?._blinkIndices([0], repeats: 1);

// S0-Block in _buildWithParams() und _buildWithStages()
if (i == 0) {
  final bool locked = widget.s0Locked ?? false;
  switchBody = VerticalStageSwitch(
    // ... andere Props
    isLocked: locked,
    onTap: widget.onTapS0,
  );
}
```

**Architektur-Details:**

- Lock-Status wird nur an S0 weitergegeben (Index 0)
- Andere Switches (S1-S5) sind nicht betroffen
- DragTarget bleibt funktionsfähig (Lock blockiert nicht Drag-and-Drop)

---

### 4. `lib/features/words/ui/widgets/levels_card.dart` (MODIFIZIERT)

**Typ:** ConsumerStatefulWidget  
**Zweck:** Levels Card im Category Detail Screen

**Neue Funktionalität:**

- **Provider-Integration:** Importiert `s0LockedProvider`
- **State-Watching:** `ref.watch(s0LockedProvider)` für aktuellen Lock-Status
- **Toggle-Handler:** Async Callback mit Blink-Effekt beim Entsperren
- **Controller-Integration:** Nutzt `StageSwitchRowController` für Blink-Effekt

**Code-Snippet:**

```dart
s0Locked: ref.watch(s0LockedProvider),
onTapS0: () async {
  final notifier = ref.read(s0LockedProvider.notifier);
  final wasLocked = notifier.state;
  notifier.state = !wasLocked;

  // Blink-Effekt beim Entsperren
  if (wasLocked) {
    await _switchCtrl.blinkS0Once();
  }
},
```

**Wichtige Details:**

- Lock-Status wird via `ref.watch()` beobachtet (reaktive Updates)
- Vorheriger Status (`wasLocked`) wird gespeichert für Blink-Logik
- Blink-Effekt nur beim Entsperren, nicht beim Sperren

---

### 5. `lib/features/words/ui/screens/learn_mode_screen.dart` (MODIFIZIERT)

**Typ:** ConsumerStatefulWidget  
**Zweck:** Learn Mode Screen mit S0-Lock-Unterstützung

**Neue Funktionalität:**

- **Provider-Import:** `s0_lock_provider.dart` importiert
- **Controller-Erstellung:** `StageSwitchRowController` für Blink-Effekt
- **Props-Weiterleitung:** `s0Locked` und `onTapS0` an `StageSwitchRow` übergeben

**Code-Snippet:**

```dart
class _LearnModeScreenState extends ConsumerState<LearnModeScreen> {
  final _switchCtrl = StageSwitchRowController(); // NEU

  // In build():
  switchesRow = StageSwitchRow(
    controller: _switchCtrl, // NEU
    // ... andere Props
    s0Locked: ref.watch(s0LockedProvider),
    onTapS0: () async {
      final notifier = ref.read(s0LockedProvider.notifier);
      final wasLocked = notifier.state;
      notifier.state = !wasLocked;

      if (wasLocked) {
        await _switchCtrl.blinkS0Once();
      }
    },
  );
}
```

**Synchronisation:**

- Nutzt denselben `s0LockedProvider` wie Category Screen
- Lock-Status ist automatisch synchronisiert zwischen beiden Screens
- Keine zusätzliche Synchronisierungs-Logik erforderlich

---

## 🔗 Verbindungen zwischen Dateien

### Provider-to-UI Flow

```
s0LockedProvider (StateProvider)
    ↓
    ├─→ levels_card.dart (Category Screen)
    │       ├─→ StageSwitchRow
    │       │       ├─→ VerticalStageSwitch (S0)
    │       │       └─→ [Lock-Overlay wird angezeigt]
    │       └─→ StageSwitchRowController.blinkS0Once()
    │
    └─→ learn_mode_screen.dart (Learn Mode Screen)
            ├─→ StageSwitchRow
            │       ├─→ VerticalStageSwitch (S0)
            │       └─→ [Lock-Overlay wird angezeigt]
            └─→ StageSwitchRowController.blinkS0Once()
```

### Data Flow Diagram

```
┌─────────────────────────────────────────────────┐
│  User tappt auf S0-Switch                      │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  onTapS0() Callback wird ausgelöst             │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  s0LockedProvider.notifier.state = !wasLocked   │
└─────────────────┬───────────────────────────────┘
                  │
                  ├─→ Provider-State aktualisiert
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  ref.watch(s0LockedProvider) triggert Rebuild  │
└─────────────────┬───────────────────────────────┘
                  │
                  ├─→ levels_card.dart rebuilds
                  ├─→ learn_mode_screen.dart rebuilds
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  VerticalStageSwitch zeigt/versteckt Lock      │
└─────────────────────────────────────────────────┘
```

---

## 🎯 Verwendungszweck jeder Datei

### Application Layer

| Datei                   | Zweck            | Verantwortlichkeit                  |
| ----------------------- | ---------------- | ----------------------------------- |
| `s0_lock_provider.dart` | State Management | Zentrale Verwaltung des Lock-Status |

### UI Layer - Widgets

| Datei                        | Zweck         | Verantwortlichkeit                                     |
| ---------------------------- | ------------- | ------------------------------------------------------ |
| `vertical_stage_switch.dart` | UI-Komponente | Rendering der Switch mit Lock-Overlay                  |
| `stage_switch_row.dart`      | UI-Container  | Zusammenstellung der Switches, Weiterleitung der Props |

### UI Layer - Screens

| Datei                    | Zweck              | Verantwortlichkeit                               |
| ------------------------ | ------------------ | ------------------------------------------------ |
| `levels_card.dart`       | Category Screen UI | Integration des Lock-Features im Category Detail |
| `learn_mode_screen.dart` | Learn Mode UI      | Integration des Lock-Features im Learn Mode      |

---

## ⚠️ Wichtige Dateien bei Änderungen

### Bei UI-Änderungen

**Lock-Overlay Design ändern:**

- `vertical_stage_switch.dart` - Lock-Overlay-Definition (Zeilen 185-197)

**Lock-Icon ändern:**

- `vertical_stage_switch.dart` - Icon-Definition (Zeile 190)

**Lock-Farbe/Transparenz ändern:**

- `vertical_stage_switch.dart` - Opacity-Wert (Zeile 59)

**Blink-Effekt anpassen:**

- `stage_switch_row.dart` - `blinkS0Once()` Methode (Zeile 29)
- `stage_switch_row.dart` - `_blinkIndices()` Methode (Zeilen 124-152)

### Bei State-Management-Änderungen

**Provider-Logik ändern:**

- `s0_lock_provider.dart` - Provider-Definition (Zeile 4)

**Persistenz hinzufügen:**

- `s0_lock_provider.dart` - Provider auf `FutureProvider` umstellen mit SharedPreferences

**Zusätzliche States:**

- `s0_lock_provider.dart` - Provider auf komplexeren State-Typ erweitern

### Bei Integration in neue Screens

**Neuer Screen mit S0-Lock:**

1. Importiere `s0_lock_provider.dart`
2. Erstelle `StageSwitchRowController` im State
3. Übergebe `controller`, `s0Locked`, `onTapS0` an `StageSwitchRow`

---

## 🏗️ Widget-Integration für neue Screens

### Minimales Beispiel

```dart
import 'package:talvori/features/words/application/s0_lock_provider.dart';
import 'package:talvori/features/words/ui/widgets/stage_switch_row.dart';

class MyNewScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyNewScreen> createState() => _MyNewScreenState();
}

class _MyNewScreenState extends ConsumerState<MyNewScreen> {
  final _switchCtrl = StageSwitchRowController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StageSwitchRow(
        controller: _switchCtrl,
        counts: [10, 20, 30, 40, 50, 60],
        // ... andere Props
        s0Locked: ref.watch(s0LockedProvider),
        onTapS0: () async {
          final notifier = ref.read(s0LockedProvider.notifier);
          final wasLocked = notifier.state;
          notifier.state = !wasLocked;

          if (wasLocked) {
            await _switchCtrl.blinkS0Once();
          }
        },
      ),
    );
  }
}
```

### Vollständiges Beispiel mit allen Props

```dart
StageSwitchRow(
  controller: _switchCtrl,
  counts: s,
  goalPerStage: 100,
  gap: 12,
  sizes: const StageSwitchSizes(
    width: 42,
    height: 75,
    knobTop: 2,
    knobBottom: 18,
  ),
  colors: StageSwitchColors(
    newOuter: const Color(0xFFA05260),
    stageOuter: const Color(0xFFE4B866),
    inner: innerFill,
    disabledOuter: Colors.white,
    innerStroke: stroke,
  ),
  labels: StageSwitchLabels(
    newLabel: 'New',
    newNote: '0',
    stagePrefix: prefix,
  ),
  visibleMask: mask,

  // S0-Lock Props
  s0Locked: ref.watch(s0LockedProvider),
  onTapS0: () async {
    final notifier = ref.read(s0LockedProvider.notifier);
    final wasLocked = notifier.state;
    notifier.state = !wasLocked;

    if (wasLocked) {
      await _switchCtrl.blinkS0Once();
    }
  },
)
```

---

## 🧹 Clean Code Prinzipien

### Separation of Concerns

**Application Layer (Business Logic):**

- `s0_lock_provider.dart` - Reiner State, keine UI-Logik

**UI Layer (Presentation):**

- Widgets enthalten keine Business-Logik
- UI-Komponenten sind wiederverwendbar und testbar

**Container vs. Presentational:**

- `StageSwitchRow` = Container (verbindet State mit UI)
- `VerticalStageSwitch` = Presentational (nur Rendering)

### Single Responsibility Principle

| Komponente            | Verantwortlichkeit                 |
| --------------------- | ---------------------------------- |
| `s0LockedProvider`    | State-Verwaltung                   |
| `VerticalStageSwitch` | UI-Rendering einer Switch          |
| `StageSwitchRow`      | Zusammenstellung mehrerer Switches |
| `LevelsCard`          | Category Screen Integration        |
| `LearnModeScreen`     | Learn Mode Integration             |

### Dependency Injection

- Provider werden via Riverpod injiziert
- Callbacks werden als Props übergeben (kein tight coupling)
- Controller werden im State erstellt (lokal verwaltet)

### Immutability

- Widgets sind immutable (Stateless/Stateful mit const Konstruktoren)
- State wird über Provider verwaltet (unidirectional data flow)

---

## 🏛️ MVC/Presentation Pattern Trennung

### Model (Domain/Data Layer)

**Fehlt aktuell:** S0-Lock ist rein UI-State, kein Domain-Model

**Mögliche Erweiterung:**

```dart
// domain/s0_lock_state.dart
class S0LockState {
  final bool isLocked;
  final DateTime? lockedAt;

  const S0LockState({required this.isLocked, this.lockedAt});
}
```

### View (UI Layer)

**Presentational Widgets:**

- `VerticalStageSwitch` - Pure UI, keine Logik
- `StageSwitchRow` - UI-Container, delegiert an Child-Widgets

**Container Widgets:**

- `LevelsCard` - Verbindet Provider mit UI
- `LearnModeScreen` - Verbindet Provider mit UI

### Controller/ViewModel (Application Layer)

**State Management:**

- `s0LockedProvider` - State Provider (äquivalent zu ViewModel)
- `StageSwitchRowController` - UI-Controller (Blink-Effekte)

### Fluss-Diagramm

```
┌────────────────────────────────────────┐
│  View (UI Layer)                      │
│  - VerticalStageSwitch                │
│  - StageSwitchRow                     │
│  - LevelsCard                         │
│  - LearnModeScreen                    │
└──────────────┬─────────────────────────┘
               │ ref.watch/ref.read
               ▼
┌────────────────────────────────────────┐
│  Controller (Application Layer)        │
│  - s0LockedProvider                   │
│  - StageSwitchRowController           │
└──────────────┬─────────────────────────┘
               │
               ▼
┌────────────────────────────────────────┐
│  Model (Domain Layer)                 │
│  - Kein Domain-Model (nur UI-State)   │
└────────────────────────────────────────┘
```

### Presentational vs. Container Pattern

**Presentational Widgets:**

- `VerticalStageSwitch` - Empfängt alle Daten als Props
- Keine direkte Provider-Abhängigkeit
- Wiederverwendbar und testbar

**Container Widgets:**

- `LevelsCard` - Verbindet Provider mit Presentational Widgets
- `LearnModeScreen` - Verbindet Provider mit Presentational Widgets
- Verwenden `ref.watch()` und `ref.read()`

---

## 🔄 State Management Patterns

### Unidirectional Data Flow

```
User Action
    ↓
onTapS0() Callback
    ↓
Provider Update (s0LockedProvider)
    ↓
Provider Notification
    ↓
Widget Rebuild (ref.watch)
    ↓
UI Update
```

### Provider Pattern (Riverpod)

**StateProvider für einfache Werte:**

- `s0LockedProvider` - Boolean State
- Geeignet für UI-State ohne komplexe Logik

**Controller Pattern:**

- `StageSwitchRowController` - Verwalten von UI-Effekten (Blink)
- Nicht für State-Management, sondern für UI-Interaktionen

---

## 📝 Best Practices

### 1. Provider-Nutzung

✅ **Gut:**

```dart
// State beobachten
final isLocked = ref.watch(s0LockedProvider);

// State ändern
ref.read(s0LockedProvider.notifier).state = true;
```

❌ **Schlecht:**

```dart
// Provider direkt im Widget erstellen
final provider = StateProvider<bool>((ref) => false);
```

### 2. Widget-Props

✅ **Gut:**

```dart
final bool isLocked;
final VoidCallback? onTap;
```

❌ **Schlecht:**

```dart
// WidgetRef im Widget direkt nutzen
WidgetRef ref;
```

### 3. Async Operations

✅ **Gut:**

```dart
onTapS0: () async {
  final wasLocked = notifier.state;
  notifier.state = !wasLocked;
  if (wasLocked) {
    await _switchCtrl.blinkS0Once();
  }
}
```

❌ **Schlecht:**

```dart
onTapS0: () {
  notifier.state = !notifier.state;
  // Blink vergessen
}
```

---

## 🚀 Erweiterungsmöglichkeiten

### Persistenz

**SharedPreferences Integration:**

```dart
final s0LockedProvider = StateNotifierProvider<S0LockNotifier, bool>((ref) {
  return S0LockNotifier();
});

class S0LockNotifier extends StateNotifier<bool> {
  S0LockNotifier() : super(false) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('s0_locked') ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('s0_locked', state);
  }
}
```

### Backend-Synchronisation

**Supabase Integration:**

```dart
// RPC Function aufrufen
await supabase.rpc('fn_set_s0_lock', params: {
  'locked': isLocked,
});
```

### Erweiterte Features

- **Per-Kategorie Lock:** Jede Kategorie hat eigenen Lock-Status
- **Auto-Lock:** Automatisches Sperren nach X neuen Karten
- **Lock-Historie:** Tracking wann und warum gesperrt wurde

---

## 🧪 Testing

### Unit Tests

**Provider Testing:**

```dart
test('s0LockedProvider toggles correctly', () {
  final container = ProviderContainer();
  final provider = container.read(s0LockedProvider.notifier);

  expect(container.read(s0LockedProvider), false);
  provider.state = true;
  expect(container.read(s0LockedProvider), true);
});
```

### Widget Tests

**VerticalStageSwitch Testing:**

```dart
testWidgets('shows lock icon when locked', (tester) async {
  await tester.pumpWidget(
    VerticalStageSwitch(
      isLocked: true,
      // ... andere Props
    ),
  );

  expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
});
```

---

## 📚 Referenzen

- **Riverpod Documentation:** https://riverpod.dev
- **Flutter Widget Testing:** https://docs.flutter.dev/testing/widget-tests
- **Clean Architecture:** https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

---

## 🎯 Zusammenfassung

Das S0-Lock-Feature ist eine **client-seitige UI-Funktion**, die es Benutzern ermöglicht, neue Karten temporär zu sperren. Die Implementierung folgt **Clean Code Prinzipien** und **MVC-Trennung**:

- **Model:** Kein Domain-Model (nur UI-State)
- **View:** Presentational Widgets (`VerticalStageSwitch`) und Container Widgets (`LevelsCard`, `LearnModeScreen`)
- **Controller:** Provider (`s0LockedProvider`) und UI-Controller (`StageSwitchRowController`)

Die Architektur ist **erweiterbar** und **wartbar**, mit klarer Trennung von Concerns und wiederverwendbaren Komponenten.

---

_Erstellt: Januar 2025_  
_Letzte Aktualisierung: Januar 2025_  
_Version: 1.0_
