import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/services/browser_return_service.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves_and_reads_last_browser_source', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = BrowserReturnService(preferences: prefs);

    await service.saveSource(
      LastBrowserSource(
        id: 'share-1',
        sourceUrl: 'https://example.com/read?utm_source=news&keep=1',
        createdAt: DateTime(2026, 5, 22, 12),
        sharedTextPreview: 'emergency',
        browserHint: 'ios_share_sheet',
        platform: 'ios',
        source: 'ios_share_extension',
      ),
    );

    final source = await service.getLastSource();

    expect(source?.id, 'share-1');
    expect(source?.sourceUrl, 'https://example.com/read?keep=1');
    expect(source?.sharedTextPreview, 'emergency');
    expect(source?.domain, 'example.com');
  });

  test('ignores_missing_or_invalid_source_for_open', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = BrowserReturnService(preferences: prefs);

    expect((await service.openLastSource()).status, BrowserOpenStatus.noSource);
    expect(
      (await service.openUrl('not a url')).status,
      BrowserOpenStatus.invalidUrl,
    );
  });

  test('browser_preference_defaults_to_system_and_can_be_saved', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = BrowserReturnService(preferences: prefs);

    expect(await service.getBrowserPreference(), BrowserPreference.system);

    await service.setBrowserPreference(BrowserPreference.chrome);

    expect(await service.getBrowserPreference(), BrowserPreference.chrome);
  });

  test('open_url_uses_external_application_launcher', () async {
    final opened = <Uri>[];
    final service = BrowserReturnService(
      launcher: (uri, mode) async {
        expect(mode, LaunchMode.externalApplication);
        opened.add(uri);
        return true;
      },
    );

    final result = await service.openUrl(
      'https://example.com/article',
      preferredBrowser: BrowserPreference.chrome,
    );

    expect(result.isOpened, isTrue);
    expect(opened.last, Uri.parse('https://example.com/article'));
  });

  test('new_share_replaces_previous_source', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = BrowserReturnService(preferences: prefs);

    await service.saveSource(
      LastBrowserSource(
        id: 'share-1',
        sourceUrl: 'https://first.example',
        createdAt: DateTime(2026, 5, 22, 12),
      ),
    );
    await service.saveSource(
      LastBrowserSource(
        id: 'share-2',
        sourceUrl: 'https://second.example',
        createdAt: DateTime(2026, 5, 22, 13),
      ),
    );

    final source = await service.getLastSource();

    expect(source?.id, 'share-2');
    expect(source?.sourceUrl, 'https://second.example');
  });
}
