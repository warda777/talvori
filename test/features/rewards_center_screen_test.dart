import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/rewards/ui/screens/rewards_center_screen.dart';

void main() {
  final now = DateTime(2026, 5, 22, 12);

  LocalWord word({
    required String id,
    required String term,
    TranslationStatus status = TranslationStatus.translated,
  }) {
    return LocalWord(
      id: id,
      categoryId: LocalLearningSource.myWords.id,
      term: term,
      translation: status == TranslationStatus.translated ? 'Übersetzung' : '',
      translationStatus: status,
      sourceLanguage: 'en',
      targetLanguage: 'de',
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> pumpRewards(
    WidgetTester tester, {
    RewardsTab initialTab = RewardsTab.leaderboard,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final words = [
      word(id: 'one', term: 'emergency'),
      word(id: 'two', term: 'shelter', status: TranslationStatus.pending),
      word(id: 'three', term: 'signal'),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return switch (source) {
              LocalLearningSource.allWords => words,
              LocalLearningSource.myWords => words,
              LocalLearningSource.favorites => [words.first],
              LocalLearningSource.knownWords => [words.first, words.last],
              LocalLearningSource.reviewedForLearning => [words.last],
              LocalLearningSource.myMix => [words.first],
            };
          }),
        ],
        child: MaterialApp(home: RewardsCenterScreen(initialTab: initialTab)),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets('progress hub shows German tabs and weekly league', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpRewards(tester);

    expect(find.text('Fortschritt'), findsOneWidget);
    expect(find.text('Liga'), findsOneWidget);
    expect(find.text('Belohnungen'), findsOneWidget);
    expect(find.text('Statistik'), findsOneWidget);
    expect(find.text('Lokale Wochenliga'), findsOneWidget);
    expect(find.text('Reset montags'), findsOneWidget);
    expect(find.text('Offline-first'), findsOneWidget);
    expect(find.text('Leaderboard'), findsNothing);
    expect(find.text('Rewards'), findsNothing);
    expect(find.text('Stats'), findsNothing);
  });

  testWidgets(
    'rewards and stats tabs show local data without fake online users',
    (tester) async {
      await pumpRewards(tester);

      await tester.tap(find.text('Belohnungen'));
      await tester.pumpAndSettle();
      expect(find.text('Erste Runde'), findsOneWidget);
      expect(find.text('100 Taler'), findsOneWidget);
      expect(find.text('Serien-Starter'), findsOneWidget);

      await tester.tap(find.text('Statistik'));
      await tester.pumpAndSettle();
      expect(find.text('Gesamt-Taler'), findsOneWidget);
      expect(find.text('Gespielte Runden'), findsOneWidget);
      expect(find.text('Richtig gelöst'), findsOneWidget);
      expect(find.text('Heute verdient'), findsOneWidget);
      expect(find.text('keine globalen Daten aktiv'), findsNothing);
    },
  );

  testWidgets('progress hub renders on phone size without flex overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previousOnError = FlutterError.onError;
    final overflows = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('RenderFlex overflowed')) {
        overflows.add(details);
        return;
      }
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await pumpRewards(tester, initialTab: RewardsTab.rewards);
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump();

    await pumpRewards(tester, initialTab: RewardsTab.stats);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump();

    expect(overflows, isEmpty);
  });
}
