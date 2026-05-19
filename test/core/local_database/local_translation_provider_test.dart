import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_translation_provider.dart';
import 'package:talvori/core/local_database/providers/shared_text_import_service_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/core/local_database/translation/deepl_translation_client.dart';
import 'package:talvori/core/local_database/translation/fake_translation_client.dart';
import 'package:talvori/core/local_database/translation/local_translation_config.dart';
import 'package:talvori/core/local_database/translation/supabase_translation_client.dart';
import 'package:talvori/core/local_database/translation/translation_client.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('local translation providers', () {
    Future<({ProviderContainer container, Directory tempDir})> createContainer({
      List<Override> overrides = const [],
    }) async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_translation_provider_test_',
      );
      final container = ProviderContainer(
        overrides: [
          localBootstrapDatabasesPathProvider.overrideWithValue(tempDir.path),
          ...overrides,
        ],
      );

      return (container: container, tempDir: tempDir);
    }

    Future<void> disposeContainer(
      ProviderContainer container,
      Directory tempDir,
    ) async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
      final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
      await databaseFactoryFfi.deleteDatabase(databasePath);
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }

    test('translation_client_provider_uses_fake_client_by_default', () async {
      final (:container, :tempDir) = await createContainer();
      addTearDown(() => disposeContainer(container, tempDir));

      final config = container.read(localTranslationConfigProvider);
      final client = container.read(translationClientProvider);
      final result = await client.translate(
        const TranslationRequest(
          text: 'hello',
          sourceLanguage: 'en',
          targetLanguage: 'de',
        ),
      );

      expect(config.mode, LocalTranslationClientMode.fake);
      expect(config.resolvedTargetLanguage, 'DE');
      expect(config.resolvedSourceLanguage, isNull);
      expect(client, isA<FakeTranslationClient>());
      expect(result.translatedText, 'hallo');
    });

    test('translation_config_normalizes_runtime_languages', () {
      const config = LocalTranslationConfig.deepl(
        apiKey: 'test-key',
        targetLanguage: ' de ',
        sourceLanguage: ' en ',
      );

      expect(config.mode, LocalTranslationClientMode.deepl);
      expect(config.hasValidDeepLConfig, isTrue);
      expect(config.resolvedTargetLanguage, 'DE');
      expect(config.resolvedSourceLanguage, 'EN');
    });

    test(
      'translation_client_provider_can_create_deepl_when_configured',
      () async {
        final (:container, :tempDir) = await createContainer(
          overrides: [
            localTranslationConfigProvider.overrideWithValue(
              LocalTranslationConfig.deepl(
                apiKey: 'test-key',
                baseUri: Uri.parse('https://api-free.deepl.com'),
                targetLanguage: 'DE',
              ),
            ),
          ],
        );
        addTearDown(() => disposeContainer(container, tempDir));

        final client = container.read(translationClientProvider);

        expect(client, isA<DeepLTranslationClient>());
      },
    );

    test(
      'translation_client_provider_falls_back_to_fake_for_empty_deepl_key',
      () async {
        final (:container, :tempDir) = await createContainer(
          overrides: [
            localTranslationConfigProvider.overrideWithValue(
              const LocalTranslationConfig.deepl(apiKey: '   '),
            ),
          ],
        );
        addTearDown(() => disposeContainer(container, tempDir));

        final client = container.read(translationClientProvider);
        final result = await client.translate(
          const TranslationRequest(
            text: 'world',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        );

        expect(client, isA<FakeTranslationClient>());
        expect(result.translatedText, 'welt');
      },
    );

    test(
      'translation_client_provider_can_create_supabase_when_configured',
      () async {
        final (:container, :tempDir) = await createContainer(
          overrides: [
            localTranslationConfigProvider.overrideWithValue(
              const LocalTranslationConfig.supabase(),
            ),
            localTranslationClientFactoryProvider.overrideWithValue(
              LocalTranslationClientFactory(
                supabaseFunctionCaller: (functionName, payload) async {
                  return {'translation': 'Haus'};
                },
              ),
            ),
          ],
        );
        addTearDown(() => disposeContainer(container, tempDir));

        final client = container.read(translationClientProvider);

        expect(client, isA<SupabaseTranslationClient>());
      },
    );

    test(
      'translation_client_provider_falls_back_to_fake_without_supabase_caller',
      () async {
        final (:container, :tempDir) = await createContainer(
          overrides: [
            localTranslationConfigProvider.overrideWithValue(
              const LocalTranslationConfig.supabase(),
            ),
          ],
        );
        addTearDown(() => disposeContainer(container, tempDir));

        final client = container.read(translationClientProvider);
        final result = await client.translate(
          const TranslationRequest(
            text: 'hello',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        );

        expect(client, isA<FakeTranslationClient>());
        expect(result.translatedText, 'hallo');
      },
    );

    test(
      'translation_client_provider_uses_injected_supabase_function_caller',
      () async {
        final (:container, :tempDir) = await createContainer(
          overrides: [
            localTranslationConfigProvider.overrideWithValue(
              const LocalTranslationConfig.supabase(),
            ),
            supabaseTranslationFunctionCallerProvider.overrideWithValue(
              (functionName, payload) async => {'translation': 'Haus'},
            ),
          ],
        );
        addTearDown(() => disposeContainer(container, tempDir));

        final client = container.read(translationClientProvider);

        expect(client, isA<SupabaseTranslationClient>());
      },
    );

    test(
      'pending_translation_processor_provider_injects_translation_client',
      () async {
        final (:container, :tempDir) = await createContainer(
          overrides: [
            translationClientProvider.overrideWithValue(
              FakeTranslationClient(translations: {'umbrella': 'regenschirm'}),
            ),
          ],
        );
        addTearDown(() => disposeContainer(container, tempDir));

        final importService = await container.read(
          sharedTextImportServiceProvider.future,
        );
        final importResult = await importService.importRawText(
          rawText: 'umbrella',
          now: DateTime(2026, 5, 19, 10),
        );
        final processor = await container.read(
          pendingTranslationProcessorProvider.future,
        );

        final processResult = await processor.processPendingTranslations(
          categoryId: localMyWordsCategoryId,
        );
        final bootstrap = await container.read(localBootstrapProvider.future);
        final word = await bootstrap.repositoryFactory.wordRepository
            .loadWordById(importResult.word!.id);

        expect(processResult.processed, 1);
        expect(processResult.translated, 1);
        expect(processResult.failed, 0);
        expect(word?.translation, 'regenschirm');
        expect(word?.translationStatus, TranslationStatus.translated);
      },
    );
  });
}
