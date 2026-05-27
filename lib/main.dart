import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:talvori/core/theme/app_theme.dart';
import 'package:talvori/core/local_database/providers/supabase_words_local_import_controller_provider.dart';
import 'package:talvori/features/home/ui/screens/home_screen.dart';
import 'package:talvori/features/impuls_postfach/notifications/impulse_inbox_notification_router.dart';
import 'package:talvori/features/local_learning_debug/routing/local_learning_debug_routes.dart';
import 'package:talvori/features/onboarding/ui/screens/onboarding_flow_screen.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_service.dart';
import 'package:talvori/features/words/ui/widgets/incoming_shared_text_import_listener.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterLocalTagesimpulsNotificationScheduler.configurePayloadHandler(
        ImpulseInboxNotificationRouter.handlePayload,
      );

      // Globale Fehler abfangen (zeigt dir Crashes im Log statt weißem Screen)
      FlutterError.onError = (details) {
        FlutterError.dumpErrorToConsole(details);
        Zone.current.handleUncaughtError(
          details.exception,
          details.stack ?? StackTrace.empty,
        );
      };

      runApp(const ProviderScope(child: TalvoriApp()));
    },
    (error, stack) {
      // Optional: an Crashlytics/Sentry senden
      debugPrint('Uncaught error: $error');
    },
  );
}

class TalvoriApp extends ConsumerWidget {
  const TalvoriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Talvori',
      navigatorKey: ImpulseInboxNotificationRouter.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _InitGate(
        child: _SupabaseWordsLocalAutoSyncBootstrap(
          child: OnboardingGate(
            child: IncomingSharedTextImportListener(child: HomeScreen()),
          ),
        ),
      ),
      routes: kDebugMode
          ? {
              localLearningDebugRouteDefinition.path: (_) =>
                  localLearningDebugRouteDefinition.builder(
                    categoryId:
                        localLearningDebugRouteDefinition.defaultCategoryId,
                  ),
            }
          : const {},
    );
  }
}

class _SupabaseWordsLocalAutoSyncBootstrap extends ConsumerStatefulWidget {
  const _SupabaseWordsLocalAutoSyncBootstrap({required this.child});

  final Widget child;

  @override
  ConsumerState<_SupabaseWordsLocalAutoSyncBootstrap> createState() =>
      _SupabaseWordsLocalAutoSyncBootstrapState();
}

class _SupabaseWordsLocalAutoSyncBootstrapState
    extends ConsumerState<_SupabaseWordsLocalAutoSyncBootstrap> {
  bool _didStartAutoSync = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didStartAutoSync) return;
      _didStartAutoSync = true;
      unawaited(
        ref
            .read(supabaseWordsLocalAutoSyncServiceProvider)
            .runIfNeeded(now: DateTime.now().toUtc()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
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
  bool _didMarkRouterReady = false;

  @override
  void initState() {
    super.initState();
    _init = _initialize();
  }

  Future<void> _initialize() async {
    // 0) Orientierung auf Hochformat fixieren (keine Drehung)
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // 1) .env laden (mit Fallback)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('⚠️ .env nicht gefunden, verwende .env.example');
      await dotenv.load(fileName: ".env.example");
    }

    assert(
      dotenv.env['SUPABASE_URL']?.isNotEmpty == true,
      'SUPABASE_URL missing',
    );
    assert(
      dotenv.env['SUPABASE_ANON_KEY']?.isNotEmpty == true,
      'SUPABASE_ANON_KEY missing',
    );

    // 2) Supabase initialisieren (mit Fallback)
    try {
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );
      debugPrint('✅ Supabase erfolgreich initialisiert');
    } catch (e) {
      debugPrint('❌ Supabase-Initialisierung fehlgeschlagen: $e');
      debugPrint('⚠️ App läuft im Offline-Modus');
      // App läuft trotzdem weiter, aber ohne Supabase
    }

    // 3) Debug-Auto-Login (nur wenn Supabase verfügbar)
    try {
      final auth = Supabase.instance.client.auth;
      debugPrint('🔧 Current user: ${auth.currentUser?.email ?? "Kein User"}');

      if (kDebugMode && auth.currentUser == null) {
        final email = dotenv.env['TEST_EMAIL'];
        final pw = dotenv.env['TEST_PASSWORD'];
        debugPrint('🔧 Versuche Debug-Login');

        if (email != null && pw != null && email.isNotEmpty && pw.isNotEmpty) {
          try {
            final result = await auth
                .signInWithPassword(email: email, password: pw)
                .timeout(const Duration(seconds: 8));
            debugPrint('✅ Login erfolgreich: ${result.user?.email}');
          } on TimeoutException {
            debugPrint('⚠️ Login timeout – UI startet trotzdem');
          } catch (e) {
            debugPrint('❌ Login fehlgeschlagen: $e');
          }
        } else {
          debugPrint('⚠️ Keine Login-Credentials in .env gefunden');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Supabase nicht verfügbar - Login übersprungen: $e');
    }

    // 4) Test-Datenbankverbindung (nur wenn Supabase verfügbar)
    try {
      final client = Supabase.instance.client;
      final response = await client.from('categories').select('count').limit(1);
      debugPrint('🔧 Datenbank-Test: ${response.length} Kategorien gefunden');
    } catch (e) {
      debugPrint('❌ Datenbank-Test fehlgeschlagen: $e');
      debugPrint('⚠️ App läuft ohne Datenbankverbindung');
    }

    try {
      await FlutterLocalTagesimpulsNotificationScheduler().initialize();
    } catch (e) {
      debugPrint('⚠️ Notification-Tap-Handler nicht bereit: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_shared_word', 'umbrella'); // TEST-Wort

    // Logging hilft beim Teilen-Debug:
    try {
      debugPrint(
        'Logged in as: ${Supabase.instance.client.auth.currentUser?.id}',
      );
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
        // Fertig initialisiert -> eigentliche App.
        if (!_didMarkRouterReady) {
          _didMarkRouterReady = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ImpulseInboxNotificationRouter.markReady();
          });
        }
        return widget.child;
      },
    );
  }
}
