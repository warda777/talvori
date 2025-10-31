# 📋 Programmliste - Vollständiger Code aller Dateien

> **Erstellt:** Januar 2025  
> **Version:** 1.0  
> **Status:** Vollständige Code-Dokumentation

Diese Datei enthält den vollständigen Codeinhalt aller Dateien im Projekt.

## 📁 Inhaltsverzeichnis

1. [Main Entry Point](#main-entry-point)
2. [Core Layer](#core-layer)
3. [Features](#features)
4. [Supabase Functions](#supabase-functions)

---

## Core/events

### `lib/core/events/events.dart`

**Typ:** Dart  
**Zeilen:** 24

**Vollständiger Code:**

```dart
import 'dart:async';
export 'reset_event.dart';

// === Heute-Statistiken: Stage-Transition ===
// Zählt "new" hoch/runter: S0 -> S1+ (+1), S1+ -> S0 (-1); repeats separat.
class StageTransitionEvent {
  final String categoryId;
  final String wordId;
  final int fromStage; // 0..5
  final int toStage;   // 0..5
  final bool wasDueBefore; // true, wenn die Karte VOR dem Schritt fällig war (für repeats)

  StageTransitionEvent({
    required this.categoryId,
    required this.wordId,
    required this.fromStage,
    required this.toStage,
    required this.wasDueBefore,
  });

  static final _ctrl = StreamController<StageTransitionEvent>.broadcast();
  static Stream<StageTransitionEvent> get stream => _ctrl.stream;
  static void emit(StageTransitionEvent e) => _ctrl.add(e);
}

```

---

### `lib/core/events/reset_event.dart`

**Typ:** Dart  
**Zeilen:** 20

**Vollständiger Code:**

```dart
// lib/core/events/reset_event.dart
import 'dart:async';

/// Globaler Event-Stream für Reset-Events
class ResetEvent {
  static final StreamController<String> _controller = StreamController<String>.broadcast();

  /// Stream für Reset-Events
  static Stream<String> get stream => _controller.stream;

  /// Sende ein Reset-Event für eine bestimmte Kategorie
  static void notifyReset(String categoryId) {
    _controller.add(categoryId);
  }

  /// Schließe den Stream
  static void dispose() {
    _controller.close();
  }
}

```

---

## Core/services

### `lib/core/services/browser_return_service.dart`

**Typ:** Dart  
**Zeilen:** 131

**Vollständiger Code:**

```dart
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:share_handler/share_handler.dart';  // Temporär deaktiviert
import 'dart:async';


class BrowserReturnService {
  static const String _kLastUrl = 'last_shared_url';

  /// Einmal in `main()` vor `runApp()` aufrufen.
  static Future<void> initShareListener() async {
    // Temporär deaktiviert wegen iOS-Problemen mit share_handler
    // TODO: Später wieder aktivieren wenn iOS-Probleme gelöst sind
    /*
    final handler = ShareHandlerPlatform.instance;

    // App kalt über "Teilen" gestartet
    final initial = await handler.getInitialSharedMedia();
    if (initial != null) {
      await _persistFromShared(initial);
    }

    // App offen und es kommt eine Share-Aktion rein
    handler.sharedMediaStream.listen((SharedMedia media) async {
      await _persistFromShared(media);
    });
    */
  }

  static Future<void> _persistFromShared(dynamic media) async {
    String? url;

    // 1) Textinhalt prüfen
    final txt = media.content?.trim();
    if (txt != null && (txt.startsWith('http') || _isLocalLike(txt))) {
      url = txt;
    }


    // 2) Anhänge prüfen (temporär deaktiviert)
    /*
    if (url == null) {
      for (final a in (media.attachments ?? const <SharedAttachment?>[])
          .whereType<SharedAttachment>()) {
        final p = a.path;
        if (p.startsWith('http') || _isLocalLike(p)) {
          url = p;
          break;
        }
      }
    }
    */

    if (url == null) return;

    // 3) http/https normalisieren (Anker/Highlights bleiben erhalten)
    if (url.startsWith('http')) {
      url = _normalizeUrl(url);
    }
    await _saveUrl(url);
  }

  // Broadcast, wenn eine neue Quelle gespeichert wurde
  static final StreamController<String> _savedController =
      StreamController<String>.broadcast();

  static Stream<String> get onSavedUrl => _savedController.stream;

  static Future<void> _saveUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastUrl, url);
    _savedController.add(url); // 🔔 Event feuern
  }

  static Future<String?> getLastUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastUrl);
  }

  static Future<bool> hasLastUrl() async {
    return (await getLastUrl()) != null;
  }

  // Manuell setzen, z. B. wenn im Share-Text eine URL erkannt wird
  static Future<void> setLastUrl(String url) => _saveUrl(url);

  /// Zum Long-Press-Reset am Chrome-Icon.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastUrl);
  }
}

// ───────────────────────── Helpers ─────────────────────────

bool looksLikePdf(String url) {
  final low = url.toLowerCase();
  return low.endsWith('.pdf') || low.contains('.pdf?') || low.contains('.pdf#');
}

String _normalizeUrl(String raw) {
  final u = raw.trim();
  final uri = Uri.tryParse(u);
  if (uri == null) return u;

  const banned = {
    'utm_source','utm_medium','utm_campaign','utm_term','utm_content',
    'fbclid','gclid','igsh','ref','referrer'
  };

  final all = Map<String, List<String>>.from(uri.queryParametersAll)
    ..removeWhere((k, _) => banned.contains(k));

  // Uri.queryParameters erwartet Map<String,String>
  final qp = <String, String>{};
  all.forEach((k, v) {
    if (v.isNotEmpty) qp[k] = v.length == 1 ? v.first : v.join(',');
  });

  return Uri(
    scheme: uri.scheme,
    userInfo: uri.userInfo,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
    queryParameters: qp.isEmpty ? null : qp,
    fragment: uri.fragment.isEmpty ? null : uri.fragment,
  ).toString();
}

bool _isLocalLike(String s) =>
    s.startsWith('content://') || s.startsWith('file://') || s.startsWith('/');

```

---

### `lib/core/services/services.dart`

**Typ:** Dart  
**Zeilen:** 2

**Vollständiger Code:**

```dart
// lib/core/services/services.dart
export 'browser_return_service.dart';

```

---

## Core/theme

### `lib/core/theme/app_theme.dart`

**Typ:** Dart  
**Zeilen:** 54

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';

class AppTheme {
  static ThemeData get dark {
    const seed = Color(0xFF7BB1AA);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(
      // Farben für .tonal Buttons (IconButton.filledTonal, FilledButton.tonal)
      secondaryContainer: const Color(0xFF2E335A),
      onSecondaryContainer: Colors.white,
      // Farben für normale FilledButtons
      primary: const Color(0xFF7C4DFF),
      onPrimary: Colors.white,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      chipTheme: const ChipThemeData(side: BorderSide(color: Colors.transparent)),

      // Optional: Standard-Styles
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,        // wirkt auf FilledButton()
          foregroundColor: scheme.onPrimary,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: scheme.secondaryContainer,   // wirkt auf IconButton.filledTonal
          foregroundColor: scheme.onSecondaryContainer,
        ),
      ),

      // WordsColors ThemeExtension
      extensions: const [
        WordsColors(
          surfaceBg: Colors.black, // Gleiche Farbe wie scaffoldBackgroundColor
          cardBg: Color(0xFF2D2D2F),
        ),
      ],
    );
  }
}
```

---

## Core/ui/widgets

### `lib/core/ui/widgets/progress_bar.dart`

**Typ:** Dart  
**Zeilen:** 46

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double value; // 0..1
  final double height;
  final BorderRadius radius;
  final Gradient? gradient;
  final Color? background;

  const ProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.radius = const BorderRadius.all(Radius.circular(3)),
    this.gradient,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: background ?? Colors.white10,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: gradient ?? LinearGradient(
                  colors: [Colors.white30, Colors.white70],
                ),
              ),
              child: SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

```

---

### `lib/core/ui/widgets/round_icon.dart`

**Typ:** Dart  
**Zeilen:** 32

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const RoundIcon({super.key, required this.icon, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white70),
        ),
      ),
    );
  }
}

```

---

## Features/decks/domain

### `lib/features/decks/domain/deck.dart`

**Typ:** Dart  
**Zeilen:** 17

**Vollständiger Code:**

```dart
class Deck {
  final String id, name;
  final String? description;
  final DateTime createdAt;

  const Deck({required this.id, required this.name, this.description, required this.createdAt});

  factory Deck.fromJson(Map<String, dynamic> j) => Deck(
    id: j['id'], name: j['name'], description: j['description'],
    createdAt: DateTime.parse(j['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'created_at': createdAt.toIso8601String(),
  };
}

```

---

## Features/home/application

### `lib/features/home/application/application.dart`

**Typ:** Dart  
**Zeilen:** 3

**Vollständiger Code:**

```dart
export 'home_controller.dart';
export 'home_state.dart';
export '../providers.dart';

```

---

### `lib/features/home/application/home_controller.dart`

**Typ:** Dart  
**Zeilen:** 78

**Vollständiger Code:**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/application/home_state.dart';
import 'package:talvori/features/home/data/share_ingest_service.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/data/last_shared_word_provider.dart';

class HomeController extends Notifier<HomeState> with WidgetsBindingObserver {
  final SupabaseWordRepository _wordRepo = SupabaseWordRepository();
  final ShareIngestService _shareService = ShareIngestService();

  @override
  HomeState build() {
    refreshMyWordsCount(); // Initial load
    return const HomeState();
  }

  Future<void> init(BuildContext context) async {
    WidgetsBinding.instance.addObserver(this);

    await _shareService.init(
      onIncomingText: (text) async {
        await _shareService.handleIncomingShare(text);
        ref.invalidate(lastSharedWordProvider);
        await refreshMyWordsCount();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inhalt erfasst')),
          );
        }
      },
      onSavedUrl: ({required bool isPdf}) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isPdf ? 'PDF-Position gespeichert' : 'Seitenposition gespeichert')),
          );
        }
      },
    );
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _shareService.dispose();
  }

  // Lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(lastSharedWordProvider);
    }
  }

  // UI toggles
  void toggleImage() => state = state.copyWith(imageExpanded: !state.imageExpanded);
  void setImageDark(bool v) => state = state.copyWith(imageIsDark: v);
  void setCategoriesActive(bool v) => state = state.copyWith(categoriesActive: v);

  // Data
  Future<void> refreshMyWordsCount() async {
    try {
      final c = await _wordRepo.countMyWords();
      debugPrint('🔢 My Words Count: $c');
      state = state.copyWith(myWordsCount: c);
    } catch (_) {/* still */}
  }

  Future<String?> handleIncomingShare(String rawText) async {
    final markedWord = await _shareService.handleIncomingShare(rawText);
    if (markedWord != null) {
      ref.invalidate(lastSharedWordProvider); // Trigger UI refresh for last shared word
      await refreshMyWordsCount();
    }
    return markedWord;
  }
}

```

---

### `lib/features/home/application/home_state.dart`

**Typ:** Dart  
**Zeilen:** 30

**Vollständiger Code:**

```dart
import 'package:flutter/foundation.dart';

@immutable
class HomeState {
  final bool imageExpanded;
  final bool imageIsDark;
  final bool categoriesActive;
  final int myWordsCount;

  const HomeState({
    this.imageExpanded = false,
    this.imageIsDark = false,
    this.categoriesActive = false,
    this.myWordsCount = 0,
  });

  HomeState copyWith({
    bool? imageExpanded,
    bool? imageIsDark,
    bool? categoriesActive,
    int? myWordsCount,
  }) {
    return HomeState(
      imageExpanded: imageExpanded ?? this.imageExpanded,
      imageIsDark: imageIsDark ?? this.imageIsDark,
      categoriesActive: categoriesActive ?? this.categoriesActive,
      myWordsCount: myWordsCount ?? this.myWordsCount,
    );
  }
}

```

---

## Features/home/data

### `lib/features/home/data/data.dart`

**Typ:** Dart  
**Zeilen:** 1

**Vollständiger Code:**

```dart
export 'share_ingest_service.dart';

```

---

### `lib/features/home/data/share_ingest_service.dart`

**Typ:** Dart  
**Zeilen:** 127

**Vollständiger Code:**

```dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:talvori/core/services/services.dart';

class ShareIngestService {
  ShareIngestService({AppLinks? appLinks})
      : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _linksSub;
  StreamSubscription<String>? _savedUrlSub;

  Future<void> init({
    required void Function(String) onIncomingText,
    required void Function({required bool isPdf}) onSavedUrl,
  }) async {
    // Initialer Link (App via Share geöffnet)
    final initial = await _appLinks.getInitialLink();
    final t = initial?.queryParameters['text']?.trim();
    if (t != null && t.isNotEmpty) onIncomingText(t);

    // Laufende Links (App offen)
    _linksSub = _appLinks.uriLinkStream.listen((uri) {
      final text = uri.queryParameters['text']?.trim();
      if (text != null && text.isNotEmpty) onIncomingText(text);
    });

    _savedUrlSub = BrowserReturnService.onSavedUrl.listen((url) {
      final isPdf = url.toLowerCase().trim().endsWith('.pdf');
      onSavedUrl(isPdf: isPdf);
    });
  }

  Future<void> dispose() async {
    await _linksSub?.cancel();
    await _savedUrlSub?.cancel();
  }

  /// URL aus Text erkennen und persistieren (für Browser-Return).
  Future<void> captureUrlIfPresent(String text) async {
    final m = RegExp(r'(https?:\/\/[^\s<>()\[\]]+)').firstMatch(text);
    if (m != null) {
      await BrowserReturnService.setLastUrl(m.group(1)!);
    }
  }

  /// Erstes Wort aus Text extrahieren (ohne URL).
  String? extractMarkedWord(String text) {
    final urlPattern = RegExp(r'https?://[^\s]+');
    final textWithoutUrl = text.replaceAll(urlPattern, '').trim();
    final sourceText = textWithoutUrl.isEmpty ? text : textWithoutUrl;

    final matches = RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿ'-]+")
        .allMatches(sourceText)
        .map((m) => m.group(0)!)
        .toList();

    if (matches.isEmpty) return null;
    return matches.first;
  }

  /// Sichert „last_shared_word“ lokal (für Provider) und triggert Supabase-Function.
  Future<String?> handleIncomingShare(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) return null;

    await captureUrlIfPresent(text);

    final marked = extractMarkedWord(text);
    if (marked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_shared_word', marked);
    }

    final sb = Supabase.instance.client;

    // Test-Login (falls kein User)
    if (sb.auth.currentUser == null) {
      final email = dotenv.env['TEST_EMAIL'];
      final pw = dotenv.env['TEST_PASSWORD'];
      if (email != null && pw != null && email.isNotEmpty && pw.isNotEmpty) {
        try {
          await sb.auth.signInWithPassword(email: email, password: pw);
        } catch (e) {
          debugPrint('Login fehlgeschlagen: $e');
          // Kein Throw – UI soll weiterlaufen
        }
      }
    }

    // Token neu holen, wenn nötig
    var session = sb.auth.currentSession;
    session ??= await sb.auth.refreshSession().then((_) => sb.auth.currentSession);
    final token = session?.accessToken;

    // Supabase Functions (Edge)
    const functionsUrl =
        'https://naplllscmpqexahxtbwg.functions.supabase.co/ingest_word';

    try {
      final resp = await http.post(
        Uri.parse(functionsUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'text': text,
          'fromLang': 'EN',
          'toLang': 'DE',
        }),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return marked;
      }
    } catch (e) {
      debugPrint('Share-Fehler: $e');
    }
    return marked;
  }
}

```

---

## Features/home

### `lib/features/home/providers.dart`

**Typ:** Dart  
**Zeilen:** 7

**Vollständiger Code:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/application/home_controller.dart';
import 'package:talvori/features/home/application/home_state.dart';

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(() {
  return HomeController();
});

```

---

## Features/home/ui

### `lib/features/home/ui/home_screen.dart`

**Typ:** Dart  
**Zeilen:** 38

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = NotifierProvider<CounterNotifier, int>(() => CounterNotifier());

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Talvori')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hello, Talvori'),
            const SizedBox(height: 12),
            Text('$count'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(counterProvider.notifier).increment(),
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}

```

---

## Features/home/ui/screens

### `lib/features/home/ui/screens/category_screen.dart`

**Typ:** Dart  
**Zeilen:** 15

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocab Sort')),
      body: SafeArea(
        child: Center(child: Text('Categories', style: TextStyle(fontSize: 20))),
      ),
    );
  }
}

```

---

### `lib/features/home/ui/screens/course_screen.dart`

**Typ:** Dart  
**Zeilen:** 90

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/features/push/data/daily_picks_store.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DailyPicksStore.I;

    // Reagiert live, wenn du über QuickSend Wörter hinzufügst
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final count = store.items.length;
        final max   = store.maxCount;
        final full  = count >= max;

        return Scaffold(
          appBar: AppBar(
            title: Text("Course  •  $count/$max picks"),
            actions: [
              IconButton(
                tooltip: full ? 'Send now' : 'Send (need ${max - count} more)',
                onPressed: count == 0
                    ? null
                    : () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Mark as sent?'),
                            content: Text(
                              full
                                  ? 'Send $count words now and clear the list?'
                                  : 'You have only $count of $max picks.\nSend anyway and clear the list?',
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Send')),
                            ],
                          ),
                        );
                        if (!context.mounted) return;

                        if (ok == true) {
                          store.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Daily picks cleared')),
                          );
                        }
                      },
                icon: const Icon(Icons.outbound_rounded),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  full
                      ? 'Ready: You reached your $max picks.'
                      : 'Pick ${max - count} more word${max - count == 1 ? '' : 's'}.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (store.items.isEmpty)
                  Text('No picks yet. Use the ↓ button on the Home card to add.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final w in store.items)
                        Chip(
                          label: Text(w),
                          onDeleted: () => store.remove(w),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

```

---

### `lib/features/home/ui/screens/home_screen.dart`

**Typ:** Dart  
**Zeilen:** 209

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/features/words/ui/cards/word_card.dart' as wc;
import 'package:talvori/features/words/ui/screens/vocab_sort_screen.dart';
import 'package:talvori/features/home/ui/screens/profile_screen.dart';
import 'package:talvori/features/words/ui/screens/my_words_screen.dart';

import 'package:talvori/features/home/application/application.dart';
import 'package:talvori/features/home/ui/widgets/widgets.dart';
import 'package:talvori/features/home/ui/theme/theme.dart';
import 'package:talvori/features/home/ui/strings/strings.dart';
import 'package:talvori/features/words/data/last_shared_word_provider.dart';
import 'package:talvori/features/push/data/daily_picks_store.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ProviderSubscription<HomeState>? _homeSub;

  @override
  void initState() {
    super.initState();

    // Controller-Listener ohne ref in dispose
    _homeSub = ref.listenManual<HomeState>(
      homeControllerProvider,
      (prev, next) {
        // Optional: auf State-Änderungen reagieren
      },
    );

    // Controller initialisieren (kümmert sich um Lifecycle & Share-Listener)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeControllerProvider.notifier).init(context);
    });
  }

  @override
  void dispose() {
    // ✅ Subscription ohne ref schließen
    _homeSub?.close();
    _homeSub = null;
    super.dispose();
  }

  void _todo(String what) {
          if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$what${HomeStrings.todo}')));
  }



  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: HomeTheme.background,
      body: SafeArea(
        child: Padding(
          padding: HomeTheme.horizontal,
          child: Column(
            children: [
              AnimatedBuilder(
                animation: DailyPicksStore.I,
                builder: (context, _) {
                  final count = DailyPicksStore.I.items.length;
                  final max = DailyPicksStore.I.maxCount;

                  return HomeTopBar(
                    onAllWords: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VocabSortScreen()),
                    ),
                    onRewards: () => _todo('Rewards/Leaderboard/Stats'),
                    onProgressTap: () => _todo('Daily picks settings'),
                    selected: count,
                    max: max,
                    showProgress: count < max,
                  );
                },
              ),
              const SizedBox(height: 16),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: LayoutBuilder(
                    builder: (ctx, box) {
                      final w = box.maxWidth;
                      final h = w * (570 / 360);

                      return SizedBox(
                        width: w,
                        height: h,
                        child: wc.WordCard(
                          key: ValueKey((state.imageIsDark, state.imageExpanded)),
                          initialWord: null, // WordCard verwendet lastSharedWordProvider
                          onQuickSend: () async {
                            // Aktuelles Wort aus dem Provider holen
                            final currentWord = await ref.read(lastSharedWordProvider.future) ?? 'to assume';
                            final res = DailyPicksStore.I.add(currentWord);

                            // Context nach await prüfen
                            if (!context.mounted) return;

                            switch (res) {
                              case AddResult.ok:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text(HomeStrings.added)),
                                );
                                break;
                              case AddResult.duplicate:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text(HomeStrings.duplicate)),
                                );
                                break;
                              case AddResult.full:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${HomeStrings.full} (${DailyPicksStore.I.maxCount})')),
                                );
                                break;
                              case AddResult.invalid:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text(HomeStrings.invalid)),
                                );
                                break;
                            }
                          },
                          isImageExpanded: state.imageExpanded,
                          onToggleImage: () => ref.read(homeControllerProvider.notifier).toggleImage(),
                          isImageDark: state.imageIsDark,
                          onImageBrightnessChanged: (isDark) => ref.read(homeControllerProvider.notifier).setImageDark(isDark),
                          contentPadding: HomeTheme.contentPadding,

                          userWordCount: state.myWordsCount,
                          onCountTap: () async {

                            final nav = Navigator.of(context); // vor await
                            await nav.push(
                              MaterialPageRoute(builder: (_) => const MyWordsScreen()),
                            );
                            if (!context.mounted) return;
                          },
                          onSpeak: () => _todo('Speak word'),
                          onMarkWords: () => _todo('Open Mark Words (web)'),
                          onGo: () => _todo('Start: My Words practice'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: HomeTheme.bottomPadding,
          child: HomeBottomNav(
            onCategories: () async {
              ref.read(homeControllerProvider.notifier).setCategoriesActive(true);
              await showCategoryPopup(
                context: context,
                onRefreshMyWords: () async {
                  // Refresh My Words count after returning from My Words screen
                  await ref.read(homeControllerProvider.notifier).refreshMyWordsCount();
                },
                onTodo: (s) => _todo(s),
              );
                if (!mounted) return;
              ref.read(homeControllerProvider.notifier).setCategoriesActive(false);
            },
            onPractice: () => showPracticePicker(context),
            onProfile: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            categoriesActive: state.categoriesActive,
          ),
        ),
      ),
    );
  }
}

/// Kleiner Helfer um „Tap außerhalb“ ohne Boilerplate zu ermöglichen.
class PositionedFill extends StatelessWidget {
  final VoidCallback onTapOutside;
  const PositionedFill({super.key, required this.onTapOutside});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTapOutside,
      ),
    );
  }
}

```

---

### `lib/features/home/ui/screens/profile_screen.dart`

**Typ:** Dart  
**Zeilen:** 15

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocab Sort')),
      body: SafeArea(
        child: Center(child: Text('Profile', style: TextStyle(fontSize: 20))),
      ),
    );
  }
}

```

---

### `lib/features/home/ui/screens/vocab_screen.dart`

**Typ:** Dart  
**Zeilen:** 15

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class VocabScreen extends StatelessWidget {
  const VocabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocab Sort')),
      body: SafeArea(
        child: Center(child: Text('Vocab', style: TextStyle(fontSize: 20))),
      ),
    );
  }
}

```

---

## Features/home/ui/strings

### `lib/features/home/ui/strings/home_strings.dart`

**Typ:** Dart  
**Zeilen:** 7

**Vollständiger Code:**

```dart
class HomeStrings {
  static const added = "Added to today's picks";
  static const duplicate = "Already in today's picks";
  static const full = "Limit reached";
  static const invalid = "Cannot add empty word";
  static const todo = " – TODO";
}

```

---

### `lib/features/home/ui/strings/strings.dart`

**Typ:** Dart  
**Zeilen:** 1

**Vollständiger Code:**

```dart
export 'home_strings.dart';

```

---

## Features/home/ui/theme

### `lib/features/home/ui/theme/home_theme.dart`

**Typ:** Dart  
**Zeilen:** 8

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class HomeTheme {
  static const background = Color(0xFF111111);
  static const contentPadding = EdgeInsets.fromLTRB(20, 16, 20, 16);
  static const horizontal = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const bottomPadding = EdgeInsets.fromLTRB(16, 0, 16, 12);
}

```

---

### `lib/features/home/ui/theme/theme.dart`

**Typ:** Dart  
**Zeilen:** 1

**Vollständiger Code:**

```dart
export 'home_theme.dart';

```

---

## Features/home/ui/widgets

### `lib/features/home/ui/widgets/bottom_nav.dart`

**Typ:** Dart  
**Zeilen:** 126

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/features/home/ui/widgets/tap_flash.dart';

// Einheitliche Größe für die runden Bottom-Buttons (Category/Profile)
const double kTopBtnSize = 52; // oder 52 – nimm deinen Zielwert

class HomeBottomNav extends StatelessWidget {
  final VoidCallback onCategories;
  final VoidCallback onPractice;
  final VoidCallback onProfile;
  final bool categoriesActive;
  final bool practiceActive;


  const HomeBottomNav({
    super.key,
    required this.onCategories,
    required this.onPractice,
    required this.onProfile,
    this.categoriesActive = false,
    this.practiceActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const gold = Color(0xFFF1C86B);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ⬅︎ Category (links) – identische Größe + volle Ausdehnung
          SizedBox.square(
            dimension: kTopBtnSize,
            child: Stack(
              fit: StackFit.expand, // Kinder füllen die ganze Fläche
              children: [
                TapFlash(
                  color: gold,
                  shape: BoxShape.circle,
                  maxOpacity: 1.0,
                  blur: 22,
                  spread: 4,
                  duration: const Duration(milliseconds: 220),
                  onTapAfter: onCategories,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.grid_view_rounded,
                        size: 24,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
                if (categoriesActive)
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gold, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(
            width: 140,
            height: 52,
            child: TapFlash(
              color: gold,                                          // Flash-Farbe
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              onTapAfter: onPractice,                               // nach dem Flash ausführen
              child: Container(
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,                     // Button-Farbe
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                ),
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_rounded, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'practice',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ───────── PROFILE (Kreis, 52×52) ─────────
          SizedBox.square(
            dimension: 52,
            child: TapFlash(
              color: cs.primary,                                    // Flash-Farbe
              shape: BoxShape.circle,
              onTapAfter: onProfile,                                // nach dem Flash ausführen
              child: Container(
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,                     // Button-Farbe
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.person_rounded, color: cs.onSecondaryContainer),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

```

---

### `lib/features/home/ui/widgets/category_popup.dart`

**Typ:** Dart  
**Zeilen:** 197

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/screens/my_words_screen.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';

typedef VoidSnack = void Function(String);

Future<void> showCategoryPopup({
  required BuildContext context,
  required Future<void> Function() onRefreshMyWords,
  required VoidSnack onTodo,
}) {
  final cs = Theme.of(context).colorScheme;
  const gold = Color(0xFFF1C86B);

  ButtonStyle pill(BuildContext ctx) => FilledButton.styleFrom(
        backgroundColor: cs.surfaceContainerHighest,
        foregroundColor: cs.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: EdgeInsets.zero,
        fixedSize: const Size(110, 48),
        minimumSize: const Size(110, 48),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );

  Widget content(BuildContext context) => Material(
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: gold, width: 1.6),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Category',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.pop(context);
                      onTodo('All words');
                    },
                    style: pill(context),
                    child: const Text('All words'),
                  ),
                  FilledButton.tonal(
                    onPressed: () async {
                      Navigator.pop(context);
                      final nav = Navigator.of(context);
                      await nav.push(
                        MaterialPageRoute(builder: (_) => const MyWordsScreen()),
                      );
                      await onRefreshMyWords();
                    },
                    style: pill(context),
                    child: const Text('My words'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.pop(context);
                      onTodo('Favorites');
                    },
                    style: pill(context),
                    child: const Text('Favorites'),
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.pop(context);
                      onTodo('Daily picks');
                    },
                    style: pill(context),
                    child: const Text('Daily picks'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.center,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WordHubScreen()),
                    );
                  },
                  child: Container(
                    width: 232,
                    height: 103,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
                    ),
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Word hub',
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.9)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 180,
                  height: 40,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onTodo('Make your own mix');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text('Make your own mix'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (ctx) {
      const double navBtn = 52;
      const double navPad = 12;
      const double leftPad = 16;
      const double gap = 10;
      const double offsetX = 8;
      const double offsetY = 32;

      final bottomInset = MediaQuery.of(ctx).padding.bottom;
      final double baseBottom = bottomInset + navPad + navBtn + gap;

      final double posLeft = leftPad + offsetX;
      final double posBottom = baseBottom + offsetY;

      final screen = MediaQuery.of(ctx).size;
      final safeLeft = posLeft.clamp(0.0, screen.width - 280);
      final safeBottom = posBottom.clamp(8.0, screen.height - 415 - 8);

      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(ctx),
            ),
          ),
          Positioned(
            left: safeLeft,
            bottom: safeBottom,
            child: SizedBox(
              width: 280,
              height: 415,
              child: content(ctx),
            ),
          ),
        ],
      );
    },
  );
}

```

---

### `lib/features/home/ui/widgets/counter_badge.dart`

**Typ:** Dart  
**Zeilen:** 67

**Vollständiger Code:**

```dart
// lib/features/home/ui/widgets/counter_badge.dart
import 'package:flutter/material.dart';

class CounterBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  final double horizontalPadding;
  final double verticalPadding;

  /// Optional: Text-/Icon-Farbe (z. B. für hell/dunkel über Bild)
  final Color? color;

  const CounterBadge({
    super.key,
    required this.count,
    this.onTap,
    this.horizontalPadding = 18,
    this.verticalPadding = 10,
    this.color, // <- wichtig: im Konstruktor führen
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = color ?? cs.onSurface;

    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (color ?? cs.primary).withValues(alpha: 0.7), // Rand passt sich an
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: 0.2,
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: badge,
      ),
    );
  }
}

```

---

### `lib/features/home/ui/widgets/glow_sweep_ring.dart`

**Typ:** Dart  
**Zeilen:** 161

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

/// Glow-Ring mit umlaufendem Lichtsektor.
/// - Eine Umdrehung dauert [duration].
/// - Er läuft [cyclesPerBurst] Runden, pausiert dann [idle], und wiederholt das,
///   wenn [loop] = true.
/// - Wenn [loop] = false, läuft er genau [cyclesPerBurst] Runden und blendet
///   sich danach aus (nur wenn [hideWhenDone] = true).
class GlowSweepRing extends StatefulWidget {
  final double size;                 // Außendurchmesser
  final double strokeWidth;          // Ringbreite
  final Duration duration;           // Dauer einer Umdrehung
  final int cyclesPerBurst;          // Runden pro Burst (z.B. 3)
  final Duration idle;               // Pause nach einem Burst (z.B. 5s)
  final bool loop;                   // true = endlos Bursts
  final bool hideWhenDone;           // nur relevant wenn loop=false
  final Color color;                 // Glow-Farbe

  const GlowSweepRing({
    super.key,
    required this.size,
    this.strokeWidth = 4,
    this.duration = const Duration(milliseconds: 900),
    this.cyclesPerBurst = 3,
    this.idle = const Duration(seconds: 5),
    this.loop = true,
    this.hideWhenDone = true,
    this.color = const Color(0xFFF1C86B), // Gold
  });

  @override
  State<GlowSweepRing> createState() => _GlowSweepRingState();
}

class _GlowSweepRingState extends State<GlowSweepRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: widget.duration);
  int _doneInThisBurst = 0;
  bool _finishedOneShot = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addStatusListener(_onStatus);
    _startNextTurn();
  }

  void _onStatus(AnimationStatus s) async {
    if (s == AnimationStatus.completed) {
      _doneInThisBurst++;

      // Noch Runden in diesem Burst übrig?
      if (_doneInThisBurst < widget.cyclesPerBurst) {
        _startNextTurn();
        return;
      }

      // Burst fertig
      if (widget.loop) {
        // Pause, dann neuer Burst
        await Future.delayed(widget.idle);
        if (!mounted) return;
        _doneInThisBurst = 0;
        _startNextTurn();
      } else {
        // One-shot fertig
        if (widget.hideWhenDone && mounted) {
          setState(() => _finishedOneShot = true);
        }
      }
    }
  }

  void _startNextTurn() {
    // eine Umdrehung
    _ctrl
      ..value = 0
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.removeStatusListener(_onStatus);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finishedOneShot) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final angle = _ctrl.value * 6.283185307179586; // 2π
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _SweepGlowPainter(
            angle: angle,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

class _SweepGlowPainter extends CustomPainter {
  final double angle;
  final Color color;
  final double strokeWidth;

  _SweepGlowPainter({
    required this.angle,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = (size.shortestSide - strokeWidth) / 2;

    // Grundring (dezent)
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color.withValues(alpha: 0.18);
    canvas.drawCircle(rect.center, r, basePaint);

    // Leuchtsektor mit Sweep-Gradient, rotiert
    final sweep = SweepGradient(
      startAngle: 0,
      endAngle: 6.283185307179586,
      colors: [
        Colors.transparent,
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.95),
        color.withValues(alpha: 0.0),
        Colors.transparent,
      ],
      stops: const [0.0, 0.40, 0.50, 0.60, 1.0],
      transform: GradientRotation(angle),
    );

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = sweep.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path()..addOval(Rect.fromCircle(center: rect.center, radius: r));
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SweepGlowPainter old) =>
      old.angle != angle || old.color != color || old.strokeWidth != strokeWidth;
}

```

---

### `lib/features/home/ui/widgets/practice_picker.dart`

**Typ:** Dart  
**Zeilen:** 103

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/home/ui/screens/vocab_screen.dart';

Future<void> showPracticePicker(BuildContext context) {
  const double btnWidth = 140;
  const double btnHeight = 52;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;

      final bottomInset = MediaQuery.of(ctx).padding.bottom;
      const navBottomPadding = 12.0;
      const overlapAdjust = 6.0;
      final bottom = bottomInset + navBottomPadding + overlapAdjust;

      final ButtonStyle pillTonal = FilledButton.styleFrom(
        backgroundColor: cs.secondaryContainer,
        foregroundColor: cs.onSecondaryContainer,
        shape: const StadiumBorder(),
        padding: EdgeInsets.zero,
        minimumSize: const Size(btnWidth, btnHeight),
        fixedSize: const Size(btnWidth, btnHeight),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );

      const TextStyle labelStyle =
          TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.2);

      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(ctx),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: btnWidth,
                  height: btnHeight,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CourseScreen()),
                      );
                    },
                    style: pillTonal,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school_rounded, size: 22),
                        SizedBox(width: 8),
                        Text('course', style: labelStyle),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: btnWidth,
                  height: btnHeight,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VocabScreen()),
                      );
                    },
                    style: pillTonal,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_rounded, size: 22),
                        SizedBox(width: 8),
                        Text('vocab', style: labelStyle),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

```

---

### `lib/features/home/ui/widgets/progress_pill.dart`

**Typ:** Dart  
**Zeilen:** 66

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class ProgressPill extends StatelessWidget {
  final int selected;          // z.B. 1
  final int max;               // z.B. 5 (später 1–20)
  final double barWidth;       // Breite des Balkens
  final VoidCallback? onTap;   // öffnet später dein Einstellungs-Sheet
  final Widget? leading;       // optional eigenes Icon/SVG

  const ProgressPill({
    super.key,
    required this.selected,
    required this.max,
    this.barWidth = 140,
    this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final value = (selected / max).clamp(0.0, 1.0);

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading ?? Icon(Icons.system_update_alt_rounded,
              size: 16, color: cs.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(
            '$selected/$max',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: barWidth,
            height: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: cs.onSecondaryContainer.withValues(alpha: 0.25),
                valueColor:
                    AlwaysStoppedAnimation<Color>(cs.onSecondaryContainer),
              ),
            ),
          ),
        ],
      ),
    );

    return onTap == null
        ? pill
        : InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: pill);
  }
}

```

---

### `lib/features/home/ui/widgets/tap_flash.dart`

**Typ:** Dart  
**Zeilen:** 113

**Vollständiger Code:**

```dart
import 'dart:async';
import 'package:flutter/material.dart';

/// TapFlash: kurzer Glow/Flash beim Tippen, dann onTapAfter().
/// - Für Kreise: [shape] = BoxShape.circle
/// - Für Pillen/Buttons: [shape] = BoxShape.rectangle + [borderRadius]
class TapFlash extends StatefulWidget {
  final Widget child;
  final FutureOr<void> Function()? onTapAfter;
  final Color color;
  final Duration duration;       // Gesamtdauer (hin & zurück)
  final double maxOpacity;       // 0..1, Helligkeit des Flash
  final double blur;             // Weichheit des Glows
  final double spread;           // Ausbreitung (Pixel)
  final BoxShape shape;          // circle / rectangle
  final BorderRadius? borderRadius; // für rectangle

  const TapFlash({
    super.key,
    required this.child,
    this.onTapAfter,
    required this.color,
    this.duration = const Duration(milliseconds: 240),
    this.maxOpacity = 0.85,
    this.blur = 18,
    this.spread = 6,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  });

  @override
  State<TapFlash> createState() => _TapFlashState();
}

class _TapFlashState extends State<TapFlash> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _a = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  bool _running = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_running) return;
    _running = true;
    try {
      await _c.forward();
      if (mounted) await _c.reverse();
      final cb = widget.onTapAfter;
      if (cb != null) await cb();
    } finally {
      _running = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Der Glow sitzt als Overlay über dem Child und wird per Opacity animiert.
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(20);

    final glow = AnimatedBuilder(
      animation: _a,
      builder: (_, __) {
        final opacity = _a.value * widget.maxOpacity;
        final color = widget.color.withValues(alpha: opacity);

        final decoration = widget.shape == BoxShape.circle
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color, blurRadius: widget.blur, spreadRadius: widget.spread),
                ],
              )
            : BoxDecoration(
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(color: color, blurRadius: widget.blur, spreadRadius: widget.spread),
                ],
              );

        return IgnorePointer(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 1),
            opacity: opacity > 0 ? 1 : 0,
            child: Container(decoration: decoration),
          ),
        );
      },
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _run,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          widget.child,
          Positioned.fill(child: glow),
        ],
      ),
    );
  }
}

```

---

### `lib/features/home/ui/widgets/top_bar.dart`

**Typ:** Dart  
**Zeilen:** 295

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import 'package:talvori/features/home/ui/widgets/tap_flash.dart';
import 'progress_pill.dart';
import 'package:talvori/features/rewards/ui/screens/rewards_center_screen.dart';

class HomeTopBar extends StatefulWidget {
  final VoidCallback onAllWords;
  final VoidCallback onRewards;         // bleibt für Kompatibilität, wird für Tap genutzt
  final VoidCallback? onProgressTap;
  final int selected;
  final int max;
  final bool showProgress;

  const HomeTopBar({
    super.key,
    required this.onAllWords,
    required this.onRewards,
    this.onProgressTap,
    this.selected = 1,
    this.max = 5,
    this.showProgress = true,
  });

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> {
  // Größen / Layout
  static const double _dim = 52.0;     // Durchmesser deiner Topbar-Buttons
  static const double _quickBtnSize = 56.0; // Größe der Quick-Select-Buttons
  static const double _gap = 16.0;     // Abstand zwischen Krone und Quick-Buttons

  final GlobalKey _crownKey = GlobalKey();
  OverlayEntry? _rewardsOverlay;
  bool _quickOpen = false;

  void _showRewardsQuick(BuildContext context) {
    if (_quickOpen) return;
    final overlay = Overlay.of(context);

    final rb = _crownKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null) return;

    final crownTopLeft = rb.localToGlobal(Offset.zero);
    final crownSize = rb.size;
    final screenW = MediaQuery.of(context).size.width;

    _quickOpen = true;
    HapticFeedback.mediumImpact();

    _rewardsOverlay = OverlayEntry(
      builder: (ctx) {
        // Basis-Positionen
        double redLeft  = crownTopLeft.dx - _gap - _quickBtnSize;                 // Leaderboard (rot) links
        double blueLeft = crownTopLeft.dx + crownSize.width + _gap;               // Stats (blau) rechts
        final top = crownTopLeft.dy + (crownSize.height - _quickBtnSize) / 2;

        // Sichtbarkeits-Checks
        final roomRightForBlue = blueLeft + _quickBtnSize <= screenW - 8;
        final roomLeftForRed   = redLeft >= 8;

        if (!roomRightForBlue && roomLeftForRed) {
          // Kein Platz rechts -> beide auf die linke Seite
          blueLeft = crownTopLeft.dx - (_gap * 2) - (_quickBtnSize * 2);
        } else if (!roomLeftForRed && roomRightForBlue) {
          // Kein Platz links -> beide auf die rechte Seite
          redLeft  = crownTopLeft.dx + crownSize.width + _gap;
          blueLeft = redLeft + _gap + _quickBtnSize;
        } else if (!roomLeftForRed && !roomRightForBlue) {
          // Extrem eng (sehr kleiner Screen) -> packe Buttons rechts an den Rand
          redLeft  = screenW - _quickBtnSize - 8 - _gap - _quickBtnSize;
          blueLeft = screenW - _quickBtnSize - 8;
        }

        return Stack(
          children: [
            // Tap-Outside: schließt & aktiviert ProgressPill wieder
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _hideRewardsQuick,
                child: const SizedBox.expand(),
              ),
            ),

            // Leaderboard (Rot)
            Positioned(
              left: redLeft,
              top: top,
              child: _quickBtn(
                color: const Color(0xFFFE9393),
                icon: Icons.emoji_events_rounded,
                onTap: () {
                  _hideRewardsQuick();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const RewardsCenterScreen(
                        initialTab: RewardsTab.leaderboard,
                      ),
                      transitionsBuilder: (_, a, __, child) =>
                          FadeTransition(opacity: a, child: child),
                    ),
                  );
                },
              ),
            ),

            // Stats (Blau)
            Positioned(
              left: blueLeft,
              top: top,
              child: _quickBtn(
                color: const Color(0xFFB0CCFE),
                icon: Icons.bar_chart_rounded,
                onTap: () {
                  _hideRewardsQuick();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const RewardsCenterScreen(
                        initialTab: RewardsTab.stats,
                      ),
                      transitionsBuilder: (_, a, __, child) =>
                          FadeTransition(opacity: a, child: child),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_rewardsOverlay!);
    setState(() {}); // ProgressPill ausblenden
  }


  void _hideRewardsQuick() {
    _rewardsOverlay?.remove();
    _rewardsOverlay = null;
    _quickOpen = false;
    setState(() {}); // Progressbar einblenden
  }

  // runder Quick-Select-Button
  Widget _quickBtn({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _quickBtnSize,
        height: _quickBtnSize,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: _dim,
      child: Row(
        children: [
          // ───────── links: V-Button (rund) mit TapFlash ─────────
          SizedBox.square(
            dimension: _dim,
            child: TapFlash(
              color: cs.primary, // Flash-Farbe
              shape: BoxShape.circle,
              onTapAfter: widget.onAllWords,
              child: Container(
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/v.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    cs.onSecondaryContainer,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          // ───────── Mitte: Progress-Pill (blendet aus, wenn Quick-Select offen) ─────────
          Expanded(
            child: Center(
              child: widget.showProgress
                  ? AnimatedOpacity(
                      duration: const Duration(milliseconds: 120),
                      opacity: _quickOpen ? 0.0 : 1.0,
                      child: IgnorePointer(
                        ignoring: _quickOpen,
                        child: (widget.onProgressTap == null)
                            ? ProgressPill(
                                selected: widget.selected,
                                max: widget.max,
                                barWidth: 120,
                              )
                            : TapFlash(
                                color: cs.secondary,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(20),
                                onTapAfter: widget.onProgressTap,
                                child: ProgressPill(
                                  selected: widget.selected,
                                  max: widget.max,
                                  barWidth: 120,
                                ),
                              ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // ───────── rechts: Krone (Tap = wie bisher, Long-Press = Quick-Select) ─────────
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onLongPressStart: (_) => _showRewardsQuick(context),
            child: SizedBox.square(
              dimension: _dim,
              child: TapFlash(
                color: cs.tertiary, // Akzent fürs Rewards
                shape: BoxShape.circle,
                onTapAfter: () {
                  // kurzer Tap: wie bisher (Standard-Rewards öffnen)
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const RewardsCenterScreen(),
                      transitionsBuilder: (_, a, __, child) =>
                          FadeTransition(opacity: a, child: child),
                    ),
                  );
                },
                child: Container(
                  key: _crownKey, // wichtig für die Overlay-Position
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/crown.svg',
                    width: 24,
                    height: 19,
                    colorFilter: ColorFilter.mode(
                      cs.onSecondaryContainer,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideRewardsQuick();
    super.dispose();
  }
}

```

---

### `lib/features/home/ui/widgets/widgets.dart`

**Typ:** Dart  
**Zeilen:** 8

**Vollständiger Code:**

```dart
export 'bottom_nav.dart';
export 'category_popup.dart';
export 'counter_badge.dart';
export 'glow_sweep_ring.dart';
export 'practice_picker.dart';
export 'progress_pill.dart';
export 'tap_flash.dart';
export 'top_bar.dart';

```

---

## Features/push/data

### `lib/features/push/data/daily_picks_store.dart`

**Typ:** Dart  
**Zeilen:** 34

**Vollständiger Code:**

```dart
import 'package:flutter/foundation.dart';

class DailyPicksStore extends ChangeNotifier {
  static final DailyPicksStore I = DailyPicksStore._();
  DailyPicksStore._();

  int maxCount = 5; // später aus Settings
  final List<String> _items = [];
  List<String> get items => List.unmodifiable(_items);

  AddResult add(String word) {
    final w = word.trim();
    if (w.isEmpty) return AddResult.invalid;
    if (_items.contains(w)) return AddResult.duplicate;
    if (_items.length >= maxCount) return AddResult.full;
    _items.add(w);
    notifyListeners();
    return AddResult.ok;
  }

  bool remove(String word) {
    final ok = _items.remove(word);
    if (ok) notifyListeners();
    return ok;
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}

enum AddResult { ok, duplicate, full, invalid }

```

---

## Features/rewards/ui/screens

### `lib/features/rewards/ui/screens/rewards_center_screen.dart`

**Typ:** Dart  
**Zeilen:** 346

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RewardsCenterScreen extends StatefulWidget {
  const RewardsCenterScreen({super.key, this.initialTab = RewardsTab.rewards}); // ⬅️ neu
  final RewardsTab initialTab; // ⬅️ neu
  @override
  State<RewardsCenterScreen> createState() => _RewardsCenterScreenState();
}

enum RewardsTab { rewards, leaderboard, stats }

class _RewardsCenterScreenState extends State<RewardsCenterScreen> {
  late RewardsTab tab;

  // Keys für Ausrichtung
  final _statsKey = GlobalKey();
  final _leaderKey = GlobalKey();
  final _rewardsKey = GlobalKey();
  final _trackKey = GlobalKey(); // Referenzfläche mit gleichem Padding wie die Button-Row

  double _tongueAlignX = 0; // -1..1 (Alignment.x)



  // Größen
  static const double kBtnSize = 56;       // Durchmesser der runden Buttons
  static const double kBtnGap = 16;       // Abstand zwischen den drei Top-Buttons
  static const double kTongueHeight = 140;  // Höhe der Zunge
  static const double kTopRowTop = 8;      // Padding oben für die Button-Row
  static const double kCardTop = 92;       // Position der Karte
  static const double kTongueOverlap = 27;  // wie weit die Zunge "hinter" den Button ragt
  static const double kTongueXOffsetPx = 0; // + = nach rechts, - = nach links
  static const double kTongueTopRadius = 28;     // Radius oben
  static const double kTongueBottomRadius = 28;  // Radius unten
  static const double kTongueWidth = 56; // ← deine Wunschbreite in px (z.B. 60)


   // Pro-Tab X-Korrektur der Zunge (Pixel): + = rechts, − = links
  static const Map<RewardsTab, double> kTongueOffsetsPx = {
    RewardsTab.rewards: 44,   // Gold
    RewardsTab.leaderboard: 23, // Rot
    RewardsTab.stats: 2,     // Blau
  };

  // Markenfarben
  static const gold = Color(0xFFFAD17D);
  static const red  = Color(0xFFFE9393);
  static const blue = Color(0xFFB0CCFE);
  Color get accent => switch (tab) {
        RewardsTab.rewards => gold,
        RewardsTab.leaderboard => red,
        RewardsTab.stats => blue,
      };

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab; // <-- vom Aufrufer übergeben

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Richte die Zunge unter dem passenden Button aus
      final GlobalKey targetKey = switch (tab) {
        RewardsTab.stats => _statsKey,
        RewardsTab.leaderboard => _leaderKey,
        _ => _rewardsKey,
      };
      _updateTongueFor(targetKey);
    });
  }

  /// Berechne die X-Ausrichtung relativ zum Track (gleiche Breite/Einrückung wie Buttons)
  void _updateTongueFor(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rb = key.currentContext?.findRenderObject() as RenderBox?;
      final track = _trackKey.currentContext?.findRenderObject() as RenderBox?;
      if (rb == null || track == null) return;

      final centerGlobal = rb.localToGlobal(rb.size.center(Offset.zero));
      final trackOrigin = track.localToGlobal(Offset.zero);
      final localX = centerGlobal.dx - trackOrigin.dx; // x innerhalb des Tracks
      final w = track.size.width;

      setState(() => _tongueAlignX = ((localX + kTongueXOffsetPx + (kTongueOffsetsPx[tab] ?? 0)) / w) * 2 - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: Stack(
          children: [
            // 1) ZUNGE – GANZ HINTEN (unter Buttons & unter Karte)
            Positioned(
              top: kTopRowTop + (kBtnSize / 2) - kTongueOverlap,
              left: 0,
              right: 0,
              child: KeyedSubtree(
                key: _trackKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IgnorePointer(
                    ignoring: true,
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      alignment: Alignment(_tongueAlignX, -1),
                      child: Container(
                        width: kTongueWidth,
                        height: kTongueHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(kTongueTopRadius),
                            topRight: Radius.circular(kTongueTopRadius),
                            bottomLeft: Radius.circular(kTongueBottomRadius),
                            bottomRight: Radius.circular(kTongueBottomRadius),
                          ),
                        ),
                        foregroundDecoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(kTongueTopRadius),
                            topRight: Radius.circular(kTongueTopRadius),
                            bottomLeft: Radius.circular(kTongueBottomRadius),
                            bottomRight: Radius.circular(kTongueBottomRadius),
                          ),
                        ),
                      ),

                    ),
                  ),
                ),
              ),
            ),

            // 2) KARTE – MITTIG (liegt über der Zunge)
            Positioned.fill(
              top: kCardTop,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: accent, width: 1),
                  ),
                  child: _buildScrollableCard(),
                ),
              ),
            ),

            // 3) TOP-ROW – GANZ VORNE (Buttons + Zurück)
            Positioned(
              left: 16,
              right: 16,
              top: kTopRowTop,
              child: Row(
                children: [
                  _roundIcon(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  _switchButton(
                    (c) => Icon(Icons.bar_chart_rounded, color: c, size: 26),
                    RewardsTab.stats,
                    key: _statsKey,
                  ),
                  const SizedBox(width: kBtnGap),
                  _switchButton(
                    (c) => Icon(Icons.emoji_events_rounded, color: c, size: 26),
                    RewardsTab.leaderboard,
                    key: _leaderKey,
                  ),
                  const SizedBox(width: kBtnGap),
                  _switchButton(
                    (c) => SvgPicture.asset(
                      'assets/icons/crown.svg',
                      width: 24,
                      height: 19,
                      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
                    ),
                    RewardsTab.rewards,
                    key: _rewardsKey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sticky-Header (Titel bleibt beim Scrollen sichtbar)
  Widget _buildScrollableCard() {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _TitleHeaderDelegate(
            height: 72,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              alignment: Alignment.center,
              child: Text(
                switch (tab) {
                  RewardsTab.rewards => 'Rewards',
                  RewardsTab.leaderboard => 'Leaderboard',
                  RewardsTab.stats => 'Stats',
                },
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 1.2,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _tabContent()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  // Inhalte je Tab (Platzhalter)
  Widget _tabContent() {
    switch (tab) {
      case RewardsTab.rewards:
        return _sectionPlaceholder('Rewards-Inhalt …');
      case RewardsTab.leaderboard:
        return _sectionPlaceholder('Leaderboard-Inhalt …');
      case RewardsTab.stats:
        return _sectionPlaceholder('Stats-Inhalt …');
    }
  }

  Widget _sectionPlaceholder(String text) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            12,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$text  •  Row ${i + 1}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _roundIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70),
      ),
    );
  }

  Widget _switchButton(
    Widget Function(Color) iconBuilder,
    RewardsTab target, {
    Key? key,
  }) {
    final selected = tab == target;
    final color = selected ? accent : Colors.white60;
    return GestureDetector(
      key: key,
      onTap: () {
        setState(() => tab = target);
        _updateTongueFor(
          target == RewardsTab.stats
              ? _statsKey
              : target == RewardsTab.leaderboard
                  ? _leaderKey
                  : _rewardsKey,
        );
      },
      child: Container(
        width: kBtnSize,
        height: kBtnSize,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          shape: BoxShape.circle,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
          border: Border.all(
            color: selected ? accent : Colors.white24,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: iconBuilder(color),
      ),
    );
  }
}

class _TitleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  const _TitleHeaderDelegate({required this.height, required this.child});
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;
  @override
  bool shouldRebuild(covariant _TitleHeaderDelegate old) =>
      old.height != height || old.child != child;
}

```

---

## Features/words/application

### `lib/features/words/application/application.dart`

**Typ:** Dart  
**Zeilen:** 5

**Vollständiger Code:**

```dart
// lib/features/words/application/application.dart
export 'learn_mode_controller.dart';
export 'word_providers.dart';
export 'srs_logic.dart';
export 'srs_config.dart';

```

---

### `lib/features/words/application/category_controller.dart`

**Typ:** Dart  
**Zeilen:** 169

**Vollständiger Code:**

```dart
import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/words/data/category_repository.dart';

part 'category_controller.g.dart';

class CategoryState {
  final List<Category> categories;
  final bool loading;
  final String? error;
  final bool offline;

  const CategoryState({
    this.categories = const [],
    this.loading = false,
    this.error,
    this.offline = false,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? loading,
    String? error,
    bool? offline,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      loading: loading ?? this.loading,
      error: error,
      offline: offline ?? this.offline,
    );
  }
}

class _CacheEntry {
  final List<Category> categories;
  final DateTime timestamp;

  _CacheEntry(this.categories) : timestamp = DateTime.now();

  bool get isFresh => DateTime.now().difference(timestamp) < const Duration(minutes: 5);

  CategoryState get state => CategoryState(
    categories: categories,
    loading: false,
    offline: false,
  );
}

@riverpod
class CategoryController extends _$CategoryController {
  final _repo = CategoryRepository();
  static final Map<String, _CacheEntry> _cache = {};
  StreamSubscription? _connSub;

  @override
  CategoryState build() {
    final link = ref.keepAlive();
    ref.onDispose(() async {
      await _connSub?.cancel();
      link.close();
    });

    if (_cache['categories'] != null && _cache['categories']!.isFresh) {
      _revalidate(unawaited: true);
      return _cache['categories']!.state.copyWith(loading: false);
    }

    // Prefs-Hydration sofort starten (setzt loading=false, wenn Daten da sind)
    _hydrateFromPrefs();

    // Revalidate im Hintergrund
    _revalidate(unawaited: true);

    // nur dann als "loading" starten, wenn noch keine Items da sind
    return const CategoryState(loading: true);
  }

  Future<void> _hydrateFromPrefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('cache_categories_v1');
      if (raw == null) return;
      final List data = jsonDecode(raw);
      final items = data.map((m) => Category.fromJson(m as Map<String, dynamic>)).toList();
      // sofort anzeigen, kein Spinner
      state = state.copyWith(categories: items, loading: false, error: null);
      _cache['categories'] = _CacheEntry(items);
    } catch (_) {
      // ignoriere Pref-Fehler still
    }
  }

  Future<void> _revalidate({bool unawaited = false}) async {
    final future = _loadFromServer();
    if (unawaited) {
      // ignore: discarded_futures
      future;
    } else {
      await future;
    }
  }


  Future<List<Category>> _loadSnapshot() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('cached_categories');
      if (raw == null) return [];
      final List list = jsonDecode(raw);
      return list.map((m) => Category.fromJson(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _loadFromServer() async {
    try {
      final categories = await _repo.fetchCategories();
      _cache['categories'] = _CacheEntry(categories);
      state = state.copyWith(
        categories: categories,
        loading: false,
        offline: false,
        error: null,
      );
    } catch (e) {
      // Bei Fehler: Snapshot versuchen
      final snapshot = await _loadSnapshot();
      if (snapshot.isNotEmpty) {
        state = state.copyWith(
          categories: snapshot,
          loading: false,
          offline: true,
          error: 'Offline – zeige zuletzt geladene Kategorien',
        );
      } else {
        state = state.copyWith(
          loading: false,
          offline: false,
          error: e.toString(),
        );
      }
    }
  }


  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final categories = await _repo.fetchCategories();
      _cache['categories'] = _CacheEntry(categories);
      state = state.copyWith(
        categories: categories,
        loading: false,
        offline: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        offline: false,
        error: e.toString(),
      );
    }
  }
}
```

---

### `lib/features/words/application/category_controller.g.dart`

**Typ:** Dart  
**Zeilen:** 27

**Vollständiger Code:**

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryControllerHash() =>
    r'394eb4a9a184ac1350ca190a282f46fa206d0ee2';

/// See also [CategoryController].
@ProviderFor(CategoryController)
final categoryControllerProvider =
    AutoDisposeNotifierProvider<CategoryController, CategoryState>.internal(
      CategoryController.new,
      name: r'categoryControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CategoryController = AutoDisposeNotifier<CategoryState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

```

---

### `lib/features/words/application/category_detail_controller.dart`

**Typ:** Dart  
**Zeilen:** 196

**Vollständiger Code:**

```dart
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'category_detail_state.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/ui/widgets/stats_helpers.dart';
import 'package:talvori/core/events/events.dart';

final categoryDetailControllerProvider =
  NotifierProvider<CategoryDetailController, CategoryDetailState>(
    () => CategoryDetailController(),
  );

class CategoryDetailController extends Notifier<CategoryDetailState> {
  @override
  CategoryDetailState build() => const CategoryDetailState();

  Timer? _switchDebounce;
  StreamSubscription<String>? _resetSub;
  StreamSubscription<StageTransitionEvent>? _stageSub;

  // === lifecycle ===
  Future<void> init({String? categoryId, String? categorySlug, required String fallbackTitle}) async {
    state = state.copyWith(loading: true);
    try {
      final cats = await fetchAllCategories();
      final idx = _findInitialIndex(cats, categoryId, categorySlug, fallbackTitle);
      state = state.copyWith(categories: cats, selectedIndex: idx);

      if (cats.isNotEmpty) {
        final selId = _currentCatId;
        await ensureTodayBucket(selId);
        await _loadProgress(selId, preferLocal: true);
        await _loadVocabsTotal(selId);
      }

      // events
      _resetSub?.cancel();
      _resetSub = ResetEvent.stream.listen((catId) async {
        if (catId == _currentCatId) {
          await applyLocalReset(catId);
          await reload();
        }
      });

      _stageSub?.cancel();
      _stageSub = StageTransitionEvent.stream.listen((e) async {
        if (e.categoryId != _currentCatId) return;
        await ensureTodayBucket(e.categoryId);
        final prefs = await SharedPreferences.getInstance();
        var todayNew = prefs.getInt('today_new_${e.categoryId}') ?? 0;
        var todayRep = prefs.getInt('today_repeats_${e.categoryId}') ?? 0;

        if (e.fromStage == 0 && e.toStage >= 1) todayNew += 1;
        else if (e.fromStage >= 1 && e.toStage == 0) todayNew = (todayNew - 1).clamp(0, 1<<30);
        if (e.wasDueBefore == true) todayRep += 1;

        await prefs.setInt('today_new_${e.categoryId}', todayNew);
        await prefs.setInt('today_repeats_${e.categoryId}', todayRep);
        state = state.copyWith(dailyNew: todayNew, dailyRepeats: todayRep);
      });
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> disposeSubscriptions() async {
    _switchDebounce?.cancel();
    await _resetSub?.cancel();
    await _stageSub?.cancel();
  }

  // === intents ===
  Future<void> switchTo(int idx) async {
    if (idx < 0 || idx >= state.categories.length) return;
    state = state.copyWith(selectedIndex: idx);
    _switchDebounce?.cancel();
    _switchDebounce = Timer(const Duration(milliseconds: 180), () async {
      final selId = _currentCatId;
      await _loadProgress(selId, preferLocal: false);
      await _loadVocabsTotal(selId);
    });
  }

  Future<void> reload() async {
    if (state.categories.isEmpty) return;
    final selId = _currentCatId;
    await ensureTodayBucket(selId);
    await _loadProgress(selId, preferLocal: true);
    await _loadVocabsTotal(selId);
  }

  Future<void> applyLocalReset(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('learn_stages_$categoryId', '0,0,0,0,0,0');
    await prefs.setInt('today_new_$categoryId', 0);
    await prefs.setInt('today_repeats_$categoryId', 0);
    await prefs.setBool('just_reset_$categoryId', true);
  }

  Future<void> seedForStart(String categoryId) async {
    final sb = Supabase.instance.client;
    await sb.rpc('fn_seed_user_category', params: {'p_category_id': categoryId});
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('learn_stages_$categoryId');
    await prefs.remove('just_reset_$categoryId');
    await prefs.setBool('just_seeded_$categoryId', true);
  }

  // === private ===
  String get _currentCatId => state.categories.isNotEmpty ? state.categories[state.selectedIndex].id : '';

  Future<void> _loadVocabsTotal(String catId) async {
    final sb = Supabase.instance.client;
    final res = await sb.rpc('fn_category_word_count', params: {'p_category_id': catId});
    state = state.copyWith(vocabsTotal: (res as int?) ?? 0);
  }

  Future<void> _loadProgress(String selId, {required bool preferLocal}) async {
    final prefs = await SharedPreferences.getInstance();
    final stageKey = 'learn_stages_$selId';
    final stored = prefs.getString(stageKey);
    List<int>? localStages;
    if (stored != null) {
      try {
        final parsed = stored.split(',').map(int.parse).toList();
        if (parsed.length == 6) localStages = parsed;
      } catch (_) {}
    }
    final justReset  = prefs.getBool('just_reset_$selId')  ?? false;
    final justSeeded = prefs.getBool('just_seeded_$selId') ?? false;

    if (justSeeded) {
      final prog = await fetchCategoryProgress(selId);
      final wl   = await fetchWorkloadToday(selId);
      await prefs.remove('just_seeded_$selId');

      final daily = await loadDailyLearningStats(selId);
      state = state.copyWith(
        progress: CategoryProgress(
          total: prog.total,
          stages: prog.stages,
          dueToday: prog.dueToday,
          newTotal: prog.newTotal,
        ),
        workload: wl,
        dailyNew: daily.$1,
        dailyRepeats: daily.$2,
      );
      return;
    }

    if (justReset && localStages != null) {
      await prefs.remove('just_reset_$selId');
      state = state.copyWith(
        progress: CategoryProgress(total: 0, stages: localStages, dueToday: 0, newTotal: 0),
        workload: WorkloadToday(dueToday: 0, newTotal: 0),
        dailyNew: 0,
        dailyRepeats: 0,
      );
      return;
    }

    final prog = await fetchCategoryProgress(selId);
    final wl   = await fetchWorkloadToday(selId);
    final daily = await loadDailyLearningStats(selId);

    final stages = (preferLocal && localStages != null) ? localStages : prog.stages;
    state = state.copyWith(
      progress: CategoryProgress(total: prog.total, stages: stages, dueToday: prog.dueToday, newTotal: prog.newTotal),
      workload: wl,
      dailyNew: daily.$1,
      dailyRepeats: daily.$2,
    );
  }

  int _findInitialIndex(List<CategoryInfo> cats, String? id, String? slug, String title) {
    if (id != null && id.isNotEmpty) {
      final i = cats.indexWhere((c) => c.id == id);
      if (i >= 0) return i;
    }
    if (slug != null && slug.isNotEmpty) {
      final i = cats.indexWhere((c) => c.slug == slug);
      if (i >= 0) return i;
    }
    final name = title.trim().toLowerCase();
    var i = cats.indexWhere((c) => c.name.trim().toLowerCase() == name);
    if (i >= 0) return i;
    final tslug = title.toLowerCase().replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
    i = cats.indexWhere((c) => c.slug == tslug);
    return i >= 0 ? i : 0;
  }
}

```

---

### `lib/features/words/application/category_detail_state.dart`

**Typ:** Dart  
**Zeilen:** 45

**Vollständiger Code:**

```dart
import 'package:talvori/features/words/data/supabase_word_repository.dart';

class CategoryDetailState {
  final bool loading;
  final List<CategoryInfo> categories;
  final int selectedIndex;
  final CategoryProgress? progress;
  final WorkloadToday? workload;
  final int vocabsTotal;
  final int dailyNew;
  final int dailyRepeats;

  const CategoryDetailState({
    this.loading = false,
    this.categories = const [],
    this.selectedIndex = 0,
    this.progress,
    this.workload,
    this.vocabsTotal = 0,
    this.dailyNew = 0,
    this.dailyRepeats = 0,
  });

  CategoryDetailState copyWith({
    bool? loading,
    List<CategoryInfo>? categories,
    int? selectedIndex,
    CategoryProgress? progress,
    WorkloadToday? workload,
    int? vocabsTotal,
    int? dailyNew,
    int? dailyRepeats,
  }) {
    return CategoryDetailState(
      loading: loading ?? this.loading,
      categories: categories ?? this.categories,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      progress: progress ?? this.progress,
      workload: workload ?? this.workload,
      vocabsTotal: vocabsTotal ?? this.vocabsTotal,
      dailyNew: dailyNew ?? this.dailyNew,
      dailyRepeats: dailyRepeats ?? this.dailyRepeats,
    );
  }
}
```

---

### `lib/features/words/application/category_id_cache.dart`

**Typ:** Dart  
**Zeilen:** 25

**Vollständiger Code:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// label -> categoryId
final categoryIdCacheProvider = NotifierProvider<CategoryIdCache, Map<String, String>>(() => CategoryIdCache());

class CategoryIdCache extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {};

  void setCategoryId(String label, String id) {
    state = {...state, label: id};
  }

  String? getCategoryId(String label) {
    return state[label];
  }
}

// Helper: liest/schreibt atomar in den Cache
String? getCachedCategoryId(Ref ref, String label) {
  return ref.read(categoryIdCacheProvider.notifier).getCategoryId(label);
}
void setCachedCategoryId(Ref ref, String label, String id) {
  ref.read(categoryIdCacheProvider.notifier).setCategoryId(label, id);
}

```

---

### `lib/features/words/application/category_stats_provider.dart`

**Typ:** Dart  
**Zeilen:** 44

**Vollständiger Code:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/word_providers.dart';
import 'package:talvori/features/words/application/category_id_cache.dart';

// kleines DTO
class CategoryStats {
  final int total;
  final int dueToday;
  final int newTotal;
  const CategoryStats({required this.total, required this.dueToday, required this.newTotal});
}

// liefert Stats zu einer Subkategorie (per Label/ID-Auflösung)
final categoryStatsProvider = FutureProvider.family<CategoryStats?, HubSubcat>((ref, sub) async {
  final repo = ref.read(supabaseWordRepositoryProvider);

  // Cache-Lookup vor Repo-Call
  final cached = getCachedCategoryId(ref, sub.label);
  if (cached != null) {
    final prog = await fetchCategoryProgress(cached);
    final wl = await fetchWorkloadToday(cached);
    return CategoryStats(total: prog.total, dueToday: wl.dueToday, newTotal: prog.stages[0]);
  }

  final String? catId = (sub.supabaseId != null && sub.supabaseId!.isNotEmpty)
      ? sub.supabaseId
      : await repo.findCategoryIdByName(sub.label);

  if (catId == null) return null;

  // Cache-Speicherung nach findCategoryIdByName
  setCachedCategoryId(ref, sub.label, catId);

  final prog = await fetchCategoryProgress(catId);
  final wl = await fetchWorkloadToday(catId);

  return CategoryStats(
    total: prog.total,
    dueToday: wl.dueToday,
    newTotal: prog.stages[0],
  );
});

```

---

### `lib/features/words/application/learn_mode_controller.dart`

**Typ:** Dart  
**Zeilen:** 1116

**Vollständiger Code:**

```dart
// lib/features/words/application/learn_mode_controller.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/srs_logic.dart';
import 'package:talvori/features/words/application/srs_config.dart';
import 'package:talvori/features/words/services/sfx_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/core/events/events.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';

/// ---------- State ----------

class LearnModeState {
  final String categoryId;
  final String title;

  final bool loading;
  final List<CategoryInfo> categories;
  final int selectedCategoryIndex;

  final List<int> stages; // [S0..S5]
  final int totalWordsInCategory;

  final List<WordUserView> wordQueue;      // Originale Wortliste (Objekte)
  final List<String> shuffledWordIds;      // Reihenfolge (nur IDs)
  final int index;                         // Zeiger in shuffledWordIds

  final bool showTranslation;

  // Timer
  final bool running;          // Timer läuft (nicht pausiert)
  final bool timerActive;      // Timer wurde gestartet (Play gedrückt)
  final bool timerPaused;      // explizit pausiert
  final double remainingMillis;
  final int timeLimit;         // Sekunden pro Karte

  // Reviews
  final List<String> recentlySwiped; // IDs der Karten, die in dieser Session korrekt geswipet wurden
  final int cardsSwipedInSession;
  final bool hasLoadedReviews;

  const LearnModeState({
    this.categoryId = '',
    this.title = '',

    this.loading = false,
    this.categories = const [],
    this.selectedCategoryIndex = 0,

    this.stages = const [0, 0, 0, 0, 0, 0],
    this.totalWordsInCategory = 0,

    this.wordQueue = const [],
    this.shuffledWordIds = const [],
    this.index = 0,

    this.showTranslation = false,

    this.running = false,
    this.timerActive = false,
    this.timerPaused = false,
    this.remainingMillis = 10000.0,
    this.timeLimit = 10,

    this.recentlySwiped = const [],
    this.cardsSwipedInSession = 0,
    this.hasLoadedReviews = false,
  });

  factory LearnModeState.initial() => const LearnModeState();

  LearnModeState copyWith({
    String? categoryId,
    String? title,

    bool? loading,
    List<CategoryInfo>? categories,
    int? selectedCategoryIndex,

    List<int>? stages,
    int? totalWordsInCategory,

    List<WordUserView>? wordQueue,
    List<String>? shuffledWordIds,
    int? index,

    bool? showTranslation,

    bool? running,
    bool? timerActive,
    bool? timerPaused,
    double? remainingMillis,
    int? timeLimit,

    List<String>? recentlySwiped,
    int? cardsSwipedInSession,
    bool? hasLoadedReviews,
  }) {
    return LearnModeState(
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,

      loading: loading ?? this.loading,
      categories: categories ?? this.categories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,

      stages: stages ?? this.stages,
      totalWordsInCategory: totalWordsInCategory ?? this.totalWordsInCategory,

      wordQueue: wordQueue ?? this.wordQueue,
      shuffledWordIds: shuffledWordIds ?? this.shuffledWordIds,
      index: index ?? this.index,

      showTranslation: showTranslation ?? this.showTranslation,

      running: running ?? this.running,
      timerActive: timerActive ?? this.timerActive,
      timerPaused: timerPaused ?? this.timerPaused,
      remainingMillis: remainingMillis ?? this.remainingMillis,
      timeLimit: timeLimit ?? this.timeLimit,

      recentlySwiped: recentlySwiped ?? this.recentlySwiped,
      cardsSwipedInSession: cardsSwipedInSession ?? this.cardsSwipedInSession,
      hasLoadedReviews: hasLoadedReviews ?? this.hasLoadedReviews,
    );
  }
}

/// ---------- Provider ----------

final learnModeControllerProvider =
    NotifierProvider<LearnModeController, LearnModeState>(() {
  return LearnModeController();
});

/// ---------- Controller ----------

class LearnModeController extends Notifier<LearnModeState> {
  @override
  LearnModeState build() => LearnModeState.initial();

  Timer? _wordTimer;
  SfxService? _sfx;

  // ---- SRS-Einstellungen und Konstanten ----

  // Stage-Daten für Switches (s0..s5)
  int _goalPerStage = 100;

  // Kartenbasiertes Wiederholungssystem
  static const int _newCardsBeforeReview = 4; // Nach X neuen Karten → Wiederholungen
  static const double _reviewRatio = 0.8; // 80% der neuen Karten wiederholen (anpassbar)

  // SRS Stats für adaptive Konfiguration
  double _rollingAccuracy = 0.8; // Rolling accuracy (0..1)
  double _avgSwipeMs = 3000.0; // Durchschnittliche Antwortzeit in ms
  int _recentTimeouts = 0; // Anzahl der letzten Timeouts

  // --- S0 Cooldown: wie viele andere Karten MINDESTENS dazwischen liegen müssen
  static const int _s0MinOthers = 3; // ← gern auf 5 erhöhen, wenn gewünscht
  final Map<String, int> _cooldown = {}; // wordId -> verbleibende "andere Karten"

  // --- Queue-Steuerung: wie viele Karten vorn „gesteuert" werden

  String get _currentCatId {
    final cats = state.categories;
    final i = state.selectedCategoryIndex;
    if (cats.isEmpty || i >= cats.length) return state.categoryId;
    return cats[i].id;
  }

  String get _stageStoreKey => 'learn_stages_$_currentCatId';

  // ---- Public API (Screen ruft das auf) ----

  Future<void> init({required String categoryId, required String title}) async {
    _set(categoryId: categoryId, title: title);
    _sfx = ref.read(sfxProvider);
    await _loadCategories();
  }

  void onSwipeRight() {
    if (!_canInteract()) return;
    _sfx?.correct();
    _handleAnswer(correct: true);
  }

  void onSwipeLeft() {
    if (!_canInteract()) return;
    _sfx?.wrong();
    _handleAnswer(correct: false);
  }

  void toggleFlip() {
    if (!_canInteract()) return;
    _set(showTranslation: !state.showTranslation);
  }

  /// Prüft, ob Interaktionen erlaubt sind (nicht pausiert)
  bool _canInteract() {
    return !state.timerPaused;
  }

  void startTimer() {
    print('🎮 startTimer() aufgerufen');
    _startWordTimer(forceActive: true);
  }
  void pauseTimer() => _set(timerPaused: true, running: false);
  void resumeTimer() {
    if (!state.timerActive) return; // nur wenn Timer aktiv ist
    _set(timerPaused: false, running: true);
  }
  void cancelTimer() => _stopTimer();

  Future<void> selectCategoryIndex(int idx) async {
    _set(selectedCategoryIndex: idx, index: 0);
    _resetCardBasedSystem();
    await _loadStageData();
    await _loadWords();
  }

  Future<void> performReset() async {
    // Single-Session Reset falls im Single-Modus
    final mode = ref.read(levelSelectionProvider);
    if (mode == LevelSelectionMode.single) {
      await resetSingleSession();
    } else {
      await _performReset();
    }
  }

  // ---- Loading ----

  Future<void> _loadCategories() async {
    _set(loading: true);
    try {
      final cats = await fetchAllCategories();
      final sel = _findInitialIndex(cats);
      _set(categories: cats, selectedCategoryIndex: sel);
      await _loadStageData();
      await _loadWords();
    } finally {
      _set(loading: false);
    }
  }

  Future<void> _persistStageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_stageStoreKey, state.stages.join(','));
    } catch (_) {}
  }

  Future<void> _loadStageData() async {
    bool hasLocal = false;

    try {
      // 1) Schnell lokal
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_stageStoreKey);
      if (stored != null) {
        try {
          final parsed = stored.split(',').map(int.parse).toList();
          if (parsed.length == 6) {
            _set(stages: parsed);
            hasLocal = true;
          }
        } catch (_) {}
      }

      // 2) Backend
      final prog = await fetchCategoryProgress(_currentCatId);
      if (!hasLocal) {
        _set(stages: prog.stages);
      }
      _set(totalWordsInCategory: prog.total);

      // 3) Lokal sichern
      await _persistStageData();

    } catch (_) {
      if (state.stages.every((s) => s == 0)) {
        _set(stages: const [0, 0, 0, 0, 0, 0]);
      }
    }
  }

  Future<void> _loadWords() async {
    try {
      final catId = _currentCatId;
      final mode = ref.read(levelSelectionProvider);
      final singleStage = ref.read(singleStageProvider); // 1..5, nur für Single relevant

      print('🧪 RPC: fn_user_learn_queue_mode(catId=$catId, mode=$mode, singleStage=$singleStage)');
      final words = await fetchLearnQueueForMode(
        catId,
        mode: mode,
        singleStage: singleStage,
      );

        // Client-seitige Filterung als zusätzliche Absicherung
        final allowed = ref.read(allowedStagesProvider);
        final filteredWords = words.where((w) => allowed.contains(w.srsStage)).toList();

        // Session-Buckets für Single-Modus initialisieren
        if (mode == LevelSelectionMode.single) {
          final cnt = filteredWords.length;
          ref.read(singleSessionBucketsProvider.notifier).state = SingleSessionBuckets(src: cnt);

          // Single-Session seeden
          try {
            await singleSeed(catId, singleStage);
            final counts = await singleCounts(catId, singleStage);
            print('🔢 SingleCounts for $catId (stage $singleStage): src=${counts.$1}, sr1=${counts.$2}, sr2=${counts.$3}');
            ref.read(singleSessionBucketsProvider.notifier).state = SingleSessionBuckets(
              src: counts.$1,
              sx: counts.$2,
              sy: counts.$3,
            );
            // Auch die neuen Counts setzen
            ref.read(singleSessionCountsProvider.notifier).state = SingleSessionCounts(
              counts.$1, counts.$2, counts.$3,
            );
          } catch (e) {
            print('❌ Single session seed failed: $e');
          }
        }

      // Histogramm ausgeben
      final rpcHist = <int,int>{};
      for (final w in words.take(60)) { rpcHist[w.srsStage] = (rpcHist[w.srsStage] ?? 0) + 1; }
      print('🧪 Words(60) stages: $rpcHist');

      // Ersten 10 Stufen klar loggen
      print('🧪 First10 stages: ${words.take(10).map((w) => w.srsStage).toList()}');

      if (filteredWords.isEmpty) {
        _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
        return;
      }

      final queue = _buildQueueDueFirst(filteredWords);

      // Sofort prüfen: Queue-Stages analysieren
      final hist = <int,int>{};
      for (final w in queue.take(50)) {
        hist[w.srsStage] = (hist[w.srsStage] ?? 0) + 1;
      }
      print('🔎 Queue first50 stages: $hist');

      // Config berechnen und übergeben
      final now = DateTime.now();
      final dueCount = queue.where((w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(now)).length;

      // Stats für adaptive Konfiguration
      final stats = SrsStats(
        rollingAccuracy: _rollingAccuracy,
        avgSwipeMs: _avgSwipeMs,
        recentTimeouts: _recentTimeouts,
      );

      final cfg = computeSrsConfig(
        totalWordsInCategory: state.totalWordsInCategory,
        dueCount: dueCount,
        stats: stats,
      );

      final allowedMaxStage = _computeAllowedMaxStageFromQueue(queue);
      final order = buildSmartCardOrder(queue, config: cfg, allowedMaxStage: allowedMaxStage);

      // Debug-Log für Gate-Logik
      final s1Count = queue.where((w) => w.srsStage == 1).length;
      final s2Count = queue.where((w) => w.srsStage == 2).length;
      final s3Count = queue.where((w) => w.srsStage == 3).length;
      final s4Count = queue.where((w) => w.srsStage == 4).length;
      print('🚪 Gate: allowedMaxStage=$allowedMaxStage (Queue: S1:$s1Count, S2:$s2Count, S3:$s3Count, S4:$s4Count)');

      // Debug-Log für SRS-Ratio Verifikation
      final headSizePreview = order.take(40).map((ix) => queue[ix]).toList();
      final newCount = headSizePreview.where((w) => w.srsStage == 0).length;
      final dueCountHead = headSizePreview.where((w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(DateTime.now())).length;
      print('🧠 Head[40]: new=$newCount, due=$dueCountHead, total=${headSizePreview.length}');

      _set(
        wordQueue: queue,
        shuffledWordIds: [for (final i in order) queue[i].id],
        index: 0,
      );
    } catch (_) {
      _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
    }
  }

  /// bevorzugt fällige Karten, Rest zufällig gemischt
  List<WordUserView> _buildQueueDueFirst(List<WordUserView> words) {
    final due = <WordUserView>[];
    final notDue = <WordUserView>[];
    final now = DateTime.now();

    for (final w in words) {
      if (w.nextDueAt != null && !w.nextDueAt!.isAfter(now)) {
        due.add(w);
      } else {
        notDue.add(w);
      }
    }

    due.shuffle();
    notDue.shuffle();
    return [...due, ...notDue];
  }


  // ---- Single Session Reset ----

  Future<void> resetSingleSession() async {
    final mode = ref.read(levelSelectionProvider);
    if (mode == LevelSelectionMode.single) {
      try {
        final singleStage = ref.read(singleStageProvider);
        await singleReset(_currentCatId, singleStage);

        // Counts nachladen und UI aktualisieren
        final counts = await singleCounts(_currentCatId, singleStage);
        ref.read(singleSessionBucketsProvider.notifier).state = SingleSessionBuckets(
          src: counts.$1,
          sx: counts.$2,
          sy: counts.$3,
        );
        ref.read(singleSessionCountsProvider.notifier).state = SingleSessionCounts(
          counts.$1, counts.$2, counts.$3,
        );
      } catch (e) {
        print('❌ Single session reset failed: $e');
      }
    }
  }

  // ---- Review / Antwort-Handling ----

  Future<void> _handleAnswer({required bool correct}) async {
    final mode = ref.read(levelSelectionProvider);

        // Progress-Update basierend auf Modus
        if (mode == LevelSelectionMode.single) {
          // Single-Modus: Server-Session updaten
          try {
            final st = ref.read(singleStageProvider);     // 1..5
            final catId = _currentCatId;                  // wie bei Seed

            // Aktuelles Wort aus wordQueue und index ableiten
            final currentWord = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
                ? state.wordQueue[state.index]
                : null;

            if (currentWord == null) return; // Kein aktuelles Wort verfügbar

            // 1) in Session-Bucket verschieben
            await singleMove(catId, st, currentWord.id, correct);

            // 2) nächste Karte aus SRC holen
            final nextId = await singleNextWordId(catId, st);

            // Falls es eine nächste Karte gibt -> IDs & Queue aktualisieren
            final ids = List<String>.from(state.shuffledWordIds);
            final i = state.index;

            if (nextId != null) {
              // IDs auf die nächste Karte setzen
              if (i < ids.length) {
                ids[i] = nextId;
              } else {
                ids.add(nextId);
              }
              // Wortobjekt nachladen (für CardArea)
              final next = await fetchWordById(nextId);
              if (next != null) {
                final q = List<WordUserView>.from(state.wordQueue);
                if (i < q.length) {
                  q[i] = next;
                } else {
                  q.add(next);
                }
                _set(wordQueue: q, shuffledWordIds: ids);
              } else {
                _set(shuffledWordIds: ids);
              }
            } else {
              // keine SRC-Karte mehr -> aktuelle ID entfernen
              if (i < ids.length) {
                ids.removeAt(i);
              }
              final newIdx = ids.isEmpty ? 0 : (i % ids.length);
              _set(shuffledWordIds: ids, index: newIdx);
            }

            // 3) Zähler aktualisieren (S{n}, SR1, SR2)
            final c = await singleCounts(catId, st);
            ref.read(singleSessionCountsProvider.notifier).state =
                SingleSessionCounts(c.$1, c.$2, c.$3);
          } catch (e) {
            print('❌ Single session move failed: $e');
          }
          return; // ✅ KEIN normales SRS-Update ausführen
        }

    if (mode == LevelSelectionMode.s1toS5) {
      // S1-S5: nur in 1..5 bewegen; niemals 0
      final queue = state.wordQueue;
      final ids = state.shuffledWordIds;
      if (queue.isEmpty || ids.isEmpty) return;

      final i = state.index;
      if (i >= ids.length) return;

      final currentId = ids[i];
      final current = queue.firstWhere((w) => w.id == currentId, orElse: () => queue.first);

      final oldStage = current.srsStage;
      final delta = correct ? 1 : -1;
      final newStage = (oldStage + delta).clamp(1, 5); // Niemals unter 1

      // Lokale Stage-Update
      final stages = [...state.stages];
      if (oldStage >= 1 && oldStage < stages.length) {
        stages[oldStage] = (stages[oldStage] - 1).clamp(0, 1 << 30);
      }
      if (newStage >= 1 && newStage < stages.length) {
        stages[newStage] = stages[newStage] + 1;
      }
      _set(stages: stages);

      // Server-Update
      try {
        final result = await submitReview(currentId, correct);
        final serverStage = result.$1;
        final serverDue = result.$2;

        // Server-Response verwenden
        final q = List<WordUserView>.from(state.wordQueue);
        final pos = q.indexWhere((w) => w.id == currentId);
        if (pos != -1) {
          q[pos] = q[pos].copyWith(srsStage: serverStage, nextDueAt: serverDue);
          _set(wordQueue: q);
        }

        // Stages mit Server-Response synchronisieren
        if (serverStage != newStage) {
          final updatedStages = [...state.stages];
          if (newStage >= 1 && newStage < updatedStages.length) {
            updatedStages[newStage] = (updatedStages[newStage] - 1).clamp(0, 1 << 30);
          }
          if (serverStage >= 1 && serverStage < updatedStages.length) {
            updatedStages[serverStage] = updatedStages[serverStage] + 1;
          }
          _set(stages: updatedStages);
        }
      } catch (e) {
        print('❌ Review submission failed: $e');
      }

      // Nächste Karte
      final nextIndex = (i + 1) % ids.length;
      _set(index: nextIndex);

      return;
    }

    // S0-S5: normale Logik (inkl. 0 ↔ 1 Übergänge)

    final queue = state.wordQueue;
    final ids   = state.shuffledWordIds;
    if (queue.isEmpty || ids.isEmpty) return;

    final i = state.index;
    if (i >= ids.length) return;

    // 🔑 1) Aktuelle Karte über shuffled IDs auflösen (statt queue[i])
    final currentId = ids[i];
    final current = queue.firstWhere((w) => w.id == currentId, orElse: () => queue.first);

    // Debug-Log für Karten-Bewertung
    final nowUtc = DateTime.now().toUtc();
    final isDueNow = current.nextDueAt != null && !current.nextDueAt!.isAfter(nowUtc);
    print('🎯 Bewerte Karte: ${current.text} (Stage: ${current.srsStage}, Due: $isDueNow) - $correct');

    // 1) Timer-Status merken (nicht stoppen!)
    final wasActive = state.timerActive;
    final wasPaused = state.timerPaused;
    final wasRunning = state.running;

    // 2) Stage lokal hoch/runter schätzen (nur für Stufen-Zähler)
    int oldStage = current.srsStage;
    int newStage = oldStage;
    if (correct) {
      newStage = (newStage < 5) ? newStage + 1 : 5;
    } else {
      newStage = (newStage > 0) ? newStage - 1 : 0;
    }

    // 3) Fortschritt updaten (lokal)
    final stages = [...state.stages];
    if (oldStage >= 0 && oldStage < stages.length) {
      stages[oldStage] = (stages[oldStage] - 1).clamp(0, 1 << 30);
    }
    if (newStage >= 0 && newStage < stages.length) {
      stages[newStage] = stages[newStage] + 1;
    }
    _set(stages: stages);

    // 4) Review an Backend schicken und Server-Response verwenden
    int serverStage = newStage; // Fallback auf lokale Schätzung
    DateTime? serverDue;
    try {
      final result = await submitReview(currentId, correct);
      serverStage = result.$1;
      serverDue = result.$2;
      print('🗂 Server says: word=$currentId -> stage=$serverStage, due=$serverDue (old=$oldStage, correct=$correct)');

      // aktuelles Word-Objekt im Cache updaten
      final q = List<WordUserView>.from(state.wordQueue);
      final pos = q.indexWhere((w) => w.id == currentId);
      if (pos != -1) {
        q[pos] = q[pos].copyWith(srsStage: serverStage, nextDueAt: serverDue);
        _set(wordQueue: q);
      }

      // Stages mit Server-Response synchronisieren (falls abweichend)
      if (serverStage != newStage) {
        final updatedStages = [...state.stages];
        // Alte lokale Schätzung rückgängig machen
        if (newStage >= 0 && newStage < updatedStages.length) {
          updatedStages[newStage] = (updatedStages[newStage] - 1).clamp(0, 1 << 30);
        }
        // Server-Stage hinzufügen
        if (serverStage >= 0 && serverStage < updatedStages.length) {
          updatedStages[serverStage] = updatedStages[serverStage] + 1;
        }
        _set(stages: updatedStages);
        print('🔄 Stages korrigiert: lokale Schätzung $newStage -> Server $serverStage');
      }

      final allowedMaxStage = _computeAllowedMaxStageFromQueue(state.wordQueue);
      final now = DateTime.now();
      final isNowDue = serverDue != null && !serverDue.isAfter(now);

      // ⛔️ Entfernen, wenn:
      // 1) Gate überschritten (z.B. S2 bei allowed=1)
      // 2) oder S1+ und nicht (mehr) fällig – ABER NICHT, wenn es gerade S0→S1 wurde (Echo bleibt)
      final bool justLearnedToS1 = (oldStage == 0 && serverStage == 1);

      final shouldRemoveFromSession =
          (serverStage > allowedMaxStage) ||
          ((serverStage >= 1) && !isNowDue && !justLearnedToS1);

      if (shouldRemoveFromSession) {
        final newIds = List<String>.from(state.shuffledWordIds);
        final pos = newIds.indexOf(currentId);
        if (pos != -1) {
          newIds.removeAt(pos);
          var nextIndex = state.index;
          if (pos <= state.index && nextIndex > 0) nextIndex -= 1;
          _set(shuffledWordIds: newIds, index: newIds.isEmpty ? 0 : nextIndex);
          print('🗑️ Karte entfernt: $currentId (Stage: $serverStage, allowed: $allowedMaxStage, due: $isNowDue)');
        }
      }

      // Echo nur, wenn es wirklich S0→S1 war:
      if (correct && justLearnedToS1) {
        _scheduleImmediateReinforce(currentId, after: 10);
        _startCooldownForS0(currentId, minOthers: 8);
      }

      // (optional) auch für S1 bei korrekt einmaliges „Echo":
      if (correct && oldStage == 1) {
        _scheduleImmediateReinforce(currentId, after: 14);
      }
    } catch (e) {
      // optional loggen
      print('❌ Review submission failed: $e');
    }

    // 5) Nächste Karte
    final nextIndex = (i + 1) % ids.length;

    // 6) recentlySwiped aktualisieren
    final newSwiped = [...state.recentlySwiped, currentId];
    if (newSwiped.length > 50) newSwiped.removeAt(0);

    _set(
      index: nextIndex,
      recentlySwiped: newSwiped,
      cardsSwipedInSession: state.cardsSwipedInSession + 1,
    );

    // 7) ggf. neu mischen, wenn am Ende
    if (nextIndex == 0) {
      // Config für Re-Shuffle berechnen
      final now = DateTime.now();
      final dueCount = queue.where((w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(now)).length;

      final stats = SrsStats(
        rollingAccuracy: _rollingAccuracy,
        avgSwipeMs: _avgSwipeMs,
        recentTimeouts: _recentTimeouts,
      );

      final cfg = computeSrsConfig(
        totalWordsInCategory: state.totalWordsInCategory,
        dueCount: dueCount,
        stats: stats,
      );

      final allowedMaxStage = _computeAllowedMaxStageFromQueue(queue);
      final shuffled = buildSmartCardOrder(queue, config: cfg, allowedMaxStage: allowedMaxStage);

      // Debug-Log für Re-Shuffle
      final reshufflePreview = shuffled.take(40).map((ix) => queue[ix]).toList();
      final reshuffleNewCount = reshufflePreview.where((w) => w.srsStage == 0).length;
      final reshuffleDueCount = reshufflePreview.where((w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(DateTime.now())).length;
      print('🔄 Re-Shuffle[40]: new=$reshuffleNewCount, due=$reshuffleDueCount, total=${reshufflePreview.length}');

      _set(shuffledWordIds: [for (final k in shuffled) queue[k].id]);
    }

    // 7b) Mini-Reshuffle nach dem „Burst" (z. B. nach 10 Swipes)
    final shouldMiniReshuffle = state.cardsSwipedInSession == 10 ||
                                (state.cardsSwipedInSession > 10 &&
                                 state.cardsSwipedInSession % 8 == 0); // danach regelmäßig

    if (shouldMiniReshuffle) {
      final now = DateTime.now();
      final dueCount = state.wordQueue.where((w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(now)).length;

      final cfg = computeSrsConfig(
        totalWordsInCategory: state.totalWordsInCategory,
        dueCount: dueCount,
        stats: SrsStats(
          rollingAccuracy: _rollingAccuracy,
          avgSwipeMs: _avgSwipeMs,
          recentTimeouts: _recentTimeouts,
        ),
      );

      final allowedMaxStage = _computeAllowedMaxStageFromQueue(state.wordQueue);
      final newOrderIdx = buildSmartCardOrder(state.wordQueue, config: cfg, allowedMaxStage: allowedMaxStage);
      final newIds = [for (final i in newOrderIdx) state.wordQueue[i].id];

      // Index auf gleiche Karte (per id) abbilden, damit kein Sprung sichtbar ist
      final currentId = state.shuffledWordIds[state.index];
      final newIndex = newIds.indexOf(currentId);
      _set(shuffledWordIds: newIds, index: newIndex >= 0 ? newIndex : 0);

      print('🔄 Mini-Reshuffle nach ${state.cardsSwipedInSession} Swipes');
    }

    // 8) Timer-Verhalten wie gewünscht:
    //    - Wenn der Timer zuvor aktiv war:
    //        * Wenn pausiert: nur Restzeit für neue Karte setzen, PAUSE bleibt.
    //        * Wenn laufend: Restzeit resetten und weiterlaufen.
    //    - Wenn Timer zuvor NICHT aktiv war: NICHT starten.
    _restartCountdownPreservingState(
      wasActive: wasActive,
      wasPaused: wasPaused,
      wasRunning: wasRunning,
    );

    // 9) S0 Cooldown und Advance Logic
    if (correct) {
      // Richtig: normal weiter
      _tickCooldowns();
      _advanceToNextEligible(avoidId: currentId);
    } else {
      // Falsch: aktuelle Karte hinten re-queuen, S0 bekommt Cooldown
      final oldIndex = state.shuffledWordIds.indexOf(currentId);
      if (oldIndex != -1) {
        final newShuffled = List<String>.from(state.shuffledWordIds);
        newShuffled.removeAt(oldIndex);
        newShuffled.add(currentId);
        _set(shuffledWordIds: newShuffled);
      }

      // Nur bei S0 Cooldown starten
      _startCooldownIfNeeded(currentId);

      // Index auf aktuelle Position clampen
      final newIndex = state.index % state.shuffledWordIds.length;
      _set(index: newIndex);

      // Eine "andere Karte" wird als nächstes gezeigt → Cooldowns ticken schon JETZT
      _tickCooldowns();

      // Wähle die nächste Karte, die nicht im Cooldown ist
      _advanceToNextEligible(avoidId: currentId);
    }

    // 10) lokalen Fortschritt speichern
    await _persistStageData();

    // 11) Stage-Transition Event feuern
    print('🎯 EMIT StageEvent cat=${state.categoryId} word=$currentId from=$oldStage to=$serverStage due=$isDueNow');
    StageTransitionEvent.emit(StageTransitionEvent(
      categoryId: state.categoryId,
      wordId: currentId,
      fromStage: oldStage,
      toStage: serverStage,
      wasDueBefore: isDueNow,
    ));

  }

  // ---- Timer ----

  /// Startet den Timer explizit (Play-Button).
  /// - forceActive: true => setzt timerActive/running = true
  void _startWordTimer({bool forceActive = false}) {
    _wordTimer?.cancel();

    final shouldBeActive = forceActive || state.timerActive;
    final keepPaused = state.timerPaused && !forceActive;

    _set(
      remainingMillis: state.timeLimit * 1000.0,
      timerPaused: keepPaused,
      timerActive: shouldBeActive,
      running: keepPaused ? false : true,
    );

    // Nur ticken, wenn nicht pausiert UND aktiv
    if (!keepPaused && shouldBeActive) {
      const tick = Duration(milliseconds: 16);
      _wordTimer = Timer.periodic(tick, (t) {
        if (state.timerPaused) return;

        final left = state.remainingMillis - 16;
        if (left <= 0) {
          t.cancel();
          HapticFeedback.mediumImpact();
          // Zeit abgelaufen -> als falsch werten
          _handleAnswer(correct: false);
        } else {
          _set(remainingMillis: left);
        }
      });
    }
  }

  /// Für den Kartenwechsel: nur die Restzeit auf neue Karte setzen.
  /// Startet den Ticker nur, wenn der Timer vorher aktiv UND nicht pausiert war.
  void _restartCountdownPreservingState({
    required bool wasActive,
    required bool wasPaused,
    required bool wasRunning,
  }) {
    _wordTimer?.cancel();

    if (!wasActive) {
      // Timer war nicht aktiv -> nur Remaining resetten, aber nicht aktivieren
      _set(
        remainingMillis: state.timeLimit * 1000.0,
        timerActive: false,
        timerPaused: false,
        running: false,
      );
      return;
    }

    // Timer war aktiv -> Restzeit auf neue Karte setzen
    _set(
      remainingMillis: state.timeLimit * 1000.0,
      timerActive: true,
      timerPaused: wasPaused,
      running: wasPaused ? false : wasRunning,
    );

    // Nur tick starten, wenn NICHT pausiert
    if (!wasPaused && wasRunning) {
    const tick = Duration(milliseconds: 16);
    _wordTimer = Timer.periodic(tick, (t) {
      if (state.timerPaused) return;
      final left = state.remainingMillis - 16;
      if (left <= 0) {
        t.cancel();
        HapticFeedback.mediumImpact();
        _handleAnswer(correct: false);
      } else {
        _set(remainingMillis: left);
      }
    });
    }
  }

  void _stopTimer() {
    _wordTimer?.cancel();
    _set(
      timerActive: false,
      timerPaused: false,
      running: false,
      remainingMillis: state.timeLimit * 1000.0,
    );
  }

  // ---- S0 Cooldown Logic ----

  void _startCooldownIfNeeded(String wordId) {
    // Cooldown nur für S0
    final word = state.wordQueue.firstWhere((w) => w.id == wordId, orElse: () => state.wordQueue.first);
    final stage = word.srsStage;
    if (stage == 0) {
      final cur = _cooldown[wordId] ?? 0;
      _cooldown[wordId] = cur > 0 ? (cur > _s0MinOthers ? cur : _s0MinOthers) : _s0MinOthers;
    }
  }

  void _tickCooldowns() {
    if (_cooldown.isEmpty) return;
    final keys = List<String>.from(_cooldown.keys);
    for (final k in keys) {
      final next = (_cooldown[k] ?? 0) - 1;
      if (next <= 0) {
        _cooldown.remove(k);
      } else {
        _cooldown[k] = next;
      }
    }
  }

  /// Setzt _index auf die nächste Karte, die nicht im Cooldown ist.
  /// avoidId: die eben geswipte Karte soll nicht sofort wieder kommen.
  void _advanceToNextEligible({String? avoidId}) {
    final len = state.shuffledWordIds.length;
    if (len == 0) {
      _set(index: 0);
      return;
    }
    int currentIndex = state.index % len; // Sicherheit

    int tries = 0;
    while (tries < len) {
      final candidateId = state.shuffledWordIds[currentIndex];
      final blocked = (_cooldown[candidateId] ?? 0) > 0 || (avoidId != null && candidateId == avoidId);
      if (!blocked) break;
      currentIndex = (currentIndex + 1) % len;
      tries++;
    }

    _set(index: currentIndex);
  }

  void _scheduleImmediateReinforce(String wordId, {int after = 8}) {
    final ids = List<String>.from(state.shuffledWordIds);
    final curPos = ids.indexOf(wordId);
    if (curPos == -1 || ids.isEmpty) return;

    // Karte an Position „index + after" verschieben (wrap-around)
    ids.removeAt(curPos);
    final insertAt = ((state.index + after) % (ids.length + 1)).clamp(0, ids.length);
    ids.insert(insertAt, wordId);

    _set(shuffledWordIds: ids);
  }

  /// Für S0-Karten auch bei KORREKT einen Cooldown zählen,
  /// damit sie NICHT sofort wieder direkt nebenan auftauchen.
  void _startCooldownForS0(String wordId, {int minOthers = 8}) {
    final cur = _cooldown[wordId] ?? 0;
    _cooldown[wordId] = (cur > 0) ? (cur > minOthers ? cur : minOthers) : minOthers;
  }

  int _computeAllowedMaxStageFromQueue(List<WordUserView> queue) {
    // Zähle Stufen in der aktuell aktiven Menge (kannst auch _capActivePool-Spiegel nutzen)
    int s1 = 0, s2 = 0, s3 = 0, s4 = 0;
    for (final w in queue) {
      switch (w.srsStage) {
        case 1: s1++; break;
        case 2: s2++; break;
        case 3: s3++; break;
        case 4: s4++; break;
      }
    }

    // Gate-Stufen NUR anhand der real verfügbaren Karten in der Queue öffnen
    if (s1 < 12) return 1;  // erst S1 aufbauen
    if (s2 < 20) return 2;  // dann S2
    if (s3 < 25) return 3;  // dann S3
    if (s4 < 30) return 4;  // dann S4
    return 5;
  }

  // ---- Helpers ----

  int _findInitialIndex(List<CategoryInfo> cats) {
    if (state.categoryId.isNotEmpty) {
      final i = cats.indexWhere((c) => c.id == state.categoryId);
      if (i >= 0) return i;
    }
    final i = cats.indexWhere((c) => c.name == state.title);
    return i >= 0 ? i : 0;
  }

  void _resetCardBasedSystem() {
    _set(
      recentlySwiped: const <String>[],
      cardsSwipedInSession: 0,
      hasLoadedReviews: false,
    );
  }

  Future<void> _performReset() async {
    // === Im Reset-Handler EINSETZEN (bestehende lokale-only-Resets ersetzen) ===
    final sb = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();
    final catId = state.categoryId; // oder deine aktuelle Category-ID

    try {
      // 1) Server-Reset
      await sb.rpc('fn_reset_user_category', params: {'p_category_id': catId});

      // 2) Sofort für LearnMode wieder befüllen (volle S0)
      await sb.rpc('fn_seed_user_category', params: {'p_category_id': catId});

      // 3) Category-Ansicht soll 0 zeigen → just_reset setzen
      await prefs.setString('learn_stages_$catId', '0,0,0,0,0,0');
      await prefs.setInt('today_new_$catId', 0);
      await prefs.setInt('today_repeats_$catId', 0);
      await prefs.setBool('just_reset_$catId', true);

      // 4) Event feuern (damit Category neu lädt – sie zeigt 0 dank Marker)
      ResetEvent.notifyReset(catId);

      // 5) Laufende Session/Queues leeren
      _cooldown.clear();
      _wordTimer?.cancel();
      _set(
        wordQueue: const [],
        shuffledWordIds: const [],
        index: 0,
        recentlySwiped: const [],
        cardsSwipedInSession: 0,
      );

      // 6) LearnMode danach NICHT aus den lokalen Prefs lesen, sondern Backend neu laden
      final prog = await fetchCategoryProgress(catId);   // <- zieht S0 voll vom Server
      _set(stages: prog.stages); // <- nutze hier prog.stages (NICHT localStages)

      // 7) Frisch laden
      await _loadWords();

    } catch (e) {
      // optional: SnackBar/Log
      print('⚠️ Reset failed: $e');
    }
  }

  // ---- State setter (einheitlich) ----
  void _set({
    String? categoryId,
    String? title,

    bool? loading,
    List<CategoryInfo>? categories,
    int? selectedCategoryIndex,

    List<int>? stages,
    int? totalWordsInCategory,

    List<WordUserView>? wordQueue,
    List<String>? shuffledWordIds,
    int? index,

    bool? showTranslation,

    // timer
    bool? running,
    bool? timerActive,
    bool? timerPaused,
    double? remainingMillis,

    // reviews
    List<String>? recentlySwiped,
    int? cardsSwipedInSession,
    bool? hasLoadedReviews,
  }) {
    state = state.copyWith(
      categoryId: categoryId,
      title: title,

      loading: loading,
      categories: categories,
      selectedCategoryIndex: selectedCategoryIndex,

      stages: stages,
      totalWordsInCategory: totalWordsInCategory,

      wordQueue: wordQueue,
      shuffledWordIds: shuffledWordIds,
      index: index,

      showTranslation: showTranslation,

      running: running,
      timerActive: timerActive,
      timerPaused: timerPaused,
      remainingMillis: remainingMillis,

      recentlySwiped: recentlySwiped,
      cardsSwipedInSession: cardsSwipedInSession,
      hasLoadedReviews: hasLoadedReviews,
    );
  }
}

```

---

### `lib/features/words/application/learning_engine_provider.dart`

**Typ:** Dart  
**Zeilen:** 7

**Vollständiger Code:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Zwei Engines: Zeitbasiert (Ebbinghaus) vs. Adaptiv (lernbasiert)
enum LearningEngine { timeSRS, adaptiveSRS }

final learningEngineProvider =
    StateProvider<LearningEngine>((_) => LearningEngine.timeSRS);

```

---

### `lib/features/words/application/level_selection_controller.dart`

**Typ:** Dart  
**Zeilen:** 27

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/ui/widgets/single_stage_picker.dart';

class LevelSelectionController {
  static Future<void> handleModeChange(
    BuildContext context,
    WidgetRef ref,
    LevelSelectionMode mode,
  ) async {
    ref.read(levelSelectionProvider.notifier).state = mode;

    if (mode == LevelSelectionMode.single) {
      final picked = await showModalBottomSheet<int>(
        context: context,
        backgroundColor: const Color(0xFF1E1E1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        builder: (_) => const SingleStagePicker(),
      );
      if (picked != null) {
        ref.read(singleStageProvider.notifier).state = picked;
      }
    }
  }
}

```

---

### `lib/features/words/application/level_selection_provider.dart`

**Typ:** Dart  
**Zeilen:** 43

**Vollständiger Code:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';

final levelSelectionProvider =
    StateProvider<LevelSelectionMode>((ref) => LevelSelectionMode.s0toS5);

// Single-Zielstufe 1..5
final singleStageProvider = StateProvider<int>((ref) => 1);

// NEU: Auswahl läuft (bis Nutzer eine Stufe tippt)
final selectingSingleProvider = StateProvider<bool>((ref) => false);

// Session-Buckets für Single-Modus (nur Learn-Modus)
class SingleSessionBuckets {
  int src; // S{n}
  int sx;  // virtuell
  int sy;  // virtuell
  SingleSessionBuckets({required this.src, this.sx = 0, this.sy = 0});
}

final singleSessionBucketsProvider = StateProvider<SingleSessionBuckets>((ref) => SingleSessionBuckets(src: 0));

// State für die drei Zähler (nur Learn-Mode)
class SingleSessionCounts {
  final int src, sr1, sr2;
  const SingleSessionCounts(this.src, this.sr1, this.sr2);
}

final singleSessionCountsProvider = StateProvider<SingleSessionCounts>((_) => const SingleSessionCounts(0, 0, 0));

// Sicht/Filter der Stufen aus Modus ableiten
final allowedStagesProvider = Provider<Set<int>>((ref) {
  final mode = ref.watch(levelSelectionProvider);
  switch (mode) {
    case LevelSelectionMode.s0toS5:
      return {0,1,2,3,4,5};
    case LevelSelectionMode.s1toS5:
      return {1,2,3,4,5};           // ← KEIN 0!
    case LevelSelectionMode.single:
      final st = ref.watch(singleStageProvider);
      return {st.clamp(1,5)};       // genau eine Stufe
  }
});

```

---

### `lib/features/words/application/s0_lock_provider.dart`

**Typ:** Dart  
**Zeilen:** 4

**Vollständiger Code:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// true = S0 gesperrt (keine neuen Karten ausgeben)
final s0LockedProvider = StateProvider<bool>((ref) => false);

```

---

### `lib/features/words/application/srs_config.dart`

**Typ:** Dart  
**Zeilen:** 95

**Vollständiger Code:**

```dart
// lib/features/words/application/srs_config.dart
class SrsStats {
  final double rollingAccuracy; // 0..1
  final double avgSwipeMs;      // Durchschnittliche Antwortzeit in ms (letzte N)
  final int recentTimeouts;     // letzte N
  const SrsStats({
    required this.rollingAccuracy,
    required this.avgSwipeMs,
    required this.recentTimeouts,
  });
}

class SrsPhase {
  final int length;        // wie viele Karten für diese Phase "steuern"
  final double reviewRatio; // 0..1
  const SrsPhase({required this.length, required this.reviewRatio});
}

class SrsConfig {
  final int initialNewBurst;
  final int headSize;
  final List<int> stageWeights;   // S0..S5
  final List<SrsPhase> phases;    // Ratio-Phasen nach dem Burst
  final int activePoolCap;        // wie viele Karten maximal gleichzeitig im Umlauf

  const SrsConfig({
    required this.initialNewBurst,
    required this.headSize,
    required this.stageWeights,
    required this.phases,
    required this.activePoolCap,
  });
}

/// Rechnet eine sinnvolle Konfiguration aus:
/// - totalWordsInCategory: 159..1379 etc.
/// - dueCount: aktuell fällige Anzahl
/// - stats: Leistung + Tempo
SrsConfig computeSrsConfig({
  required int totalWordsInCategory,
  required int dueCount,
  required SrsStats stats,
}) {
  // 1) Initialer Burst skaliert moderat mit Kategoriegröße
  final burst = _clampInt(
    (0.018 * totalWordsInCategory).round(),
    8, 14,
  ); // ~2% der Kategorie, min 8, max 14

  // 2) Kopfgröße (wie viele wir "steuern")
  final head = _clampInt(
    (totalWordsInCategory < 400) ? 120 : 180,
    90, 220,
  );

  // 3) Grund-Ratios
  double r1 = 0.70, r2 = 0.80, r3 = 0.90;

  // 4) Adaptieren anhand Accuracy
  if (stats.rollingAccuracy < 0.75) { r1 += 0.10; r2 += 0.05; r3 += 0.00; }
  if (stats.rollingAccuracy > 0.90) { r1 -= 0.05; r2 -= 0.05; r3 -= 0.05; }

  // 5) Adaptieren anhand Tempo / Timeouts
  if (stats.avgSwipeMs > 5000 || stats.recentTimeouts > 2) {
    r1 = (r1 + 0.10).clamp(0.6, 0.95);
    r2 = (r2 + 0.05).clamp(0.6, 0.95);
    // r3 belassen – Endphase bleibt review-lastig
  } else if (stats.avgSwipeMs < 2000) {
    r1 = (r1 - 0.05).clamp(0.6, 0.95);
  }

  // 6) Phasenlängen abhängig von vorhandenen "due"s (wenn viele fällig → schneller in hohe Review-Ratio)
  final p1Len = (dueCount > 50) ? 30 : 40;
  final p2Len = (dueCount > 100) ? 70 : 60;

  // 7) Stage-Gewichte (S0..S5) – S2/S3 leicht priorisieren
  final weights = <int>[1, 3, 4, 4, 2, 1];

  // 8) Active-Pool-Cap – wie viele Karten gleichzeitig im Umlauf:
  final cap = (totalWordsInCategory < 400) ? 80 : 120;

  return SrsConfig(
    initialNewBurst: burst,
    headSize: head,
    stageWeights: weights,
    phases: [
      SrsPhase(length: p1Len, reviewRatio: r1),
      SrsPhase(length: p2Len, reviewRatio: r2),
      const SrsPhase(length: 99999, reviewRatio: 0.90), // Rest der Session
    ],
    activePoolCap: cap,
  );
}

int _clampInt(int v, int min, int max) => v < min ? min : (v > max ? max : v);

```

---

### `lib/features/words/application/srs_logic.dart`

**Typ:** Dart  
**Zeilen:** 188

**Vollständiger Code:**

```dart
// lib/features/words/application/srs_logic.dart
import 'dart:math';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/srs_config.dart';

List<int> buildSmartCardOrder(
  List<WordUserView> queue, {
  SrsConfig? config,
  int allowedMaxStage = 1, // default = nur S0/S1
}) {
  final now = DateTime.now();
  if (queue.isEmpty) return const [];

  // Fallback-Config
  final cfg = config ??
      const SrsConfig(
        initialNewBurst: 10,
        headSize: 150,
        stageWeights: [1, 3, 4, 4, 2, 1],
        phases: [
          SrsPhase(length: 40, reviewRatio: 0.70),
          SrsPhase(length: 60, reviewRatio: 0.80),
          SrsPhase(length: 99999, reviewRatio: 0.90),
        ],
        activePoolCap: 120,
      );

  // --- (optional) aktiven Pool begrenzen -----------------------------
  final pool = _capActivePool(queue, cfg.activePoolCap, now);

  // --- Buckets -------------------------------------------------------
  final dueByStage  = List.generate(6, (_) => <int>[]);
  final waitByStage = List.generate(6, (_) => <int>[]);
  final rest        = <int>[];
  final forbidden   = <int>[]; // Karten mit st > allowedMaxStage

  bool isDue(WordUserView w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(now);

  for (var i = 0; i < pool.length; i++) {
    final w  = pool[i];
    final st = w.srsStage.clamp(0, 5);
    final due = isDue(w);

    if (st > allowedMaxStage) {
      forbidden.add(i);
      continue;
    }
    (due ? dueByStage[st] : waitByStage[st]).add(i);
  }

  void shuffleAll() {
    for (var s = 0; s < 6; s++) {
      dueByStage[s].shuffle();
      waitByStage[s].shuffle();
    }
    rest.shuffle();
  }
  shuffleAll();

  int? pullAnyDue() {
    for (var s = allowedMaxStage; s >= 0; s--) {
      if (dueByStage[s].isNotEmpty) return dueByStage[s].removeLast();
    }
    return null;
  }

  int? pullReview() {
    for (var s = allowedMaxStage; s >= 1; s--) {
      if (dueByStage[s].isNotEmpty) return dueByStage[s].removeLast();
    }
    if (dueByStage[0].isNotEmpty) return dueByStage[0].removeLast();
    // gewichtete wait-Reviews (nur bis allowedMaxStage)
    final weighted = <int>[];
    for (var s = 1; s <= allowedMaxStage; s++) {
      if (waitByStage[s].isEmpty) continue;
      for (var k = 0; k < cfg.stageWeights[s]; k++) {
        weighted.add(s);
      }
    }
    if (weighted.isEmpty) return null;
    final s = weighted[Random().nextInt(weighted.length)];
    return waitByStage[s].removeLast();
  }

  int? pullNew() => waitByStage[0].isNotEmpty ? waitByStage[0].removeLast() : null;

  // --- Head ----------------------------------------------------------
  final head = <int>[];

  // Debug-Log für Gate-Logik
  print('🚪 SRS Logic: allowedMaxStage=$allowedMaxStage, forbidden=${forbidden.length}');

  // kleine due-Vorstreuung
  while (head.length < min(12, cfg.headSize)) {
    final d = pullAnyDue();
    if (d == null) break;
    head.add(d);
  }

  // initialer Burst (Neue)
  while (head.length < cfg.headSize &&
      head.where((i) => pool[i].srsStage == 0 && !isDue(pool[i])).length < cfg.initialNewBurst) {
    final d = pullAnyDue();
    if (d != null) { head.add(d); continue; }
    final n = pullNew();
    if (n == null) break;
    head.add(n);
  }

  // Phasen (Ratios)
  int produced = 0;
  for (final p in cfg.phases) {
    final target = min(cfg.headSize, head.length + p.length);
    while (head.length < target) {
      final d = pullAnyDue();
      if (d != null) { head.add(d); continue; }

      // Verhältnis prüfen
      final revCount = head.where((ix) {
        final w = pool[ix];
        final isNewWait = (w.srsStage == 0) && !isDue(w);
        return !isNewWait;
      }).length;
      final newCount = head.length - revCount;
      final currentRatio = revCount / max(1, revCount + newCount);

      int? pick;
      if (currentRatio < p.reviewRatio) {
        pick = pullReview() ?? pullNew();
      } else {
        pick = pullNew() ?? pullReview();
      }
      if (pick == null) break;
      head.add(pick);
      produced++;
      if (head.length >= cfg.headSize) break;
    }
    if (head.length >= cfg.headSize) break;
  }

  // Tail NUR aus erlaubten Buckets, dann erst Verbotene anhängen:
  final tail = <int>[];
  for (var s = allowedMaxStage; s >= 0; s--) {
    tail.addAll(dueByStage[s]);
  }
  for (var s = allowedMaxStage; s >= 0; s--) {
    tail.addAll(waitByStage[s]);
  }
  tail.addAll(rest);
  tail.addAll(forbidden); // ganz hinten
  tail.shuffle();

  // Indizes wieder auf Original-queue beziehen:
  // `pool` ist ggf. beschnitten – wir müssen auf die Original-Indizes abbilden.
  final poolToOriginal = <int, int>{};
  for (var i = 0; i < pool.length; i++) {
    poolToOriginal[i] = queue.indexWhere((w) => w.id == pool[i].id);
  }

  List<int> mapBack(List<int> arr) => [
        for (final i in arr)
          poolToOriginal[i] ?? i // fallback (sollte nicht passieren)
      ];

  return <int>[...mapBack(head), ...mapBack(tail)];
}

// Beschneidet die aktive Menge auf `cap` Karten: due zuerst, dann restl. Mischung
List<WordUserView> _capActivePool(List<WordUserView> queue, int cap, DateTime now) {
  if (queue.length <= cap) return queue;

  final due = <WordUserView>[];
  final wait = <WordUserView>[];

  bool isDue(WordUserView w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(now);
  for (final w in queue) {
    (isDue(w) ? due : wait).add(w);
  }
  due.shuffle();
  wait.shuffle();

  final take = <WordUserView>[];
  take.addAll(due.take(cap));
  if (take.length < cap) {
    take.addAll(wait.take(cap - take.length));
  }
  return take;
}

```

---

### `lib/features/words/application/srs_mode_controller.dart`

**Typ:** Dart  
**Zeilen:** 128

**Vollständiger Code:**

```dart
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Öffentliche API
enum SrsSystem { time, adaptive, hybrid }

class SrsModeState {
  final SrsSystem mode;
  final SrsSystem lastNonHybrid;
  final bool counting;   // läuft der Countdown?
  final int count;       // 3..1 (0 = aus)

  const SrsModeState({
    required this.mode,
    required this.lastNonHybrid,
    required this.counting,
    required this.count,
  });

  SrsModeState copyWith({
    SrsSystem? mode,
    SrsSystem? lastNonHybrid,
    bool? counting,
    int? count,
  }) => SrsModeState(
        mode: mode ?? this.mode,
        lastNonHybrid: lastNonHybrid ?? this.lastNonHybrid,
        counting: counting ?? this.counting,
        count: count ?? this.count,
      );

  static const initial = SrsModeState(
    mode: SrsSystem.time,
    lastNonHybrid: SrsSystem.time,
    counting: false,
    count: 0,
  );
}

class SrsModeController extends StateNotifier<SrsModeState> {
  SrsModeController() : super(SrsModeState.initial);

  Timer? _timer;

  // UI ruft nur diese Methoden:

  void tap() {
    if (state.counting) return;
    if (state.mode == SrsSystem.hybrid) {
      // zurück in letzten Nicht-Hybrid
      state = state.copyWith(mode: state.lastNonHybrid);
      HapticFeedback.selectionClick();
    } else {
      toggleTimeAdaptive();
    }
  }

  void toggleTimeAdaptive() {
    if (state.counting) return;
    final next = (state.mode == SrsSystem.time)
        ? SrsSystem.adaptive
        : SrsSystem.time;
    state = state.copyWith(mode: next, lastNonHybrid: next);
    HapticFeedback.selectionClick();
  }

  void longPressStart() {
    if (state.counting || state.mode == SrsSystem.hybrid) return;
    _cancel();
    state = state.copyWith(counting: true, count: 2);
    HapticFeedback.lightImpact();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final c = state.count;
      if (c > 1) {
        state = state.copyWith(count: c - 1);
      } else {
        t.cancel();
        _timer = null;
        _toHybrid();
      }
    });
  }

  void longPressEnd() {
    // Abbruch vor 0
    if (state.counting) _cancel();
  }

  void _toHybrid() {
    state = state.copyWith(
      counting: false,
      count: 0,
      lastNonHybrid: state.mode,
      mode: SrsSystem.hybrid,
    );
    HapticFeedback.mediumImpact();
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(counting: false, count: 0);
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }
}

// Riverpod Provider
final srsModeControllerProvider =
    StateNotifierProvider<SrsModeController, SrsModeState>(
  (ref) => SrsModeController(),
);

// (Optional) abgeleitete Farbe pro Modus
final srsAccentColorProvider = Provider<Color>((ref) {
  switch (ref.watch(srsModeControllerProvider).mode) {
    case SrsSystem.time:    return const Color(0xFF6FD3FF);
    case SrsSystem.adaptive:return const Color(0xFF66FFA8);
    case SrsSystem.hybrid:  return const Color(0xFFE5B966);
  }
});

```

---

### `lib/features/words/application/timer_helpers.dart`

**Typ:** Dart  
**Zeilen:** 21

**Vollständiger Code:**

```dart
import 'dart:async';

class WordTimerHelper {
  static Timer? start({
    required Duration tick,
    required void Function() onExpire,
    required void Function(double newRemaining) onTick,
    required double initialMillis,
  }) {
    double remaining = initialMillis;
    return Timer.periodic(tick, (t) {
      remaining -= tick.inMilliseconds;
      if (remaining <= 0) {
        t.cancel();
        onExpire();
      } else {
        onTick(remaining);
      }
    });
  }
}

```

---

### `lib/features/words/application/word_list_controller.dart`

**Typ:** Dart  
**Zeilen:** 373

**Vollständiger Code:**

```dart
import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/features/words/domain/word.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';

part 'word_list_controller.g.dart';

class _CacheEntry {
  final WordListState state;
  final DateTime ts;
  _CacheEntry(this.state) : ts = DateTime.now();
  bool get fresh => DateTime.now().difference(ts) < const Duration(minutes: 5);
}

enum WordFilterKind { about, domain, pos, level, category, query }

@immutable
class WordListFilter {
  final WordFilterKind kind;
  final String value;
  const WordListFilter(this.kind, this.value);
}

enum SortMode { az, newest }

@immutable
class WordListState {
  final List<Word> words;
  final Set<String> picked;
  final bool isFirstLoad;
  final bool isLoadingMore;
  final bool hasMore;
  final int offset;
  final String query;
  final SortMode sort;
  final String? error; // NEU
  final bool offline; // NEU

  const WordListState({
    this.words = const [],
    this.picked = const {},
    this.isFirstLoad = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.offset = 0,
    this.query = '',
    this.sort = SortMode.az,
    this.error,
    this.offline = false, // NEU
  });

  WordListState copyWith({
    List<Word>? words,
    Set<String>? picked,
    bool? isFirstLoad,
    bool? isLoadingMore,
    bool? hasMore,
    int? offset,
    String? query,
    SortMode? sort,
    String? error,
    bool? offline, // NEU
  }) {
    return WordListState(
      words: words ?? this.words,
      picked: picked ?? this.picked,
      isFirstLoad: isFirstLoad ?? this.isFirstLoad,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      error: error,
      offline: offline ?? this.offline,
    );
  }
}

@riverpod
class WordListController extends _$WordListController {
  final _repo = SupabaseWordRepository();

  static final Map<String, _CacheEntry> _cache = {}; // key = provKey
  Timer? _debounce; // (hast du schon)
  StreamSubscription? _connSub;
  late String _provKey; // merken

  late WordListFilter _baseFilter;
  String? _overrideCategoryId;

  static const _pageSize = 50;

  // Family-Arg kommt hier rein:
  @override
  WordListState build(String provKey) {
    _provKey = provKey;
    final link = ref.keepAlive();
    ref.onDispose(() {
      _debounce?.cancel();
      _connSub?.cancel();
      link.close();
    });

    // Verbindung überwachen
    _connSub = Connectivity().onConnectivityChanged.listen((results) async {
      final online = !results.contains(ConnectivityResult.none);
      if (online && state.offline) {
        // Supabase einmal testen (Ping)
        try {
          await Supabase.instance.client.from('words').select('id').limit(1);
          // Wenn erfolgreich → neu laden
          await loadFirstPage(resetCache: true);
        } catch (_) {
          // bleibt offline
        }
      }
    });

    final hit = _cache[provKey];
    if (hit != null && hit.fresh) {
      return hit.state.copyWith(isFirstLoad: false); // sofort anzeigen
    }
    return const WordListState(); // kalt, lädt via init()
  }

  Future<void> init({
    required WordListFilter filter,
    String? overrideCategoryId,
  }) async {
    _baseFilter = filter;
    _overrideCategoryId = overrideCategoryId;

    // SWR: Zeig Snapshot, wenn vorhanden (kein Spinner)
    await _hydrateFromSnapshotIfAny();

    // Nur laden, wenn wirklich leer (oder explizit Refresh)
    if (state.words.isEmpty) {
      // unawaited: stilles Revalidate
      // ignore: discarded_futures
      loadFirstPage();
    }
  }

  WordListFilter _effectiveFilter() {
    final value = _overrideCategoryId ?? _baseFilter.value;
    return WordListFilter(_baseFilter.kind, value);
  }

  Future<void> _saveOfflineSnapshot(List<Word> words) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final data = words.map((w) => w.toJson()).toList();
      await sp.setString('wl_snapshot_$_provKey', jsonEncode(data));
    } catch (_) {/* silent */}
  }

  Future<List<Word>?> _loadOfflineSnapshot() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('wl_snapshot_$_provKey');
      if (raw == null) return null;
      final List list = jsonDecode(raw);
      return list.map<Word>((m) => Word.fromJson(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _hydrateFromSnapshotIfAny() async {
    final snap = await _loadOfflineSnapshot();
    if (snap != null && snap.isNotEmpty) {
      state = state.copyWith(
        words: snap,
        isFirstLoad: false,   // <- kein Spinner
        isLoadingMore: false,
        hasMore: false,       // korrigiert sich nach Netz-Load
        error: null,
        offline: false,
      );
      _cache[_provKey] = _CacheEntry(state);
    }
  }

  Future<void> loadFirstPage({bool resetCache = false}) async {
    if (resetCache) _cache.remove(_provKey);

    // Instant Render: Behalte vorhandene Wörter, nur Spinner wenn wirklich leer
    final hadWords = state.words.isNotEmpty;

    state = state.copyWith(
      isFirstLoad: !hadWords,   // Spinner nur, wenn wirklich leer
      isLoadingMore: false,
      // words NICHT leeren, wenn hadWords == true
      picked: <String>{},
      offset: 0,
      hasMore: true,
    );

    try {
      final batch = await _repo.fetchByFilter(
        _effectiveFilter(),
        limit: _pageSize,
        offset: 0,
        query: state.query.isEmpty ? null : state.query,
        sort: state.sort,
      );

      if (batch == null) {
        // 304 – nichts neu → State so lassen, nur Flags korrigieren
        state = state.copyWith(
          isFirstLoad: false,
          isLoadingMore: false,
          error: null,
          offline: false,
          // hasMore bleibt wie zuvor (optional: neu berechnen, wenn nötig)
        );
        _cache[_provKey] = _CacheEntry(state);
        await _saveOfflineSnapshot(state.words);
        return;
      }

      // Normaler 200-Pfad
      Set<String> pickedIds = {};
      if (batch.isNotEmpty) {
        pickedIds = await _repo.getPickedWordIds(batch.map((w) => w.id));
      }

      state = state.copyWith(
        words: [...batch],
        picked: {...pickedIds},
        offset: batch.length,
        hasMore: batch.length == _pageSize,
        isFirstLoad: false,
        isLoadingMore: false,
        error: null,
        offline: false,
      );
      _cache[_provKey] = _CacheEntry(state);
      await _saveOfflineSnapshot(state.words);
    } catch (e) {
      // Offline-Snapshot versuchen
      final snap = await _loadOfflineSnapshot();
      if (snap != null && snap.isNotEmpty) {
        state = state.copyWith(
          words: snap,
          isFirstLoad: false,
          isLoadingMore: false,
          hasMore: false,
          error: 'Offline – zeige zuletzt geladene Liste',
          offline: true, // NEU
        );
        _cache[_provKey] = _CacheEntry(state);
      } else {
        state = state.copyWith(
          isFirstLoad: false,
          isLoadingMore: false,
          error: e.toString(),
          offline: false,
        );
      }
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final batch = await _repo.fetchByFilter(
        _effectiveFilter(),
        limit: _pageSize,
        offset: state.offset,
        query: state.query.isEmpty ? null : state.query,
        sort: state.sort,
      );

      if (batch == null) {
        // 304 beim Pagination-Call ist ungewöhnlich, aber: nichts tun
        state = state.copyWith(isLoadingMore: false, error: null, offline: false);
        _cache[_provKey] = _CacheEntry(state);
        return;
      }

      Set<String> pickedIds = {};
      if (batch.isNotEmpty) {
        pickedIds = await _repo.getPickedWordIds(batch.map((w) => w.id));
      }

      state = state.copyWith(
        words: [...state.words, ...batch],
        picked: {...state.picked, ...pickedIds},
        offset: state.offset + batch.length,
        hasMore: batch.length == _pageSize,
        isLoadingMore: false,
        error: null,
        offline: false,
      );
      _cache[_provKey] = _CacheEntry(state);
      await _saveOfflineSnapshot(state.words);
    } catch (e) {
      state = state.copyWith(
        isFirstLoad: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void setQueryDebounced(String q, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounce?.cancel();
    _debounce = Timer(delay, () async {
      if (state.query != q) {
        state = state.copyWith(query: q);
      }
      await loadFirstPage(); // NEU: serverseitig neu laden
      _cache[_provKey] = _CacheEntry(state);
    });
  }

  // optional weiterhin verfügbar
  void setQuery(String q) => state = state.copyWith(query: q);

  void setSort(SortMode s) async {
    if (state.sort == s) return;
    state = state.copyWith(sort: s);
    await loadFirstPage(); // NEU: serverseitig neu laden
    _cache[_provKey] = _CacheEntry(state);
  }

  void setSortDebounced(SortMode s, {Duration d = const Duration(milliseconds: 150)}) {
    _debounce?.cancel();
    _debounce = Timer(d, () => setSort(s));
  }

  Future<String?> togglePick(BuildContext ctx, Word w) async {
    final wasPicked = state.picked.contains(w.id);

    // Optimistisch
    final newPicked = {...state.picked};
    if (wasPicked) {
      newPicked.remove(w.id);
    } else {
      newPicked.add(w.id);
    }
    state = state.copyWith(picked: newPicked);

    try {
      if (wasPicked) {
        await _repo.removeFromMyWords(w.id);
        return 'Entfernt: ${w.text}';
      } else {
        await _repo.addToMyWords(w.id);
        return 'Hinzugefügt: ${w.text}';
      }
    } catch (e) {
      // Rollback
      final rollback = {...state.picked};
      if (wasPicked) {
        rollback.add(w.id);
      } else {
        rollback.remove(w.id);
      }
      state = state.copyWith(picked: rollback);
      return 'Fehler: $e';
    }
  }
}
```

---

### `lib/features/words/application/word_list_controller.g.dart`

**Typ:** Dart  
**Zeilen:** 165

**Vollständiger Code:**

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wordListControllerHash() =>
    r'31f1c9f025e8ace6323cbfc9f62297e94e895350';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$WordListController
    extends BuildlessAutoDisposeNotifier<WordListState> {
  late final String provKey;

  WordListState build(String provKey);
}

/// See also [WordListController].
@ProviderFor(WordListController)
const wordListControllerProvider = WordListControllerFamily();

/// See also [WordListController].
class WordListControllerFamily extends Family<WordListState> {
  /// See also [WordListController].
  const WordListControllerFamily();

  /// See also [WordListController].
  WordListControllerProvider call(String provKey) {
    return WordListControllerProvider(provKey);
  }

  @override
  WordListControllerProvider getProviderOverride(
    covariant WordListControllerProvider provider,
  ) {
    return call(provider.provKey);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'wordListControllerProvider';
}

/// See also [WordListController].
class WordListControllerProvider
    extends AutoDisposeNotifierProviderImpl<WordListController, WordListState> {
  /// See also [WordListController].
  WordListControllerProvider(String provKey)
    : this._internal(
        () => WordListController()..provKey = provKey,
        from: wordListControllerProvider,
        name: r'wordListControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$wordListControllerHash,
        dependencies: WordListControllerFamily._dependencies,
        allTransitiveDependencies:
            WordListControllerFamily._allTransitiveDependencies,
        provKey: provKey,
      );

  WordListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.provKey,
  }) : super.internal();

  final String provKey;

  @override
  WordListState runNotifierBuild(covariant WordListController notifier) {
    return notifier.build(provKey);
  }

  @override
  Override overrideWith(WordListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: WordListControllerProvider._internal(
        () => create()..provKey = provKey,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        provKey: provKey,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<WordListController, WordListState>
  createElement() {
    return _WordListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WordListControllerProvider && other.provKey == provKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, provKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WordListControllerRef on AutoDisposeNotifierProviderRef<WordListState> {
  /// The parameter `provKey` of this provider.
  String get provKey;
}

class _WordListControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<WordListController, WordListState>
    with WordListControllerRef {
  _WordListControllerProviderElement(super.provider);

  @override
  String get provKey => (origin as WordListControllerProvider).provKey;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

```

---

### `lib/features/words/application/word_providers.dart`

**Typ:** Dart  
**Zeilen:** 259

**Vollständiger Code:**

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:talvori/features/words/data/mock_word_repository.dart';
import 'package:talvori/features/words/domain/word.dart';
import 'package:talvori/features/words/application/learn_mode_controller.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';

import 'package:talvori/features/words/data/supabase_word_repository.dart' show WordUserView;

final wordRepositoryProvider = Provider<MockWordRepository>((ref) {
  return MockWordRepository();
});

final recentWordsProvider = FutureProvider<List<Word>>((ref) async {
  return ref.read(wordRepositoryProvider).fetchRecentWords();
});

// ---- Learn Mode Selektoren ----

/// Aktuelles Wort basierend auf Index und Queue
final currentWordProvider = Provider<WordUserView?>((ref) {
  final s = ref.watch(learnModeControllerProvider);
  if (s.shuffledWordIds.isEmpty || s.index >= s.shuffledWordIds.length) return null;
  final id = s.shuffledWordIds[s.index];
  final w = s.wordQueue.where((e) => e.id == id);
  return w.isEmpty ? null : w.first;
});

/// Stages für die Switches
final stagesProvider = Provider<List<int>>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.stages));
});

/// Timer-Status (aktiv und läuft)
final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.timerActive && s.running));
});

/// Timer-Status (pausiert)
final isPausedProvider = Provider<bool>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.timerActive && s.timerPaused));
});

/// Verbleibende Zeit
final remainingTimeProvider = Provider<double>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.remainingMillis));
});

/// Karten in Session
final cardsSwipedProvider = Provider<int>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.cardsSwipedInSession));
});

/// Loading-Status
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.loading));
});

/// Kategorien
final categoriesProvider = Provider<List<CategoryInfo>>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.categories));
});

/// Ausgewählte Kategorie
final selectedCategoryProvider = Provider<CategoryInfo?>((ref) {
  final s = ref.watch(learnModeControllerProvider);
  if (s.selectedCategoryIndex < 0 || s.selectedCategoryIndex >= s.categories.length) return null;
  return s.categories[s.selectedCategoryIndex];
});

// ===== WordHub (Liste/Suche/Pagination) =====

// WICHTIG: eigener Name, kollidiert nicht mit MockWordRepository oben.
final supabaseWordRepositoryProvider = Provider<SupabaseWordRepository>((ref) {
  return SupabaseWordRepository();
});

class WordHubState extends Equatable {
  final bool loading;
  final List<Word> items;
  final String? query;
  final String? categorySlug;
  final bool canLoadMore;

  const WordHubState({
    this.loading = false,
    this.items = const [],
    this.query,
    this.categorySlug,
    this.canLoadMore = true,
  });

  WordHubState copyWith({
    bool? loading,
    List<Word>? items,
    String? query,
    String? categorySlug,
    bool? canLoadMore,
  }) => WordHubState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
        query: query ?? this.query,
        categorySlug: categorySlug ?? this.categorySlug,
        canLoadMore: canLoadMore ?? this.canLoadMore,
      );

  @override
  List<Object?> get props => [loading, items, query, categorySlug, canLoadMore];
}

class WordHubController extends Notifier<WordHubState> {
  static const _pageSize = 50;
  late final SupabaseWordRepository _repo;
  Timer? _debounce;

  @override
  WordHubState build() {
    _repo = ref.read(supabaseWordRepositoryProvider);
    ref.onDispose(() => _debounce?.cancel());
    return const WordHubState();
  }

  Future<void> init({String? categorySlug}) async {
    state = state.copyWith(loading: true, categorySlug: categorySlug);
    final data = await _repo.fetchRecentWords(limit: _pageSize);
    state = state.copyWith(
      loading: false,
      items: data,
      canLoadMore: data.length == _pageSize,
    );
  }

  Future<void> search(String? q) async {
    state = state.copyWith(query: q);
    await init(categorySlug: state.categorySlug);
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.loading) return;
    state = state.copyWith(loading: true);
    final more = await _repo.fetchRecentWords(limit: _pageSize);
    state = state.copyWith(
      loading: false,
      items: [...state.items, ...more],
      canLoadMore: more.length == _pageSize,
    );
  }

  // Exponiere Repo für bestehende Card-Stats (_CategoryCard nutzt derzeit Repo-Methoden)
  SupabaseWordRepository get repo => _repo;

  void searchDebounced(String q, {Duration delay = const Duration(milliseconds: 350)}) {
    _debounce?.cancel();
    _debounce = Timer(delay, () => search(q));
  }
}

// Riverpod-Provider für Controller/State
final wordHubControllerProvider =
    NotifierProvider<WordHubController, WordHubState>(() => WordHubController());

// ===== Meine Wörter (Liste / Suche / Pagination) =====

// State
class MyWordsState extends Equatable {
  final bool loadingFirst;
  final bool loadingMore;
  final bool hasMore;
  final List<Word> items;
  final String query;
  final int offset;

  const MyWordsState({
    this.loadingFirst = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.items = const [],
    this.query = '',
    this.offset = 0,
  });

  MyWordsState copyWith({
    bool? loadingFirst,
    bool? loadingMore,
    bool? hasMore,
    List<Word>? items,
    String? query,
    int? offset,
  }) => MyWordsState(
        loadingFirst: loadingFirst ?? this.loadingFirst,
        loadingMore: loadingMore ?? this.loadingMore,
        hasMore: hasMore ?? this.hasMore,
        items: items ?? this.items,
        query: query ?? this.query,
        offset: offset ?? this.offset,
      );

  @override
  List<Object?> get props => [loadingFirst, loadingMore, hasMore, items, query, offset];
}

// Controller
class MyWordsController extends Notifier<MyWordsState> {
  static const _pageSize = 50;
  late final SupabaseWordRepository _repo;
  Timer? _debounce;

  @override
  MyWordsState build() {
    _repo = ref.read(supabaseWordRepositoryProvider);
    ref.onDispose(() => _debounce?.cancel());
    return const MyWordsState();
  }

  Future<void> init() async {
    state = state.copyWith(loadingFirst: true, items: [], offset: 0, hasMore: true);
    final batch = await _repo.fetchMyWords(limit: _pageSize, offset: 0, query: state.query);
    state = state.copyWith(
      loadingFirst: false,
      items: batch,
      offset: batch.length,
      hasMore: batch.length == _pageSize,
    );
  }

  void setQuery(String q) {
    state = state.copyWith(query: q);
  }

  void searchDebounced(String q, {Duration delay = const Duration(milliseconds: 350)}) {
    setQuery(q);
    _debounce?.cancel();
    _debounce = Timer(delay, () => init());
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    state = state.copyWith(loadingMore: true);
    final batch = await _repo.fetchMyWords(limit: _pageSize, offset: state.offset, query: state.query);
    state = state.copyWith(
      loadingMore: false,
      items: [...state.items, ...batch],
      offset: state.offset + batch.length,
      hasMore: batch.length == _pageSize,
    );
  }

  Future<void> removeWord(String wordId) async {
    await _repo.removeFromMyWords(wordId);
    final next = [...state.items]..removeWhere((w) => w.id == wordId);
    state = state.copyWith(items: next, offset: next.length);
  }
}

// Provider
final myWordsControllerProvider =
    NotifierProvider<MyWordsController, MyWordsState>(() => MyWordsController());


```

---

## Features/words/data

### `lib/features/words/data/category_repository.dart`

**Typ:** Dart  
**Zeilen:** 112

**Vollständiger Code:**

```dart
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class Category {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final int wordCount;
  final String? groupSlug;
  final String? groupName;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.wordCount,
    this.groupSlug,
    this.groupName,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    slug: json['slug'] as String,
    description: json['description'] as String?,
    wordCount: (json['word_count'] as int?) ?? 0,
    groupSlug: json['group_slug'] as String?,
    groupName: json['group_name'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'word_count': wordCount,
    'group_slug': groupSlug,
    'group_name': groupName,
  };
}

class CategoryRepository {

  Future<List<Category>?> _getCachedCategories() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('cached_categories');
      if (raw == null) return null;
      final List list = jsonDecode(raw);
      return list.map((m) => Category.fromJson(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _setCachedCategories(List<Category> categories) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final data = categories.map((c) => c.toJson()).toList();
      await sp.setString('cached_categories', jsonEncode(data));
    } catch (_) {/* silent */}
  }

  Future<List<Category>> fetchCategories() async {
    final baseUrl = '${dotenv.env['SUPABASE_URL']}/rest/v1/categories';
    final apiKey = dotenv.env['SUPABASE_ANON_KEY']!;
    final etagKey = 'categories';

    final prefs = await SharedPreferences.getInstance();
    final oldEtag = prefs.getString('etag_cat_$etagKey');

    final headers = {
      'apikey': apiKey,
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
      if (oldEtag != null) 'If-None-Match': oldEtag,
    };

    final uri = Uri.parse('$baseUrl?select=id,name,slug,description,word_count,group_slug,group_name&order=name.asc');

    final resp = await http.get(uri, headers: headers);

    // 304: keine Änderungen → Cache zurückgeben
    if (resp.statusCode == 304) {
      final cached = await _getCachedCategories();
      return cached ?? [];
    }

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.reasonPhrase}');
    }

    // Neuen ETag speichern
    final newEtag = resp.headers['etag'];
    if (newEtag != null) {
      await prefs.setString('etag_cat_$etagKey', newEtag);
    }

    // Daten parsen
    final List data = jsonDecode(resp.body);
    final categories = data.map((m) => Category.fromJson(m)).toList();

    // Cache aktualisieren
    await _setCachedCategories(categories);

    return categories;
  }
}
```

---

### `lib/features/words/data/last_shared_word_provider.dart`

**Typ:** Dart  
**Zeilen:** 41

**Vollständiger Code:**

```dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

const _appGroupId = 'group.com.talvori.app'; // <- exakt wie in Xcode
const _fileName   = 'last_shared_word.txt';
const _prefsKey   = 'last_shared_word';

final lastSharedWordProvider = FutureProvider<String?>((ref) async {
  try {
    // nur iOS: App-Group lesen
    if (Platform.isIOS) {
      final dir = await _getAppGroupDirectory(_appGroupId);
      if (dir != null) {
        final file = File(p.join(dir, _fileName));
        if (await file.exists()) {
          final s = (await file.readAsString()).trim();
          if (s.isNotEmpty) return s;
        }
      }
    }
  } catch (_) {/* ignore and fall back */}

  // Fallback: SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final s = prefs.getString(_prefsKey)?.trim();
  return (s == null || s.isEmpty) ? null : s;
});

// Lokale Implementierung für App Group Directory
Future<String?> _getAppGroupDirectory(String appGroupId) async {
  try {
    const platform = MethodChannel('app_group_directory');
    final String? directory = await platform.invokeMethod('getAppGroupDirectory');
    return directory;
  } catch (e) {
    return null;
  }
}

```

---

### `lib/features/words/data/mock_word_repository.dart`

**Typ:** Dart  
**Zeilen:** 49

**Vollständiger Code:**

```dart
import 'package:talvori/features/words/domain/word.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';

/// Kleiner Vertrag für das UI
abstract class WordRepository {
  Future<List<Word>?> fetchByFilter(WordListFilter filter, {int limit = 50, int offset = 0, String? query, SortMode? sort});
  Future<List<Word>> fetchRecentWords({int limit = 20});
}

/// Deine Mock-Implementierung (behält fetchRecentWords bei)
class MockWordRepository implements WordRepository {
  static final MockWordRepository I = MockWordRepository._();
  MockWordRepository._();
  factory MockWordRepository() => I;  // erlaubt MockWordRepository() in Providern

  @override
  Future<List<Word>> fetchRecentWords({int limit = 20}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return List.generate(limit, (i) => Word(
      id: 'w$i',
      text: 'bridge_$i',
      translation: 'Brücke',
      fromLang: 'en',
      toLang: 'de',
      createdAt: now.subtract(Duration(minutes: i)),
      srsStage: i % 5,
    ));
  }

  @override
  Future<List<Word>?> fetchByFilter(WordListFilter filter, {int limit = 50, int offset = 0, String? query, SortMode? sort}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    // einfache Demo-Daten auf Basis des Filters
    return List.generate(limit, (i) {
      final idx = offset + i;
      return Word(
        id: 'mock_${filter.kind.name}_${filter.value}_$idx',
        text: '${filter.value.toLowerCase()}_$idx',
        translation: 'Übersetzung $idx',
        fromLang: 'en',
        toLang: 'de',
        createdAt: DateTime.now().subtract(Duration(days: idx)),
        favorite: idx % 7 == 0,
        srsStage: idx % 5,
      );
    });
  }
}

```

---

### `lib/features/words/data/supabase_word_repository.dart`

**Typ:** Dart  
**Zeilen:** 584

**Vollständiger Code:**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/features/words/domain/word.dart';
// Wir brauchen nur die Typen für den Filter:
import 'package:talvori/features/words/application/word_list_controller.dart'
    show WordListFilter, WordFilterKind, SortMode;
import 'package:flutter/foundation.dart'; // für debugPrint
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // falls noch nicht


class StageCount {
  final int stage;
  final int count;
  StageCount(this.stage, this.count);
}

class WorkloadToday {
  final int dueToday;
  final int newTotal;
  WorkloadToday({required this.dueToday, required this.newTotal});
}

// Falls du keinen kombinierten Typ hast: minimaler View-Mapper für v_words_user
class WordUserView {
  final String id;
  final String text;
  final String translation;
  final String? level;
  final bool inMyWords;
  final bool pickedUser;
  final bool favoriteUser;
  final int srsStage;
  final DateTime? nextDueAt;
  final DateTime? userAddedAt;

  WordUserView({
    required this.id,
    required this.text,
    required this.translation,
    this.level,
    this.inMyWords = false,
    this.pickedUser = false,
    this.favoriteUser = false,
    this.srsStage = 0,
    this.nextDueAt,
    this.userAddedAt,
  });

  WordUserView.fromJson(Map<String, dynamic> j)
      : id = (j['id'] as String?) ?? '',
        text = (j['text'] as String?) ?? '',
        translation = (j['translation'] as String?) ?? '',
        level = j['level'] as String?,
        inMyWords = (j['in_my_words'] as bool?) ?? false,
        pickedUser = (j['picked_user'] as bool?) ?? false,
        favoriteUser = (j['favorite_user'] as bool?) ?? false,
        srsStage = (j['srs_stage_user'] as int?) ?? 0,
        nextDueAt = j['next_due_at_user'] != null ? DateTime.parse(j['next_due_at_user']) : null,
        userAddedAt = j['user_added_at'] != null ? DateTime.parse(j['user_added_at']) : null;

  WordUserView copyWith({
    int? srsStage,
    DateTime? nextDueAt,
    bool setDueNull = false,
  }) {
    return WordUserView(
      id: id,
      text: text,
      translation: translation,
      level: level,
      inMyWords: inMyWords,
      pickedUser: pickedUser,
      favoriteUser: favoriteUser,
      srsStage: srsStage ?? this.srsStage,
      nextDueAt: setDueNull ? null : (nextDueAt ?? this.nextDueAt),
      userAddedAt: userAddedAt,
    );
  }
}

final _sb = Supabase.instance.client;

/// 1) Stufen-Balken pro Kategorie
Future<List<StageCount>> fetchStageCounts(String categoryId) async {
  final rows = await _sb.rpc('fn_user_stage_counts', params: {'cat': categoryId});
  final list = (rows as List).cast<Map<String, dynamic>>();
  return list.map((r) => StageCount((r['stage'] as int?) ?? 0, (r['cnt'] as int?) ?? 0)).toList();
}

/// 2) „Aktuelle Aufgabe“ (fällig heute + neu gesamt) pro Kategorie
Future<WorkloadToday> fetchWorkloadToday(String categoryId) async {
  final res = await Supabase.instance.client
      .rpc('fn_user_workload_today', params: {'cat': categoryId});

  late final Map<String, dynamic> j;
  if (res is Map<String, dynamic>) {
    j = res;
  } else if (res is List && res.isNotEmpty && res.first is Map<String, dynamic>) {
    j = res.first as Map<String, dynamic>;
  } else {
    j = const {}; // fallback
  }

  return WorkloadToday(
    newTotal: (j['newTotal'] ?? j['new_total'] ?? 0) as int,
    dueToday: (j['dueToday'] ?? j['due_today'] ?? 0) as int,
  );
}


/// Lern-Queue (alle Wörter der Kategorie – Größe dynamisch aus Progress)
Future<List<WordUserView>> fetchLearnQueueAll(String categoryId) async {
  final prog = await fetchCategoryProgress(categoryId);
  final take = (prog.total > 0) ? prog.total : 2000; // Fallback
  final rows = await _sb.rpc('fn_user_learn_queue', params: {'cat': categoryId, 'take': take});
  final list = (rows as List).cast<Map<String, dynamic>>();
  return list.map((j) => WordUserView.fromJson(j)).toList();
}

/// Lern-Queue für Learn Mode (nur S0 + fällige S1-S5)
Future<List<WordUserView>> fetchLearnQueueForMode(
  String categoryId, {
  required LevelSelectionMode mode,
  int? singleStage, // 1..5 (nur relevant bei single)
}) async {
  // Korrekte RPC-Funktion mit korrekten Parameter-Namen
  final modeStr = switch (mode) {
    LevelSelectionMode.s0toS5 => 'all',
    LevelSelectionMode.s1toS5 => 'reviews',
    LevelSelectionMode.single => 'single',
  };

  final params = <String, dynamic>{
    'category_id': categoryId,        // ✅ genau so benannt
    'mode': modeStr,                  // 'all' | 'reviews' | 'single'
    if (mode == LevelSelectionMode.single) 'single_stage': singleStage, // 1..5
    'limit': 50,                      // falls in SQL unterstützt
  };

  final res = await _sb.rpc('fn_user_learn_queue_mode', params: params);
  final list = (res as List).cast<Map<String, dynamic>>();
  return list.map((j) => WordUserView.fromJson(j)).toList();
}


/// Review-Ergebnis senden (true = richtig, false = falsch)
Future<(int stage, DateTime due)> submitReview(String wordId, bool correct) async {
  final rows = await _sb.rpc('fn_user_review', params: {
    'p_word': wordId,
    'p_result': correct,
  });

  final list = (rows as List).cast<Map<String, dynamic>>();
  final row = list.first;

  final stage = (row['srs_stage'] as int?) ?? 0;
  final dueStr = row['next_due_at'] as String?;
  final due = dueStr != null ? DateTime.parse(dueStr) : DateTime.now();

  return (stage, due);
}

/// Convenience:
Future<(int stage, DateTime due)> reviewCorrect(String wordId) =>
    submitReview(wordId, true);

Future<(int stage, DateTime due)> reviewWrong(String wordId) =>
    submitReview(wordId, false);

class CategoryProgress {
  final int total;
  final List<int> stages; // [s0..s5]
  final int dueToday;
  final int newTotal;
  CategoryProgress({
    required this.total,
    required this.stages,
    required this.dueToday,
    required this.newTotal,
  });
}

Future<CategoryProgress> fetchCategoryProgress(String categoryId) async {
  final rows = await _sb.rpc('fn_user_category_progress', params: {'cat': categoryId});
  final r = rows.cast<Map<String, dynamic>>().first;

  return CategoryProgress(
    total: (r['total'] as int?) ?? 0,
    stages: [
      (r['stage0'] as int?) ?? 0,
      (r['stage1'] as int?) ?? 0,
      (r['stage2'] as int?) ?? 0,
      (r['stage3'] as int?) ?? 0,
      (r['stage4'] as int?) ?? 0,
      (r['stage5'] as int?) ?? 0,
    ],
    dueToday: (r['due_today'] as int?) ?? 0,
    newTotal: (r['new_total'] as int?) ?? 0,
  );
}

class SupabaseWordRepository {
  final _sb = Supabase.instance.client;


  Future<List<Word>> fetchRecentWords({int limit = 20}) async {
    final data = await _sb
        .from('words')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List)
        .map((j) => Word.fromJson(j as Map<String, dynamic>))
        .toList();
  }

    Future<String> _ensureCategorySlug(String value) async {
    // Wenn 'value' already a slug, einfach zurückgeben (heuristik: enthält keine '{' und keine ':' und keine Großbuchstaben)
    final isUuidLike = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(value);
    if (!isUuidLike) return value; // already a slug

    // sonst: per UUID -> slug nachschlagen
    final row = await _sb
        .from('categories')
        .select('slug')
        .eq('id', value)
        .maybeSingle();
    if (row == null || row['slug'] == null) {
      throw Exception('Kategorie-Slug nicht gefunden für id=$value');
    }
    return row['slug'] as String;
  }

  Future<List<Word>?> fetchByFilter(
    WordListFilter filter, {
    int limit = 50,
    int offset = 0,
    String? query,
    SortMode? sort,
  }) async {
    final baseUrl = '${dotenv.env['SUPABASE_URL']}/rest/v1/words_view';
    final apiKey = dotenv.env['SUPABASE_ANON_KEY']!;

    // Lokaler Schlüssel pro Filter+Sort-Kombination
    final etagKey = '${filter.kind}:${filter.value}:${sort ?? ''}:${query ?? ''}';
    final prefs = await SharedPreferences.getInstance();
    final oldEtag = prefs.getString('etag_$etagKey');

    final headers = {
      'apikey': apiKey,
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
      if (oldEtag != null) 'If-None-Match': oldEtag,
    };

    // Querystring aufbauen
    final params = <String>[
      'select=id,text,translation,level,pos,created_at,category_id',
      'limit=$limit',
      'offset=$offset',
      'order=${sort == SortMode.newest ? 'created_at.desc' : 'text.asc'}',
    ];

    // Filter (per eq)
    switch (filter.kind) {
      case WordFilterKind.category:
        params.add('category_id=eq.${filter.value}');
        break;
      case WordFilterKind.level:
        params.add('level=eq.${filter.value}');
        break;
      case WordFilterKind.pos:
        params.add('pos=eq.${filter.value}');
        break;
      case WordFilterKind.domain:
        params.add('group_slug=eq.${filter.value}');
        break;
      case WordFilterKind.about:
        params.add('category_slug=eq.${filter.value}');
        break;
      case WordFilterKind.query:
        break;
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim();
      params.add('or=(text.ilike.%$q%,translation.ilike.%$q%)');
    }

    final uri = Uri.parse('$baseUrl?${params.join('&')}');

    // Anfrage senden
    final resp = await http.get(uri, headers: headers);

    // 👇 nur Debug
    // ignore: avoid_print
    print('ETag fetch ${uri.path}: ${resp.statusCode} (If-None-Match=${headers['If-None-Match'] != null})');

    if (resp.statusCode == 304) {
      return null; // WICHTIG: „unverändert" – UI nicht überschreiben!
    }

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.reasonPhrase}');
    }

    // Neuen ETag speichern
    final newEtag = resp.headers['etag'];
    if (newEtag != null) {
      await prefs.setString('etag_$etagKey', newEtag);
    }

    // Daten parsen
    final List data = jsonDecode(resp.body);
    final words = data.map((m) => Word.fromJson(m)).toList();

    // Dedupe nach ID
    final seen = <String>{};
    final unique = <Word>[];
    for (final w in words) {
      if (seen.add(w.id)) unique.add(w);
    }
    return unique;
  }

  Future<void> addToMyWords(String wordId) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    await _sb.from('user_words').upsert({
      'user_id': user.id,
      'word_id': wordId,
      'picked': true,
    });
  }

  Future<void> removeFromMyWords(String wordId) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    await _sb
        .from('user_words')
        .delete()
        .eq('user_id', user.id)
        .eq('word_id', wordId);
  }

  /// Optional: initiale Markierungen für eine Liste abfragen (Batch)
  Future<Set<String>> getPickedWordIds(Iterable<String> wordIds) async {
    final user = _sb.auth.currentUser;
    if (user == null || wordIds.isEmpty) return {};
    final data = await _sb
        .from('user_words')
        .select('word_id')
        .eq('user_id', user.id)
        .inFilter('word_id', wordIds.toList());

    return {
      for (final row in (data as List))
        (row as Map<String, dynamic>)['word_id'] as String
    };
  }

  Future<void> testIngestWord() async {
    final supabase = Supabase.instance.client;

    final response = await supabase.functions.invoke(
      'ingest_word',
      body: {
        'text': 'house',
        'fromLang': 'EN',
        'toLang': 'DE',
      },
    );

    debugPrint('🔹 Function response: ${response.data}');
  }

}

// --- MyWords API: fetch + count --------------------------------------------
extension MyWordsApi on SupabaseWordRepository {
  /// Gemerkte Wörter des aktuellen Users (Pagination). Optional clientseitige Suche.
  Future<List<Word>> fetchMyWords({
    int limit = 50,
    int offset = 0,
    String? query,
  }) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Join: user_words -> words (als "word")
    final data = await _sb
        .from('user_words')
        .select('word:words(*)')
        .eq('user_id', user.id)
        .eq('picked', true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    // Map zu Word-Liste
    var items = (data as List)
        .map((row) => Word.fromJson(
              (row as Map<String, dynamic>)['word'] as Map<String, dynamic>,
            ))
        .toList();

    // Einfache clientseitige Suche
    final q = query?.trim().toLowerCase();
    if (q != null && q.isNotEmpty) {
      items = items
          .where((w) =>
              w.text.toLowerCase().contains(q) ||
              w.translation.toLowerCase().contains(q))
          .toList();
    }

    return items;
  }

  /// Anzahl der gemerkten Wörter (einfach & robust).
  Future<int> countMyWords() async {
    final user = _sb.auth.currentUser;
    if (user == null) return 0;

    final data = await _sb
        .from('user_words')
        .select('word_id') // kein head/count – einfach zählen
        .eq('user_id', user.id)
        .eq('picked', true);

    return (data as List).length;
  }
}

// --- Kategorie-Resolver -----------------------------------------------
extension CategoryLookup on SupabaseWordRepository {
  /// Sucht die Kategorie-ID (UUID) per Anzeigename (case-insensitive).
  Future<String?> findCategoryIdByName(String name) async {
    final row = await _sb
        .from('categories')
        .select('id')
        .ilike('name', name) // "Health & Fitness" ≈ "health & fitness"
        .maybeSingle();
    if (row == null) return null;
    return row['id'] as String?;
  }
}

/// Info für die UI
class CategoryInfo {
  final String id;
  final String name;
  final String slug;
  final String? groupSlug;
  final String? groupName;
  final int? orderIndex;

  CategoryInfo({
    required this.id,
    required this.name,
    required this.slug,
    this.groupSlug,
    this.groupName,
    this.orderIndex,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> j) => CategoryInfo(
        id: (j['id'] as String?) ?? '',
        name: (j['name'] as String?) ?? '',
        slug: (j['slug'] as String?) ?? '',
        groupSlug: j['group_slug'] as String?,
        groupName: j['group_name'] as String?,
        orderIndex: j['order_index'] as int?,
      );
}


Future<List<CategoryInfo>> fetchAllCategories() async {
  final rows = await _sb
      .from('categories')
      .select('id,name,slug,group_slug,group_name,order_index,type')
      .eq('type', 'topic')
      .order('group_slug', ascending: true)
      .order('order_index', ascending: true);
  return (rows as List).map((e) => CategoryInfo.fromJson(e as Map<String, dynamic>)).toList();
}

// === Single Session Hooks ===

Future<void> singleSeed(String catId, int stage) =>
  _sb.rpc('fn_single_session_seed', params: {
    'p_category_id': catId, 'p_stage': stage, 'p_limit': 200,
  });

Future<(int src, int sr1, int sr2)> singleCounts(String catId, int stage) async {
  final res = await _sb.rpc('fn_single_session_counts', params: {
    'p_category_id': catId,
    'p_stage': stage,
  });
  final list = (res as List).cast<Map<String, dynamic>>(); // ⬅ wie bei deinen anderen RPCs
  final row = list.isEmpty ? null : list.first;
  return (
    (row?['src'] ?? 0) as int,
    (row?['sr1'] ?? 0) as int,
    (row?['sr2'] ?? 0) as int
  );
}

Future<void> singleMove(String catId, int stage, String wordId, bool correct) =>
  _sb.rpc('fn_single_session_move', params: {
    'p_category_id': catId,
    'p_stage': stage,
    'p_word_id': wordId,
    'p_correct': correct, // <-- boolean statt Bucket-String
  });

Future<void> singleReset(String catId, int stage) =>
  _sb.rpc('fn_single_session_reset', params: {
    'p_category_id': catId, 'p_stage': stage,
  });

Future<Map<String, dynamic>?> fetchNextFromSingle(String catId, int stage) async {
  final res = await _sb
      .from('single_session_items')
      .select('word_id, bucket')
      .eq('category_id', catId)
      .eq('stage', stage)
      .eq('bucket', 'src')
      .limit(1);
  if (res.isEmpty) return null;
  final wordId = res[0]['word_id'];
  // Lade Wortdaten wie sonst auch:
  final w = await _sb.from('v_words_user')
      .select()
      .eq('id', wordId)
      .maybeSingle();
  return w;
}

Future<String?> singleNextWordId(String catId, int stage) async {
  final res = await _sb
      .rpc('fn_single_session_next', params: {
        'p_category_id': catId,
        'p_stage': stage,
      });

  if (res == null) return null;

  // Rückgabe kann Liste oder Map sein (je nach Supabase-Version)
  final data = res is List
      ? (res.isNotEmpty ? res.first as Map<String, dynamic> : null)
      : (res as Map<String, dynamic>?);

  if (data == null) return null;

  final wordId = data['word_id'] as String?;
  final bucket = data['bucket'] as String?;

  if (wordId == null) return null;

  // Debug-Ausgabe zur Kontrolle
  debugPrint('🧩 Next word: $wordId from bucket=$bucket');

  // Wortdaten nachladen (wie bisher)
  final w = await _sb.from('v_words_user')
      .select()
      .eq('id', wordId)
      .maybeSingle();

  return w == null ? null : wordId;
}

Future<WordUserView?> fetchWordById(String wordId) async {
  final row = await _sb
      .from('v_words_user')
      .select()
      .eq('id', wordId)
      .maybeSingle();
  return row == null ? null : WordUserView.fromJson(row);
}

```

---

### `lib/features/words/data/word_hub_taxonomy.dart`

**Typ:** Dart  
**Zeilen:** 109

**Vollständiger Code:**

```dart
class HubSubcat {
  final String key;
  final String label;
  final String? supabaseId; // UUID deiner word_categories (später befüllen)
  const HubSubcat({required this.key, required this.label, this.supabaseId});
}

class HubSection {
  final String key;
  final String title;
  final String focus;
  final List<HubSubcat> subcats;
  const HubSection({required this.key, required this.title, required this.focus, required this.subcats});
}

// Acht Bereiche + Tabs (Labels = deine neuen Kategorien)
const hubSections = <HubSection>[
  HubSection(
    key: 'life_daily_flow',
    title: 'Life & Daily Flow',
    focus: 'Alltag & Routinen',
    subcats: [
      HubSubcat(key: 'health_fitness', label: 'Health & Fitness'),
      HubSubcat(key: 'home_living', label: 'Home & Living'),
      HubSubcat(key: 'food_cooking', label: 'Food & Cooking'),
      HubSubcat(key: 'style_fashion', label: 'Style & Fashion'),
      HubSubcat(key: 'money_shopping', label: 'Money & Shopping'),
    ],
  ),
  HubSection(
    key: 'people_mind',
    title: 'People & Mind',
    focus: 'Zwischenmenschliches, Emotionen',
    subcats: [
      HubSubcat(key: 'personality', label: 'Personality'),
      HubSubcat(key: 'feelings', label: 'Feelings'),
      HubSubcat(key: 'relationships', label: 'Relationships'),
      HubSubcat(key: 'thoughts', label: 'Thoughts'),
    ],
  ),
  HubSection(
    key: 'society_systems',
    title: 'Society & Systems',
    focus: 'Welt, Arbeit, Bildung',
    subcats: [
      HubSubcat(key: 'tech_innovation', label: 'Tech & Innovation'),
      HubSubcat(key: 'work_careers', label: 'Work & Careers'),
      HubSubcat(key: 'school_studies', label: 'School & Studies'),
      HubSubcat(key: 'media_news', label: 'Media & News'),
      HubSubcat(key: 'law_politics', label: 'Law & Politics'),
    ],
  ),
  HubSection(
    key: 'nature_beyond',
    title: 'Nature & Beyond',
    focus: 'Umwelt, Tiere, Wissenschaft',
    subcats: [
      HubSubcat(key: 'environment', label: 'Environment'),
      HubSubcat(key: 'animals', label: 'Animals'),
      HubSubcat(key: 'nature', label: 'Nature'),
      HubSubcat(key: 'space', label: 'Space'),
      HubSubcat(key: 'science', label: 'Science'),
    ],
  ),
  HubSection(
    key: 'action_adventure',
    title: 'Action & Adventure',
    focus: 'Bewegung & Reisen',
    subcats: [
      HubSubcat(key: 'sports', label: 'Sports'),
      HubSubcat(key: 'travel', label: 'Travel'),
      HubSubcat(key: 'gaming', label: 'Gaming'),
      HubSubcat(key: 'transport', label: 'Transport'),
    ],
  ),
  HubSection(
    key: 'culture_creativity',
    title: 'Culture & Creativity',
    focus: 'Ausdruck & Kunst',
    subcats: [
      HubSubcat(key: 'music_entertainment', label: 'Music & Entertainment'),
      HubSubcat(key: 'art_literature', label: 'Art & Literature'),
    ],
  ),
  HubSection(
    key: 'language_tools',
    title: 'Language Tools',
    focus: 'Lernhilfen & Grammatik',
    subcats: [
      HubSubcat(key: 'top_500', label: 'Top 500 Words'),
      HubSubcat(key: 'phrases_idioms', label: 'Phrases & Idioms'),
      HubSubcat(key: 'irregular_verbs', label: 'Irregular Verbs'),
      HubSubcat(key: 'grammar_syntax', label: 'Grammar & Syntax'),
    ],
  ),
  HubSection(
    key: 'levels_progress',
    title: 'Levels & Progress',
    focus: 'Sprachstufen & Lernpfade',
    subcats: [
      HubSubcat(key: 'a1', label: 'A1'),
      HubSubcat(key: 'a2', label: 'A2'),
      HubSubcat(key: 'b1', label: 'B1'),
      HubSubcat(key: 'b2', label: 'B2'),
      HubSubcat(key: 'c1', label: 'C1'),
      HubSubcat(key: 'c2', label: 'C2'),
    ],
  ),
];

```

---

### `lib/features/words/data/words_store.dart`

**Typ:** Dart  
**Zeilen:** 27

**Vollständiger Code:**

```dart
import 'package:flutter/foundation.dart';

class WordsStore extends ChangeNotifier {
  static final WordsStore I = WordsStore._();
  WordsStore._();

  final List<String> _items = [];
  List<String> get items => List.unmodifiable(_items);

  void add(String w) {
    if (w.trim().isEmpty) return;
    _items.insert(0, w.trim());
    notifyListeners();
  }

  void updateAt(int i, String w) {
    if (i < 0 || i >= _items.length) return;
    _items[i] = w.trim();
    notifyListeners();
  }

  void removeAt(int i) {
    if (i < 0 || i >= _items.length) return;
    _items.removeAt(i);
    notifyListeners();
  }
}

```

---

## Features/words/domain

### `lib/features/words/domain/srs_kind.dart`

**Typ:** Dart  
**Zeilen:** 2

**Vollständiger Code:**

```dart
/// Fachlicher SRS-Typ (ohne UI-Bezug)
enum SrsKind { tSrs, aSrs }

```

---

### `lib/features/words/domain/word.dart`

**Typ:** Dart  
**Zeilen:** 53

**Vollständiger Code:**

```dart
class Word {
  final String id, text, translation, fromLang, toLang;
  final String? deckId;
  final bool favorite;
  final DateTime createdAt;
  final DateTime? dueAt;
  final int srsStage;

  const Word({
    required this.id,
    required this.text,
    required this.translation,
    required this.fromLang,
    required this.toLang,
    this.deckId,
    this.favorite = false,
    required this.createdAt,
    this.dueAt,
    this.srsStage = 0,
  });

  Word copyWith({
    String? id, String? text, String? translation, String? fromLang, String? toLang,
    String? deckId, bool? favorite, DateTime? createdAt, DateTime? dueAt, int? srsStage,
  }) => Word(
    id: id ?? this.id, text: text ?? this.text, translation: translation ?? this.translation,
    fromLang: fromLang ?? this.fromLang, toLang: toLang ?? this.toLang,
    deckId: deckId ?? this.deckId, favorite: favorite ?? this.favorite,
    createdAt: createdAt ?? this.createdAt, dueAt: dueAt ?? this.dueAt,
    srsStage: srsStage ?? this.srsStage,
  );

  factory Word.fromJson(Map<String, dynamic> j) => Word(
    id: (j['id'] as String?) ?? '',
    text: (j['text'] as String?) ?? '',
    translation: (j['translation'] as String?) ?? '',
    fromLang: (j['from_lang'] as String?) ?? '',
    toLang: (j['to_lang'] as String?) ?? '',
    deckId: j['deck_id'] as String?,
    favorite: (j['favorite'] ?? false) as bool,
    createdAt: DateTime.parse(j['created_at']),
    dueAt: j['due_at'] != null ? DateTime.parse(j['due_at']) : null,
    srsStage: (j['srs_stage'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'text': text, 'translation': translation,
    'from_lang': fromLang, 'to_lang': toLang,
    'deck_id': deckId, 'favorite': favorite,
    'created_at': createdAt.toIso8601String(),
    'due_at': dueAt?.toIso8601String(), 'srs_stage': srsStage,
  };
}
```

---

## Features/words/services

### `lib/features/words/services/services.dart`

**Typ:** Dart  
**Zeilen:** 2

**Vollständiger Code:**

```dart
// lib/features/words/services/services.dart
export 'sfx_service.dart';

```

---

### `lib/features/words/services/sfx_service.dart`

**Typ:** Dart  
**Zeilen:** 42

**Vollständiger Code:**

```dart
// lib/features/words/application/sfx_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SFX Service für Sounds und Haptik
class SfxService {
  final _player = AudioPlayer();

  /// Korrekte Antwort - Sound oder Haptik
  Future<void> correct() async {
    try {
      await _player.play(AssetSource('sounds/correct.mp3'));
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }

  /// Falsche Antwort - Sound oder Haptik
  Future<void> wrong() async {
    try {
      await _player.play(AssetSource('sounds/incorrect.mp3'));
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Neue Karte - Sound oder Haptik
  Future<void> newCard() async {
    try {
      await _player.play(AssetSource('sounds/new_card.mp3'));
    } catch (_) {
      HapticFeedback.selectionClick();
    }
  }

  /// Ressourcen freigeben
  void dispose() => _player.dispose();
}

/// Provider für SFX Service
final sfxProvider = Provider((_) => SfxService());

```

---

## Features/words/ui/cards

### `lib/features/words/ui/cards/cards.dart`

**Typ:** Dart  
**Zeilen:** 5

**Vollständiger Code:**

```dart
export 'word_card.dart';
export 'swipeable_word_card.dart';
export 'counter_badge.dart';
export 'tap_flash.dart';
export 'glow_sweep_ring.dart';

```

---

### `lib/features/words/ui/cards/counter_badge.dart`

**Typ:** Dart  
**Zeilen:** 38

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class CounterBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  final Color? color;
  final Color? textColor;

  const CounterBadge({
    super.key,
    required this.count,
    this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          count.toString(),
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/cards/glow_sweep_ring.dart`

**Typ:** Dart  
**Zeilen:** 140

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class GlowSweepRing extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final Duration duration;
  final int cyclesPerBurst;
  final Duration idle;
  final bool loop;

  const GlowSweepRing({
    super.key,
    required this.size,
    this.strokeWidth = 3.0,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
    this.cyclesPerBurst = 1,
    this.idle = const Duration(seconds: 5),
    this.loop = true,
  });

  @override
  State<GlowSweepRing> createState() => _GlowSweepRingState();
}

class _GlowSweepRingState extends State<GlowSweepRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Start animation and repeat
    _startAnimation();
  }

  void _startAnimation() {
    if (!mounted) return;

    _controller.forward().then((_) {
      if (mounted && widget.loop) {
        Future.delayed(widget.idle, () {
          if (mounted) {
            _controller.reset();
            _startAnimation();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: GlowSweepPainter(
              progress: _animation.value,
              strokeWidth: widget.strokeWidth,
              color: widget.color ?? Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}

class GlowSweepPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  GlowSweepPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw the full ring background (subtle)
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Add glow effect by drawing multiple strokes
    for (int i = 0; i < 3; i++) {
      final glowRadius = radius + (i * 2);
      final glowAlpha = 0.8 - (i * 0.2);
      final glowStrokeWidth = strokeWidth + (i * 2);

      final paint = Paint()
        ..color = color.withValues(alpha: glowAlpha)
        ..strokeWidth = glowStrokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: glowRadius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GlowSweepPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

```

---

### `lib/features/words/ui/cards/swipeable_word_card.dart`

**Typ:** Dart  
**Zeilen:** 318

**Vollständiger Code:**

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import '../widgets/level_badge.dart';

typedef SwipeDecision = Future<void> Function(bool correct);

class SwipeableWordCard extends StatefulWidget {
  final String frontText;
  final String backText;
  final String? level;               // CEFR Level (A1-C2)
  final bool showTranslation;
  final bool gesturesEnabled;        // blockt Flip/Swipe bei pausiertem Timer
  final Widget? footer;              // TimerBar etc.
  final SwipeDecision onSwipe;       // true = right/correct, false = left/incorrect
  final VoidCallback onFlip;         // UI -> Controller.toggleFlip()

  const SwipeableWordCard({
    super.key,
    required this.frontText,
    required this.backText,
    required this.level,
    required this.showTranslation,
    required this.gesturesEnabled,
    required this.onSwipe,
    required this.onFlip,
    this.footer,
  });

  @override
  State<SwipeableWordCard> createState() => _SwipeableWordCardState();
}

class _SwipeableWordCardState extends State<SwipeableWordCard>
    with TickerProviderStateMixin {
  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;

  Offset _offset = Offset.zero;
  double _rotation = 0;
  bool _dragging = false;
  bool _slidingIn = false;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant SwipeableWordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync Flip-Animation mit showTranslation
    if (widget.showTranslation && _flipCtrl.status != AnimationStatus.forward && _flipCtrl.value == 0) {
      _flipCtrl.forward();
    } else if (!widget.showTranslation && _flipCtrl.value != 0) {
      _flipCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  void _resetPos() {
    setState(() {
      _offset = Offset.zero;
      _rotation = 0;
    });
  }

  Future<void> _animateAway(bool correct) async {
    final width = MediaQuery.of(context).size.width;
    final endX = correct ? width * 1.5 : -width * 1.5;

    HapticFeedback.mediumImpact();
    setState(() {
      _offset = Offset(endX, _offset.dy - 100);
      _rotation = correct ? 0.5 : -0.5;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    await widget.onSwipe(correct);

    // Flip zurück auf Front
    _flipCtrl.reset();

    await Future.delayed(const Duration(milliseconds: 50));
    setState(() {
      _offset = Offset.zero;
      _rotation = 0;
      _slidingIn = true;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _slidingIn = false);
  }

  @override
  Widget build(BuildContext context) {
    final threshold = MediaQuery.of(context).size.width * 0.35;

    return GestureDetector(
      onTap: () {
        if (!widget.gesturesEnabled) return;
        HapticFeedback.selectionClick();
        widget.onFlip();
      },
      onPanUpdate: (d) {
        if (!widget.gesturesEnabled) return;
        setState(() {
          _dragging = true;
          _offset += d.delta;
          _rotation = (_offset.dx / 1000).clamp(-0.26, 0.26);
        });
      },
      onPanEnd: (_) {
        if (!_dragging) return;
        setState(() => _dragging = false);
        if (!widget.gesturesEnabled) {
          _resetPos();
          return;
        }
        if (_offset.dx > threshold) {
          _animateAway(true);
        } else if (_offset.dx < -threshold) {
          _animateAway(false);
        } else {
          _resetPos();
        }
      },
      child: AnimatedContainer(
        duration: _dragging
            ? Duration.zero
            : (_slidingIn
                ? const Duration(milliseconds: 400)
                : const Duration(milliseconds: 300)),
        curve: _slidingIn ? Curves.easeOutCubic : Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(_offset.dx, _offset.dy)
          ..rotateZ(_slidingIn ? 0 : _rotation),
        child: _buildFlip(),
      ),
    );
  }

  Widget _buildFlip() {
    return AnimatedBuilder(
      animation: _flipAnim,
      builder: (_, __) {
        final angle = _flipAnim.value * math.pi;
        final isFront = angle < math.pi / 2;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: isFront ? _buildFront() : Transform(
            transform: Matrix4.identity()..rotateY(math.pi),
            alignment: Alignment.center,
            child: _buildBack(),
          ),
        );
      },
    );
  }

  Widget _buildFront() {
    return _CardShell(
      child: Stack(
        children: [
          Positioned(top: 12, right: 12, child: LevelBadge(level: widget.level)),
          const Positioned(
            top: 12, left: 12,
            child: Icon(Icons.rocket_launch_rounded, color: Colors.white70, size: 20),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              child: _AdaptiveText(widget.frontText),
            ),
          ),
          if (widget.footer != null)
            Positioned(bottom: 8, left: 30, right: 30, child: widget.footer!),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return _CardShell(
      dark: true,
      child: Stack(
        children: [
          const _SwipeHint(),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              child: _AdaptiveText(widget.backText, back: true),
            ),
          ),
          if (widget.footer != null)
            Positioned(bottom: 8, left: 30, right: 30, child: widget.footer!),
        ],
      ),
    );
  }
}

/// re-usable Shell
class _CardShell extends StatelessWidget {
  final Widget child;
  final bool dark;
  const _CardShell({required this.child, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      height: MediaQuery.of(context).size.height * 0.52,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF3A3939) : WordsUIConstants.cardBackground,
        borderRadius: BorderRadius.circular(WordsUIConstants.borderRadius),
        border: Border.all(color: Colors.white24),
        boxShadow: WordsUIConstants.cardShadow,
      ),
      child: child,
    );
  }
}

class _AdaptiveText extends StatelessWidget {
  final String text;
  final bool back;
  const _AdaptiveText(this.text, {this.back = false});

  @override
  Widget build(BuildContext context) {
    final wordCount = text.split(' ').length;
    final isPhrase = wordCount > 1;
    final total = text.length;

    double fontSize; int maxLines;

    if (isPhrase) {
      if (back) {
        if (total > 50) { fontSize = 24; maxLines = 5; }
        else if (total > 35) { fontSize = 26; maxLines = 4; }
        else if (total > 20) { fontSize = 28; maxLines = 3; }
        else { fontSize = 30; maxLines = 2; }
      } else {
        if (total > 40) { fontSize = 26; maxLines = 4; }
        else if (total > 25) { fontSize = 28; maxLines = 3; }
        else { fontSize = 30; maxLines = 2; }
      }
    } else {
      if (back) {
        if (total > 20) { fontSize = 26; maxLines = 3; }
        else if (total > 14) { fontSize = 28; maxLines = 2; }
        else if (total > 10) { fontSize = 30; maxLines = 2; }
        else { fontSize = 32; maxLines = 1; }
      } else {
        if (total > 18) { fontSize = 28; maxLines = 2; }
        else if (total > 12) { fontSize = 30; maxLines = 2; }
        else { fontSize = 34; maxLines = 1; }
      }
    }

    return Text(
      text.isNotEmpty ? text : '—',
      textAlign: TextAlign.center,
      maxLines: maxLines,
      overflow: TextOverflow.visible,
      softWrap: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.33,
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16, left: 0, right: 0,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swipe_left,  color: Colors.red.withOpacity(0.6),   size: 16),
            const SizedBox(width: 4),
            Text('Falsch',  style: TextStyle(color: Colors.red.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(width: 16),
            Text('•', style: TextStyle(color: Colors.white.withOpacity(0.3))),
            const SizedBox(width: 16),
            Text('Richtig', style: TextStyle(color: Colors.green.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.swipe_right, color: Colors.green.withOpacity(0.6), size: 16),
          ],
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/cards/tap_flash.dart`

**Typ:** Dart  
**Zeilen:** 80

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class TapFlash extends StatefulWidget {
  final Widget child;
  final Color color;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final VoidCallback? onTapAfter;

  const TapFlash({
    super.key,
    required this.child,
    required this.color,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.onTapAfter,
  });

  @override
  State<TapFlash> createState() => _TapFlashState();
}

class _TapFlashState extends State<TapFlash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onTapAfter?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              shape: widget.shape,
            ),
            child: Stack(
              children: [
                widget.child,
                if (_animation.value > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: _animation.value * 0.3),
                      borderRadius: widget.borderRadius,
                      shape: widget.shape,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

```

---

### `lib/features/words/ui/cards/word_card.dart`

**Typ:** Dart  
**Zeilen:** 516

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'counter_badge.dart';
import 'dart:ui' as ui;
import 'glow_sweep_ring.dart';
import 'tap_flash.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:talvori/core/services/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/last_shared_word_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: use_build_context_synchronously
// ignore_for_file: unnecessary_null_comparison


class WordCard extends ConsumerWidget {
  // Aktionen
  final VoidCallback onSpeak;
  final VoidCallback onMarkWords;
  final VoidCallback onQuickSend;
  final VoidCallback onGo;

  // Bild
  final ImageProvider? wordImage;
  final VoidCallback? onImageTap;
  final VoidCallback? onImageLongPress; // (derzeit ungenutzt)

  // Zähler
  final int userWordCount;
  final VoidCallback? onCountTap;

  // Größe + Wort
  final double? height;      // äußere Zielhöhe der Karte (nur als Mindesthöhe)
  final double? maxWidth;    // äußere Zielbreite (Deckel)
  final String? initialWord; // optionales Fallback

  // Feste Innenränder der Karte (bleiben IMMER gleich)
  final EdgeInsets contentPadding;

  // Bild-Modus
  final bool isImageExpanded;     // true = großes, randloses Bild
  final VoidCallback? onToggleImage;

  final bool isImageDark;                           // <- NEU
  final ValueChanged<bool>? onImageBrightnessChanged; // <- NEU

  const WordCard({
    super.key,
    required this.onSpeak,
    required this.onMarkWords,
    required this.onQuickSend,
    required this.onGo,
    this.wordImage,
    this.onImageTap,
    this.onImageLongPress,
    this.userWordCount = 0,
    this.onCountTap,
    this.height,
    this.maxWidth,
    this.initialWord,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 16, 20, 16),
    this.isImageExpanded = false,
    this.onToggleImage,
    this.isImageDark = false,
    this.onImageBrightnessChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final cardRadius = BorderRadius.circular(28);
    final onImageFg = isImageDark ? Colors.white : Colors.black;          // helle/dunkle Schrift/Icons
    final onImageIcon = isImageDark ? Colors.white : Colors.black87;      // Icons minimal kräftiger
    final asyncWord = ref.watch(lastSharedWordProvider);
    final displayWord = asyncWord.maybeWhen(
      data: (v) => (v != null && v.trim().isNotEmpty) ? v.trim() : (initialWord ?? 'to assume'),
      orElse: () => initialWord ?? 'to assume',
    );


    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height ?? 500,   // du nutzt im Home-Screen 570 – das passt
        maxWidth:  maxWidth ?? 360,
      ),
      child: ClipRRect(
        // sorgt dafür, dass die Rundung auch fürs große Bild gilt
        borderRadius: cardRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ───────────────── HINTERGRUND: großes Bild (nur Optik) ─────────────────
            if (isImageExpanded)
              // Bild liegt UNTER dem Inhalt und füllt die Karte komplett aus
              GestureDetector(
                onTap: onToggleImage ?? onImageTap,
                child: _WordImageWithProbe(provider: wordImage, fit: BoxFit.cover, onLuma: onImageBrightnessChanged) // <- meldet true = dunkel, false = hell)
              ),

            // ───────────────── VORDERGRUND (alles mit festen Pixelwerten) ─────────────────
            // Der gesamte Inhalt liegt über dem Bild und hat IMMER dasselbe Padding.
            Padding(
              padding: contentPadding,
              child: Stack(
                children: [
                  // ─── KLEINES BILD (nur wenn NICHT erweitert) ───
                  if (!isImageExpanded)
                    Positioned(
                      top: 16,       // Abstand von oben
                      left: 10,      // seitlicher Rand links
                      right: 10,     // seitlicher Rand rechts
                      height: 200,   // Höhe des kleinen Bildrahmens
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: GestureDetector(
                          onTap: onToggleImage ?? onImageTap,
                          child: _WordImageWithProbe(
                            provider: wordImage,
                            fit: BoxFit.cover,
                            onLuma: onImageBrightnessChanged, // <- meldet dunkel/hell auch im kleinen Bild
                          ),
                        ),
                      ),
                    ),

                  // ─── COUNTER (mit TapFlash) ───
                  Positioned(
                    top: 16, left: 0, right: 0,
                    child: Center(
                      child: TapFlash(
                        color: Theme.of(context).colorScheme.primary, // Flash-Farbe
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(14),
                        onTapAfter: onCountTap,
                        child: CounterBadge(
                          count: userWordCount,
                          onTap: null,            // TapFlash übernimmt das Tippen
                          color: Colors.black.withValues(alpha: 0.7), // Hintergrund
                          textColor: onImageFg,   // Textfarbe
                        ),
                      ),
                    ),
                  ),

                  // ─── "My Words" (immer identisch) ───
                  Positioned(
                    top: 70, left: 0, right: 0,
                    child: Center(
                      child: Text(
                        'My Words',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          // <- NUR EINE Farbe und NICHT const außenrum:
                          color: onImageFg, // <- immer dynamisch (hell/dunkel) – auch im kleinen Bild
                          shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
                        ),
                      ),
                    ),
                  ),

                  // ─── WORT (immer identisch) ───
                  Positioned(
                    top: 220, left: 0, right: 0,
                    child: GestureDetector(
                      onLongPress: () async {
                        final controller = TextEditingController(text: displayWord);
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Wort setzen'),
                            content: TextField(
                              controller: controller,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: 'Neues Wort eingeben',
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Abbrechen')),
                              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('OK')),
                            ],
                          ),
                        ) ?? false;

                        if (!ok || !context.mounted) return;
                        final w = controller.text.trim();
                        if (w.isEmpty) return;

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('last_shared_word', w);
                        // Provider neu laden
                        ref.invalidate(lastSharedWordProvider);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gesetzt: $w')),
                        );
                      },
                      child: Text(
                        displayWord,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: isImageExpanded ? onImageFg : cs.onSurface,
                          shadows: isImageExpanded
                              ? const [Shadow(color: Colors.black54, blurRadius: 8)]
                              : const [],
                        ),
                      ),
                    ),
                  ),

                  // ─── SPEAKER (mit TapFlash) ───
                  Positioned(
                    top: 276, left: 0, right: 0, // 220 + 56
                    child: SizedBox(
                      width: 44, height: 44,
                      child: TapFlash(
                        color: Theme.of(context).colorScheme.primary, // Flash-Farbe
                        shape: BoxShape.circle,
                        onTapAfter: onSpeak,                     // nach Flash ausführen
                        child: Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.volume_up,
                            size: 28,
                            color: isImageExpanded ? onImageIcon : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ─── PLAY (nur Icon, unten mittig, fix) ───
                  Positioned(
                    bottom: 30, left: 0, right: 0,
                    child: GestureDetector(
                      onTap: onMarkWords,
                      behavior: HitTestBehavior.translucent,
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow: 1 Runden -> 5s Pause -> wiederholen
                            GlowSweepRing(
                              size: 100,
                              strokeWidth: 5,
                              duration: const Duration(milliseconds: 1200), // 1 Runde ≈ 1.2s
                              cyclesPerBurst: 1,
                              idle: const Duration(seconds: 5),
                              loop: true,
                              color: const Color(0xFFF1C86B), // Gold
                            ),

                            // Play-Icon
                            SvgPicture.asset(
                              'assets/icons/circle-play.svg',
                              width: 94,
                              height: 94,
                              colorFilter: ColorFilter.mode(
                                isImageExpanded ? onImageIcon : cs.onSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── LINKES ICON (unten links) mit TapFlash ───
                  Positioned(
                    bottom: 16, left: 8,
                    child: SizedBox.square(
                      dimension: 52,
                      child: TapFlash(
                        color: Theme.of(context).colorScheme.primary, // deine App-Farbe, NICHT Gold
                        shape: BoxShape.circle,
                        onTapAfter: onQuickSend,
                        child: Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/cellphone_arrow_down_icon.svg',
                            width: 40, height: 40,
                            colorFilter: ColorFilter.mode(
                              isImageExpanded ? onImageIcon : cs.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ─── RECHTES ICON Chrome Button(unten rechts) mit TapFlash ───
                  Positioned(
                    bottom: 16, right: 8,
                    child: Tooltip(
                      message: 'Zuletzt geteilte Quelle öffnen (Long-press: zurücksetzen)',
                      child: GestureDetector( // ⬅️ NEU für Long-Press
                        onLongPress: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Gespeicherten Link löschen?'),
                              content: const Text('Die „Zurück zum Browser“-Position wird zurückgesetzt.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Abbrechen')),
                                TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Löschen')),
                              ],
                            ),
                          ) ?? false;

                          if (!context.mounted) return;
                          if (ok) {
                            await BrowserReturnService.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Zurück-Position gelöscht')),
                            );
                          }
                        },
                        child: SizedBox.square(
                          dimension: 52,
                          child: TapFlash(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            onTapAfter: () => onChromeButtonTap(context),
                            child: Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'assets/icons/line_chrome.svg',
                                width: 56, height: 56,
                                colorFilter: ColorFilter.mode(
                                  isImageExpanded ? onImageIcon : cs.onSurface,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void onChromeButtonTap(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);

  BrowserReturnService.getLastUrl().then((url) async {
    if (!context.mounted) return;

    if (url == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Kein geteilter Link gefunden')));
      return;
    }

    final isPdf = looksLikePdf(url);

    // vorher: SnackBar mit Action „Kopieren“
    // nachher: kurzer Auto-Dismiss, kein Button
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(isPdf
              ? 'Öffne zuletzt geteilte PDF …'
              : 'Öffne zuletzt geteilte Quelle …'),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          dismissDirection: DismissDirection.horizontal,
        ),
      );

    // Primär öffnen
    final Uri primary = url.startsWith('/') ? Uri.file(url) : Uri.parse(url);
    final ok = await launchUrl(primary, mode: LaunchMode.externalApplication);

    // PDF-Fallback (nur http/https)
    if (!ok && isPdf && (primary.scheme == 'http' || primary.scheme == 'https')) {
      final gview = Uri.parse(
        'https://docs.google.com/gview?embedded=1&url=${Uri.encodeComponent(url)}',
      );
      await launchUrl(gview, mode: LaunchMode.externalApplication);
    }
  });
}


/// Optionaler Helfer (falls du den Titel separat brauchst)
// ignore: unused_element
class _MyWordsTitle extends StatelessWidget {
  const _MyWordsTitle();
  @override
  Widget build(BuildContext context) {
    return const Text(
      'My Words',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
      ),
    );
  }
}

// Bild + Helligkeitsmessung
class _WordImageWithProbe extends StatefulWidget {
  final ImageProvider? provider;
  final BoxFit fit;
  final ValueChanged<bool>? onLuma;
  const _WordImageWithProbe({
    required this.provider,
    // ignore: unused_element_parameter
    this.fit = BoxFit.cover,
    this.onLuma,
  });

  @override
  State<_WordImageWithProbe> createState() => _WordImageWithProbeState();
}

class _WordImageWithProbeState extends State<_WordImageWithProbe> {
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant _WordImageWithProbe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      _unsubscribe();
      _subscribe();
    }
  }

  void _subscribe() {
    final prov = widget.provider ?? const AssetImage('assets/images/placeholder_1.png');
    _stream = prov.resolve(const ImageConfiguration());
    _listener = ImageStreamListener((info, _) async {
      try {
        final ui.Image img = info.image;
        final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (byteData == null) return;
        final bytes = byteData.buffer.asUint8List();

        // Grobe Stichprobe: 20x20 Pixel aus der Bildmitte mitteln (spart Zeit)
        final sample = 20;
        final startX = (img.width / 2 - sample / 2).clamp(0, img.width - 1).toInt();
        final startY = (img.height / 2 - sample / 2).clamp(0, img.height - 1).toInt();
        int count = 0;
        double lumSum = 0;
        for (int y = 0; y < sample; y += 2) {
          for (int x = 0; x < sample; x += 2) {
            final px = ((startY + y) * img.width + (startX + x)) * 4;
            if (px + 3 >= bytes.length) continue;
            final r = bytes[px].toDouble();
            final g = bytes[px + 1].toDouble();
            final b = bytes[px + 2].toDouble();
            // sRGB Luminanz
            final luma = 0.2126 * r + 0.7152 * g + 0.0722 * b;
            lumSum += luma;
            count++;
          }
        }
        if (count > 0 && widget.onLuma != null) {
          final avg = lumSum / count; // 0..255
          final isDark = avg < 128;   // Schwelle: 128
          widget.onLuma!(isDark);
        }
      } catch (_) {/* ignorieren */}
    });

    _stream?.addListener(_listener!);
  }

  void _unsubscribe() {
    if (_listener != null && _stream != null) {
      _stream!.removeListener(_listener!);
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = widget.provider ?? const AssetImage('assets/images/placeholder_1.png');
    return Image(image: prov, fit: widget.fit);
  }

}

```

---

## Features/words/ui/screens

### `lib/features/words/ui/screens/category_detail_screen.dart`

**Typ:** Dart  
**Zeilen:** 286

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/ui/widgets/category_header_capsule.dart';
import 'package:talvori/features/words/ui/widgets/learning_status_panel.dart';
import 'package:talvori/features/words/ui/widgets/levels_card.dart';
import 'package:talvori/features/words/ui/widgets/mode_toggle.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/application/category_detail_controller.dart';
import 'package:talvori/features/words/application/category_detail_state.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';
// removed srs_mode_provider import to avoid SrsSystem conflicts; we use controller enum
import 'package:talvori/features/words/ui/widgets/srs_mode_toggle.dart';
import 'package:talvori/features/words/ui/widgets/srs_mode_toggle_with_hint.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';



// ===== KONSTANTEN =====
const kAccentBlue = Color(0xFFB1CCFE);

/// ==============================
/// SCREEN
/// ==============================
class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String title;              // z.B. "Health & Fitness"
  final String? categoryId;        // Supabase UUID (word_categories.id); kann null sein
  final String? categorySlug;    // fallback:
  final WordListFilter listFilter; // Fallback/Anzeige-Liste

  const CategoryDetailScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.categorySlug,
    required this.listFilter,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> with WidgetsBindingObserver {
  ProviderSubscription<CategoryDetailState>? _controllerSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Controller-Listener ohne ref in dispose
    _controllerSub = ref.listenManual<CategoryDetailState>(
      categoryDetailControllerProvider,
      (prev, next) {
        // Optional: auf State-Änderungen reagieren
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryDetailControllerProvider.notifier).init(
        categoryId: widget.categoryId,
        categorySlug: widget.categorySlug,
        fallbackTitle: widget.title,
      );
      // Sicherstellen: Toggle startet NICHT im Hybrid-Modus
      final ctrl = ref.read(srsModeControllerProvider.notifier);
      final st = ref.read(srsModeControllerProvider);
      if (st.mode == SrsSystem.hybrid) {
        // per Tap-Logik zurück (setzt auf lastNonHybrid)
        ctrl.tap();
      }

    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // ✅ Subscription ohne ref schließen
    _controllerSub?.close();
    _controllerSub = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload über WidgetsBinding, nicht über ref
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(categoryDetailControllerProvider.notifier).reload();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(categoryDetailControllerProvider);
    final loading = s.loading;
    final stages = s.progress?.stages ?? const [0,0,0,0,0,0];
    final mode = ref.watch(levelSelectionProvider);
    final selecting = ref.watch(selectingSingleProvider);
    final allowed = ref.watch(allowedStagesProvider);
    final mask = List<bool>.generate(6, (i) => allowed.contains(i));

    final dailyTotal = s.dailyNew + s.dailyRepeats;
    const dailyTarget = 20;
    final dailyPercent = dailyTarget == 0 ? 0.0 : (dailyTotal / dailyTarget).clamp(0.0,1.0);

    final totalWords = s.progress?.total ?? stages.fold<int>(0, (a,b)=>a+b);
    final learnedWords = stages.skip(1).fold<int>(0,(a,b)=>a+b);
    final overallPercent = totalWords == 0 ? 0.0 : (learnedWords/totalWords).clamp(0.0,1.0);
    final overallLabel = '$learnedWords/$totalWords';

    final cats = s.categories;
    final selIndex = s.selectedIndex;
    final currentId = cats.isNotEmpty ? cats[selIndex].id : '';

    // Fix 4: Loader nur zeigen, wenn wirklich leer
    if (loading && s.categories.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }


    final srs = ref.watch(srsModeControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
                  children: [
            // FIX: fester Header – kein Flexible
            SizedBox(
              height: WordsLayout.topCapsuleH,
              child: CategoryHeaderCapsule(
                height: WordsLayout.topCapsuleH,
                title: cats.isNotEmpty ? cats[selIndex].name : widget.title,
                vocabsCount: s.vocabsTotal,
                categories: cats.map((e)=>e.name).toList(),
                selectedIndex: cats.isEmpty ? 0 : selIndex.clamp(0, cats.length - 1),
                onWheelChanged: (idx, _) => ref.read(categoryDetailControllerProvider.notifier).switchTo(idx),
                      onBack: () => Navigator.of(context).pop(),
                      onVocabs: () {
                        if (currentId.isEmpty) return;
                        final currentName = cats.isNotEmpty ? cats[selIndex].name : widget.title;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => WordListScreen(
                              filter: widget.listFilter,
                              overrideCategoryId: currentId,
                              overrideCategoryLabel: currentName,
                            ),
                          ),
                        );
                      },
                        onAdd: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Add tapped')),
                          );
                        },
                        onSettings: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings tapped')),
                          );
                        },
                // Offsets wie im Learn-Mode:
                wheelOffsetX: WordsLayout.wheelOffsetX,
                wheelOffsetY: WordsLayout.wheelOffsetY,
                rowOffsetX: WordsLayout.rowOffsetX,
                rowOffsetY: WordsLayout.rowOffsetY,
                vocabsTileOffsetX: WordsLayout.vocabsTileOffsetX,
                vocabsTileOffsetY: WordsLayout.vocabsTileOffsetY,
                rightBtnsOffsetX: WordsLayout.rightBtnsOffsetX,
                rightBtnsOffsetY: WordsLayout.rightBtnsOffsetY,
                wheelBottomGap: WordsLayout.wheelBottomGap,
                accentColor: kAccentBlue,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                trailingRightBelow: const SrsModeToggleWithHint(),
              ),
            ),

            const SizedBox(height: WordsLayout.gapBelowTop),

            // FIX: Mittel + Levels scrollbar machen, damit nix überläuft
          Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: WordsLayout.pageBottomPadding),
            child: Column(
                        children: [
                    LearningStatusPanel(
                                percent: dailyPercent,
                      percentLabel: '${(dailyPercent*100).round()}%',
                      newCount: s.dailyNew,
                      repeatsCount: s.dailyRepeats,
                      repeatsOfTargetLabel: '$dailyTotal/$dailyTarget',
                      overallPercent: overallPercent,
                      overallLabel: overallLabel,
                          ),

                          const SizedBox(height: WordsLayout.gapAboveBottom),
                          Transform.translate(
                            offset: const Offset(0, -24), // 🔼 nach oben (spiel mit -16…-32)
                            child: SizedBox(
                              height: WordsLayout.levelsCardH,
                              child: LevelsCard(
                                height: WordsLayout.levelsCardH,
                                  stages: stages,
                                  goalPerStage: 100,
                                  mode: mode,
                                  selectingSingle: selecting,                         // ← NEU
                                  visibleMask: mask,                                 // ← NEU
                                  onSelectSingleStage: (stg) {                        // ← NEU
                                    ref.read(singleStageProvider.notifier).state = stg;      // 1..5
                                    ref.read(selectingSingleProvider.notifier).state = false; // Pulse stoppen
                                  },
                                  onModeChanged: (m) async {
                                    ref.read(levelSelectionProvider.notifier).state = m;
                                    if (m == LevelSelectionMode.single) {
                                      // 1× sequentiell blinken (S1..S5), dann Idle-Pulse starten
                                      // await _switchCtrl.blinkSequentialS1toS5();     // du hast den Controller schon in LevelsCard; hier aufrufen, falls exposed
                                      ref.read(selectingSingleProvider.notifier).state = true;
                                    } else {
                                      ref.read(selectingSingleProvider.notifier).state = false;
                                    }
                                  },
                                  titleOffsetY: -15, // Buttons höher positionieren
                                  onStartPressed: () async {
                            if (currentId.isEmpty) return;
                            await ref.read(categoryDetailControllerProvider.notifier).seedForStart(currentId);
                            if (mounted) {
                              await Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => LearnModeScreen(
                                          categoryId: currentId,
                                  title: cats.isNotEmpty ? cats[selIndex].name : widget.title,
                                ),
                              ));
                              await ref.read(categoryDetailControllerProvider.notifier).reload();
                            }
                          },
                        ),
                      ),
                      ),
                    ],
                  ),
              ),
            ),
          ],
            ),

            if (srs.counting) Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.75),
                  alignment: const Alignment(0, -1.0),
        child: Column(
                    mainAxisSize: MainAxisSize.min,
          children: [
                      const Text(
                        'System wird auf Hybrid umgestellt',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${srs.count}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### `lib/features/words/ui/screens/learn_mode_screen.dart`

**Typ:** Dart  
**Zeilen:** 195

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import '../widgets/widgets.dart';
import 'package:talvori/features/words/ui/widgets/single_mode_switch_row.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/widgets/srs_visuals.dart';
import 'package:talvori/features/words/application/s0_lock_provider.dart';


class LearnModeScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String title; // z. B. "Money & Shopping"

  const LearnModeScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  ConsumerState<LearnModeScreen> createState() => _LearnModeScreenState();
}

class _LearnModeScreenState extends ConsumerState<LearnModeScreen> {
  // Controller (Business-Logik)
  late final LearnModeController _controller;
  // Controller für Switch-Row Blink-Effekte
  final _switchCtrl = StageSwitchRowController();


  @override
  void initState() {
    super.initState();
    _controller = ref.read(learnModeControllerProvider.notifier);

    // Init nach 1. Frame (damit Provider hängt)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init(
        categoryId: widget.categoryId,
        title: widget.title,
      );
    });
  }


  // === Build ===

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(levelSelectionProvider);
    final allowed = ref.watch(allowedStagesProvider);
    final mask = List<bool>.generate(6, (i) => allowed.contains(i));
    final state = ref.watch(learnModeControllerProvider);
    final s = state.stages; // [S0..S5]

    Widget switchesRow;
    if (mode == LevelSelectionMode.single) {
      final st = ref.watch(singleStageProvider);                 // z.B. 2
      final counts = ref.watch(singleSessionCountsProvider);     // (src, sr1, sr2)

      // Modus → Stroke & Prefix ableiten
      final srsMode = ref.watch(srsModeControllerProvider);
      final kind = switch (srsMode.mode) {
        SrsSystem.time => SrsKind.tSrs,
        SrsSystem.adaptive => SrsKind.aSrs,
        SrsSystem.hybrid => SrsKind.neutral,
      };
      final t = Theme.of(context);
      // Stroke: T/A ausblenden, Hybrid beibehalten
      final stroke = () {
        switch (kind) {
          case SrsKind.tSrs:
          case SrsKind.aSrs:
            return Colors.transparent;
          case SrsKind.neutral:
            return innerCapsuleStrokeColor(t, kind);
        }
      }();
      // Inner-Fill je Modus
      final innerFill = () {
        switch (kind) {
          case SrsKind.tSrs:
            return const Color(0xFF1A1A1A);
          case SrsKind.aSrs:
            return const Color(0xFF162743);
          case SrsKind.neutral:
            return const Color(0xFF2D2D2F);
        }
      }();
      final prefix = switch (kind) {
        SrsKind.tSrs => 'T',
        SrsKind.aSrs => 'A',
        SrsKind.neutral => '', // Hybrid
      };
      final stageLabelText = prefix.isEmpty ? 'S$st' : '$prefix$st';
      final srPrefix = prefix; // '' => Hybrid zeigt 'R1/R2'

      switchesRow = SingleModeSwitchRow(
        stageLabel: stageLabelText,
        srcCount: counts.src,
        sr1Count: counts.sr1,
        sr2Count: counts.sr2,
        srPrefix: srPrefix,               // ← NEU
        innerStrokeColor: stroke,         // ← NEU
        innerFillColor: innerFill,        // ← NEU
      );
    } else {
      // Non-Single: S0–S5 / S1–S5
      // Modus → Stroke & Prefix ableiten
      final srsMode = ref.watch(srsModeControllerProvider);
      final kind = switch (srsMode.mode) {
        SrsSystem.time => SrsKind.tSrs,
        SrsSystem.adaptive => SrsKind.aSrs,
        SrsSystem.hybrid => SrsKind.neutral,
      };
      final t = Theme.of(context);
      // Stroke: T/A ausblenden, Hybrid beibehalten
      final stroke = () {
        switch (kind) {
          case SrsKind.tSrs:
          case SrsKind.aSrs:
            return Colors.transparent;
          case SrsKind.neutral:
            return innerCapsuleStrokeColor(t, kind);
        }
      }();
      // Inner-Fill je Modus
      final innerFill = () {
        switch (kind) {
          case SrsKind.tSrs:
            return const Color(0xFF1A1A1A);
          case SrsKind.aSrs:
            return const Color(0xFF162743);
          case SrsKind.neutral:
            return const Color(0xFF2D2D2F);
        }
      }();
      final prefix = switch (kind) {
        SrsKind.tSrs => 'T',
        SrsKind.aSrs => 'A',
        SrsKind.neutral => '',
      };

      switchesRow = StageSwitchRow(
        controller: _switchCtrl,
        counts: s,
        goalPerStage: 100,
        gap: 12, // kSwitchGap
        sizes: const StageSwitchSizes(width: 42, height: 75, knobTop: 2, knobBottom: 18),
        colors: StageSwitchColors(
          newOuter: const Color(0xFFA05260),
          stageOuter: const Color(0xFFE4B866),
          inner: innerFill,
          disabledOuter: Colors.white,
          innerStroke: stroke,
        ),
        labels: StageSwitchLabels(newLabel: 'New', newNote: '0', stagePrefix: prefix),
        visibleMask: mask,                        // ⚠️ KEINE visibleMask hier für Single – diese Branch rendert nur für non-Single
        s0Locked: ref.watch(s0LockedProvider),
        onTapS0: () async {
          final notifier = ref.read(s0LockedProvider.notifier);
          final wasLocked = notifier.state;
          notifier.state = !wasLocked;

          // Wenn gerade ENTSPERRT wurde → einmal S0 blinken lassen
          if (wasLocked) {
            await _switchCtrl.blinkS0Once();
          }
        },
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderBar(),
            const CardArea(),
            switchesRow,
            const SizedBox(height: WordsUIConstants.sectionSpacing), // Mehr Luft zwischen Switches und Buttons
            const BottomControls(),
          ],
        ),
      ),
    );
  }
}




```

---

### `lib/features/words/ui/screens/my_words_screen.dart`

**Typ:** Dart  
**Zeilen:** 104

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/word_providers.dart';
import 'package:talvori/features/words/ui/widgets/empty_state.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';

class MyWordsScreen extends ConsumerStatefulWidget {
  const MyWordsScreen({super.key});

  @override
  ConsumerState<MyWordsScreen> createState() => _MyWordsScreenState();
}

class _MyWordsScreenState extends ConsumerState<MyWordsScreen> {
  @override
  void initState() {
    super.initState();
    // ersten Load starten
    Future.microtask(() => ref.read(myWordsControllerProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(myWordsControllerProvider);
    final c = ref.read(myWordsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Meine Wörter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => c.searchDebounced(v.trim()),
              onSubmitted: (_) => c.init(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Suchen in „Meine Wörter“',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          Expanded(
            child: vm.loadingFirst && vm.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => c.init(),
                    child: vm.items.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 120),
                              EmptyState(
                                icon: Icons.bookmark_add_outlined,
                                title: 'Noch keine Wörter gemerkt',
                                message: 'Markiere Wörter im Word Hub oder in Kategorien, um sie hier zu sehen.',
                                cta: 'Zum Word Hub',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const WordHubScreen()),
                                ),
                              ),
                            ],
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (n) {
                              if (n.metrics.extentAfter < 400) c.loadMore();
                              return false;
                            },
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: vm.items.length + ((vm.loadingMore || vm.hasMore) ? 1 : 0),
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                if (i >= vm.items.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                final w = vm.items[i];
                                return ListTile(
                                  title: Text(w.text),
                                  subtitle: Text(w.translation),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    tooltip: 'Aus „Meine Wörter" entfernen',
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      await c.removeWord(w.id);
                                      messenger.showSnackBar(SnackBar(content: Text('Entfernt: ${w.text}')));
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

```

---

### `lib/features/words/ui/screens/vocab_sort_screen.dart`

**Typ:** Dart  
**Zeilen:** 15

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class VocabSortScreen extends StatelessWidget {
  const VocabSortScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocab Sort')), // 👈 back button
      body: SafeArea(
        child: Center(child: Text('Vocab Sort', style: TextStyle(fontSize: 20))),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/screens/word_hub_screen.dart`

**Typ:** Dart  
**Zeilen:** 201

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/word_providers.dart';
import 'package:talvori/features/words/ui/widgets/category_card.dart';

class WordHubScreen extends ConsumerWidget {
  const WordHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final repo = ref.read(wordHubControllerProvider.notifier).repo; // nur hier bezogen

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Schließen',
        ),
        title: const Text('Word Hub'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: const StadiumBorder(),
              ),
              onPressed: () {},
              child: const Text('Alles freischalten'),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Suche
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                textInputAction: TextInputAction.search,
                onSubmitted: (q) {
                  final query = q.trim();
                  if (query.isEmpty) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WordListScreen(
                        filter: WordListFilter(WordFilterKind.query, query),
                      ),
                    ),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Suchen',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),

          // Sektionen
          for (final section in hubSections) ...[
            _SectionHeader('${section.title} • ${section.focus}'),
            _GridSection(
              sectionKey: section.key,
              subs: section.subcats,
              repo: repo,
              onTapSub: (sub) async {
                String? catId;
                try {
                  catId = (sub.supabaseId != null && sub.supabaseId!.isNotEmpty)
                      ? sub.supabaseId
                      : await repo.findCategoryIdByName(sub.label);
                } catch (_) {
                  catId = null;
                }

                if (!context.mounted) return;
                if (catId == null && sub.supabaseId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hinweis: Kategorie-Lookup nicht möglich. Fallback aktiv.')),
                  );
                }

                if (catId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailScreen(
                        title: sub.label,
                        categoryId: catId!,
                        categorySlug: null,
                        listFilter: WordListFilter(WordFilterKind.category, catId),
                      ),
                    ),
                  );
                } else {
                  final (kind, value) = _mapToFilter(section.key, sub.label);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailScreen(
                        title: sub.label,
                        categoryId: null,
                        categorySlug: _slugifyLocal(sub.label),
                        listFilter: WordListFilter(kind, value),
                      ),
                    ),
                  );
                }
              },
            ),
          ],

          SliverToBoxAdapter(child: SizedBox(height: bottomInset + 10)),
        ],
      ),
    );
  }

  (WordFilterKind, String) _mapToFilter(String sectionKey, String label) {
    if (sectionKey == 'levels_progress') {
      return (WordFilterKind.level, label);
    }
    return (WordFilterKind.about, label);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _GridSection extends StatelessWidget {
  final String sectionKey;
  final List<HubSubcat> subs;
  final SupabaseWordRepository repo;
  final void Function(HubSubcat sub)? onTapSub;

  const _GridSection({
    required this.sectionKey,
    required this.subs,
    required this.repo,
    this.onTapSub,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => CategoryCard(
            sectionKey: sectionKey,
            sub: subs[i],
            onTap: onTapSub == null ? null : () => onTapSub!(subs[i]),
          ),
          childCount: subs.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
      ),
    );
  }
}

String _slugifyLocal(String s) {
  return s
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}


```

---

### `lib/features/words/ui/screens/word_list_screen.dart`

**Typ:** Dart  
**Zeilen:** 201

**Vollständiger Code:**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/domain/word.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/widgets/word_list_toolbar.dart';
import 'package:talvori/features/words/ui/widgets/word_list_item.dart';
import 'package:talvori/features/words/ui/widgets/list_end_footer.dart';
import 'package:talvori/features/words/ui/widgets/shimmer_list.dart';

class WordListScreen extends ConsumerStatefulWidget {
  final WordListFilter filter;
  final String? titleOverride;
  final String? overrideCategoryId;
  final String? overrideCategoryLabel;

  const WordListScreen({
    super.key,
    required this.filter,
    this.titleOverride,
    this.overrideCategoryId,
    this.overrideCategoryLabel,
  });

  @override
  ConsumerState<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends ConsumerState<WordListScreen> {
  final _scroll = ScrollController();
  late final String _provKey; // stabiler Key für provider family
  Timer? _scrollThrottle; // oben bei _scroll
  ProviderSubscription<WordListState>? _controllerSub; // NEU: für listenManual

  @override
  void initState() {
    super.initState();
    _provKey = _buildKey();
    _scroll.addListener(_onScroll);

    // Re-Online Snackbar - FIX: listenManual statt listen
    _controllerSub = ref.listenManual<WordListState>(
      wordListControllerProvider(_provKey),
      (prev, next) {
        if ((prev?.offline ?? false) && !next.offline) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wieder online'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );

    // Controller initialisieren
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(wordListControllerProvider(_provKey));
      if (s.isFirstLoad && s.words.isEmpty) {
        ref
            .read(wordListControllerProvider(_provKey).notifier)
            .init(filter: widget.filter, overrideCategoryId: widget.overrideCategoryId);
      }
    });
  }

  String _buildKey() =>
      '${widget.filter.kind}:${widget.overrideCategoryId ?? widget.filter.value}';

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _scrollThrottle?.cancel();
    // FIX: Subscription schließen
    _controllerSub?.close();
    _controllerSub = null;
    super.dispose();
  }

  void _onScroll() {
    final s = ref.read(wordListControllerProvider(_provKey));
    if (s.isLoadingMore || !s.hasMore) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      if (_scrollThrottle != null) return; // throttle aktiv
      _scrollThrottle = Timer(const Duration(milliseconds: 200), () {
        _scrollThrottle = null;
      });
      ref.read(wordListControllerProvider(_provKey).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordListControllerProvider(_provKey));
    final ctrl = ref.read(wordListControllerProvider(_provKey).notifier);
    final effectiveCategoryLabel =
        widget.overrideCategoryLabel ?? widget.filter.value;
    final title = widget.titleOverride ?? 'Word Hub • $effectiveCategoryLabel';

    final list = state.words;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          WordListToolbar(
            onQueryChanged: ctrl.setQueryDebounced, // <-- statt ctrl.setQuery
            sort: state.sort,
            onSortChanged: ctrl.setSortDebounced,
            visibleCount: list.length, // statt: sorted.length
            offline: state.offline, // NEU
          ),
          Expanded(
            child: state.words.isEmpty && state.isFirstLoad
                ? const ShimmerList(items: 10)
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Fehler: ${state.error}', textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => ctrl.loadFirstPage(),
                              child: const Text('Erneut versuchen'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ctrl.loadFirstPage(resetCache: true),
                        child: _buildList(context, list, state, ctrl),
                      ),
          ),
        ],
      ),
    );
  }


  Widget _buildList(BuildContext context, List<Word> list, WordListState state,
      WordListController ctrl) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Keine Wörter gefunden.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                // Suche zurücksetzen + neu laden (serverside)
                ctrl.setQuery('');
                await ctrl.loadFirstPage();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter zurückgesetzt')),
                  );
                }
              },
              child: const Text('Filter zurücksetzen'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      key: PageStorageKey('wordList:$_provKey'),
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      itemCount: list.length + 1, // immer ein Footer
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        if (i == list.length) {
          return ListEndFooter(
            loading: state.isLoadingMore,
            showDone: !state.hasMore,
          );
        }
        final w = list[i];
        final picked = state.picked.contains(w.id);
        return WordListItem(
          word: w,
          picked: picked,
          onTogglePick: () async {
            final msg = await ctrl.togglePick(context, w);
            if (context.mounted && msg != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            }
          },
          onTap: () {},
        );
      },
    );
  }
}

```

---

## Features/words/ui/theme

### `lib/features/words/ui/theme/theme.dart`

**Typ:** Dart  
**Zeilen:** 2

**Vollständiger Code:**

```dart
export 'words_colors.dart';
export 'words_layout.dart';

```

---

### `lib/features/words/ui/theme/words_colors.dart`

**Typ:** Dart  
**Zeilen:** 22

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

@immutable
class WordsColors extends ThemeExtension<WordsColors> {
  final Color surfaceBg;
  final Color cardBg;

  const WordsColors({required this.surfaceBg, required this.cardBg});

  @override
  WordsColors copyWith({Color? surfaceBg, Color? cardBg}) =>
      WordsColors(surfaceBg: surfaceBg ?? this.surfaceBg, cardBg: cardBg ?? this.cardBg);

  @override
  ThemeExtension<WordsColors> lerp(ThemeExtension<WordsColors>? other, double t) {
    final o = other as WordsColors;
    return WordsColors(
      surfaceBg: Color.lerp(surfaceBg, o.surfaceBg, t)!,
      cardBg: Color.lerp(cardBg, o.cardBg, t)!,
    );
  }
}

```

---

### `lib/features/words/ui/theme/words_layout.dart`

**Typ:** Dart  
**Zeilen:** 44

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

/// Zentrale Layout- und Spacing-Definitionen für Words-UI.
class WordsLayout {
  /// Header / Top-Kachel
  static const double topCapsuleH = 260.0;
  static const EdgeInsets topPadding = EdgeInsets.fromLTRB(14, 12, 14, 12);

  /// Abstände zwischen Blöcken
  static const double gapBelowTop = 16.0;
  static const double gapAboveBottom = 40.0;
  static const double pageBottomPadding = 24.0;

  /// Mittelteil (Progress/Stats)
  static const double midPaddingH = 25.0;

  /// Levels-Card
  static const double levelsCardH = 260.0;
  static const EdgeInsets levelsOuterPadding =
      EdgeInsets.fromLTRB(20, 8, 20, 0);

  /// Header-Row (Vocabs + Buttons) Offsets
  static const double rowOffsetX = 0.0;
  static const double rowOffsetY = 0.0;
  static const double vocabsTileOffsetX = 0.0;
  static const double vocabsTileOffsetY = 0.0;
  static const double rightBtnsOffsetX = 0.0;
  static const double rightBtnsOffsetY = 0.0;

  /// Wheel im Header
  static const double wheelOffsetX = 0.0;
  static const double wheelOffsetY = 0.0;
  static const double wheelHeight = 72.0;
  static const double wheelBottomGap = 28.0;

  /// Stage-Switches
  static const double switchGap = 12.0;
  static const double switchesOffsetX = 0.0;
  static const double switchesOffsetY = -12.0;

  /// Start-Button
  static const double startBtnOffsetX = 0.0;
  static const double startBtnOffsetY = 0.0;
}

```

---

## Features/words/ui

### `lib/features/words/ui/ui_constants.dart`

**Typ:** Dart  
**Zeilen:** 78

**Vollständiger Code:**

```dart
// lib/features/words/ui/ui_constants.dart
import 'package:flutter/material.dart';

/// UI-Konstanten für den Words-Feature
class WordsUIConstants {
  // ---- Farben ----

  /// Karten-Hintergrund
  static const Color cardBackground = Color(0xFF2D2C2C);

  /// Stage-Switch Farben
  static const Color stageOuter = Color(0xFFE4B866);
  static const Color stageInner = Color(0xFF2D2C2C);
  static const Color stageInnerRed = Color(0xFFA05260);
  static const Color stageInnerDark = Color(0xFF2D2D2F);

  /// Inaktive Stage-Switch Farbe (jetzt komplett Weiß)
  static Color get stageInactive => Colors.white;

  /// Loading-Indikator Farbe
  static const Color loadingIndicator = Colors.white54;

  // ---- Abstände ----

  /// Abstand zwischen Stage-Switches
  static const double switchGap = 8.0;

  /// Standard-Padding für Screens
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(18, 10, 18, 5);
  static const EdgeInsets bottomControlsPadding = EdgeInsets.fromLTRB(18, 8, 18, 24);

  /// Abstände zwischen UI-Elementen
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 12.0;
  static const double largeSpacing = 80.0;
  static const double sectionSpacing = 20.0; // Abstand zwischen Hauptbereichen

  // ---- Offsets ----

  /// Stage-Switch Offsets
  static const Offset switchOffset = Offset(0.0, 0.0);

  /// Header-Offset
  static const Offset headerOffset = Offset(0.0, 0.0);

  // ---- Größen ----

  /// Header-Höhe
  static const double headerHeight = 72.0;

  /// Icon-Größen
  static const double iconSize = 44.0;
  static const double smallIconSize = 22.0;

  /// Stage-Switch Größen
  static const double stageSwitchWidth = 42.0;
  static const double stageSwitchHeight = 75.0; // Zurück auf 75px
  static const double stageSwitchRadius = 21.0;

  /// Loading-Indikator Größen
  static const Size loadingSize = Size(280.0, 72.0);

  /// Border-Radius
  static const double borderRadius = 22.0;

  /// Card-Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 12)),
  ];

  // ---- Stage-Switch spezifische Konstanten ----

  /// Ziel-Anzahl für Stage-Completion
  static const int stageGoal = 100;

  /// Highlight-Schwellenwert
  static const int highlightThreshold = 100;
}

```

---

## Features/words/ui/widgets

### `lib/features/words/ui/widgets/bottom_controls.dart`

**Typ:** Dart  
**Zeilen:** 63

**Vollständiger Code:**

```dart
// lib/features/words/ui/widgets/bottom_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'package:talvori/core/ui/widgets/round_icon.dart';
import 'package:talvori/features/words/ui/widgets/play_pause_button.dart';
import 'package:talvori/features/words/ui/widgets/cancel_timer_button.dart';
import 'package:talvori/features/words/ui/widgets/reset_button.dart';
import 'package:talvori/features/words/ui/widgets/menu_sheet.dart';

class BottomControls extends ConsumerWidget {
  const BottomControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider);
    final s = ref.watch(learnModeControllerProvider);
    final c = ref.read(learnModeControllerProvider.notifier);

    return Padding(
      padding: WordsUIConstants.bottomControlsPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoundIcon(
            icon: Icons.grid_view_rounded,
            onTap: () => _showMenu(context),
          ),
          const SizedBox(width: WordsUIConstants.largeSpacing),
          PlayPauseButton(
            isPlaying: isPlaying,
            onTap: () {
              if (!s.timerActive) {
                c.startTimer();
              } else {
                if (s.running) {
                  c.pauseTimer();
                } else {
                  c.resumeTimer();
                }
              }
            },
          ),
          const SizedBox(width: WordsUIConstants.largeSpacing),
          s.timerActive
              ? CancelTimerButton(onTap: c.cancelTimer)
              : ResetButton(onResetComplete: c.performReset),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showWordsMenuSheet(context, items: [
      MenuItemData(Icons.auto_awesome, 'ChatGPT', () {}),
      MenuItemData(Icons.translate_rounded, 'DeepL', () {}),
      MenuItemData(Icons.favorite_border, 'Favorit', () {}),
      MenuItemData(Icons.note_alt_outlined, 'Notizen', () {}),
      MenuItemData(Icons.settings_rounded, 'Einstellungen', () {}),
    ]);
  }
}

```

---

### `lib/features/words/ui/widgets/cancel_timer_button.dart`

**Typ:** Dart  
**Zeilen:** 36

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class CancelTimerButton extends StatelessWidget {
  final VoidCallback onTap;

  const CancelTimerButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.close_rounded, color: Colors.red, size: 24),
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/card_area.dart`

**Typ:** Dart  
**Zeilen:** 43

**Vollständiger Code:**

```dart
// lib/features/words/ui/widgets/card_area.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/cards/swipeable_word_card.dart';
import 'package:talvori/features/words/ui/widgets/timer_bar.dart';

class CardArea extends ConsumerWidget {
  const CardArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentWordProvider);
    final isPaused = ref.watch(isPausedProvider);
    final s = ref.watch(learnModeControllerProvider);
    final c = ref.read(learnModeControllerProvider.notifier);


    final word = current?.text ?? (s.shuffledWordIds.isEmpty ? 'Keine Wörter\nverfügbar' : '—');
    final translation = current?.translation ?? '';

    return Expanded(
      child: Center(
        child: SwipeableWordCard(
          frontText: word,
          backText: translation,
          level: current?.level,
          showTranslation: s.showTranslation,
          gesturesEnabled: !isPaused,
          footer: TimerBar(s: s),
          onSwipe: (correct) async {
            if (correct) {
              c.onSwipeRight();
            } else {
              c.onSwipeLeft();
            }
          },
          onFlip: () => c.toggleFlip(),
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/category_card.dart`

**Typ:** Dart  
**Zeilen:** 110

**Vollständiger Code:**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/events/events.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/application/category_stats_provider.dart';
import 'mini_badge.dart';
import 'shimmer_box.dart';

class CategoryCard extends ConsumerStatefulWidget {
  final String sectionKey;
  final HubSubcat sub;
  final VoidCallback? onTap;

  const CategoryCard({
    required this.sectionKey,
    required this.sub,
    this.onTap,
    super.key,
  });

  @override
  ConsumerState<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends ConsumerState<CategoryCard> with WidgetsBindingObserver {
  StreamSubscription<String>? _resetSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Invalidate Stats bei Reset-Events
    _resetSubscription = ResetEvent.stream.listen((_) {
      ref.invalidate(categoryStatsProvider(widget.sub));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(categoryStatsProvider(widget.sub));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final asyncStats = ref.watch(categoryStatsProvider(widget.sub));
    final stats = asyncStats.value; // kann schon befüllt sein
    final loading = asyncStats.isLoading && stats == null; // 👈 nur dann "echt" laden

    return Material(
      color: t.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          if (widget.onTap != null) widget.onTap!();
        },
        overlayColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)),
        splashFactory: InkRipple.splashFactory,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: t.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (loading) const Expanded(child: ShimmerBox(height: 16, borderRadius: 999)),
              if (loading) const SizedBox(width: 8),
              if (!loading && stats != null) ...[
                MiniBadge(icon: Icons.refresh, label: '${stats.dueToday}'),
                const SizedBox(width: 6),
                MiniBadge(icon: Icons.fiber_new, label: '${stats.newTotal}'),
              ],
            ]),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (loading)
                    const Expanded(child: ShimmerBox(height: 18, borderRadius: 6))
                  else
                    Expanded(child: Text(widget.sub.label, style: t.textTheme.titleMedium)),
                  if (!loading && stats != null) Text('${stats.total}', style: t.textTheme.bodyMedium),
                  if (loading) const SizedBox(width: 12),
                  if (loading) const ShimmerBox(height: 14, borderRadius: 6),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/category_header_capsule.dart`

**Typ:** Dart  
**Zeilen:** 189

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/widgets/srs_mode_toggle_with_hint.dart';
import 'package:talvori/features/words/ui/widgets/category_wheel.dart';
import 'package:talvori/features/words/ui/widgets/glow_circle_button.dart';
import 'package:talvori/features/words/ui/widgets/glow_rect_tile.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';

class CategoryHeaderCapsule extends StatelessWidget {
  final double height;

  final String title;
  final int vocabsCount;

  final List<String> categories;
  final int selectedIndex;
  final void Function(int index, String label) onWheelChanged;

  final VoidCallback onBack;
  final VoidCallback onVocabs;
  final VoidCallback onAdd;
  final VoidCallback onSettings;

  // Offsets/Knobs – Defaults wie bisher, aber überschreibbar
  final double wheelOffsetX;
  final double wheelOffsetY;
  final double rowOffsetX;
  final double rowOffsetY;
  final double vocabsTileOffsetX;
  final double vocabsTileOffsetY;
  final double rightBtnsOffsetX;
  final double rightBtnsOffsetY;
  final double wheelBottomGap; // NEU

  final Color accentColor;
  final Color? backgroundColor;

  // Optional: zusätzliches Widget rechts unter den Add/Settings-Buttons (z. B. Toggle)
  final Widget? trailingRightBelow;

  const CategoryHeaderCapsule({
    super.key,
    required this.height,
    required this.title,
    required this.vocabsCount,
    required this.categories,
    required this.selectedIndex,
    required this.onWheelChanged,
    required this.onBack,
    required this.onVocabs,
    required this.onAdd,
    required this.onSettings,
    this.wheelOffsetX = WordsLayout.wheelOffsetX,
    this.wheelOffsetY = WordsLayout.wheelOffsetY,
    this.rowOffsetX = WordsLayout.rowOffsetX,
    this.rowOffsetY = WordsLayout.rowOffsetY,
    this.vocabsTileOffsetX = WordsLayout.vocabsTileOffsetX,
    this.vocabsTileOffsetY = WordsLayout.vocabsTileOffsetY,
    this.rightBtnsOffsetX = WordsLayout.rightBtnsOffsetX,
    this.rightBtnsOffsetY = WordsLayout.rightBtnsOffsetY,
    this.wheelBottomGap = WordsLayout.wheelBottomGap,
    this.accentColor = const Color(0xFFB1CCFE),
    this.backgroundColor,
    this.trailingRightBelow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: WordsLayout.topPadding,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
            // Back + Wheel - mit fester Höhe wie im Learn-Mode
            SizedBox(
              height: WordsLayout.wheelHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: onBack,
                    child: const SizedBox(
                      width: 44, height: 44,
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: CategoryWheel(
                        categories: categories,
                        initialIndex: selectedIndex,
                        onChanged: onWheelChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),
            SizedBox(height: wheelBottomGap), // ← statt const SizedBox(height: 10),

            // Vocabs-Kachel + Buttons
            Transform.translate(
              offset: Offset(rowOffsetX, rowOffsetY),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: Offset(vocabsTileOffsetX, vocabsTileOffsetY),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: onVocabs,
                          child: GlowRectTile(
                            width: 84,
                            height: 85,
                            radius: 15,
                            title: 'Vocabs',
                            icon: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                            outlineColor: accentColor,
                            glowColor: accentColor,
                            badgeText: '$vocabsCount',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Transform.translate(
                    offset: Offset(rightBtnsOffsetX, rightBtnsOffsetY),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            GlowCircleButton(
                              size: 62,
                              onTap: onAdd,
                              child: const Icon(Icons.add, color: Colors.white, size: 28),
                              outlineColor: accentColor,
                              glowColor: accentColor,
                            ),
                            const SizedBox(width: 10),
                            GlowCircleButton(
                              size: 62,
                              onTap: onSettings,
                              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
                              outlineColor: accentColor,
                              glowColor: accentColor,
                            ),
                            ],
                          ),
                        ),
                        if (trailingRightBelow != null) ...[
                          const SizedBox(height: 25), // weiter nach unten
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 70), // mehr nach innen
                              child: trailingRightBelow!,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/category_wheel.dart`

**Typ:** Dart  
**Zeilen:** 372

**Vollständiger Code:**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double kWheelWidth = 280.0;
const double kWheelHeight = 72.0;
const double kWheelItemExtent = 34.0;
const double kWheelPillWidth = 240.0;
const double kWheelPillRadius = 14.0;

const double kWheelActiveOpacity = 1.0;
const double kWheelNeighborOpacity = 0.55;
const double kWheelFarOpacity = 0.30;

const double kWheelActiveScale = 1.00;
const double kWheelNeighborScale = 0.94;
const double kWheelFarScale = 0.88;

const double kWheelGlowBlur = 18.0;
const double kWheelGlowOpacity = 0.35;

const double kWheelEdgeFadeHeight = 24.0;

const double kWheelArrowRightOut = 22.0;
const int kWheelArrowAutoHideMs = 800;
const double kWheelArrowNudge = 0.0;

/// Reine UI-Komponente – liefert den gedimmten Wheel-Selector.
/// `onChanged(index, label)` wird bei Auswahl aufgerufen.
class CategoryWheel extends StatefulWidget {
  final List<String> categories;
  final int initialIndex;
  final void Function(int index, String label) onChanged;

  const CategoryWheel({
    super.key,
    required this.categories,
    required this.initialIndex,
    required this.onChanged,
  });

  @override
  State<CategoryWheel> createState() => _CategoryWheelState();
}

class _CategoryWheelState extends State<CategoryWheel>
    with SingleTickerProviderStateMixin {
  Timer? _notifyDebounce;
  late FixedExtentScrollController _ctrl;
  late int _current;
  bool _showArrows = false;
  bool _flashUp = false;
  bool _flashDown = false;
  DateTime _lastMove = DateTime.now();

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex.clamp(0, (widget.categories.length - 1).clamp(0, 9999));
    _ctrl = FixedExtentScrollController(initialItem: _current);
  }

  @override
  void dispose() {
    _notifyDebounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CategoryWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.categories.length != oldWidget.categories.length) {
      _current = _current.clamp(0, (widget.categories.length - 1).clamp(0, 9999));
    }

    if (widget.initialIndex != oldWidget.initialIndex &&
        !_ctrl.position.isScrollingNotifier.value) {
      final newIndex =
          widget.initialIndex.clamp(0, (widget.categories.length - 1).clamp(0, 9999));
      _current = newIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ctrl.jumpToItem(_current);
      });
    }
  }

  void _onChanged(int idx) {
    if (idx == _current) return;
    final oldCurrent = _current;
    setState(() {
      _flashUp = idx < oldCurrent;
      _flashDown = idx > oldCurrent;
      _showArrows = true;
      _current = idx;
      _lastMove = DateTime.now();
    });

    HapticFeedback.lightImpact();

    Future.delayed(const Duration(milliseconds: kWheelArrowAutoHideMs), () {
      if (mounted &&
          DateTime.now().difference(_lastMove).inMilliseconds >=
              kWheelArrowAutoHideMs) {
        setState(() => _showArrows = false);
      }
    });

    widget.onChanged(idx, widget.categories[idx]);
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.categories;
    if (cats.isEmpty) {
      return Container(
        width: kWheelWidth,
        height: kWheelHeight,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('Loading...', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return SizedBox(
      width: kWheelWidth,
      height: kWheelHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _EdgeFade(
            fadeHeight: kWheelEdgeFadeHeight,
            child: ListWheelScrollView.useDelegate(
              controller: _ctrl,
              itemExtent: kWheelItemExtent,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: _onChanged,
              diameterRatio: 2.2,
              perspective: 0.002,
              overAndUnderCenterOpacity: 1,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: cats.length,
                builder: (context, index) {
                  final dist = (index - _current).abs();

                  final opacity = dist == 0
                      ? kWheelActiveOpacity
                      : (dist == 1 ? kWheelNeighborOpacity : kWheelFarOpacity);

                  final scale = dist == 0
                      ? kWheelActiveScale
                      : (dist == 1 ? kWheelNeighborScale : kWheelFarScale);

                  return Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 120),
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: _AdaptivePill(
                          text: cats[index],
                          width: kWheelPillWidth,
                          height: kWheelItemExtent - 6,
                          radius: kWheelPillRadius,
                          active: dist == 0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // rechte Pfeile
          Positioned.fill(
            right: -kWheelArrowRightOut,
            child: IgnorePointer(
              ignoring: false,
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showArrows ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: kWheelArrowNudge),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ArrowIcon(
                          up: true,
                          flash: _flashUp,
                          onTap: () => _ctrl.animateToItem(
                            (_current - 1).clamp(0, cats.length - 1),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _ArrowIcon(
                          up: false,
                          flash: _flashDown,
                          onTap: () => _ctrl.animateToItem(
                            (_current + 1).clamp(0, cats.length - 1),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptivePill extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final double radius;
  final bool active;

  const _AdaptivePill({
    required this.text,
    required this.width,
    required this.height,
    required this.radius,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2C2C),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white24),
        boxShadow: active && kWheelGlowBlur > 0
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(kWheelGlowOpacity),
                  blurRadius: kWheelGlowBlur,
                ),
              ]
            : const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: Colors.white,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgeFade extends StatelessWidget {
  final double fadeHeight;
  final Widget child;
  const _EdgeFade({required this.fadeHeight, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 0, right: 0, top: 0, height: fadeHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0, right: 0, bottom: 0, height: fadeHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  final bool up;
  final bool flash;
  final VoidCallback onTap;
  const _ArrowIcon({required this.up, required this.flash, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: 0.7,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          alignment: Alignment.center,
          child: Icon(
            up ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/category_wheel_example.dart`

**Typ:** Dart  
**Zeilen:** 125

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/category_controller.dart';
import 'package:talvori/features/words/ui/widgets/shimmer_list.dart';
import 'package:talvori/ui/common/mini_badge.dart';

/// Beispiel für die Verwendung des CategoryController im UI
class CategoryWheelExample extends ConsumerWidget {
  const CategoryWheelExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catState = ref.watch(categoryControllerProvider);

    return Column(
      children: [
        if (catState.offline) const MiniBadge(icon: Icons.cloud_off, label: 'Offline'),
        Expanded(
          child: _buildContent(catState, ref),
        ),
      ],
    );
  }

  Widget _buildContent(CategoryState catState, WidgetRef ref) {
    // Mikro-Check
    debugPrint('wheel: loading=${catState.loading} items=${catState.categories.length}');

    if (catState.loading && catState.categories.isEmpty) {
      return const ShimmerList(items: 5); // Shimmer während Loading
    }

    if (catState.error != null && catState.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Fehler: ${catState.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(categoryControllerProvider.notifier).refresh(),
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: catState.categories.length,
      itemBuilder: (context, index) {
        final category = catState.categories[index];
        return ListTile(
          title: Text(category.name),
          subtitle: Text('${category.wordCount} Wörter'),
          trailing: Text(category.slug),
        );
      },
    );
  }
}

/// Erweiterte Verwendung mit Pull-to-Refresh
class CategoryWheelWithRefresh extends ConsumerWidget {
  const CategoryWheelWithRefresh({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catState = ref.watch(categoryControllerProvider);

    return Column(
      children: [
        if (catState.offline) const MiniBadge(icon: Icons.cloud_off, label: 'Offline'),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(categoryControllerProvider.notifier).refresh(),
            child: _buildRefreshContent(catState, ref, context),
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshContent(CategoryState catState, WidgetRef ref, BuildContext context) {
    if (catState.loading && catState.categories.isEmpty) {
      return const ShimmerList(items: 5);
    }

    if (catState.error != null && catState.categories.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Fehler: ${catState.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(categoryControllerProvider.notifier).refresh(),
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return catState.categories.isEmpty
        ? const Center(child: Text('Keine Kategorien gefunden'))
        : ListView.builder(
            itemCount: catState.categories.length,
            itemBuilder: (context, index) {
              final category = catState.categories[index];
              return ListTile(
                title: Text(category.name),
                subtitle: Text('${category.wordCount} Wörter'),
                trailing: Text(category.slug),
              );
            },
          );
  }
}

```

---

### `lib/features/words/ui/widgets/empty_state.dart`

**Typ:** Dart  
**Zeilen:** 40

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String cta;
  final VoidCallback onTap;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: t.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: t.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, style: t.textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onTap, child: Text(cta)),
          ],
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/glow_circle_button.dart`

**Typ:** Dart  
**Zeilen:** 45

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class GlowCircleButton extends StatelessWidget {
  final double size;
  final Widget child;
  final VoidCallback? onTap;
  final Color outlineColor;
  final Color glowColor;

  const GlowCircleButton({
    super.key,
    required this.size,
    required this.child,
    this.onTap,
    required this.outlineColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2C2C),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: glowColor.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, -2)),
              BoxShadow(color: glowColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 4)),
              BoxShadow(color: glowColor.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 8)),
            ],
            border: Border.all(color: outlineColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/glow_rect_tile.dart`

**Typ:** Dart  
**Zeilen:** 118

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class GlowRectTile extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final String title;
  final Widget icon;
  final VoidCallback? onTap;
  final Color outlineColor;
  final Color glowColor;
  final String? badgeText;

  const GlowRectTile({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
    required this.title,
    required this.icon,
    this.onTap,
    this.outlineColor = Colors.white,
    this.glowColor = Colors.white,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final borderR = BorderRadius.circular(radius);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2C2C),
            borderRadius: borderR,
            boxShadow: [
              BoxShadow(color: glowColor.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, -2)),
              BoxShadow(color: glowColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 4)),
              BoxShadow(color: glowColor.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 8)),
            ],
            border: Border.all(color: outlineColor, width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: borderR),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: borderR,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    icon,
                  ],
                ),
              ),
            ),
          ),
        ),
        if (badgeText != null && badgeText!.isNotEmpty)
          Positioned(
            top: -8,
            right: -30,
            child: _CountBadge(text: badgeText!, outlineColor: outlineColor, glowColor: glowColor),
          ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String text;
  final Color outlineColor;
  final Color glowColor;

  const _CountBadge({
    required this.text,
    required this.outlineColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineColor, width: 1.5),
        boxShadow: [
          BoxShadow(color: glowColor.withOpacity(0.7), blurRadius: 3, offset: const Offset(0, -1)),
          BoxShadow(color: glowColor.withOpacity(0.7), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/grid_section.dart`

**Typ:** Dart  
**Zeilen:** 39

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'category_card.dart';

class GridSection extends StatelessWidget {
  final String sectionKey;
  final List<HubSubcat> subs;
  final void Function(HubSubcat sub)? onTapSub;

  const GridSection({
    required this.sectionKey,
    required this.subs,
    this.onTapSub,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => CategoryCard(
            sectionKey: sectionKey,
            sub: subs[i],
            onTap: onTapSub == null ? null : () => onTapSub!(subs[i]),
          ),
          childCount: subs.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/header_bar.dart`

**Typ:** Dart  
**Zeilen:** 60

**Vollständiger Code:**

```dart
// lib/features/words/ui/widgets/header_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'category_wheel.dart';

class HeaderBar extends ConsumerWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final categories = ref.watch(categoriesProvider);
    final s = ref.watch(learnModeControllerProvider);
    final c = ref.read(learnModeControllerProvider.notifier);

    return SizedBox(
      height: WordsUIConstants.headerHeight,
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(WordsUIConstants.borderRadius),
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: WordsUIConstants.iconSize,
              height: WordsUIConstants.iconSize,
              child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: WordsUIConstants.mediumSpacing),
          Expanded(
            child: Transform.translate(
              offset: WordsUIConstants.headerOffset,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: WordsUIConstants.loadingSize.width,
                        height: WordsUIConstants.loadingSize.height,
                        child: const Center(
                          child: CircularProgressIndicator(color: WordsUIConstants.loadingIndicator),
                        ),
                      )
                    : CategoryWheel(
                        categories: categories.map((c) => c.name).toList(),
                        initialIndex: s.selectedCategoryIndex,
                        onChanged: (idx, label) async {
                          // Kategorie umschalten → macht Controller (lädt Stages + Queue)
                          await c.selectCategoryIndex(idx);
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(width: WordsUIConstants.iconSize + WordsUIConstants.mediumSpacing),
        ],
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/learning_status_panel.dart`

**Typ:** Dart  
**Zeilen:** 166

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/widgets/progress_ring.dart';

class LearningStatusPanel extends StatelessWidget {
  final double percent;        // daily progress 0..1
  final String percentLabel;   // e.g. "15%"
  final int newCount;
  final int repeatsCount;
  final String repeatsOfTargetLabel; // e.g. "3/20"
  final double overallPercent; // overall 0..1
  final String overallLabel;   // e.g. "150/263"

  const LearningStatusPanel({
    super.key,
    required this.percent,
    required this.percentLabel,
    required this.newCount,
    required this.repeatsCount,
    required this.repeatsOfTargetLabel,
    required this.overallPercent,
    required this.overallLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, 10),
                child: ProgressRing(
                  size: 120,
                  thickness: 12,
                  percent: percent,
                  center: Text(percentLabel,
                      style: t.textTheme.titleSmall?.copyWith(color: Colors.white)),
                ),
              ),
              const Spacer(),
              Transform.translate(
                offset: const Offset(0, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Transform.translate(
                      offset: const Offset(-100, -30),
                      child: Text('Daily Progress',
                          style: t.textTheme.titleSmall?.copyWith(color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    _CounterRow(label: 'New', value: '$newCount'),
                    const SizedBox(height: 12),
                    _CounterRow(label: 'Repeats', value: repeatsOfTargetLabel),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _OverallProgressBar(percent: overallPercent, label: overallLabel),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final String value;
  const _CounterRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white)),
          const SizedBox(width: 8),
          Container(
            width: 75,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      );
}

class _OverallProgressBar extends StatelessWidget {
  final double percent;
  final String label;
  const _OverallProgressBar({required this.percent, required this.label});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overall Progress',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: ClipRRect(                            // ⬅️ NEU
                borderRadius: BorderRadius.circular(4),    // gleiche Radius wie Hintergrund
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percent.clamp(0.0, 1.0),
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE4B866), Color(0xFFF5D492)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 75,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF2C2C2C)),
              ),
              alignment: Alignment.center,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            )
          ]),
        ],
      );
}

```

---

### `lib/features/words/ui/widgets/level_badge.dart`

**Typ:** Dart  
**Zeilen:** 84

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class LevelBadge extends StatelessWidget {
  final String? level;
  final int? stage;

  const LevelBadge({
    super.key,
    this.level,
    this.stage,
  });

  @override
  Widget build(BuildContext context) {
    final text = level ?? _mapStageToLevel(stage ?? 0);
    if (text.isEmpty) return const SizedBox.shrink();

    final color = _getLevelColor(text);
    final textColor = _getTextColor(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _mapStageToLevel(int s) {
    switch (s) {
      case 0: return 'A1';
      case 1: return 'A2';
      case 2: return 'B1';
      case 3: return 'B2';
      case 4: return 'C1';
      case 5: return 'C2';
      default: return '';
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return Colors.red.shade600;
      case 'A2':
        return Colors.orange.shade600;
      case 'B1':
        return Colors.yellow.shade600;
      case 'B2':
        return Colors.green.shade600;
      case 'C1':
        return Colors.blue.shade600;
      case 'C2':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  /// Bestimmt die optimale Schriftfarbe basierend auf der Hintergrundfarbe
  Color _getTextColor(Color backgroundColor) {
    // Berechne die relative Helligkeit der Hintergrundfarbe
    final luminance = backgroundColor.computeLuminance();

    // Wenn die Hintergrundfarbe hell ist (luminance > 0.5), verwende schwarze Schrift
    // Wenn die Hintergrundfarbe dunkel ist (luminance <= 0.5), verwende weiße Schrift
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

```

---

### `lib/features/words/ui/widgets/level_selector_buttons.dart`

**Typ:** Dart  
**Zeilen:** 109

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

/// Auswahl-Modi für die Levels-Schaltung
enum LevelSelectionMode { s0toS5, s1toS5, single }

/// Drei schlanke Buttons: [S0–S5] [S1–S5] [Single]
/// - Aktiv: Füllung #2D2C2E, weißer Rand + Glow, Text weiß
/// - Inaktiv: nur Rand #2D2C2E, Innen transparent, Text ausgegraut
class LevelSelectorButtons extends StatelessWidget {
  const LevelSelectorButtons({
    super.key,
    required this.mode,
    required this.onModeChanged,
    this.spacing = 20, // Mehr Abstand zwischen den Buttons
  });

  final LevelSelectionMode mode;
  final ValueChanged<LevelSelectionMode> onModeChanged;
  final double spacing;

  static const _w = 87.0;
  static const _h = 27.0;
  static const _r = 13.5;
  static const _activeFill = Color(0xFF2D2C2E);
  static const _inactiveStroke = Color(0xFF2D2C2E);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModeButton(
          label: 'S0–S5',
          selected: mode == LevelSelectionMode.s0toS5,
          onTap: () => onModeChanged(LevelSelectionMode.s0toS5),
        ),
        SizedBox(width: spacing),
        _ModeButton(
          label: 'S1–S5',
          selected: mode == LevelSelectionMode.s1toS5,
          onTap: () => onModeChanged(LevelSelectionMode.s1toS5),
        ),
        SizedBox(width: spacing),
        _ModeButton(
          label: 'Single',
          selected: mode == LevelSelectionMode.single,
          onTap: () => onModeChanged(LevelSelectionMode.single),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _w = LevelSelectorButtons._w;
  static const _h = LevelSelectorButtons._h;
  static const _r = LevelSelectorButtons._r;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: selected
              ? Colors.white
              : Colors.white.withOpacity(0.45), // ausgegraut
        );

    final decoration = BoxDecoration(
      color: selected ? LevelSelectorButtons._activeFill : Colors.transparent,
      borderRadius: BorderRadius.circular(_r),
      border: Border.all(
        color: selected ? Colors.white : LevelSelectorButtons._inactiveStroke,
        width: selected ? 1.5 : 1.0,
      ),
      boxShadow: selected
          ? [
              // sanfter weißer Glow
              BoxShadow(
                color: Colors.white.withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ]
          : null,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: _w,
        height: _h,
        alignment: Alignment.center,
        decoration: decoration,
        child: Text(label, style: textStyle),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/levels_card.dart`

**Typ:** Dart  
**Zeilen:** 202

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/ui/widgets/stage_switch_row.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/application/s0_lock_provider.dart';

class LevelsCard extends ConsumerStatefulWidget {
  final double height;
  final List<int> stages;
  final int goalPerStage;
  final Future<void> Function() onStartPressed;
  final LevelSelectionMode mode;
  final void Function(LevelSelectionMode) onModeChanged;

  // Layout-Knobs (standard-Werte wie vorher)
  final double outerPadL;
  final double outerPadT;
  final double outerPadR;
  final double outerPadB;
  final double titleOffsetX;
  final double titleOffsetY;
  final double switchesOffsetX;
  final double switchesOffsetY;
  final double startBtnOffsetX;
  final double startBtnOffsetY;
  final double switchGap;
  final bool selectingSingle;                      // ← NEU
  final ValueChanged<int>? onSelectSingleStage;    // ← NEU
  final List<bool>? visibleMask;                   // ← NEU

  const LevelsCard({
    super.key,
    required this.height,
    required this.stages,
    required this.goalPerStage,
    required this.onStartPressed,
    required this.mode,
    required this.onModeChanged,
    this.outerPadL = 20.0,
    this.outerPadT = 8.0,
    this.outerPadR = 20.0,
    this.outerPadB = 0.0,
    this.titleOffsetX = 0.0,
    this.titleOffsetY = 0.0,
    this.switchesOffsetX = WordsLayout.switchesOffsetX,
    this.switchesOffsetY = WordsLayout.switchesOffsetY,
    this.startBtnOffsetX = WordsLayout.startBtnOffsetX,
    this.startBtnOffsetY = WordsLayout.startBtnOffsetY,
    this.switchGap = WordsLayout.switchGap,
    this.selectingSingle = false,                  // ← NEU
    this.onSelectSingleStage,                      // ← NEU
    this.visibleMask,                              // ← NEU
  });

  @override
  ConsumerState<LevelsCard> createState() => _LevelsCardState();
}

class _LevelsCardState extends ConsumerState<LevelsCard> {
  final _switchCtrl = StageSwitchRowController();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = (widget.stages.length >= 6) ? widget.stages : [0, 0, 0, 0, 0, 0];
    final srs = ref.watch(srsModeControllerProvider);
    // Stroke: in T/A ausblenden, in Hybrid wie gehabt
    final Color stroke = () {
      switch (srs.mode) {
        case SrsSystem.time:
          return Colors.transparent;
        case SrsSystem.adaptive:
          return Colors.transparent;
        case SrsSystem.hybrid:
          return Colors.white24;
      }
    }();
    // Inner-Fill: T = schwarz, A = helleres Grau, Hybrid = 0xFF2D2D2F
    final Color innerFill = () {
      switch (srs.mode) {
        case SrsSystem.time:
          return const Color(0xFF1A1A1A);
        case SrsSystem.adaptive:
          return const Color(0xFF162743);
        case SrsSystem.hybrid:
          return const Color(0xFF2D2D2F);
      }
    }();
    final String prefix = () {
      switch (srs.mode) {
        case SrsSystem.time:
          return 'T';
        case SrsSystem.adaptive:
          return 'A';
        case SrsSystem.hybrid:
          return '';
      }
    }();

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: Padding(
        padding: EdgeInsets.fromLTRB(widget.outerPadL, widget.outerPadT, widget.outerPadR, widget.outerPadB),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Transform.translate(
              offset: Offset(widget.titleOffsetX, widget.titleOffsetY),
              child: Center(
                child: LevelSelectorButtons(
                  mode: widget.mode,
                  onModeChanged: (m) async {
                    widget.onModeChanged(m); // nach außen melden

                    if (m == LevelSelectionMode.s0toS5) {
                      await _switchCtrl.blinkS0toS5();
                    } else if (m == LevelSelectionMode.s1toS5) {
                      await _switchCtrl.blinkS1toS5();
                    } else {
                      await _switchCtrl.blinkSequentialS1toS5();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Transform.translate(
                  offset: Offset(widget.switchesOffsetX, widget.switchesOffsetY),
                  child: StageSwitchRow(
                    controller: _switchCtrl,
                    counts: s,
                    goalPerStage: widget.goalPerStage,
                    gap: widget.switchGap,
                    sizes: const StageSwitchSizes(
                        width: 42, height: 75, knobTop: 2, knobBottom: 18),
                    colors: StageSwitchColors(
                      newOuter: Color(0xFFA05260),
                      stageOuter: Color(0xFFE4B866),
                      inner: innerFill,
                      disabledOuter: Colors.white,
                      innerStroke: stroke,
                    ),
                    labels: StageSwitchLabels(
                        newLabel: 'New', newNote: '0', stagePrefix: prefix),
                    selectable: widget.mode == LevelSelectionMode.single,   // ← NEU
                    idlePulse: widget.mode == LevelSelectionMode.single && widget.selectingSingle, // ← NEU
                    selectedStageHighlight: (widget.mode == LevelSelectionMode.single) ? ref.read(singleStageProvider) : null, // ← NEU
                    // ✅ KEINE visibleMask hier im Kategorie-Screen
                    s0Locked: ref.watch(s0LockedProvider),
                    onTapS0: () async {
                      final notifier = ref.read(s0LockedProvider.notifier);
                      final wasLocked = notifier.state;
                      notifier.state = !wasLocked;

                      // NEU: Wenn gerade ENTSPERRT wurde → einmal S0 blinken lassen
                      if (wasLocked) {
                        await _switchCtrl.blinkS0Once();
                      }
                    },
                    onSelectStage: (stg) {
                      // Nutzer hat S1..S5 gewählt:
                      widget.onSelectSingleStage?.call(stg); // ← wir fügen Props hinzu
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Transform.translate(
              offset: Offset(widget.startBtnOffsetX, widget.startBtnOffsetY),
              child: Center(
                child: SizedBox(
                  width: 138,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2D2D2F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    onPressed: widget.onStartPressed,
                    child: const Text('Start'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/list_end_footer.dart`

**Typ:** Dart  
**Zeilen:** 24

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class ListEndFooter extends StatelessWidget {
  final bool loading;
  final bool showDone;
  const ListEndFooter({super.key, required this.loading, this.showDone = false});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (showDone) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('— alles geladen —')),
      );
    }
    return const SizedBox.shrink();
  }
}

```

---

### `lib/features/words/ui/widgets/menu_sheet.dart`

**Typ:** Dart  
**Zeilen:** 68

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const MenuItemData(this.icon, this.label, this.onTap);
}

Future<void> showWordsMenuSheet(
  BuildContext context, {
  required List<MenuItemData> items,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black.withOpacity(0.75),
    barrierColor: Colors.black.withOpacity(0.85),
    builder: (_) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((it) => _MenuItem(it)).toList(),
        ),
      ),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final MenuItemData data;
  const _MenuItem(this.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1.0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Navigator.of(context).pop();
              data.onTap();
            },
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(data.icon, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(data.label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

```

---

### `lib/features/words/ui/widgets/mini_badge.dart`

**Typ:** Dart  
**Zeilen:** 32

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class MiniBadge extends StatelessWidget {
  final IconData? icon;
  final String label;

  const MiniBadge({this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14),
            const SizedBox(width: 4),
          ],
          Text(label, style: t.textTheme.labelSmall),
        ],
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/mode_toggle.dart`

**Typ:** Dart  
**Zeilen:** 73

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/learning_engine_provider.dart';

class LearningEngineToggle extends ConsumerWidget {
  const LearningEngineToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(learningEngineProvider);
    final isAdaptive = engine == LearningEngine.adaptiveSRS;
    // Aktive Label-Farbe (goldener Ton mit besserem Kontrast)
    const activeC = Color(0xFFE5B966);
    const inactiveC = Colors.white70;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'T-SRS',
          style: TextStyle(
            color: engine == LearningEngine.timeSRS ? activeC : inactiveC,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            shadows: engine == LearningEngine.timeSRS
                ? [
                    Shadow(color: activeC.withOpacity(0.30), blurRadius: 6, offset: const Offset(0, 2)),
                    Shadow(color: activeC.withOpacity(0.45), blurRadius: 12, offset: const Offset(0, 6)),
                    Shadow(color: activeC.withOpacity(0.60), blurRadius: 18, offset: const Offset(0, 12)),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 80, height: 44,
          child: Center(
            child: Transform.scale(
              scale: 1.25,
              child: Switch(
                value: isAdaptive,
                onChanged: (v) => ref
                    .read(learningEngineProvider.notifier)
                    .state = v ? LearningEngine.adaptiveSRS
                               : LearningEngine.timeSRS,
                // Farben gemäß Vorgabe
                thumbColor: const MaterialStatePropertyAll(Color(0xFFAFCCFE)),
                trackColor: const MaterialStatePropertyAll(Color(0xFF2C2C2C)),
                trackOutlineColor: const MaterialStatePropertyAll(Color(0xFFAFCCFE)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'A-SRS',
          style: TextStyle(
            color: engine == LearningEngine.adaptiveSRS ? activeC : inactiveC,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            shadows: engine == LearningEngine.adaptiveSRS
                ? [
                    Shadow(color: activeC.withOpacity(0.30), blurRadius: 6, offset: const Offset(0, 2)),
                    Shadow(color: activeC.withOpacity(0.45), blurRadius: 12, offset: const Offset(0, 6)),
                    Shadow(color: activeC.withOpacity(0.60), blurRadius: 18, offset: const Offset(0, 12)),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}

```

---

### `lib/features/words/ui/widgets/play_pause_button.dart`

**Typ:** Dart  
**Zeilen:** 41

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const PlayPauseButton({super.key, required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/progress_ring.dart`

**Typ:** Dart  
**Zeilen:** 101

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double size;
  final double thickness;
  final double percent; // 0..1
  final Widget? center;

  const ProgressRing({
    super.key,
    required this.size,
    required this.thickness,
    required this.percent,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              percent: percent.clamp(0, 1),
              thickness: thickness,
              bgColor: Colors.white.withOpacity(0.12),
              fgColor: Colors.white,
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final double thickness;
  final Color bgColor;
  final Color fgColor;

  _RingPainter({
    required this.percent,
    required this.thickness,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2 - thickness / 2;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = fgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Hintergrund
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -90 * (3.1415926535 / 180),
      360 * (3.1415926535 / 180),
      false,
      bgPaint,
    );

    // Fortschritt
    final sweep = 360 * percent;
    if (sweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -90 * (3.1415926535 / 180),
        sweep * (3.1415926535 / 180),
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.percent != percent ||
        old.thickness != thickness ||
        old.bgColor != bgColor ||
        old.fgColor != fgColor;
  }
}

```

---

### `lib/features/words/ui/widgets/reset_button.dart`

**Typ:** Dart  
**Zeilen:** 159

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reset-Button mit Hold-to-Confirm:
/// - Langes Drücken startet einen 3s-Countdown im Fullscreen-Overlay.
/// - Haptik bei Start & Abschluss.
/// - Finger loslassen → Abbruch.
/// - Nach Ablauf wird [onResetComplete] aufgerufen.
class ResetButton extends StatefulWidget {
  final Future<void> Function() onResetComplete;

  const ResetButton({super.key, required this.onResetComplete});

  @override
  State<ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<ResetButton> {
  bool _isPressed = false;
  int _countdown = 3;
  OverlayEntry? _overlayEntry;

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isPressed = true;
      _countdown = 3;
    });

    HapticFeedback.mediumImpact();
    _showOverlay();
    _startCountdown();
  }

  void _onLongPressEnd(LongPressEndDetails details) => _cancel();
  void _onLongPressCancel() => _cancel();

  void _cancel() {
    setState(() {
      _isPressed = false;
      _countdown = 3;
    });
    _removeOverlay();
    HapticFeedback.lightImpact();
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Reset',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  )),
              const SizedBox(height: 8),
              const Text('Lernfortschritt?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 40),
              StatefulBuilder(
                builder: (context, setOverlayState) => Text(
                  '$_countdown',
                  style: const TextStyle(
                    color: Color(0xFFA05260),
                    fontSize: 80,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text('Finger gedrückt halten...',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      if (!_isPressed) {
        _removeOverlay();
        return;
      }
      setState(() => _countdown = i);
      _overlayEntry?.markNeedsBuild();
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!_isPressed) {
      _removeOverlay();
      return;
    }

    _removeOverlay();
    HapticFeedback.heavyImpact();

    await widget.onResetComplete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lernfortschritt wurde zurückgesetzt'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFFA05260),
      ));
    }

    setState(() {
      _isPressed = false;
      _countdown = 3;
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFFA05260) : const Color(0xFF2D2D2F),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.refresh_rounded,
          color: _isPressed ? Colors.white : Colors.white70,
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/section_header.dart`

**Typ:** Dart  
**Zeilen:** 19

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/shimmer_box.dart`

**Typ:** Dart  
**Zeilen:** 41

**Vollständiger Code:**

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  final double height;
  final double borderRadius;
  const ShimmerBox({super.key, this.height = 16, this.borderRadius = 8});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final hi = Theme.of(context).colorScheme.surface;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = (math.sin((_c.value * 2 * math.pi)) + 1) / 2; // 0..1
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, Color.lerp(base, hi, 0.5)!, base],
              stops: [0, t.clamp(0.2, 0.8), 1],
            ),
          ),
        );
      },
    );
  }
}

```

---

### `lib/features/words/ui/widgets/shimmer_list.dart`

**Typ:** Dart  
**Zeilen:** 101

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class ShimmerList extends StatefulWidget {
  final int items;
  const ShimmerList({super.key, this.items = 8});

  @override
  State<ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<ShimmerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final highlight = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);

    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: widget.items,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, __) => _ShimmerTile(
            t: _c.value,
            base: base,
            highlight: highlight,
          ),
        );
      },
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  final double t;
  final Color base;
  final Color highlight;

  const _ShimmerTile({required this.t, required this.base, required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: base,
      ),
      child: ShaderMask(
        shaderCallback: (rect) {
          final width = rect.width;
          final gradX = (t * (width + 200)) - 200; // wandernde Bande
          return LinearGradient(
            begin: Alignment(-1.0 + (gradX / width), 0.0),
            end: Alignment(1.0 + (gradX / width), 0.0),
            colors: [base, highlight, base],
            stops: const [0.35, 0.5, 0.65],
          ).createShader(rect);
        },
        blendMode: BlendMode.srcATop,
        child: Row(
          children: [
            const SizedBox(width: 12),
            _bar(width: 56, height: 12, radius: 6),
            const SizedBox(width: 12),
            Expanded(child: _bar(width: double.infinity, height: 12, radius: 6)),
          ],
        ),
      ),
    );
  }

  Widget _bar({required double width, required double height, double radius = 8}) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/single_mode_switch_row.dart`

**Typ:** Dart  
**Zeilen:** 180

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'stage_switch_row.dart'; // für StageDrag

Offset knobDragAnchorStrategy(Draggable<Object> draggable, BuildContext context, Offset globalPosition) {
  return const Offset(19.0, 80.0);
}

class SingleModeSwitchRow extends StatelessWidget {
  const SingleModeSwitchRow({
    super.key,
    required this.stageLabel,      // z.B. 'S2'
    required this.srcCount,
    required this.sr1Count,
    required this.sr2Count,
    required this.srPrefix,        // NEU
    this.innerStrokeColor,         // NEU
    required this.innerFillColor,  // NEU: dynamische Füllfarbe innen
    this.onBucketDrop,             // NEU
  });

  final String stageLabel;
  final int srcCount, sr1Count, sr2Count;
  // neu:
  final String srPrefix;              // z.B. 'T' / 'A' / '' (Hybrid)
  final Color? innerStrokeColor;      // Stroke-Farbe für die innere Kapsel
  final Color innerFillColor;         // Füllfarbe der inneren Kapsel
  final void Function(String fromBucket, String toBucket, int count)? onBucketDrop; // 'SRC'|'R1'|'R2'

  @override
  Widget build(BuildContext context) {
    Widget buildSwitch(String label, int count, {bool isFirst = false}) {
      // Gleiche Farben wie im S0-S5 Modus
      final Color outerColor = count > 0
          ? (isFirst
              ? const Color(0xFFA05260)  // Rot für den ersten Switch (S{n}) wenn aktiv
              : const Color(0xFFE4B866)) // Gold für andere aktive Switches
          : Colors.white;               // Inaktiv jetzt komplett Weiß

      final Color innerColor = innerFillColor; // aus Modus abgeleitet

      final bool highlight = count > 0 && count < 100; // Glow nur wenn 1-99 Karten

      // Glow nur für den äußeren Container (Gold oder Rot), nicht für die innere Kapsel
      final List<BoxShadow>? boxShadow = highlight
          ? [BoxShadow(color: outerColor.withOpacity(0.8), blurRadius: 14, spreadRadius: 1)]
          : null;

      return Container(
        margin: const EdgeInsets.only(right: 8), // WordsUIConstants.switchGap
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: WordsUIConstants.stageSwitchWidth,
              height: WordsUIConstants.stageSwitchHeight,
              decoration: BoxDecoration(
                color: outerColor,
                borderRadius: BorderRadius.circular(WordsUIConstants.stageSwitchRadius),
                boxShadow: boxShadow,
                border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    left: 2,
                    right: 2,
                    top: count > 0 ? 2.0 : 18.0, // _getSwitchPosition()
                    child: () {
                      final Widget knobCore = AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: 38,
                        height: 52,
                        decoration: BoxDecoration(
                          color: innerColor,
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: (innerStrokeColor ?? Colors.white24), width: 1.6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$count',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      );
                      return LongPressDraggable<StageDrag>(
                        data: StageDrag(isFirst ? 0 : (label.endsWith('R1') ? 1 : 2), count: 1),
                        child: knobCore,
                        childWhenDragging: Opacity(opacity: 0.35, child: knobCore),
                        feedback: _KnobFeedback(count: count, innerColor: innerColor, stroke: innerStrokeColor),
                        dragAnchorStrategy: knobDragAnchorStrategy,
                        feedbackOffset: Offset.zero,
                        maxSimultaneousDrags: count > 0 ? 1 : 0,
                      );
                    }(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    Widget _draggableBucket({required String bucket, required int count, required Widget child}) {
      final draggable = LongPressDraggable<StageDrag>(
        data: StageDrag(bucket == 'SRC' ? 0 : (bucket == 'R1' ? 1 : 2), count: 1),
        feedback: Opacity(opacity: 0.9, child: SizedBox(width: 38, height: 52, child: child)),
        childWhenDragging: Opacity(opacity: 0.35, child: child),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        maxSimultaneousDrags: count > 0 ? 1 : 0,
        child: child,
      );
      return DragTarget<StageDrag>(
        onWillAccept: (d) => d != null,
        onAccept: (d) {
          final from = (d.fromStage == 0) ? 'SRC' : (d.fromStage == 1 ? 'R1' : 'R2');
          onBucketDrop?.call(from, bucket, d.count);
        },
        builder: (_, __, ___) => draggable,
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: [
      _draggableBucket(
        bucket: 'SRC',
        count: srcCount,
        child: buildSwitch(stageLabel, srcCount, isFirst: true),
      ),
      _draggableBucket(
        bucket: 'R1',
        count: sr1Count,
        child: buildSwitch('${srPrefix}R1', sr1Count),
      ),
      _draggableBucket(
        bucket: 'R2',
        count: sr2Count,
        child: buildSwitch('${srPrefix}R2', sr2Count),
      ),
    ]);
  }
}

class _KnobFeedback extends StatelessWidget {
  final int count;
  final Color innerColor;
  final Color? stroke;
  const _KnobFeedback({required this.count, required this.innerColor, this.stroke});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: 38, height: 52,
        child: Container(
          decoration: BoxDecoration(
            color: innerColor,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: (stroke ?? Colors.white24), width: 1.6),
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/single_stage_picker.dart`

**Typ:** Dart  
**Zeilen:** 41

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class SingleStagePicker extends StatelessWidget {
  const SingleStagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Stufe wählen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(5, (i) {
                final stage = i + 1;
                return SizedBox(
                  width: 72, height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2D2C2E)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: const Color(0xFF2D2C2E),
                    ),
                    onPressed: () => Navigator.of(context).pop(stage),
                    child: Text('S$stage'),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/srs_mode_toggle.dart`

**Typ:** Dart  
**Zeilen:** 201

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';

class SrsModeToggle extends ConsumerWidget {
  const SrsModeToggle({super.key});

  static const _size = Size(80, 44);
  static const _gold = Color(0xFFE5B966);
  static const _track = Color(0xFF2C2C2C);
  static const _thumb = _gold;
  static const _outline = Color(0xFFAFCCFE); // blau: Stroke/Outline
  static const _activeTxt = _gold;
  static const _inactiveTxt = Colors.white70;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(srsModeControllerProvider);
    final ctrl = ref.read(srsModeControllerProvider.notifier);
    final mode = state.mode; // direkt aus Controller-State
    final isHybrid = mode == SrsSystem.hybrid;
    final isAdaptive = mode == SrsSystem.adaptive;
    final counting = state.counting;
    final count = state.count;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: ctrl.tap,
      // Long-Press vom übergeordneten Wrapper (SrsModeHybridWrapper) behandeln lassen
      onLongPressStart: (_) => ctrl.longPressStart(),   // ← NEU
      onLongPressEnd:   (_) => ctrl.longPressEnd(),     // ← NEU
      child: SizedBox(
        width: _size.width,
        height: _size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!isHybrid) _buildTA(ref, isAdaptive),
            if (isHybrid)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: ctrl.tap, // Hybrid -> zurück zu lastNonHybrid
                child: _buildHybridButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTA(WidgetRef ref, bool isAdaptive) {
    // Stack lässt uns außerhalb der 80×44 zeichnen, ohne Layout zu verbreitern.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Switch zentriert
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 36,
            height: 30,
            child: Transform.scale(
              scale: 1.0,
              child: AbsorbPointer(
                absorbing: true,
                child: Switch(
                  value: isAdaptive, // bewegt die Kugel visuell
                  onChanged: (_) {},
                  thumbColor: const MaterialStatePropertyAll(_thumb),
                  trackColor: const MaterialStatePropertyAll(_track),
                  trackOutlineColor: const MaterialStatePropertyAll(_outline),
                ),
              ),
            ),
          ),
        ),

        // T-SRS links, vertikal mittig
        Align(
          alignment: Alignment.centerLeft,
          child: Transform.translate(
            offset: const Offset(-46, 0), // nach außen schieben
            child: Container(
              decoration: !isAdaptive
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: _activeTxt.withOpacity(0.20), blurRadius: 16, spreadRadius: 3, offset: const Offset(0, 6)),
                        BoxShadow(color: _activeTxt.withOpacity(0.10), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 6)),
                      ],
                    )
                  : null,
              child: Text(
                'T-SRS',
                style: TextStyle(
                  color: !isAdaptive ? _activeTxt : _inactiveTxt,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  shadows: !isAdaptive
                      ? [Shadow(color: _activeTxt.withOpacity(0.25), blurRadius: 14, offset: Offset(0, 10))]
                      : null,
                ),
              ),
            ),
          ),
        ),

        // A-SRS rechts, vertikal mittig
        Align(
          alignment: Alignment.centerRight,
          child: Transform.translate(
            offset: const Offset(46, 0),
            child: Container(
              decoration: isAdaptive
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: _activeTxt.withOpacity(0.20), blurRadius: 16, spreadRadius: 1, offset: const Offset(0, 6)),
                        BoxShadow(color: _activeTxt.withOpacity(0.10), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 6)),
                      ],
                    )
                  : null,
              child: Text(
                'A-SRS',
                style: TextStyle(
                  color: isAdaptive ? _activeTxt : _inactiveTxt,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  shadows: isAdaptive
                      ? [Shadow(color: _activeTxt.withOpacity(0.25), blurRadius: 14, offset: Offset(0, 10))]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

    Widget _buildCountdown(int count) {
    // Overlay NICHT klickbar und oberhalb der Switch
    return IgnorePointer(
      ignoring: true,
      child: Transform.translate(
        offset: const Offset(0, -96), // höher über der Switch (Feinjustage: -88…-112)
        child: Container(
          width: 240,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24, width: 1),
            boxShadow: const [BoxShadow(blurRadius: 24, color: Colors.black54)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'System wird auf Hybrid umgestellt',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70, height: 1.1),
              ),
              const SizedBox(height: 6),
              Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHybridButton() {
    return Container(
      width: _size.width,
      height: _size.height,
      decoration: BoxDecoration(
        color: _gold,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(color: _gold.withOpacity(0.55), blurRadius: 20, spreadRadius: 1),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'Hybrid',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.black,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/srs_mode_toggle_with_hint.dart`

**Typ:** Dart  
**Zeilen:** 79

**Vollständiger Code:**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/widgets/srs_mode_toggle.dart';

class SrsModeToggleWithHint extends ConsumerStatefulWidget {
  const SrsModeToggleWithHint({
    super.key,
    this.toggleHeight = 44, // sichtbare Höhe des Toggles (anpassen falls nötig)
    this.gap = 6,           // Abstand unter dem Toggle
  });

  final double toggleHeight;
  final double gap;

  @override
  ConsumerState<SrsModeToggleWithHint> createState() => _SrsModeToggleWithHintState();
}

class _SrsModeToggleWithHintState extends ConsumerState<SrsModeToggleWithHint> {
  bool _show = false;
  Timer? _timer;

  void _flash() {
    _timer?.cancel();
    setState(() => _show = true);
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _show = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hinweis nur bei Wechsel T-SRS <-> A-SRS
    ref.listen<SrsModeState>(srsModeControllerProvider, (prev, next) {
      final f = prev?.mode, t = next.mode;
      if ((f == SrsSystem.time && t == SrsSystem.adaptive) ||
          (f == SrsSystem.adaptive && t == SrsSystem.time)) {
        _flash();
      }
    });

    // Fixe Box in Toggle-Höhe; Hint wird darunter GEMALT (ohne Layout-Shift)
    return SizedBox(
      height: widget.toggleHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          const SrsModeToggle(),
          if (_show)
            Positioned(
              top: widget.toggleHeight + widget.gap, // unter dem Toggle
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Long-press for Hybrid',
                    style: TextStyle(fontSize: 10, color: Colors.white, height: 1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/srs_visuals.dart`

**Typ:** Dart  
**Zeilen:** 46

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

/// UI-Helfer: rein präsentationsbezogen, liest Theme & SRS-Kind
enum SrsKind { tSrs, aSrs, neutral } // neutral für Hybrid

/// Stroke-Farbe für die innere Kapsel (S0–S5) je nach Modus:
Color innerCapsuleStrokeColor(ThemeData t, SrsKind kind) {
  final cs = t.colorScheme;
  switch (kind) {
    case SrsKind.tSrs:
      return cs.primary.withOpacity(0.70);        // ruhig, klar
    case SrsKind.aSrs:
      return cs.tertiary.withOpacity(0.70);       // harmonische Absetzung
    case SrsKind.neutral:
      return cs.outlineVariant.withOpacity(0.65); // Hybrid: neutral
  }
}

/// Optional: dezente Füllung (kannst du bei Bedarf nutzen)
Color? innerCapsuleFill(ThemeData t, SrsKind kind) {
  final cs = t.colorScheme;
  switch (kind) {
    case SrsKind.tSrs:
      return cs.primaryContainer.withOpacity(0.10);
    case SrsKind.aSrs:
      return cs.tertiaryContainer.withOpacity(0.10);
    case SrsKind.neutral:
      return cs.surfaceVariant.withOpacity(0.08);
  }
}

/// Label-Anzeige für Stages.
/// - T-SRS: "T0"–"T5"
/// - A-SRS: "A0"–"A5"
/// - Hybrid: "0"–"5" (neutral)
String stageLabel(int stage, SrsKind kind) {
  assert(stage >= 0 && stage <= 5);
  switch (kind) {
    case SrsKind.tSrs:
      return 'T$stage';
    case SrsKind.aSrs:
      return 'A$stage';
    case SrsKind.neutral:
      return '$stage';
  }
}

```

---

### `lib/features/words/ui/widgets/stage_switch_row.dart`

**Typ:** Dart  
**Zeilen:** 455

**Vollständiger Code:**

```dart
// lib/features/words/ui/widgets/stage_switch_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'vertical_stage_switch.dart';

// Knopf-Anker: Finger sitzt leicht UNTER dem Knopf, damit der Knopf sichtbar VOR dem Finger ist.
Offset knobDragAnchorStrategy(Draggable<Object> draggable, BuildContext context, Offset globalPosition) {
  // Knopfgröße: 38x52 -> Anker unten bei ~75% Höhe
  return const Offset(19.0, 80.0);
}

class StageDrag {
  final int fromStage; // 0..5
  final int count;     // vorerst 1
  const StageDrag(this.fromStage, {this.count = 1});
}

class StageSwitchRowController {
  _StageSwitchRowState? _state;
  void _attach(_StageSwitchRowState s) => _state = s;

  Future<void> blinkS0toS5() async => _state?._blinkIndices([0,1,2,3,4,5], repeats: 2);
  Future<void> blinkS1toS5() async => _state?._blinkIndices([1,2,3,4,5], repeats: 2);
  Future<void> blinkSequentialS1toS5() async => _state?._blinkIndices([1,2,3,4,5], repeats: 1, sequential: true);

  // NEU: nur S0 einmal aufglühen lassen
  Future<void> blinkS0Once() async => _state?._blinkIndices([0], repeats: 1);
}

class _KnobFeedback extends StatelessWidget {
  final int count;
  final Color innerColor;
  final Color? stroke;
  const _KnobFeedback({required this.count, required this.innerColor, this.stroke});
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: 38, height: 52,
        child: Container(
          decoration: BoxDecoration(
            color: innerColor,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: (stroke ?? Colors.white24), width: 1.6),
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class StageSwitchRow extends StatefulWidget {
  final List<int>? counts;
  final int? goalPerStage;
  final double? gap;
  final StageSwitchSizes? sizes;
  final StageSwitchColors? colors;
  final StageSwitchLabels? labels;
  final StageSwitchRowController? controller;
  final bool selectable;                 // ← NEU: Tippen erlaubt?
  final ValueChanged<int>? onSelectStage; // ← NEU: Callback bei Tap
  final bool idlePulse;                  // ← NEU: sanftes Pulsieren aller
  final List<bool>? visibleMask;         // ← NEU: List<bool> mit Länge 6
  final int? selectedStageHighlight;     // ← NEU: 1..5 (nur Single), null = keiner
  final void Function(int fromStage, int toStage, int count)? onStageDrop; // NEW
  final bool? s0Locked;                // ← NEU
  final VoidCallback? onTapS0;          // ← NEU

  const StageSwitchRow({
    super.key,
    this.counts,
    this.goalPerStage,
    this.gap,
    this.sizes,
    this.colors,
    this.labels,
    this.controller,
    this.selectable = false,                 // ← NEU: Tippen erlaubt?
    this.onSelectStage,                      // ← NEU: Callback bei Tap
    this.idlePulse = false,                  // ← NEU: sanftes Pulsieren aller
    this.visibleMask,                        // ← NEU: List<bool> mit Länge 6
    this.selectedStageHighlight,             // ← NEU: 1..5 (nur Single), null = keiner
    this.onStageDrop,
    this.s0Locked,
    this.onTapS0,
  });

  @override
  State<StageSwitchRow> createState() => _StageSwitchRowState();
}

class _StageSwitchRowState extends State<StageSwitchRow> with SingleTickerProviderStateMixin {
  final Set<int> _blinking = {}; // Indizes die kurz glühen
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse; // 0..1

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _maybeRunPulse();
  }

  @override
  void didUpdateWidget(covariant StageSwitchRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller?._attach(this);
    }
    _maybeRunPulse();
  }

  void _maybeRunPulse() {
    if (widget.idlePulse) {
      if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.stop();
    }
  }

  Future<void> _blinkIndices(List<int> indices, {int repeats = 2, bool sequential = false}) async {
    const on = Duration(milliseconds: 140);
    const off = Duration(milliseconds: 140);

    if (sequential) {
      for (final i in indices) {
        _blinking
          ..clear()
          ..add(i);
        setState(() {});
        await Future.delayed(on);
        _blinking.clear();
        setState(() {});
        await Future.delayed(off);
      }
      return;
    }

    for (int r = 0; r < repeats; r++) {
      _blinking
        ..clear()
        ..addAll(indices);
      setState(() {});
      await Future.delayed(on);
      _blinking.clear();
      setState(() {});
      await Future.delayed(off);
    }
  }

  // NEU: nur eine Stufe blinken (z. B. nach Auswahl)
  Future<void> _blinkOnly(int s) async => _blinkIndices([s], repeats: 1, sequential: false);

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wenn Parameter übergeben wurden, verwende diese (für category_detail_screen)
    if (widget.counts != null) {
      return _buildWithParams();
    }

    // Sonst verwende Riverpod (für learn_mode_screen)
    return Consumer(
      builder: (context, ref, child) {
        final stages = ref.watch(stagesProvider);
        return _buildWithStages(stages);
      },
    );
  }

  Widget _buildWithParams() {
    final s = widget.counts!;
    final goal = widget.goalPerStage ?? 100;
    final switchGap = widget.gap ?? 8.0;

    // 6er-Default wenn keine Maske übergeben
    final mask = widget.visibleMask ??
        const [true, true, true, true, true, true];

    // Welche Indizes sollen wirklich sichtbar sein?
    final visibleIndices = <int>[];
    for (var i = 0; i < 6; i++) {
      final show = i < mask.length ? mask[i] : true;
      if (show) visibleIndices.add(i);
    }

    final children = <Widget>[];

    for (var vi = 0; vi < visibleIndices.length; vi++) {
      final i = visibleIndices[vi];
      final isLast = vi == visibleIndices.length - 1;

      // Switch-Body für Index i
      Widget switchBody;

      if (i == 0) {
        // S0 (New) Switch: nur Drop-Ziel
        final bool locked = widget.s0Locked ?? false;
        switchBody = DragTarget<StageDrag>(
          onWillAccept: (data) => data != null && data.fromStage != 0,
          onAccept: (data) => widget.onStageDrop?.call(data.fromStage, 0, data.count),
          builder: (_, __, ___) => VerticalStageSwitch(
            count: s[0],
            outerColor: s[0] > 0 ? (widget.colors?.newOuter ?? const Color(0xFFA05260))
                         : (widget.colors?.disabledOuter ?? Colors.grey),
            innerColor: widget.colors?.inner ?? const Color(0xFF2D2C2C),
            innerStrokeColor: widget.colors?.innerStroke,
            highlight: s[0] > 0,
            completed: false,
            label: widget.labels?.newLabel ?? 'New',
            note: widget.labels?.newNote ?? '0',
            isFirst: true,
            glow: _blinking.contains(0),
            isLocked: locked,           // ← NEU: UI-Zustand
            onTap: widget.onTapS0,      // ← NEU: toggelt Lock
          ),
        );
      } else {
        // S1-S5 Switches
        final stage = i;
        final prefix = widget.labels?.stagePrefix ?? 'S';

        // Bestimme, ob gerade Blink (hart) oder Idle-Pulse (soft) greift
        final bool hardGlow = _blinking.contains(stage);
        final bool softGlow = widget.idlePulse && (stage >= 1);
        final bool isSelected = (widget.selectedStageHighlight != null) && (stage == widget.selectedStageHighlight);

        Widget knobbed = VerticalStageSwitch(
          count: s[stage],
          outerColor: s[stage] > 0 ? (widget.colors?.stageOuter ?? Colors.yellow) : (widget.colors?.disabledOuter ?? Colors.white),
          innerColor: widget.colors?.inner ?? Colors.grey,
          innerStrokeColor: widget.colors?.innerStroke,
          highlight: s[stage] > 0 && s[stage] < goal,
          completed: s[stage] >= goal,
          label: '$prefix$stage',
          note: '$prefix$stage',
          glow: hardGlow || softGlow || isSelected,
          pulseAnimation: softGlow ? _pulse : null,
          selectedHighlight: isSelected,
          knobWrapper: (knob) => LongPressDraggable<StageDrag>(
            data: StageDrag(stage, count: 1),
            child: knob,
            childWhenDragging: Opacity(opacity: 0.35, child: knob),
            feedback: _KnobFeedback(count: s[stage], innerColor: widget.colors?.inner ?? Colors.grey, stroke: widget.colors?.innerStroke),
            dragAnchorStrategy: knobDragAnchorStrategy,
            feedbackOffset: Offset.zero,
            maxSimultaneousDrags: s[stage] > 0 ? 1 : 0,
          ),
        );

        switchBody = DragTarget<StageDrag>(
          onWillAccept: (d) => d != null && d.fromStage != stage,
          onAccept: (d) => widget.onStageDrop?.call(d.fromStage, stage, d.count),
          builder: (_, __, ___) => knobbed,
        );
      }

      // Falls selektierbar (Single-Mode), Tap/LongPress wie gehabt:
      if (widget.selectable && i >= 1) {
        switchBody = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            widget.onSelectStage?.call(i);
            await _blinkOnly(i);
          },
          onLongPress: () {
            // TODO: später Karten verschieben
          },
          child: switchBody,
        );
      }

      children.add(
        Container(
          margin: EdgeInsets.only(right: isLast ? 0 : switchGap),
          child: switchBody,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildWithStages(List<int> stages) {
    // 6er-Default wenn keine Maske übergeben
    final mask = widget.visibleMask ??
        const [true, true, true, true, true, true];

    // Welche Indizes sollen wirklich sichtbar sein?
    final visibleIndices = <int>[];
    for (var i = 0; i < 6; i++) {
      final show = i < mask.length ? mask[i] : true;
      if (show) visibleIndices.add(i);
    }

    final children = <Widget>[];

    for (var vi = 0; vi < visibleIndices.length; vi++) {
      final i = visibleIndices[vi];
      final isLast = vi == visibleIndices.length - 1;

      // Switch-Body für Index i
      Widget switchBody;

      if (i == 0) {
        // S0 (New) Switch: nur Drop-Ziel
        final bool locked = widget.s0Locked ?? false;
        switchBody = DragTarget<StageDrag>(
          onWillAccept: (data) => data != null && data.fromStage != 0,
          onAccept: (data) => widget.onStageDrop?.call(data.fromStage, 0, data.count),
          builder: (_, __, ___) => VerticalStageSwitch(
            count: stages[0],
            outerColor: stages[0] > 0 ? WordsUIConstants.stageInnerRed : WordsUIConstants.stageInactive,
            innerColor: WordsUIConstants.stageInnerDark,
            highlight: stages[0] > 0,
            completed: false,
            label: 'New',
            note: '0',
            isFirst: true,
            glow: _blinking.contains(0),
            isLocked: locked,
            onTap: widget.onTapS0,
          ),
        );
      } else {
        // S1-S5 Switches
        final stage = i;
        Widget knobbed = VerticalStageSwitch(
          count: stages[stage],
          outerColor: stages[stage] > 0 ? WordsUIConstants.stageOuter : WordsUIConstants.stageInactive,
          innerColor: WordsUIConstants.stageInner,
          highlight: stages[stage] > 0 && stages[stage] < WordsUIConstants.stageGoal,
          completed: stages[stage] >= WordsUIConstants.stageGoal,
          label: 'S$stage',
          note: '$stage',
          glow: _blinking.contains(stage),
          knobWrapper: (knob) => LongPressDraggable<StageDrag>(
            data: StageDrag(stage, count: 1),
            child: knob,
            childWhenDragging: Opacity(opacity: 0.35, child: knob),
            feedback: const _KnobFeedback(count: 0, innerColor: WordsUIConstants.stageInner, stroke: null),
            dragAnchorStrategy: knobDragAnchorStrategy,
            feedbackOffset: Offset.zero,
            maxSimultaneousDrags: stages[stage] > 0 ? 1 : 0,
          ),
        );

        switchBody = DragTarget<StageDrag>(
          onWillAccept: (d) => d != null && d.fromStage != stage,
          onAccept: (d) => widget.onStageDrop?.call(d.fromStage, stage, d.count),
          builder: (_, __, ___) => knobbed,
        );
      }

      // Falls selektierbar (Single-Mode), Tap/LongPress wie gehabt:
      if (widget.selectable && i >= 1) {
        switchBody = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            widget.onSelectStage?.call(i);
            await _blinkOnly(i);
          },
          onLongPress: () {
            // TODO: später Karten verschieben
          },
          child: switchBody,
        );
      }

      children.add(
        Container(
          margin: EdgeInsets.only(right: isLast ? 0 : WordsUIConstants.switchGap),
          child: switchBody,
        ),
      );
    }

    return Padding(
      padding: WordsUIConstants.screenPadding,
      child: Transform.translate(
        offset: WordsUIConstants.switchOffset,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}


// Helper classes für Parameter
class StageSwitchSizes {
  final double width;
  final double height;
  final double knobTop;
  final double knobBottom;

  const StageSwitchSizes({
    required this.width,
    required this.height,
    required this.knobTop,
    required this.knobBottom,
  });
}

class StageSwitchColors {
  final Color newOuter;
  final Color stageOuter;
  final Color inner;
  final Color disabledOuter;
  final Color? innerStroke; // NEU

  const StageSwitchColors({
    required this.newOuter,
    required this.stageOuter,
    required this.inner,
    required this.disabledOuter,
    this.innerStroke,
  });
}

class StageSwitchLabels {
  final String newLabel;
  final String newNote;
  final String stagePrefix;

  const StageSwitchLabels({
    required this.newLabel,
    required this.newNote,
    required this.stagePrefix,
  });
}

```

---

### `lib/features/words/ui/widgets/stats_helpers.dart`

**Typ:** Dart  
**Zeilen:** 24

**Vollständiger Code:**

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// Lädt tägliche Lernstatistiken (heute) für eine Kategorie.
/// Returns: (newCount, repeatCount)
Future<(int, int)> loadDailyLearningStats(String categoryId) async {
  final prefs = await SharedPreferences.getInstance();
  final newToday = prefs.getInt('today_new_$categoryId') ?? 0;
  final repsToday = prefs.getInt('today_repeats_$categoryId') ?? 0;
  return (newToday, repsToday);
}

/// Stellt sicher, dass der "heute"-Bucket korrekt initialisiert ist (Tageswechsel reset).
Future<void> ensureTodayBucket(String categoryId) async {
  final prefs = await SharedPreferences.getInstance();
  final keyDate = 'today_date_$categoryId';
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final last = prefs.getString(keyDate);
  if (last != today) {
    prefs
      ..setString(keyDate, today)
      ..setInt('today_new_$categoryId', 0)
      ..setInt('today_repeats_$categoryId', 0);
  }
}

```

---

### `lib/features/words/ui/widgets/timer_bar.dart`

**Typ:** Dart  
**Zeilen:** 30

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/core/ui/widgets/progress_bar.dart';
import 'package:talvori/features/words/application/learn_mode_controller.dart';

class TimerBar extends StatelessWidget {
  final LearnModeState s;
  const TimerBar({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final progress = (s.remainingMillis / (s.timeLimit * 1000.0))
        .clamp(0.0, 1.0);
    final isLowTime = s.remainingMillis <= 3000;


    if (!s.timerActive) {
      return ProgressBar(value: 0.0, background: Colors.white10);
    }

    return ProgressBar(
      value: progress,
      background: Colors.black.withOpacity(0.15),
      gradient: LinearGradient(
        colors: isLowTime
            ? [Colors.red.shade700, Colors.red.shade400]
            : const [Color(0xFFB1CCFE), Color(0xFFD0E0FF)],
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/vertical_stage_switch.dart`

**Typ:** Dart  
**Zeilen:** 218

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';

class VerticalStageSwitch extends StatelessWidget {
  final int count;
  final Color outerColor;
  final Color innerColor;
  final bool highlight;
  final bool completed;
  final String label; // "S1" / "New" (nur für Semantik)
  final String note;  // "0".."5"
  final bool isFirst;
  final bool glow; // NEU: für Blink-Effekt
  final Animation<double>? pulseAnimation; // NEU: für sanftes Pulsieren
  final bool selectedHighlight; // NEU: für Single-Modus Hervorhebung
  final Color? innerStrokeColor; // NEU: injizierbarer Stroke der inneren Kapsel
  final Widget Function(Widget knob)? knobWrapper; // optionaler Wrapper nur um den Knopf
  final bool isLocked;              // ← NEU
  final VoidCallback? onTap;        // ← NEU

  const VerticalStageSwitch({
    super.key,
    required this.count,
    required this.outerColor,
    required this.innerColor,
    required this.highlight,
    required this.completed,
    required this.label,
    required this.note,
    this.isFirst = false,
    this.glow = false, // NEU: Standard false
    this.pulseAnimation, // NEU: für sanftes Pulsieren
    this.selectedHighlight = false, // NEU: für Single-Modus Hervorhebung
    this.innerStrokeColor,
    this.knobWrapper,
    this.isLocked = false,          // ← NEU (Default)
    this.onTap,                     // ← NEU
  });

  double _getSwitchPosition() => count > 0 ? 2.0 : 18.0;

  @override
  Widget build(BuildContext context) {
    final badgeGlow = highlight
        ? [BoxShadow(color: outerColor.withOpacity(0.8), blurRadius: 14, spreadRadius: 1)]
        : const <BoxShadow>[];

    return Padding(
      padding: EdgeInsets.only(left: isFirst ? 6 : 0, right: isFirst ? 4 : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onTap, // ← nur gesetzt, wenn übergeben (bei S0)
            child: Stack(
              children: [
                // Die Switch selbst mit Opacity (wird ausgebleicht)
                Opacity(
                  opacity: isLocked ? 0.45 : 1.0,     // 45% sichtbar, Ursprung bleibt erkennbar
                  child: Container(
                    width: WordsUIConstants.stageSwitchWidth,
                    height: WordsUIConstants.stageSwitchHeight,
                    decoration: BoxDecoration(
                      color: outerColor,
                      borderRadius: BorderRadius.circular(WordsUIConstants.stageSwitchRadius),
                      boxShadow: badgeGlow,
                      border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          left: 2,
                          right: 2,
                          top: _getSwitchPosition(),
                          child: pulseAnimation != null
                              ? AnimatedBuilder(
                                  animation: pulseAnimation!,
                                  builder: (context, child) {
                                    final double soft = 0.15 + 0.35 * pulseAnimation!.value; // 0.15..0.5
                                    final Color glowColor = const Color(0xFF00FF88);
                                    final Color accentColor = const Color(0xFF6FD3FF); // hellblau für "gewählt"
                                    final List<BoxShadow>? boxShadow = glow
                                        ? [
                                            BoxShadow(
                                              color: glowColor.withOpacity(0.85),
                                              blurRadius: 16,
                                              spreadRadius: 1.5,
                                            ),
                                          ]
                                        : (selectedHighlight
                                            ? [
                                                BoxShadow(
                                                  color: accentColor.withOpacity(0.5),
                                                  blurRadius: 14,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : [
                                                BoxShadow(
                                                  color: glowColor.withOpacity(soft),
                                                  blurRadius: 18,
                                                  spreadRadius: 2.0,
                                                ),
                                              ]);

                                    final Widget knobCore = AnimatedContainer(
                                      duration: const Duration(milliseconds: 120),
                                      width: 38,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: innerColor,
                                        borderRadius: BorderRadius.circular(21),
                                        border: glow
                                            ? Border.all(color: glowColor, width: 1)
                                            : (selectedHighlight
                                                ? Border.all(color: accentColor, width: 1)
                                                : Border.all(color: innerStrokeColor ?? Colors.white24, width: 1.6)),
                                        boxShadow: boxShadow,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$count',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                    final Widget knob = knobWrapper != null ? knobWrapper!(knobCore) : knobCore;
                                    return knob;
                                  },
                                )
                              : () {
                                  final Widget knobCore = AnimatedContainer(
                                  duration: const Duration(milliseconds: 120),
                                  width: 38,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: innerColor,
                                    borderRadius: BorderRadius.circular(21),
                                    border: glow
                                        ? Border.all(color: const Color(0xFF00FF88), width: 1)
                                        : (selectedHighlight
                                            ? Border.all(color: const Color(0xFF6FD3FF), width: 1)
                                            : Border.all(color: innerStrokeColor ?? Colors.white24, width: 1.6)),
                                    boxShadow: glow
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF00FF88).withOpacity(0.85), // Grün-Glow
                                              blurRadius: 16,
                                              spreadRadius: 1.5,
                                            ),
                                          ]
                                        : (selectedHighlight
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF6FD3FF).withOpacity(0.5),
                                                  blurRadius: 14,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  );
                                  final Widget knob = knobWrapper != null ? knobWrapper!(knobCore) : knobCore;
                                  return knob;
                                }(),
                        ),
                      ],
                    ),
                  ),
                ),

                // NEU: Schloss-Overlay (zentriert ÜBER der ganzen Switch, außerhalb des Opacity)
                if (isLocked)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 42,
            child: Text(
              note,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

```

---

### `lib/features/words/ui/widgets/widgets.dart`

**Typ:** Dart  
**Zeilen:** 18

**Vollständiger Code:**

```dart
export 'reset_button.dart';
export 'vertical_stage_switch.dart';
export 'package:talvori/core/ui/widgets/round_icon.dart';
export 'play_pause_button.dart';
export 'cancel_timer_button.dart';
export 'timer_bar.dart';
export 'category_wheel.dart';
export 'level_badge.dart';
export 'menu_sheet.dart';
export 'header_bar.dart';
export 'card_area.dart';
export 'stage_switch_row.dart';
export 'bottom_controls.dart';
export 'section_header.dart';
export 'mini_badge.dart';
export 'category_card.dart';
export 'grid_section.dart';
export 'package:talvori/features/words/application/category_stats_provider.dart';

```

---

### `lib/features/words/ui/widgets/word_list_item.dart`

**Typ:** Dart  
**Zeilen:** 30

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/features/words/domain/word.dart';

class WordListItem extends StatelessWidget {
  final Word word;
  final bool picked;
  final VoidCallback onTogglePick;
  final VoidCallback? onTap;

  const WordListItem({
    super.key,
    required this.word,
    required this.picked,
    required this.onTogglePick,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(word.text),
      subtitle: Text(word.translation),
      trailing: IconButton(
        icon: Icon(picked ? Icons.check_circle : Icons.add_circle_outline),
        onPressed: onTogglePick,
      ),
      onTap: onTap,
    );
  }
}

```

---

### `lib/features/words/ui/widgets/word_list_toolbar.dart`

**Typ:** Dart  
**Zeilen:** 64

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/ui/common/mini_badge.dart';

class WordListToolbar extends StatelessWidget {
  final ValueChanged<String> onQueryChanged;
  final SortMode sort;
  final ValueChanged<SortMode> onSortChanged;
  final int visibleCount;
  final bool offline; // NEU

  const WordListToolbar({
    super.key,
    required this.onQueryChanged,
    required this.sort,
    required this.onSortChanged,
    required this.visibleCount,
    this.offline = false, // NEU
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Suchen (Wort oder Übersetzung)',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<SortMode>(
                  segments: const [
                    ButtonSegment(value: SortMode.az, label: Text('A–Z')),
                    ButtonSegment(value: SortMode.newest, label: Text('Neueste')),
                  ],
                  selected: {sort},
                  onSelectionChanged: (s) => onSortChanged(s.first),
                ),
              ),
              const SizedBox(width: 12),
              Text('$visibleCount'),
              if (offline) ...[
                const SizedBox(width: 8),
                const MiniBadge(icon: Icons.cloud_off, label: 'Offline'),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

```

---

## Main Entry Point

### `lib/main.dart`

**Typ:** Dart  
**Zeilen:** 188

**Vollständiger Code:**

```dart
import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:talvori/core/theme/app_theme.dart';
import 'package:talvori/features/home/ui/screens/home_screen.dart';
import 'package:talvori/core/services/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Globale Fehler abfangen (zeigt dir Crashes im Log statt weißem Screen)
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    Zone.current.handleUncaughtError(details.exception, details.stack ?? StackTrace.empty);
  };

  runZonedGuarded(() {
    runApp(const ProviderScope(child: TalvoriApp()));
  }, (error, stack) {
    // Optional: an Crashlytics/Sentry senden
    debugPrint('Uncaught error: $error');
  });
}

class TalvoriApp extends ConsumerWidget {
  const TalvoriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Talvori',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _InitGate(child: HomeScreen()),
    );
  }
}

/// Lädt .env, initialisiert Supabase und (im Debug) loggt den Test-User ein.
/// Zeigt dabei klaren Lade- und Fehlerzustand statt „weißer Screen".
class _InitGate extends StatefulWidget {
  final Widget child;
  const _InitGate({required this.child});

  @override
  State<_InitGate> createState() => _InitGateState();
}

class _InitGateState extends State<_InitGate> {
  late Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = _initialize();
  }

  Future<void> _initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1) .env laden (mit Fallback)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print('⚠️ .env nicht gefunden, verwende .env.example');
      await dotenv.load(fileName: ".env.example");
    }

    // Debug: Prüfe ob Keys geladen werden
    print('URL=${dotenv.env['SUPABASE_URL']}');
    print('ANON=${dotenv.env['SUPABASE_ANON_KEY']?.substring(0, 8)}...');
    assert(dotenv.env['SUPABASE_URL']?.isNotEmpty == true, 'SUPABASE_URL missing');
    assert(dotenv.env['SUPABASE_ANON_KEY']?.isNotEmpty == true, 'SUPABASE_ANON_KEY missing');

    // 2) Supabase initialisieren (mit Fallback)
    print('🔧 Supabase URL: ${dotenv.env['SUPABASE_URL']}');
    print('🔧 Supabase Anon Key: ${dotenv.env['SUPABASE_ANON_KEY']?.substring(0, 20)}...');

    try {
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );
      print('✅ Supabase erfolgreich initialisiert');
    } catch (e) {
      print('❌ Supabase-Initialisierung fehlgeschlagen: $e');
      print('⚠️ App läuft im Offline-Modus');
      // App läuft trotzdem weiter, aber ohne Supabase
    }

    // 3) Debug-Auto-Login (nur wenn Supabase verfügbar)
    try {
      final auth = Supabase.instance.client.auth;
      print('🔧 Current user: ${auth.currentUser?.email ?? "Kein User"}');

      if (kDebugMode && auth.currentUser == null) {
        final email = dotenv.env['TEST_EMAIL'];
        final pw    = dotenv.env['TEST_PASSWORD'];
        print('🔧 Versuche Login mit: $email');

        if (email != null && pw != null && email.isNotEmpty && pw.isNotEmpty) {
          try {
            final result = await auth.signInWithPassword(email: email, password: pw)
                      .timeout(const Duration(seconds: 8));
            print('✅ Login erfolgreich: ${result.user?.email}');
          } on TimeoutException {
            print('⚠️ Login timeout – UI startet trotzdem');
          } catch (e) {
            print('❌ Login fehlgeschlagen: $e');
          }
        } else {
          print('⚠️ Keine Login-Credentials in .env gefunden');
        }
      }
    } catch (e) {
      print('⚠️ Supabase nicht verfügbar - Login übersprungen: $e');
    }

    // 4) Test-Datenbankverbindung (nur wenn Supabase verfügbar)
    try {
      final client = Supabase.instance.client;
      final response = await client.from('categories').select('count').limit(1);
      print('🔧 Datenbank-Test: ${response.length} Kategorien gefunden');
    } catch (e) {
      print('❌ Datenbank-Test fehlgeschlagen: $e');
      print('⚠️ App läuft ohne Datenbankverbindung');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_shared_word', 'umbrella'); // TEST-Wort

    // Logging hilft beim Teilen-Debug:
    try {
      debugPrint('Logged in as: ${Supabase.instance.client.auth.currentUser?.id}');
    } catch (e) {
      debugPrint('Kein User eingeloggt (Supabase nicht verfügbar)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          // Schlichter Splash/Ladezustand
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          // Klarer Fehlerbildschirm statt weiß
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    const Text('Initialisierung fehlgeschlagen'),
                    const SizedBox(height: 8),
                    Text(
                      '${snap.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() => _init = _initialize()),
                      child: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        // Fertig initialisiert → eigentliche App
        return widget.child;
      },
    );
  }
}
```

---

## UI/common

### `lib/ui/common/mini_badge.dart`

**Typ:** Dart  
**Zeilen:** 40

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';

class MiniBadge extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color? color;
  final EdgeInsets margin;

  const MiniBadge({
    super.key,
    this.icon,
    required this.label,
    this.color,
    this.margin = const EdgeInsets.only(right: 6),
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? t.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14),
            const SizedBox(width: 4),
          ],
          Text(label, style: t.textTheme.labelSmall),
        ],
      ),
    );
  }
}

```

---

### `lib/ui/common/mini_badge_examples.dart`

**Typ:** Dart  
**Zeilen:** 88

**Vollständiger Code:**

```dart
import 'package:flutter/material.dart';
import 'package:talvori/ui/common/mini_badge.dart';

/// Beispiele für verschiedene MiniBadge-Varianten
class MiniBadgeExamples extends StatelessWidget {
  const MiniBadgeExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MiniBadge Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Standard Badges:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                MiniBadge(icon: Icons.cloud_off, label: 'Offline'),
                MiniBadge(icon: Icons.star, label: 'Top 10'),
                MiniBadge(icon: Icons.new_releases, label: 'Neu'),
                MiniBadge(icon: Icons.trending_up, label: 'Trending'),
                MiniBadge(label: 'Text Only'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Custom Colors:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MiniBadge(
                  icon: Icons.star,
                  label: 'Premium',
                  color: Colors.amber.withOpacity(0.15),
                ),
                MiniBadge(
                  icon: Icons.error,
                  label: 'Error',
                  color: Colors.red.withOpacity(0.15),
                ),
                MiniBadge(
                  icon: Icons.check_circle,
                  label: 'Success',
                  color: Colors.green.withOpacity(0.15),
                ),
                MiniBadge(
                  icon: Icons.info,
                  label: 'Info',
                  color: Colors.blue.withOpacity(0.15),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Custom Margins:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                MiniBadge(
                  icon: Icons.cloud_off,
                  label: 'Offline',
                  margin: EdgeInsets.only(bottom: 6),
                ),
                MiniBadge(
                  icon: Icons.star,
                  label: 'Featured',
                  margin: EdgeInsets.symmetric(horizontal: 4),
                ),
                MiniBadge(
                  icon: Icons.new_releases,
                  label: 'New',
                  margin: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

```

---

## Supabase/ingest_word

### `supabase/functions/ingest_word/index.ts`

**Typ:** TypeScript  
**Zeilen:** 322

**Vollständiger Code:**

```typescript
// supabase/functions/ingest_word/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type Body = {
  id?: string; // optional: Force-Translate by UUID
  text?: string;
  fromLang: string;
  toLang: string;
  pos?: string; // optional: 'noun'|'verb'|'adj'|...
  mode?: "create" | "fix"; // 'create' (default) oder 'fix' für Re-Translate/QA
  formality?: "default" | "prefer_more" | "prefer_less";
};

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const deeplKey = Deno.env.get("DEEPL_API_KEY")!; // in Supabase Secrets
const glossaryId = Deno.env.get("DEEPL_GLOSSARY_ID") || ""; // optional
const deeplEndpoint = "https://api-free.deepl.com/v2/translate"; // oder api.deepl.com

function norm(s: string) {
  return s.trim();
}

// Text-Normalisierung: Trim + Whitespace auf einzelne Leerzeichen reduzieren + Case-insensitive
function normalizeText(s: string) {
  return s.replace(/\s+/g, " ").trim().toLowerCase();
}
function jaccard(a: string, b: string) {
  const A = new Set(a.toLowerCase().split(/\s+/));
  const B = new Set(b.toLowerCase().split(/\s+/));
  const inter = [...A].filter((x) => B.has(x)).length;
  return inter / (A.size + B.size - inter || 1);
}

async function deeplTranslate(
  texts: string[],
  source: string,
  target: string,
  formality?: string
) {
  const form = new URLSearchParams();
  form.append("auth_key", deeplKey);
  texts.forEach((t) => form.append("text", t));
  form.append("source_lang", source.toUpperCase());
  form.append("target_lang", target.toUpperCase());
  if (formality) form.append("formality", formality);
  // Tipp: Format beibehalten, bessere Terminologie
  form.append("preserve_formatting", "1");
  if (glossaryId) form.append("glossary_id", glossaryId);

  const res = await fetch(deeplEndpoint, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: form.toString(),
  });
  if (!res.ok) throw new Error(`DeepL ${res.status}`);
  const data = await res.json();
  return (data?.translations ?? []).map((t: any) => String(t.text));
}

serve(async (req) => {
  // Debug-Ping
  if (new URL(req.url).searchParams.get("debug") === "ping") {
    return new Response(
      JSON.stringify({ ok: true, fn: "ingest_word", build: "v5-qa" }),
      { status: 200 }
    );
  }

  try {
    const sbAdmin = createClient(supabaseUrl, serviceKey);

    const authHeader = req.headers.get("Authorization") ?? "";
    let userId: string | null = null;

    try {
      const sbAuth = createClient(supabaseUrl, serviceKey, {
        global: { headers: { Authorization: authHeader } },
      });
      const { data: auth } = await sbAuth.auth.getUser();
      userId = auth?.user?.id ?? null; // kann null sein
    } catch {
      userId = null;
    }

    const body = (await req.json()) as Body;
    const fromLang = norm(body.fromLang ?? "");
    const toLang = norm(body.toLang ?? "");
    const pos = (body.pos ?? "").toLowerCase();
    const mode = body.mode ?? "create";
    const formality = body.formality ?? "prefer_more";

    // Validierung: entweder id ODER text muss vorhanden sein
    if (!body.id && !body.text) {
      return new Response("Bad Request: id or text required", { status: 400 });
    }
    if (!fromLang || !toLang) {
      return new Response("Bad Request: fromLang and toLang required", {
        status: 400,
      });
    }

    let textNormalized = "";
    let existing = null;
    let sErr = null;

    // 1) Force-Translate by ID (wenn id gegeben) - 100% Treffer
    let row = existing;
    if (!row && body.id) {
      const { data: byId, error: idErr } = await sbAdmin
        .from("words")
        .select("id, text, translation, pos, from_lang, to_lang")
        .eq("id", body.id)
        .maybeSingle();

      if (idErr) throw idErr;
      row = byId || null;
      if (row) {
        existing = row;
        textNormalized = normalizeText(row.text || "");
      } else {
        return new Response(
          JSON.stringify({ ok: false, error: "Word not found by id" }),
          { status: 404, headers: { "Content-Type": "application/json" } }
        );
      }
    }
    // 2) Lookup existierendes Wort by text (case-insensitive, whitespace-tolerant)
    else if (body.text) {
      const raw = norm(body.text);
      textNormalized = normalizeText(raw);

      // Versuch 1: ilike (case-insensitive) - jetzt mit normalisiertem Text
      const lookup1 = await sbAdmin
        .from("words")
        .select("id, text, translation, pos, from_lang, to_lang")
        .eq("from_lang", fromLang)
        .eq("to_lang", toLang)
        .ilike("text", textNormalized)
        .limit(1)
        .maybeSingle();

      if (lookup1.error) {
        sErr = lookup1.error;
      } else if (lookup1.data) {
        // Exakte Übereinstimmung nach Normalisierung prüfen (jetzt case-insensitive)
        if (normalizeText(lookup1.data.text) === textNormalized) {
          existing = lookup1.data;
        }
      }

      // Versuch 2: Falls kein Match, exact match mit normalisiertem Text
      if (!existing && !sErr) {
        const lookup2 = await sbAdmin
          .from("words")
          .select("id, text, translation, pos, from_lang, to_lang")
          .eq("text", textNormalized)
          .eq("from_lang", fromLang)
          .eq("to_lang", toLang)
          .limit(1)
          .maybeSingle();

        if (lookup2.error) {
          sErr = lookup2.error;
        } else if (lookup2.data) {
          existing = lookup2.data;
        }
      }

      // Versuch 3: Falls immer noch kein Match, RPC mit btrim für robuste Whitespace-Behandlung
      if (!existing && !sErr) {
        try {
          const { data: lookup3, error: rpcErr } = await sbAdmin.rpc(
            "find_word_by_normalized_text",
            {
              p_text: textNormalized,
              p_from_lang: fromLang,
              p_to_lang: toLang,
            }
          );

          if (!rpcErr && lookup3 && lookup3.length > 0) {
            existing = lookup3[0];
          }
        } catch (rpcError) {
          // RPC-Funktion existiert möglicherweise nicht, das ist OK
          console.log(
            "RPC lookup not available, continuing with standard search"
          );
        }
      }

      if (sErr) throw sErr;
    }

    let wordId = existing?.id as string | undefined;
    let translation = existing?.translation as string | undefined;
    let finalPos = pos || existing?.pos || "";

    // Heuristik: Nomen auf Deutsch groß schreiben
    const enforceGermanNoun = (de: string) =>
      finalPos === "noun" && de
        ? de.replace(/^([a-zäöü])/u, (m) => m.toUpperCase())
        : de;

    // (a) CREATE-Modus: nur übersetzen, wenn leer
    // (b) FIX-Modus: neu übersetzen, wenn leer ODER QA schlecht
    let needsTranslation = !translation || translation.trim() === "";
    let qa_score: number | null = null;
    let qa_note = "";

    if (mode === "fix" && translation) {
      // Back-translation zur Qualität
      const backEn = await deeplTranslate([translation], "DE", "EN", "default");
      const score = jaccard(textNormalized, backEn[0] || "");
      qa_score = score;
      if (score < 0.55) {
        needsTranslation = true;
        qa_note = "low_backtranslation_similarity";
      }
      // POS-Heuristik: Nomen groß
      if (finalPos === "noun" && /^[a-zäöü]/u.test(translation)) {
        needsTranslation = true;
        qa_note = (qa_note ? qa_note + ";" : "") + "noun_capitalization_fix";
      }
    }

    // Übersetzen (DeepL) - nutze normalisierten Text für konsistente Übersetzungen
    if (needsTranslation) {
      if (!deeplKey) {
        return new Response(
          JSON.stringify({ ok: false, error: "DEEPL_API_KEY missing" }),
          { status: 500 }
        );
      }
      const out = await deeplTranslate(
        [textNormalized],
        fromLang,
        toLang,
        formality
      );
      const rawTranslation = out[0] || "";
      translation = enforceGermanNoun(rawTranslation);

      // Logging: Wenn DeepL leer zurückgibt
      if (!translation || translation.trim() === "") {
        console.error("DeepL returned empty translation for:", {
          text: textNormalized,
          fromLang,
          toLang,
          formality,
          rawResponse: out,
        });
        qa_note = (qa_note ? qa_note + ";" : "") + "deepl_empty_result";
      }
    }

    // Upsert (mit normalisiertem Text)
    const payload: any = {
      text: textNormalized,
      translation: translation ?? "",
      from_lang: fromLang,
      to_lang: toLang,
    };
    if (finalPos) payload.pos = finalPos;
    payload.translated_by = "deepl";
    payload.translated_at = new Date().toISOString();
    if (qa_score !== null) payload.qa_score = qa_score;
    if (qa_note) payload.qa_note = qa_note;

    const { data: up, error: upErr } = await sbAdmin
      .from("words")
      .upsert([payload], {
        onConflict: "text,from_lang,to_lang",
        ignoreDuplicates: false,
      })
      .select("id, translation, qa_score, qa_note")
      .single();
    if (upErr) throw upErr;

    wordId = up.id;
    translation = up.translation;

    // user_words upsert (nur wenn userId existiert)
    if (userId) {
      const { error: uErr } = await sbAdmin.from("user_words").upsert(
        {
          user_id: userId,
          word_id: wordId,
          picked: true,
          source: "browser",
        },
        { onConflict: "user_id,word_id" }
      );
      if (uErr) throw uErr;
    }

    return new Response(
      JSON.stringify({
        ok: true,
        wordId,
        text: textNormalized,
        translation,
        qa_score: up.qa_score ?? qa_score,
        qa_note: up.qa_note ?? qa_note,
        mode,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    console.error("ingest_word error:", e);
    const msg =
      e && typeof e === "object"
        ? (e as any).message ?? JSON.stringify(e)
        : String(e);
    return new Response(JSON.stringify({ ok: false, error: msg }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
```

---

## Supabase/translate-missing

### `supabase/functions/translate-missing/index.ts`

**Typ:** TypeScript  
**Zeilen:** 253

**Vollständiger Code:**

```typescript
// supabase/functions/translate-missing/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type ReqBody = {
  // Wie viele insgesamt in diesem Aufruf maximal bearbeiten?
  maxTotal?: number; // Default 5000
  // Wie viele DB-Zeilen pro Runde laden?
  chunkSize?: number; // Default 500 (max 2000)
  // Wie viele Texte pro DeepL-Request?
  deeplBatchSize?: number; // Default 50 (sicher)
  category?: string; // optional Filter, braucht v_words_with_categories
  formality?: "default" | "prefer_more" | "prefer_less";
  writeQa?: boolean; // Back-Translation + qa_score/qa_note (langsamer)
  dryRun?: boolean; // nur simulieren
  sleepMsBetweenBatches?: number; // Pause zwischen DeepL-Requests (Default 150ms)
};

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const DEEPL_KEY = Deno.env.get("DEEPL_API_KEY")!;
const GLOSSARY_ID = Deno.env.get("DEEPL_GLOSSARY_ID") || "";
const DL_ENDPOINT =
  Deno.env.get("DEEPL_ENDPOINT") || "https://api-free.deepl.com/v2/translate";

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

function jaccard(a: string, b: string) {
  const A = new Set(a.toLowerCase().split(/\s+/).filter(Boolean));
  const B = new Set(b.toLowerCase().split(/\s+/).filter(Boolean));
  const inter = [...A].filter((x) => B.has(x)).length;
  const denom = A.size + B.size - inter;
  return denom > 0 ? inter / denom : 1;
}

async function deeplBatch(
  texts: string[],
  src = "EN",
  tgt = "DE",
  formality?: string
) {
  const form = new URLSearchParams();
  form.append("auth_key", DEEPL_KEY);
  texts.forEach((t) => form.append("text", t));
  form.append("source_lang", src);
  form.append("target_lang", tgt);
  form.append("preserve_formatting", "1");
  if (formality) form.append("formality", formality);
  if (GLOSSARY_ID) form.append("glossary_id", GLOSSARY_ID);

  const maxRetries = 6; // bis ~ 1+2+4+8+16+32s
  let delay = 1000; // ms
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    const res = await fetch(DL_ENDPOINT, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: form.toString(),
    });

    if (res.ok) {
      const json = await res.json();
      return (json?.translations ?? []).map((t: any) => String(t.text));
    }

    // 429 = Rate Limit → warten & retry
    if (res.status === 429) {
      // Retry-After Header, falls vorhanden, respektieren
      const ra = Number(res.headers.get("Retry-After"));
      const waitMs = !Number.isNaN(ra) && ra > 0 ? ra * 1000 : delay;
      await new Promise((r) => setTimeout(r, waitMs));
      delay = Math.min(delay * 2, 30000); // exponentiell bis max 30s
      continue;
    }

    // 5xx → kurzfristige Serverprobleme → kurzer Retry
    if (res.status >= 500 && res.status < 600) {
      await new Promise((r) => setTimeout(r, delay));
      delay = Math.min(delay * 2, 30000);
      continue;
    }

    const txt = await res.text().catch(() => "");
    throw new Error(`DeepL ${res.status}: ${txt}`);
  }

  throw new Error("DeepL: max retries exceeded");
}

serve(async (req) => {
  try {
    // Authorization prüfen (JWT, i. d. R. Anon-Key)
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader)
      return new Response(
        JSON.stringify({ ok: false, error: "Missing Authorization header" }),
        { status: 401 }
      );

    const body = (await req.json().catch(() => ({}))) as ReqBody;
    const maxTotal = Math.max(1, Math.min(body.maxTotal ?? 5000, 50000)); // harte Kappe
    const chunkSize = Math.max(1, Math.min(body.chunkSize ?? 500, 2000)); // pro DB-Load
    const deeplBatchSize = Math.max(
      1,
      Math.min(body.deeplBatchSize ?? 50, 100)
    ); // pro DeepL-Call
    const formality = body.formality ?? "prefer_more";
    const writeQa = !!body.writeQa; // langsamer
    const dryRun = !!body.dryRun;
    const sleepMs = Math.max(0, body.sleepMsBetweenBatches ?? 150);
    const category = body.category?.trim();

    if (!SUPABASE_URL || !SERVICE_KEY)
      return new Response(
        JSON.stringify({
          ok: false,
          error: "Server misconfigured (SUPABASE_URL/SERVICE_KEY)",
        }),
        { status: 500 }
      );
    if (!DEEPL_KEY)
      return new Response(
        JSON.stringify({ ok: false, error: "DEEPL_API_KEY missing" }),
        { status: 500 }
      );

    const sb = createClient(SUPABASE_URL, SERVICE_KEY);

    let processed = 0;
    let fetchedThisRound = 0;
    let rounds = 0;

    const selectMissing = async () => {
      if (category) {
        const r = await sb
          .from("v_words_with_categories")
          .select(
            "id,text,from_lang,to_lang,level,pos,category_slug,translation"
          )
          .eq("category_slug", category)
          .eq("from_lang", "en")
          .eq("to_lang", "de")
          .or("translation.is.null,translation.eq.")
          .order("text", { ascending: true })
          .limit(chunkSize);
        if (r.error) throw r.error;
        return r.data as any[];
      } else {
        const r = await sb
          .from("words")
          .select("id,text,from_lang,to_lang,level,pos,translation")
          .eq("from_lang", "EN".toLowerCase())
          .eq("to_lang", "DE".toLowerCase())
          .or("translation.is.null,translation.eq.")
          .order("text", { ascending: true })
          .limit(chunkSize);
        if (r.error) throw r.error;
        return r.data as any[];
      }
    };

    while (processed < maxTotal) {
      const rows = (await selectMissing()).filter(
        (r) => r.text && String(r.text).trim() !== ""
      );
      fetchedThisRound = rows.length;
      if (fetchedThisRound === 0) break;
      rounds++;

      const texts = rows.map((r) => String(r.text));
      let translations: string[] = [];
      let backTranslations: string[] = [];

      if (dryRun) {
        // nichts
      } else {
        // DeepL in Teilpaketen
        for (let i = 0; i < texts.length; i += deeplBatchSize) {
          const slice = texts.slice(i, i + deeplBatchSize);
          const res = await deeplBatch(slice, "EN", "DE", formality);
          translations.push(...res);
          if (sleepMs) await sleep(sleepMs);
        }
        if (writeQa) {
          for (let i = 0; i < translations.length; i += deeplBatchSize) {
            const slice = translations.slice(i, i + deeplBatchSize);
            const res = await deeplBatch(slice, "DE", "EN", "default");
            backTranslations.push(...res);
            if (sleepMs) await sleep(sleepMs);
          }
        }
      }

      const ts = new Date().toISOString();
      const updates = rows.map((r, i) => {
        const tr = dryRun ? null : translations[i] ?? null;
        const qa_score =
          writeQa && !dryRun
            ? jaccard(String(r.text), backTranslations[i] || "")
            : null;
        const qa_note =
          writeQa && qa_score !== null && qa_score < 0.55
            ? "low_backtranslation_similarity"
            : "";
        return {
          id: r.id,
          text: r.text, // Pflichtfelder für Insert-Sicherheit
          from_lang: r.from_lang,
          to_lang: r.to_lang,
          translation: tr,
          translated_by: tr ? "deepl" : null,
          translated_at: tr ? ts : null,
          qa_score,
          qa_note,
        };
      });

      if (!dryRun) {
        const up = await sb
          .from("words")
          .upsert(updates, { onConflict: "id", ignoreDuplicates: false })
          .select("id");
        if (up.error) throw up.error;
      }

      processed += rows.length;
      if (rows.length === 0) break; // nur stoppen, wenn wirklich nichts mehr fehlt
    }

    return new Response(
      JSON.stringify({
        ok: true,
        processed,
        rounds,
        last_chunk: fetchedThisRound,
        category: category || null,
        formality,
        writeQa,
        dryRun,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    console.error("translate-missing error:", e);
    const msg =
      e && typeof e === "object"
        ? (e as any).message ?? JSON.stringify(e)
        : String(e);
    return new Response(JSON.stringify({ ok: false, error: msg }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
```

---
