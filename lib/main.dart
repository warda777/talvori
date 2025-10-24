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
    // 1) .env laden
    await dotenv.load(fileName: ".env");

    // 2) Supabase initialisieren
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    // 3) Debug-Auto-Login (nur wenn kein User vorhanden)
    final auth = Supabase.instance.client.auth;
    if (kDebugMode && auth.currentUser == null) {
      final email = dotenv.env['TEST_EMAIL'];
      final pw    = dotenv.env['TEST_PASSWORD'];
      if (email != null && pw != null && email.isNotEmpty && pw.isNotEmpty) {
        try {
          await auth.signInWithPassword(email: email, password: pw)
                    .timeout(const Duration(seconds: 8));
        } on TimeoutException {
          debugPrint('Login timeout – UI startet trotzdem');
        } catch (e) {
          debugPrint('Login fehlgeschlagen: $e');
        }
      } else {
        debugPrint('TEST_EMAIL / TEST_PASSWORD fehlen in .env');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_shared_word', 'umbrella'); // TEST-Wort

    // Logging hilft beim Teilen-Debug:
    debugPrint('Logged in as: ${Supabase.instance.client.auth.currentUser?.id}');
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