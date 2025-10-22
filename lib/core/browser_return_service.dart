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
