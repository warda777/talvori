import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/onboarding/application/onboarding_settings_provider.dart';
import 'package:talvori/features/onboarding/ui/screens/onboarding_flow_screen.dart';

void main() {
  Future<void> pumpGate(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingGate(child: Scaffold(body: Text('App Home'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapPrimary(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> reachPlacementIntro(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tapPrimary(tester, 'Weiter');
    }
    expect(find.text('Wie hast du von Talvori erfahren?'), findsOneWidget);

    await tester.tap(find.text('Instagram'));
    await tester.pumpAndSettle();
    await tapPrimary(tester, 'Weiter');
    expect(find.text('Welche Themen interessieren dich?'), findsOneWidget);

    await tester.tap(find.text('Emotionen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wörter in Fremdsprachen'));
    await tester.pumpAndSettle();
    await tapPrimary(tester, 'Weiter');
    expect(find.text('Was treibt deine Neugier an?'), findsOneWidget);

    await tester.tap(find.text('Ich lerne ein Leben lang'));
    await tester.pumpAndSettle();
    await tapPrimary(tester, 'Weiter');
    expect(
      find.text('Wie viele Wörter möchtest du pro Woche lernen?'),
      findsOneWidget,
    );

    await tester.tap(find.text('30 Wörter pro Woche'));
    await tester.pumpAndSettle();
    await tapPrimary(tester, 'Weiter');
    expect(
      find.text('Wo fühlst du dich mit deinem Wortschatz am unsichersten?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Beim Schreiben'));
    await tester.pumpAndSettle();
    await tapPrimary(tester, 'Weiter');
    expect(find.text('Wie groß ist dein Wortschatz?'), findsOneWidget);

    await tester.tap(find.text('Mittleres Niveau'));
    await tester.pumpAndSettle();
    await tapPrimary(tester, 'Zur Einstufung');
  }

  testWidgets('first start shows onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await pumpGate(tester);

    expect(find.text('Erweitere dein Vokabular'), findsOneWidget);
    expect(find.text('App Home'), findsNothing);
  });

  testWidgets('skip completes onboarding and opens the app', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await pumpGate(tester);
    await tester.tap(find.byKey(const Key('onboarding-skip-button')));
    await tester.pumpAndSettle();

    expect(find.text('App Home'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(onboardingCompletedKey), isTrue);
  });

  testWidgets('personalization screens appear in the expected order', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await pumpGate(tester);

    await tapPrimary(tester, 'Weiter');
    expect(find.text('Passe die App an'), findsOneWidget);

    await tapPrimary(tester, 'Weiter');
    expect(find.text('Wörter über den Tag'), findsOneWidget);

    await tapPrimary(tester, 'Weiter');
    expect(find.text('Bereit für Widgets'), findsOneWidget);

    await tapPrimary(tester, 'Weiter');
    expect(find.text('Lerne mit Ziel'), findsOneWidget);

    await tapPrimary(tester, 'Weiter');
    expect(find.text('Wie hast du von Talvori erfahren?'), findsOneWidget);

    await tester.tap(find.text('Facebook'));
    await tester.pumpAndSettle();
    await tapPrimary(tester, 'Weiter');
    expect(find.text('Welche Themen interessieren dich?'), findsOneWidget);

    await tester.tap(find.text('Gesellschaft'));
    await tester.pumpAndSettle();
    await tapPrimary(tester, 'Weiter');
    expect(find.text('Was treibt deine Neugier an?'), findsOneWidget);

    await tester.tap(find.text('Mehr wissen als andere'));
    await tester.pumpAndSettle();
    await tapPrimary(tester, 'Weiter');
    expect(
      find.text('Wie viele Wörter möchtest du pro Woche lernen?'),
      findsOneWidget,
    );

    await tester.tap(find.text('10 Wörter pro Woche'));
    await tester.pumpAndSettle();
    await tapPrimary(tester, 'Weiter');
    expect(
      find.text('Wo fühlst du dich mit deinem Wortschatz am unsichersten?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Beim Lesen'));
    await tester.pumpAndSettle();
    await tapPrimary(tester, 'Weiter');
    expect(find.text('Wie groß ist dein Wortschatz?'), findsOneWidget);

    await tester.tap(find.text('Anfänger'));
    await tester.pumpAndSettle();
    await tapPrimary(tester, 'Zur Einstufung');
    expect(
      find.text('Lass uns testen, wie viele Wörter du kennst'),
      findsOneWidget,
    );

    await tapPrimary(tester, 'Weiter');
    expect(find.text('Anfängerwörter'), findsOneWidget);

    await tapPrimary(tester, 'Weiter');
    expect(find.text('Mittelstufenwörter'), findsOneWidget);

    await tapPrimary(tester, 'Weiter');
    expect(find.text('Expertenwörter'), findsOneWidget);
  });

  testWidgets('completion stores result and onboarding is not shown again', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await pumpGate(tester);
    await reachPlacementIntro(tester);
    expect(
      find.text('Lass uns testen, wie viele Wörter du kennst'),
      findsOneWidget,
    );
    await tapPrimary(tester, 'Weiter');

    expect(find.text('Anfängerwörter'), findsOneWidget);
    await tester.tap(find.text('house'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('water'));
    await tester.pumpAndSettle();

    await tapPrimary(tester, 'Weiter');
    expect(find.text('Mittelstufenwörter'), findsOneWidget);
    await tester.tap(find.text('journey'));
    await tester.pumpAndSettle();

    await tapPrimary(tester, 'Weiter');
    expect(find.text('Expertenwörter'), findsOneWidget);

    await tapPrimary(tester, 'Weiter');
    expect(find.text('Willkommen bei Talvori'), findsOneWidget);
    expect(
      find.textContaining('Dein Startniveau wurde grob eingeschätzt'),
      findsOneWidget,
    );

    await tapPrimary(tester, 'Los geht’s');
    expect(find.text('App Home'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(onboardingCompletedKey), isTrue);
    expect(prefs.getInt(onboardingPlacementKnownWordsKey), 3);
    expect(prefs.getString(onboardingPlacementLevelKey), 'Anfänger');
    expect(prefs.getString(onboardingReferralSourceKey), 'Instagram');
    expect(prefs.getStringList(onboardingTopicInterestsKey), [
      'Emotionen',
      'Wörter in Fremdsprachen',
    ]);
    expect(prefs.getStringList(onboardingMotivationsKey), [
      'Ich lerne ein Leben lang',
    ]);
    expect(prefs.getString(onboardingWeeklyGoalKey), '30 Wörter pro Woche');
    expect(prefs.getString(onboardingUncertaintyAreaKey), 'Beim Schreiben');
    expect(prefs.getString(onboardingSelfAssessmentKey), 'Mittleres Niveau');

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpGate(tester);

    expect(find.text('App Home'), findsOneWidget);
    expect(find.text('Erweitere dein Vokabular'), findsNothing);
  });

  testWidgets('already completed onboarding opens app directly', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({onboardingCompletedKey: true});

    await pumpGate(tester);

    expect(find.text('App Home'), findsOneWidget);
    expect(find.text('Erweitere dein Vokabular'), findsNothing);
  });
}
