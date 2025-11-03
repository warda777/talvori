import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
// import 'package:share_handler/share_handler.dart';  // Temporär deaktiviert für iOS
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
    // 1) ANDROID: echte Share-Intents (ACTION_SEND) - temporär deaktiviert
    // TODO: share_handler wieder aktivieren, wenn iOS-Build-Problem gelöst ist
    // if (Platform.isAndroid) {
    //   debugPrint('🔎 SHARE_INIT: Android share check aktiv');
    //   final sh = ShareHandlerPlatform.instance;
    //   // ... Android Share-Code
    // }

    // 2) Deep-Links (talvori://... oder https://... mit ?text=)
    final initialLink = await _appLinks.getInitialLink();
    final t = initialLink?.queryParameters['text']?.trim();
    if (t != null && t.isNotEmpty) onIncomingText(t);

    _linksSub = _appLinks.uriLinkStream.listen((uri) {
      final text = uri.queryParameters['text']?.trim();
      if (text != null && text.isNotEmpty) onIncomingText(text);
    });

    // 3) Browser-Return (PDF/Seitenposition)
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
