import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/assets/talvori_mascot_assets.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/companion/application/companion_ai_service.dart';
import 'package:talvori/features/companion/domain/companion_chat_constants.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impuls_postfach_screen.dart';
import 'package:talvori/features/home/ui/screens/boss_fight_game_screen.dart';
import 'package:talvori/features/home/ui/screens/context_challenge_game_screen.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/home/ui/screens/daily_word_quest_game_screen.dart';
import 'package:talvori/features/home/ui/screens/gap_word_game_screen.dart';
import 'package:talvori/features/home/ui/screens/hangman_game_screen.dart';
import 'package:talvori/features/home/ui/screens/home_screen.dart';
import 'package:talvori/features/home/ui/screens/listen_and_write_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_duel_preview_screen.dart';
import 'package:talvori/features/home/ui/screens/word_recognition_game_screen.dart';
import 'package:talvori/features/home/ui/screens/speed_round_game_screen.dart';
import 'package:talvori/features/home/ui/screens/vocab_screen.dart';
import 'package:talvori/features/home/ui/screens/word_hunt_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_match_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_puzzle_game_screen.dart';
import 'package:talvori/features/home/ui/widgets/bottom_nav.dart';
import 'package:talvori/features/home/ui/widgets/talvori_companion_card.dart';
import 'package:talvori/features/rewards/ui/screens/rewards_center_screen.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';
import 'package:talvori/features/world/ui/screens/world_region_screen.dart';
import 'package:talvori/features/words/ui/cards/word_card.dart';
import 'package:talvori/features/words/ui/screens/local_learning_source_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/local_learning_sources_screen.dart';
import 'package:talvori/features/words/ui/screens/local_known_review_screen.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';
import 'package:talvori/features/words/ui/widgets/category_wheel.dart';

void main() {
  LocalWord localWord({
    required String id,
    required String term,
    String translation = 'Übersetzung',
  }) {
    final now = DateTime(2026, 5, 22, 12);
    return LocalWord(
      id: id,
      categoryId: LocalLearningSource.myWords.id,
      term: term,
      translation: translation,
      sourceLanguage: 'en',
      targetLanguage: 'de',
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJyb2xlIjoiYW5vbiIsImlzcyI6InRlc3QiLCJpYXQiOjAsImV4cCI6MTg5MzQ1NjAwMH0.'
          'test-signature',
    );
  });

  test('home word counter count formatting stays compact', () {
    expect(formatHomeWordCounterCount(0), '0');
    expect(formatHomeWordCounterCount(999), '999');
    expect(formatHomeWordCounterCount(10000), '10k');
    expect(formatHomeWordCounterCount(100000), '100k');
  });

  testWidgets('home_screen_renders_on_small_height_without_bottom_overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final previousOnError = FlutterError.onError;
    final bottomOverflows = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed') &&
          message.contains('bottom')) {
        bottomOverflows.add(details);
      }
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    FlutterError.onError = previousOnError;

    expect(bottomOverflows, isEmpty);
    expect(find.byKey(const Key('talvori-world-home-hero')), findsOneWidget);
    expect(find.byKey(const Key('talvori-world-globe-button')), findsOneWidget);
    expect(find.byKey(const Key('home-orbit-action-selector')), findsOneWidget);
    expect(
      find.byKey(const Key('home-sentence-sparks-button')),
      findsOneWidget,
    );
    expect(find.text('Deine Welt wartet.'), findsOneWidget);
    expect(find.text('Meine Wörter bauen eine Welt'), findsOneWidget);
    expect(find.byType(WordCard), findsNothing);
    expect(find.byType(Switch), findsNothing);
    final globeRect = tester.getRect(
      find.byKey(const Key('talvori-world-globe-button')),
    );
    await tester.tap(find.byKey(const Key('talvori-world-globe-button')));
    await tester.pump();
    expect(globeRect.width, greaterThan(180));
    expect(find.text('Wortspiele'), findsOneWidget);
    expect(find.text('Wörter'), findsWidgets);
    expect(
      find.byKey(const Key('home-impuls-postfach-button')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.grid_view_rounded), findsNothing);
    expect(find.text('Impuls vorbereiten'), findsNothing);
    expect(find.text('Impuls-Vorschau'), findsNothing);
  });

  testWidgets('home word card handles large counts without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    final previousOnError = FlutterError.onError;
    final overflows = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) {
        overflows.add(details);
        return;
      }
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    const cases = <int>[0, 999, 10000, 100000];

    for (final count in cases) {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  height: 570,
                  child: WordCard(
                    onSpeak: (_) {},
                    onMarkWords: () {},
                    onQuickSend: null,
                    onGo: () {},
                    userWordCount: count,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    FlutterError.onError = previousOnError;
    expect(overflows, isEmpty);
  });

  testWidgets('home screen shows Talvori companion on regular height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('talvori-companion-card')), findsOneWidget);
    expect(find.text('Tali'), findsOneWidget);
    expect(find.text('Bereit für dein nächstes Wort?'), findsOneWidget);
    final mascotImage = tester.widget<Image>(
      find.byKey(const Key('talvori-companion-mascot-image')),
    );
    expect(
      (mascotImage.image as AssetImage).assetName,
      TalvoriMascotAssets.spiritPathFor(TaliEmotion.neutral),
    );
  });

  testWidgets('home screen uses locally selected male Talvori style', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      'talvori_profile_mascot_style_v1': 'male',
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final mascotImage = tester.widget<Image>(
      find.byKey(const Key('talvori-companion-mascot-image')),
    );
    expect(
      (mascotImage.image as AssetImage).assetName,
      TalvoriMascotAssets.spiritPathFor(
        TaliEmotion.neutral,
        style: TalvoriMascotStyle.male,
      ),
    );
    expect(find.text('Vori'), findsOneWidget);
  });

  testWidgets('home chat hint disappears permanently after opening chat', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('home-companion-chat-hint')), findsOneWidget);
    expect(find.text('Chatten \u2192'), findsOneWidget);

    await tester.tap(find.byKey(const Key('talvori-companion-bubble')));
    await tester.pump();

    expect(find.byKey(const Key('home-companion-chat-hint')), findsNothing);
    expect(
      find.byKey(const Key('talvori-companion-chat-input')),
      findsOneWidget,
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('talvori_profile_has_seen_home_chat_hint_v1'), isTrue);
  });

  testWidgets('home empty my words state lets companion show browser hint', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('Markiere ein Wort im Browser und teile es mit Tali.'),
      findsOneWidget,
    );
    final browserHint = tester.widget<Text>(
      find.text('Markiere ein Wort im Browser und teile es mit Tali.'),
    );
    expect(browserHint.maxLines, 3);
    expect(browserHint.overflow, TextOverflow.clip);
    final mascotImage = tester.widget<Image>(
      find.byKey(const Key('talvori-companion-mascot-image')),
    );
    expect(
      (mascotImage.image as AssetImage).assetName,
      TalvoriMascotAssets.spiritPathFor(TaliEmotion.neutral),
    );
  });

  testWidgets('home companion chat input sends prompt and shows response', (
    tester,
  ) async {
    final aiReply = Completer<AiChatResult>();
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_home_companion_chat_persistence',
      clock: () => DateTime(2026, 5, 20, 12),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          companionAiServiceProvider.overrideWithValue(
            CompanionAiService(
              aiChatClient: _HomeFakeAiChatClient((request) => aiReply.future),
            ),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byKey(const Key('talvori-companion-chat-icon')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('talvori-companion-chat-icon')));
    await tester.pump();

    expect(
      find.byKey(const Key('talvori-companion-chat-input')),
      findsOneWidget,
    );
    expect(
      tester
          .getRect(find.byKey(const Key('talvori-companion-chat-input')))
          .width,
      greaterThan(300),
    );

    await tester.pump(const Duration(seconds: 7));
    await tester.pump();
    expect(
      find.byKey(const Key('talvori-companion-chat-input')),
      findsOneWidget,
    );
    expect(find.text('Ich denke kurz nach ...'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('talvori-companion-chat-text-field')),
      'Was soll ich üben?\nVielleicht A1?\nOder Reisen?',
    );
    expect(find.textContaining('Vielleicht A1?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('talvori-companion-chat-send')));
    await tester.pump();

    expect(find.text('Ich denke kurz nach ...'), findsOneWidget);

    aiReply.complete(const AiChatResult(reply: 'Starte mit einem Wort.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Starte mit einem Wort.'), findsOneWidget);
    expect(
      find.byKey(const Key('talvori-companion-chat-input')),
      findsOneWidget,
    );
    final chatCompanion = tester.widget<TalvoriCompanionCard>(
      find.byType(TalvoriCompanionCard),
    );
    expect(chatCompanion.messageMaxLines, 6);
    final reopenedInput = tester.widget<TextField>(
      find.byKey(const Key('talvori-companion-chat-text-field')),
    );
    expect(reopenedInput.controller?.text, isEmpty);
    expect(reopenedInput.maxLines, 5);

    final chats = await repository.listChats();
    expect(
      chats.where((chat) => chat.id == CompanionChatConstants.chatId),
      hasLength(1),
    );
    expect(
      chats
          .singleWhere((chat) => chat.id == CompanionChatConstants.chatId)
          .title,
      CompanionChatConstants.title,
    );
    final messages = await repository.listMessages(
      CompanionChatConstants.chatId,
    );
    expect(messages, hasLength(2));
    expect(messages[0].source, ImpulseMessageSource.user);
    expect(
      messages[0].text,
      'Was soll ich üben?\nVielleicht A1?\nOder Reisen?',
    );
    expect(messages[1].source, ImpulseMessageSource.ai);
    expect(messages[1].text, 'Starte mit einem Wort.');
  });

  testWidgets('home companion chat input survives reduced keyboard height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('talvori-companion-chat-icon')));
    await tester.pump();
    expect(
      find.byKey(const Key('talvori-companion-chat-input')),
      findsOneWidget,
    );

    tester.view.physicalSize = const Size(800, 520);
    await tester.pump();

    expect(
      find.byKey(const Key('talvori-companion-chat-input')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('talvori-companion-chat-text-field')),
      'Bleib offen',
    );
    expect(find.text('Bleib offen'), findsOneWidget);
  });

  testWidgets('home companion chat input closes on outside tap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('talvori-companion-chat-icon')));
    await tester.pump();
    expect(
      find.byKey(const Key('talvori-companion-chat-input')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('talvori-companion-chat-text-field')),
      'Nicht senden',
    );
    await tester.tapAt(const Offset(24, 560));
    await tester.pump();

    expect(find.byKey(const Key('talvori-companion-chat-input')), findsNothing);
    expect(find.text('Nicht senden'), findsNothing);
  });

  testWidgets(
    'home companion chat input closes when keyboard inset returns to zero',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('talvori-companion-chat-icon')));
      await tester.pump();
      expect(
        find.byKey(const Key('talvori-companion-chat-input')),
        findsOneWidget,
      );
      final inputRect = tester.getRect(
        find.byKey(const Key('talvori-companion-chat-input')),
      );
      final textFieldRect = tester.getRect(
        find.byKey(const Key('talvori-companion-chat-text-field')),
      );
      final companionRect = tester.getRect(
        find.byKey(const Key('talvori-companion-card')),
      );
      expect(inputRect.top, greaterThanOrEqualTo(0));
      expect(inputRect.bottom, closeTo(878, 1));
      expect(inputRect.bottom, lessThanOrEqualTo(880));
      expect(textFieldRect.top, greaterThanOrEqualTo(inputRect.top));
      expect(textFieldRect.bottom, lessThanOrEqualTo(inputRect.bottom));
      expect(companionRect.bottom, lessThan(inputRect.top));

      tester.view.resetViewInsets();
      await tester.pump();
      await tester.pump();

      expect(
        find.byKey(const Key('talvori-companion-chat-input')),
        findsNothing,
      );
    },
  );

  testWidgets('home companion toggles on tap and rest timer restarts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Bereit für dein nächstes Wort?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('talvori-companion-mascot-image')));
    await tester.pump();

    expect(find.text('Bereit für dein nächstes Wort?'), findsNothing);
    var mascotImage = tester.widget<Image>(
      find.byKey(const Key('talvori-companion-mascot-image')),
    );
    expect(
      (mascotImage.image as AssetImage).assetName,
      TalvoriMascotAssets.spiritPathFor(TaliEmotion.neutral),
    );
    expect(
      tester
          .getRect(find.byKey(const Key('talvori-companion-mascot-image')))
          .height,
      lessThan(70),
    );
    final compactGlobeRect = tester.getRect(
      find.byKey(const Key('talvori-world-globe-button')),
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.byKey(const Key('talvori-companion-mascot-image')));
    await tester.pump();

    expect(find.text('Bereit für dein nächstes Wort?'), findsOneWidget);
    mascotImage = tester.widget<Image>(
      find.byKey(const Key('talvori-companion-mascot-image')),
    );
    expect(
      (mascotImage.image as AssetImage).assetName,
      TalvoriMascotAssets.spiritPathFor(TaliEmotion.neutral),
    );
    final activeGlobeRect = tester.getRect(
      find.byKey(const Key('talvori-world-globe-button')),
    );
    expect(activeGlobeRect.top, compactGlobeRect.top);
    expect(activeGlobeRect.left, compactGlobeRect.left);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();

    expect(find.text('Bereit für dein nächstes Wort?'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Bereit für dein nächstes Wort?'), findsNothing);
    mascotImage = tester.widget<Image>(
      find.byKey(const Key('talvori-companion-mascot-image')),
    );
    expect(
      (mascotImage.image as AssetImage).assetName,
      TalvoriMascotAssets.spiritPathFor(TaliEmotion.neutral),
    );
    expect(
      tester
          .getRect(find.byKey(const Key('talvori-companion-mascot-image')))
          .height,
      lessThan(70),
    );
  });

  testWidgets('home globe opens Talvori Welt placeholder region', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('talvori-world-globe-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('talvori-world-globe-button')));
    await tester.pumpAndSettle();

    expect(find.byType(WorldRegionScreen), findsOneWidget);
    expect(find.text('Talvori Welt'), findsOneWidget);
    expect(find.text('Deine Welt entsteht hier.'), findsOneWidget);
  });

  testWidgets('home screen shows impulse inbox entry with unread badge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed')) return;
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_home_impulse_inbox_entry',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'Your daily impulse is waiting.',
        usedWords: ['daily'],
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byKey(const Key('home-impuls-postfach-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('home-impuls-postfach-unread-badge')),
      findsOneWidget,
    );

    expect(find.text('Impuls vorbereiten'), findsNothing);
  });

  testWidgets('home impulse inbox entry opens impulse inbox screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed')) return;
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_home_impulse_inbox_open',
      clock: () => DateTime(2026, 5, 20, 12),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    tester.widget<HomeBottomNav>(find.byType(HomeBottomNav)).onImpulseInbox();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();

    expect(find.byType(ImpulsPostfachScreen), findsOneWidget);
    expect(find.text('Noch keine Chats'), findsOneWidget);
  });

  testWidgets('home words dock opens category popup', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final observer = _RecordingNavigatorObserver();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          navigatorObservers: [observer],
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    tester.widget<HomeBottomNav>(find.byType(HomeBottomNav)).onWords();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();

    expect(find.byType(LocalWordListScreen), findsNothing);
    expect(find.byType(LocalLearningSourceDetailScreen), findsNothing);
    expect(find.byType(LocalLearningSourcesScreen), findsNothing);
    expect(find.text('Kategorie'), findsOneWidget);
    expect(
      find.byKey(const Key('category-popup-my-words-tile')),
      findsOneWidget,
    );
    expect(find.text('All words'), findsNothing);
    expect(find.text('My words'), findsNothing);
    expect(find.text('Favorites'), findsNothing);
    expect(find.text('Words I know'), findsNothing);
    expect(find.text('My mix'), findsNothing);
    expect(
      observer.pushedRouteNames,
      isNot(contains('local-source-detail-my_words')),
    );
    expect(
      observer.pushedRouteNames,
      isNot(contains(LocalLearningSourcesScreen.routeName)),
    );
  });

  testWidgets('home play opens category popup', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-my-words-play-button')));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();

    expect(find.byType(LocalLearningSourcesScreen), findsNothing);
    expect(find.byType(LocalLearningSourceDetailScreen), findsNothing);
    expect(find.text('Kategorie'), findsOneWidget);
    expect(
      find.byKey(const Key('category-popup-all-words-tile')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('category-popup-favorites-tile')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('category-popup-my-words-tile')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('category-popup-known-words-tile')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('category-popup-my-mix-tile')), findsOneWidget);
    expect(find.text('Übungsmodus'), findsNothing);
    expect(find.text('All words'), findsNothing);
    expect(find.text('My words'), findsNothing);
    expect(find.text('Favorites'), findsNothing);
    expect(find.text('Words I know'), findsNothing);
    expect(find.text('My mix'), findsNothing);
  });

  testWidgets('home sentence sparks opens Tagesimpuls area', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-sentence-sparks-button')));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();

    expect(find.byType(CourseScreen), findsOneWidget);
    expect(find.textContaining('Tagesimpuls'), findsWidgets);
  });

  testWidgets(
    'home browser button shows Standardbrowser Chrome Brave choices',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final opened = <Uri>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeExternalBrowserLauncherProvider.overrideWithValue((uri) async {
              opened.add(uri);
              return true;
            }),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('home-browser-return-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(opened, isEmpty);
      expect(find.byKey(const Key('home-browser-open-sheet')), findsOneWidget);
      expect(find.text('Browser öffnen'), findsOneWidget);
      expect(find.text('Standardbrowser'), findsOneWidget);
      expect(find.text('Safari'), findsNothing);
      expect(find.text('Chrome'), findsOneWidget);
      expect(find.text('Brave'), findsOneWidget);
      expect(find.text('Eigene Webseite hinterlegen'), findsOneWidget);
      expect(find.text('Anderer Browser'), findsNothing);
      expect(find.byKey(const Key('home-browser-option-safari')), findsNothing);
      expect(find.byKey(const Key('home-browser-option-other')), findsNothing);
      expect(
        find.textContaining('Safari öffnet sich über Standardbrowser'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-browser-missing-url-sheet')),
        findsNothing,
      );
      expect(find.text('Talvori-Leser'), findsNothing);
      expect(find.text('Keine Seite gespeichert'), findsNothing);
    },
  );

  testWidgets('home browser custom start page can be saved', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final browserButton = find.byKey(const Key('home-browser-return-button'));
    await tester.scrollUntilVisible(
      browserButton,
      120,
      scrollable: find.byType(Scrollable),
    );
    await tester.pump();
    await tester.tap(browserButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('home-browser-set-start-url')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(const Key('home-browser-start-url-sheet')),
      findsOneWidget,
    );
    expect(find.text('Eigene Webseite'), findsOneWidget);
    final input = tester.widget<TextField>(
      find.byKey(const Key('home-browser-start-url-input')),
    );
    expect(input.controller?.text, isEmpty);

    await tester.enterText(
      find.byKey(const Key('home-browser-start-url-input')),
      'bbc.com',
    );
    await tester.tap(find.byKey(const Key('home-browser-start-url-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(homeBrowserCustomStartUrlStorageKey),
      'https://bbc.com',
    );
  });

  testWidgets('home browser custom start page rejects invalid url', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final browserButton = find.byKey(const Key('home-browser-return-button'));
    await tester.ensureVisible(browserButton);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(browserButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('home-browser-set-start-url')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(
      find.byKey(const Key('home-browser-start-url-input')),
      'keine webseite',
    );
    await tester.tap(find.byKey(const Key('home-browser-start-url-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(homeBrowserCustomStartUrlStorageKey), isNull);
    expect(find.byKey(const Key('home-browser-open-toast')), findsOneWidget);
    expect(find.text('Bitte gib eine gültige Webseite ein.'), findsOneWidget);
  });

  test('home browser start url normalization accepts only web urls', () {
    expect(normalizeHomeBrowserStartUrl(null), isNull);
    expect(normalizeHomeBrowserStartUrl(''), isNull);
    expect(
      normalizeHomeBrowserStartUrl('bbc.com'),
      Uri.parse('https://bbc.com'),
    );
    expect(
      normalizeHomeBrowserStartUrl('https://www.wikipedia.org'),
      Uri.parse('https://www.wikipedia.org'),
    );
    expect(normalizeHomeBrowserStartUrl('ftp://example.com'), isNull);
    expect(normalizeHomeBrowserStartUrl('keine webseite'), isNull);
  });

  testWidgets('home browser standard choice opens system browser url', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final opened = <Uri>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBrowserUrlResolverProvider.overrideWithValue(
            () async => Uri.parse('https://www.bbc.com'),
          ),
          homeExternalBrowserLauncherProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return true;
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final browserButton = find.byKey(const Key('home-browser-return-button'));
    await tester.ensureVisible(browserButton);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -96));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(browserButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('home-browser-option-system')));
    await tester.pump(const Duration(seconds: 2));

    expect(opened, [Uri.parse('https://www.bbc.com')]);
    expect(find.text('Talvori-Leser'), findsNothing);
    expect(find.text('Kategorie'), findsNothing);
    expect(find.text('Vocabs'), findsNothing);
    expect(find.byType(ImpulsPostfachScreen), findsNothing);
  });

  testWidgets('home browser brave choice tries brave then default fallback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final opened = <Uri>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBrowserUrlResolverProvider.overrideWithValue(
            () async => Uri.parse('https://www.bbc.com'),
          ),
          homeExternalBrowserLauncherProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return uri.scheme == 'https';
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final browserButton = find.byKey(const Key('home-browser-return-button'));
    await tester.ensureVisible(browserButton);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -96));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(browserButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('home-browser-option-brave')));
    await tester.pump(const Duration(seconds: 2));

    expect(opened, [
      Uri.parse('brave://open-url?url=https%3A%2F%2Fwww.bbc.com'),
      Uri.parse('https://www.bbc.com'),
    ]);
    expect(
      find.text('Brave ist nicht verfügbar. Standardbrowser wird geöffnet.'),
      findsOneWidget,
    );
    expect(find.text('Talvori-Leser'), findsNothing);
  });

  testWidgets('home browser chrome choice tries chrome then default fallback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final opened = <Uri>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBrowserUrlResolverProvider.overrideWithValue(
            () async => Uri.parse('https://www.bbc.com'),
          ),
          homeExternalBrowserLauncherProvider.overrideWithValue((uri) async {
            opened.add(uri);
            if (uri.scheme == 'googlechromes') {
              throw StateError('Chrome unavailable');
            }
            return uri.scheme == 'https';
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-browser-return-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('home-browser-option-chrome')));
    await tester.pump(const Duration(seconds: 2));

    expect(opened, [
      Uri.parse('googlechromes://www.bbc.com'),
      Uri.parse('https://www.bbc.com'),
    ]);
    expect(
      find.text('Chrome ist nicht verfügbar. Standardbrowser wird geöffnet.'),
      findsOneWidget,
    );
    expect(find.text('Talvori-Leser'), findsNothing);
  });

  testWidgets('home browser choice sheet has no overflow on compact height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final previousOnError = FlutterError.onError;
    final overflows = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed')) {
        overflows.add(details);
      } else {
        previousOnError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeExternalBrowserLauncherProvider.overrideWithValue((_) async {
            return true;
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final browserButton = find.byKey(const Key('home-browser-return-button'));
    await tester.ensureVisible(browserButton);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -96));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(browserButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('home-browser-open-sheet')), findsOneWidget);
    expect(find.text('Standardbrowser'), findsOneWidget);
    expect(find.text('Safari'), findsNothing);
    expect(find.text('Chrome'), findsOneWidget);
    expect(find.text('Brave'), findsOneWidget);
    expect(find.text('Eigene Webseite hinterlegen'), findsOneWidget);
    expect(find.text('Anderer Browser'), findsNothing);
    expect(find.byKey(const Key('home-browser-option-safari')), findsNothing);
    expect(find.byKey(const Key('home-browser-option-other')), findsNothing);
    expect(overflows, isEmpty);
  });

  testWidgets('home top right button opens progress hub', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-progress-hub-button')));
    await tester.pumpAndSettle();

    expect(find.byType(RewardsCenterScreen), findsOneWidget);
    expect(find.text('Fortschritt'), findsOneWidget);
    expect(find.text('Liga'), findsOneWidget);
    expect(find.text('Belohnungen'), findsOneWidget);
    expect(find.text('Statistik'), findsOneWidget);
  });

  testWidgets('home top left V button opens local known review screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-known-review-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.byType(LocalKnownReviewScreen), findsOneWidget);
  });

  testWidgets('bottom word games button opens word games directly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Wortspiele'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-practice-button')));
    await tester.pumpAndSettle();

    expect(find.byType(VocabScreen), findsOneWidget);
    expect(find.text('Wortspiele'), findsWidgets);
    expect(find.text('Vocabs'), findsNothing);
    expect(find.text('Course'), findsNothing);
    expect(find.text('Üben wird vorbereitet.'), findsNothing);
    expect(find.text('Kategorie'), findsNothing);
    expect(find.byKey(const Key('category-popup-my-words-tile')), findsNothing);
    expect(find.byType(LocalLearningSourcesScreen), findsNothing);
    expect(find.byType(LocalLearningSourceDetailScreen), findsNothing);
  });

  testWidgets('word games screen shows all game cards without legacy mocks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();

    expect(find.byType(VocabScreen), findsOneWidget);
    expect(find.text('Wortspiele'), findsOneWidget);
    const visibleTexts = [
      'Schnellspiele',
      'Wörter bauen',
      'Smart Challenges',
      'Blitzrunde',
      'Wort-Match',
      'Hör & Schreib',
      'Lückenwort',
      'Wort-Jagd',
      'Wort erkennen',
      'Wort-Duell',
      'Hör-Fang',
      'Wort-Puzzle',
      'Hangman',
      'Silben-Regen',
      'Wortpfad',
      'Wortsuche',
      'Kontext-Challenge',
      'Gegenwort',
      'Synonym-Rätsel',
      'Boss-Fight',
      'Daily Word Quest',
    ];
    for (final text in visibleTexts) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.text('spielbar'), findsWidgets);
    expect(find.text('Vorschau'), findsOneWidget);
    expect(find.text('bald spielbar'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Wort-Duell')).dy,
      lessThan(tester.getTopLeft(find.text('Wörter bauen')).dy),
    );
    expect(find.text('Vocab Practice'), findsNothing);
    expect(find.text('Übungsarten'), findsNothing);
    expect(find.text('Bedeutung finden'), findsNothing);
    expect(find.text('Bedeutungs-Duell'), findsNothing);
    expect(find.text('Try Game shuffle'), findsNothing);
    expect(find.text('Vocab classic'), findsNothing);
    expect(find.text('Build words'), findsNothing);
    expect(find.text('Choose the word'), findsNothing);
    expect(find.text('Guess the word'), findsNothing);
    expect(find.text('Coming soon (tap to vote!)'), findsNothing);
    expect(find.text('Perfection'), findsNothing);
    expect(find.text('Klassisch üben'), findsNothing);
    expect(find.text('Frei wiederholen'), findsNothing);
  });

  testWidgets('word games screen has no tile overflow on iPhone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final previousOnError = FlutterError.onError;
    final overflows = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed')) {
        overflows.add(details);
        return;
      }
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();
    await tester.fling(find.byType(ListView), const Offset(0, -520), 1000);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, -720), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Wortspiele'), findsOneWidget);
    expect(find.text('Daily Word Quest'), findsOneWidget);
    expect(overflows, isEmpty);
  });

  testWidgets('word game subtitles can use a third line on compact cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();

    final blitzSubtitle = tester.widget<Text>(
      find.text('60 Sekunden, so viele Wörter wie möglich'),
    );
    final bossTile = find.byKey(const ValueKey('word-game-boss_fight'));
    await tester.scrollUntilVisible(
      bossTile,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final bossSubtitle = tester.widget<Text>(
      find.text('Besiege deine schwierigsten Wörter'),
    );

    expect(blitzSubtitle.maxLines, greaterThanOrEqualTo(3));
    expect(blitzSubtitle.overflow, TextOverflow.fade);
    expect(bossSubtitle.maxLines, greaterThanOrEqualTo(3));
    expect(bossSubtitle.overflow, TextOverflow.fade);
  });

  testWidgets('context challenge card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
              localWord(id: 'water', term: 'water', translation: 'Wasser'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-context_challenge')));
    await tester.pumpAndSettle();

    expect(find.byType(ContextChallengeGameScreen), findsOneWidget);
    expect(find.text('Kontext-Challenge'), findsWidgets);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
    expect(find.byType(LocalLearningSourcesScreen), findsNothing);
  });

  testWidgets('word hunt card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
              localWord(id: 'water', term: 'water', translation: 'Wasser'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-word_hunt')));
    await tester.pumpAndSettle();

    expect(find.byType(WordHuntGameScreen), findsOneWidget);
    expect(find.text('Wort-Jagd'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('speed round card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
              localWord(id: 'water', term: 'water', translation: 'Wasser'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-speed_round')));
    await tester.pumpAndSettle();

    expect(find.byType(SpeedRoundGameScreen), findsOneWidget);
    expect(find.text('Blitzrunde'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('word recognition card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
              localWord(id: 'water', term: 'water', translation: 'Wasser'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-word_recognition')));
    await tester.pumpAndSettle();

    expect(find.byType(WordRecognitionGameScreen), findsOneWidget);
    expect(find.text('Wort erkennen'), findsWidgets);
    expect(
      find.byKey(const ValueKey('word-recognition-start-button')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('word-recognition-hint')), findsNothing);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('word duel card opens preview screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();

    final duelTile = find.byKey(const ValueKey('word-game-word_duel'));
    await tester.ensureVisible(duelTile);
    await tester.pump();
    await tester.tap(duelTile);
    await tester.pumpAndSettle();

    expect(find.byType(WordDuelPreviewScreen), findsOneWidget);
    expect(find.text('Wort-Duell'), findsWidgets);
    expect(
      find.textContaining('vorbereiteter Mehrspieler-Modus'),
      findsOneWidget,
    );
    expect(find.text('Bedeutungs-Duell'), findsNothing);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('listen and write card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [localWord(id: 'emergency', term: 'emergency')];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-listen_write')));
    await tester.pumpAndSettle();

    expect(find.byType(ListenAndWriteGameScreen), findsOneWidget);
    expect(find.text('Hör & Schreib'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('gap word card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [localWord(id: 'emergency', term: 'emergency')];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-gap_word')));
    await tester.pumpAndSettle();

    expect(find.byType(GapWordGameScreen), findsOneWidget);
    expect(find.text('Lückenwort'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('word match card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-word_match')));
    await tester.pumpAndSettle();

    expect(find.byType(WordMatchGameScreen), findsOneWidget);
    expect(find.text('Wort-Match'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('word puzzle card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [localWord(id: 'emergency', term: 'emergency')];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-word_puzzle')));
    await tester.pumpAndSettle();

    expect(find.byType(WordPuzzleGameScreen), findsOneWidget);
    expect(find.text('Wort-Puzzle'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('hangman card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [localWord(id: 'level', term: 'level')];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-hangman')));
    await tester.pumpAndSettle();

    expect(find.byType(HangmanGameScreen), findsOneWidget);
    expect(find.text('Hangman'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('daily word quest card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
              localWord(id: 'water', term: 'water', translation: 'Wasser'),
              localWord(id: 'level', term: 'level', translation: 'Stufe'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('word-game-daily_word_quest')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('word-game-daily_word_quest')));
    await tester.pumpAndSettle();

    expect(find.byType(DailyWordQuestGameScreen), findsOneWidget);
    expect(find.text('Daily Word Quest'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('boss fight card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
              localWord(id: 'water', term: 'water', translation: 'Wasser'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('word-game-boss_fight')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('word-game-boss_fight')));
    await tester.pumpAndSettle();

    expect(find.byType(BossFightGameScreen), findsOneWidget);
    expect(find.text('Boss-Fight'), findsWidgets);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('word games hub has no prepared dummy card left', (tester) async {
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();

    const gameIds = [
      'speed_round',
      'word_hunt',
      'word_recognition',
      'word_duel',
      'audio_catch',
      'word_match',
      'word_puzzle',
      'gap_word',
      'hangman',
      'syllable_rain',
      'word_path',
      'word_search',
      'listen_write',
      'context_challenge',
      'odd_word',
      'synonym_riddle',
      'boss_fight',
      'daily_word_quest',
    ];

    for (final id in gameIds) {
      expect(find.byKey(ValueKey('word-game-$id')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('word-game-training_camp')), findsNothing);
    expect(find.text('Trainingscamp'), findsNothing);
    expect(find.byKey(const Key('word-game-prepared-toast')), findsNothing);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('local sources open source details and keep back stack', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LocalLearningSourcesScreen()),
      ),
    );
    await tester.pump();

    for (final entry in const [
      (Key('local-source-all-words-tile'), 'Alle Wörter'),
      (Key('local-source-favorites-tile'), 'Favoriten'),
      (Key('local-source-my-words-tile'), 'Meine Wörter'),
      (Key('local-source-known-words-tile'), 'Wörter, die ich kenne'),
      (Key('local-source-reviewed-for-learning-tile'), 'Noch zu lernen'),
      (Key('local-source-my-mix-tile'), 'Mein Mix'),
    ]) {
      await tester.tap(find.byKey(entry.$1));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      final opensFilterList =
          entry.$1 == const Key('local-source-known-words-tile') ||
          entry.$1 == const Key('local-source-reviewed-for-learning-tile');
      expect(
        find.byType(LocalLearningSourceDetailScreen),
        opensFilterList ? findsNothing : findsOneWidget,
      );
      expect(
        find.byType(LocalWordListScreen),
        opensFilterList ? findsOneWidget : findsNothing,
      );
      expect(find.text(entry.$2), findsWidgets);
      if (!opensFilterList) {
        final wheel = tester.widget<CategoryWheel>(find.byType(CategoryWheel));
        expect(wheel.categories, const [
          'Alle Wörter',
          'Favoriten',
          'Meine Wörter',
          'Wörter, die ich kenne',
          'Noch zu lernen',
          'Mein Mix',
        ]);
        wheel.onChanged(1, 'Favoriten');
        await tester.pump();
        final updatedWheel = tester.widget<CategoryWheel>(
          find.byType(CategoryWheel),
        );
        expect(updatedWheel.initialIndex, 1);
      }
      expect(find.text('Übungsmodus'), findsNothing);
      expect(find.text('All Words'), findsNothing);
      expect(find.text('My words'), findsNothing);
      expect(find.text('Favorites'), findsNothing);
      expect(find.text('Words I know'), findsNothing);
      expect(find.text('My mix'), findsNothing);

      Navigator.of(
        tester.element(
          opensFilterList
              ? find.byType(LocalWordListScreen)
              : find.byType(LocalLearningSourceDetailScreen),
        ),
      ).pop();
      await tester.pumpAndSettle();
      expect(find.byType(LocalLearningSourcesScreen), findsOneWidget);
      expect(find.text('Wortquellen'), findsOneWidget);
    }
  });
}

class _HomeFakeAiChatClient implements AiChatClient {
  const _HomeFakeAiChatClient(this._handler);

  final Future<AiChatResult> Function(AiChatRequest request) _handler;

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) => _handler(request);
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  final pushedRouteNames = <String?>[];
  final poppedRouteNames = <String?>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    pushedRouteNames.add(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    poppedRouteNames.add(route.settings.name);
  }
}
