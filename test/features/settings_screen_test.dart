import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/home/ui/screens/settings_screen.dart';

void main() {
  Future<void> pumpSettings(
    WidgetTester tester, {
    SettingsExternalLinkLauncher? linkLauncher,
  }) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (linkLauncher != null)
            settingsExternalLinkLauncherProvider.overrideWithValue(
              linkLauncher,
            ),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
  }

  Future<void> scrollTo(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
  }

  testWidgets('settings screen shows German grouped sections', (tester) async {
    await pumpSettings(tester);

    expect(find.text('Einstellungen'), findsOneWidget);
    expect(find.text('PREMIUM'), findsOneWidget);
    expect(find.text('ÜBER DICH'), findsOneWidget);
    expect(find.text('APP & LERNEN'), findsOneWidget);

    await scrollTo(tester, 'KONTO');
    expect(find.text('KONTO'), findsOneWidget);
    await scrollTo(tester, 'UNTERSTÜTZUNG');
    expect(find.text('UNTERSTÜTZUNG'), findsOneWidget);
    expect(find.text('Hilfe & Support'), findsOneWidget);
    expect(find.text('Feedback & Kontakt'), findsOneWidget);
    await scrollTo(tester, 'RECHTLICHES');
    expect(find.text('RECHTLICHES'), findsOneWidget);
    expect(find.text('Datenschutzrichtlinie'), findsOneWidget);
    expect(find.text('Nutzungsbedingungen / AGB'), findsOneWidget);
    expect(find.text('Impressum / Anbieterinformationen'), findsOneWidget);
    await scrollTo(tester, 'ENTWICKLER');
    expect(find.text('ENTWICKLER'), findsOneWidget);
    expect(find.text('Supabase-Wörter lokal importieren'), findsOneWidget);

    expect(find.text('Manage subscription'), findsNothing);
    expect(find.text('Make it yours'), findsNothing);
    expect(find.text('Privacy Policy'), findsNothing);
  });

  testWidgets('name can be entered and saved locally', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Namen eingeben'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Andreas');
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    expect(find.text('Name gespeichert.'), findsOneWidget);
  });

  testWidgets('personal choice detail pages open', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Geschlechtsidentität'));
    await tester.pumpAndSettle();
    expect(find.text('Weiblich'), findsOneWidget);
    expect(find.text('Möchte ich nicht sagen'), findsOneWidget);
    await tester.tap(find.text('Divers'));
    await tester.pumpAndSettle();
    expect(find.text('Divers'), findsOneWidget);

    await tester.tap(find.text('Alter'));
    await tester.pumpAndSettle();
    expect(find.text('13 bis 17'), findsOneWidget);
    expect(find.text('55+'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Level'));
    await tester.pumpAndSettle();
    expect(find.text('Anfänger'), findsOneWidget);
    expect(find.text('Mittleres Niveau'), findsOneWidget);
    expect(find.text('Fortgeschritten'), findsOneWidget);
  });

  testWidgets('mascot style can be changed locally', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Talvori Stil'));
    await tester.pumpAndSettle();

    expect(find.text('Weiblich'), findsOneWidget);
    expect(find.text('Männlich'), findsOneWidget);

    await tester.tap(find.text('Männlich'));
    await tester.pumpAndSettle();

    expect(find.text('Talvori Stil'), findsOneWidget);
    expect(find.text('Männlich'), findsOneWidget);
  });

  testWidgets('language settings explain app native and learning language', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Sprache'));
    await tester.pumpAndSettle();

    expect(find.text('App-Sprache'), findsOneWidget);
    expect(find.text('Sprache der App-Oberfläche'), findsOneWidget);
    expect(find.text('Muttersprache'), findsOneWidget);
    expect(
      find.text('Sprache für Übersetzungen und Erklärungen'),
      findsOneWidget,
    );
    expect(find.text('Lernsprache'), findsOneWidget);
    expect(find.text('Sprache, die du lernen möchtest'), findsOneWidget);
    expect(
      find.textContaining('Aktuelles Lernpaar: Englisch → Deutsch'),
      findsOneWidget,
    );

    await tester.tap(find.text('App-Sprache'));
    await tester.pumpAndSettle();

    expect(find.text('Deutsch'), findsWidgets);
    expect(find.text('Englisch'), findsOneWidget);
    expect(find.text('Spanisch'), findsOneWidget);
    expect(find.text('Französisch'), findsOneWidget);
    expect(find.text('Chinesisch'), findsNothing);
    expect(find.text('Hindi'), findsNothing);
    expect(find.text('Japanisch'), findsNothing);
    expect(find.text('Russisch'), findsNothing);
    expect(find.text('Arabisch'), findsNothing);
  });

  testWidgets('subscription and muted content screens open', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Abonnement verwalten'));
    await tester.pumpAndSettle();
    expect(find.text('Premium-Erweiterung'), findsOneWidget);
    expect(find.text('Premium-Plan ansehen'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    await scrollTo(tester, 'Stummgeschaltete Inhalte');
    await tester.tap(find.text('Stummgeschaltete Inhalte'));
    await tester.pumpAndSettle();
    expect(find.text('Du hast noch nichts stummgeschaltet'), findsOneWidget);
    expect(find.text('Inhalte hinzufügen'), findsOneWidget);
  });

  testWidgets('debug import tile opens Supabase local import screen', (
    tester,
  ) async {
    await pumpSettings(tester);

    await scrollTo(tester, 'Supabase-Wörter lokal importieren');
    await tester.tap(find.text('Supabase-Wörter lokal importieren'));
    await tester.pumpAndSettle();

    expect(find.text('Preview ausführen'), findsOneWidget);
    expect(find.text('Import starten'), findsOneWidget);
    expect(
      find.textContaining('SRS-Fortschritt bleibt unverändert'),
      findsOneWidget,
    );
  });

  testWidgets('marketing analytics toggle changes locally', (tester) async {
    await pumpSettings(tester);

    await scrollTo(tester, 'Marketing & Analysen');
    final toggle = find.byType(Switch);
    expect(tester.widget<Switch>(toggle).value, isFalse);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(toggle).value, isTrue);
  });

  testWidgets('legal and support entries open Talvori links', (tester) async {
    final opened = <Uri>[];
    await pumpSettings(
      tester,
      linkLauncher: (uri) async {
        opened.add(uri);
        return true;
      },
    );

    await scrollTo(tester, 'Hilfe & Support');
    await tester.tap(find.text('Hilfe & Support'));
    await tester.pump();

    await scrollTo(tester, 'Feedback & Kontakt');
    await tester.tap(find.text('Feedback & Kontakt'));
    await tester.pump();

    await scrollTo(tester, 'Datenschutzrichtlinie');
    await tester.tap(find.text('Datenschutzrichtlinie'));
    await tester.pump();

    await scrollTo(tester, 'Nutzungsbedingungen / AGB');
    await tester.tap(find.text('Nutzungsbedingungen / AGB'));
    await tester.pump();

    await scrollTo(tester, 'Impressum / Anbieterinformationen');
    await tester.tap(find.text('Impressum / Anbieterinformationen'));
    await tester.pump();

    expect(
      opened,
      containsAllInOrder([
        SettingsScreen.supportUri,
        SettingsScreen.supportMailUri,
        SettingsScreen.privacyUri,
        SettingsScreen.termsUri,
        SettingsScreen.imprintUri,
      ]),
    );
  });

  testWidgets('settings screens render on phone size without flex overflow', (
    tester,
  ) async {
    final previousOnError = FlutterError.onError;
    final flexOverflows = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed')) {
        flexOverflows.add(details);
        return;
      }
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    final opened = <Uri>[];
    await pumpSettings(
      tester,
      linkLauncher: (uri) async {
        opened.add(uri);
        return true;
      },
    );
    await scrollTo(tester, 'RECHTLICHES');
    await tester.tap(find.text('Datenschutzrichtlinie'));
    await tester.pump();
    expect(opened, [SettingsScreen.privacyUri]);

    expect(flexOverflows, isEmpty);
  });
}
