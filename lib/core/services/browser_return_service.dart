import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

enum BrowserPreference {
  system,
  safari,
  chrome,
  brave;

  String get label {
    return switch (this) {
      BrowserPreference.system => 'Systemstandard',
      BrowserPreference.safari => 'Safari',
      BrowserPreference.chrome => 'Chrome',
      BrowserPreference.brave => 'Brave',
    };
  }

  static BrowserPreference fromStorage(String? raw) {
    return BrowserPreference.values.firstWhere(
      (preference) => preference.name == raw,
      orElse: () => BrowserPreference.system,
    );
  }
}

class LastBrowserSource {
  const LastBrowserSource({
    required this.id,
    required this.sourceUrl,
    required this.createdAt,
    this.title,
    this.sharedTextPreview,
    this.browserHint,
    this.platform,
    this.source,
  });

  final String id;
  final String sourceUrl;
  final DateTime createdAt;
  final String? title;
  final String? sharedTextPreview;
  final String? browserHint;
  final String? platform;
  final String? source;

  String get domain {
    final host = Uri.tryParse(sourceUrl)?.host ?? '';
    if (host.isEmpty) return sourceUrl;
    return host.startsWith('www.') ? host.substring(4) : host;
  }
}

typedef BrowserUrlLauncher = Future<bool> Function(Uri uri, LaunchMode mode);

class BrowserReturnService {
  BrowserReturnService({
    SharedPreferences? preferences,
    BrowserUrlLauncher? launcher,
  }) : _preferences = preferences,
       _launcher = launcher ?? ((uri, mode) => launchUrl(uri, mode: mode));

  static const String _kLastUrl = 'last_shared_url';
  static const String _kLastId = 'last_browser_source_id_v1';
  static const String _kLastCreatedAt = 'last_browser_source_created_at_v1';
  static const String _kLastPreview = 'last_browser_source_preview_v1';
  static const String _kLastBrowserHint = 'last_browser_source_hint_v1';
  static const String _kLastPlatform = 'last_browser_source_platform_v1';
  static const String _kLastSource = 'last_browser_source_source_v1';
  static const String browserPreferenceStorageKey =
      'talvori_browser_preference_v1';

  final SharedPreferences? _preferences;
  final BrowserUrlLauncher _launcher;

  static final StreamController<LastBrowserSource> _savedController =
      StreamController<LastBrowserSource>.broadcast();

  static Stream<LastBrowserSource> get onSavedSource => _savedController.stream;

  // Compatibility stream for older callers.
  static Stream<String> get onSavedUrl =>
      onSavedSource.map((source) => source.sourceUrl);

  static Future<void> initShareListener() async {}

  Future<SharedPreferences> _prefs() async {
    return _preferences ?? SharedPreferences.getInstance();
  }

  Future<void> saveSource(LastBrowserSource source) async {
    final normalized = _normalizeUrl(source.sourceUrl);
    if (!_isOpenableWebUrl(normalized)) return;
    final prefs = await _prefs();
    await prefs.setString(_kLastUrl, normalized);
    await prefs.setString(_kLastId, source.id);
    await prefs.setInt(
      _kLastCreatedAt,
      source.createdAt.millisecondsSinceEpoch,
    );
    await _setOptionalString(prefs, _kLastPreview, source.sharedTextPreview);
    await _setOptionalString(prefs, _kLastBrowserHint, source.browserHint);
    await _setOptionalString(prefs, _kLastPlatform, source.platform);
    await _setOptionalString(prefs, _kLastSource, source.source);
    _savedController.add(
      LastBrowserSource(
        id: source.id,
        sourceUrl: normalized,
        createdAt: source.createdAt,
        title: source.title,
        sharedTextPreview: source.sharedTextPreview,
        browserHint: source.browserHint,
        platform: source.platform,
        source: source.source,
      ),
    );
    debugPrint(
      'Talvori BrowserReturn saved sourceUrl host=${Uri.tryParse(normalized)?.host}',
    );
  }

  Future<LastBrowserSource?> getLastSource() async {
    final prefs = await _prefs();
    final url = prefs.getString(_kLastUrl);
    if (url == null || !_isOpenableWebUrl(url)) {
      return null;
    }
    debugPrint(
      'Talvori BrowserReturn read sourceUrl host=${Uri.tryParse(url)?.host}',
    );
    final createdAtMs = prefs.getInt(_kLastCreatedAt);
    return LastBrowserSource(
      id: prefs.getString(_kLastId) ?? 'legacy:${url.hashCode}',
      sourceUrl: url,
      createdAt: createdAtMs == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      sharedTextPreview: prefs.getString(_kLastPreview),
      browserHint: prefs.getString(_kLastBrowserHint),
      platform: prefs.getString(_kLastPlatform),
      source: prefs.getString(_kLastSource),
    );
  }

  Future<BrowserPreference> getBrowserPreference() async {
    final prefs = await _prefs();
    return BrowserPreference.fromStorage(
      prefs.getString(browserPreferenceStorageKey),
    );
  }

  Future<void> setBrowserPreference(BrowserPreference preference) async {
    final prefs = await _prefs();
    await prefs.setString(browserPreferenceStorageKey, preference.name);
  }

  Future<BrowserOpenResult> openLastSource({
    BrowserPreference? preferredBrowser,
  }) async {
    final source = await getLastSource();
    if (source == null) {
      return const BrowserOpenResult.noSource();
    }
    return openUrl(
      source.sourceUrl,
      preferredBrowser: preferredBrowser ?? await getBrowserPreference(),
    );
  }

  Future<BrowserOpenResult> openUrl(
    String rawUrl, {
    BrowserPreference preferredBrowser = BrowserPreference.system,
  }) async {
    final normalized = _normalizeUrl(rawUrl);
    if (!_isOpenableWebUrl(normalized)) {
      return const BrowserOpenResult.invalidUrl();
    }
    final primary = Uri.parse(normalized);
    for (final candidate in _candidateUris(primary, preferredBrowser)) {
      final opened = await _launcher(candidate, LaunchMode.externalApplication);
      if (opened) {
        return BrowserOpenResult.opened(
          usedFallback: candidate != primary,
          openedUri: candidate,
        );
      }
    }
    return const BrowserOpenResult.failed();
  }

  Future<void> clearSource() async {
    final prefs = await _prefs();
    await prefs.remove(_kLastUrl);
    await prefs.remove(_kLastId);
    await prefs.remove(_kLastCreatedAt);
    await prefs.remove(_kLastPreview);
    await prefs.remove(_kLastBrowserHint);
    await prefs.remove(_kLastPlatform);
    await prefs.remove(_kLastSource);
  }

  static Future<void> setLastUrl(String url) {
    return BrowserReturnService().saveSource(
      LastBrowserSource(
        id: 'manual:${DateTime.now().microsecondsSinceEpoch}',
        sourceUrl: url,
        createdAt: DateTime.now(),
        source: 'manual_text_url',
      ),
    );
  }

  static Future<String?> getLastUrl() async {
    return (await BrowserReturnService().getLastSource())?.sourceUrl;
  }

  static Future<bool> hasLastUrl() async {
    return (await BrowserReturnService().getLastSource()) != null;
  }

  static Future<void> clear() => BrowserReturnService().clearSource();
}

class BrowserOpenResult {
  const BrowserOpenResult._({
    required this.status,
    this.usedFallback = false,
    this.openedUri,
  });

  const BrowserOpenResult.opened({
    required bool usedFallback,
    required Uri openedUri,
  }) : this._(
         status: BrowserOpenStatus.opened,
         usedFallback: usedFallback,
         openedUri: openedUri,
       );

  const BrowserOpenResult.noSource()
    : this._(status: BrowserOpenStatus.noSource);

  const BrowserOpenResult.invalidUrl()
    : this._(status: BrowserOpenStatus.invalidUrl);

  const BrowserOpenResult.failed() : this._(status: BrowserOpenStatus.failed);

  final BrowserOpenStatus status;
  final bool usedFallback;
  final Uri? openedUri;

  bool get isOpened => status == BrowserOpenStatus.opened;
}

enum BrowserOpenStatus { opened, noSource, invalidUrl, failed }

bool looksLikePdf(String url) {
  final low = url.toLowerCase();
  return low.endsWith('.pdf') || low.contains('.pdf?') || low.contains('.pdf#');
}

List<Uri> _candidateUris(Uri primary, BrowserPreference preference) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return [primary];
  if (primary.scheme != 'http' && primary.scheme != 'https') return [primary];

  final candidates = <Uri>[];
  switch (preference) {
    case BrowserPreference.chrome:
      final scheme = primary.scheme == 'https'
          ? 'googlechromes'
          : 'googlechrome';
      candidates.add(primary.replace(scheme: scheme));
    case BrowserPreference.brave:
      candidates.add(
        Uri.parse(
          'brave://open-url?url=${Uri.encodeComponent(primary.toString())}',
        ),
      );
    case BrowserPreference.safari:
    case BrowserPreference.system:
      break;
  }
  candidates.add(primary);
  return candidates;
}

bool _isOpenableWebUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return false;
  return uri.scheme == 'http' || uri.scheme == 'https';
}

String _normalizeUrl(String raw) {
  final trimmed = raw.trim();
  final withScheme = trimmed.startsWith('www.') ? 'https://$trimmed' : trimmed;
  final uri = Uri.tryParse(withScheme);
  if (uri == null || uri.host.isEmpty) return withScheme;

  const banned = {
    'utm_source',
    'utm_medium',
    'utm_campaign',
    'utm_term',
    'utm_content',
    'fbclid',
    'gclid',
    'igsh',
    'ref',
    'referrer',
  };

  final all = Map<String, List<String>>.from(uri.queryParametersAll)
    ..removeWhere((key, _) => banned.contains(key));
  final qp = <String, String>{};
  all.forEach((key, value) {
    if (value.isNotEmpty) {
      qp[key] = value.length == 1 ? value.first : value.join(',');
    }
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

Future<void> _setOptionalString(
  SharedPreferences prefs,
  String key,
  String? value,
) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return prefs.remove(key);
  }
  return prefs.setString(key, trimmed);
}
