import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // 0) Orientierung auf Hochformat fixieren (keine Drehung)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
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