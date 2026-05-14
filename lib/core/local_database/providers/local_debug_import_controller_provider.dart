import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/local_debug_import_controller.dart';
import '../services/local_controlled_asset_import_service.dart';
import '../services/local_json_asset_import_service.dart';
import '../services/local_json_import_service.dart';
import 'local_bootstrap_provider.dart';

final localDebugImportAssetBundleProvider = Provider<AssetBundle>((ref) {
  return rootBundle;
});

final localDebugImportControllerProvider =
    AsyncNotifierProvider<
      LocalDebugImportControllerNotifier,
      LocalDebugImportControllerState
    >(LocalDebugImportControllerNotifier.new);

class LocalDebugImportControllerNotifier
    extends AsyncNotifier<LocalDebugImportControllerState> {
  LocalDebugImportController? _controller;

  @override
  Future<LocalDebugImportControllerState> build() async {
    final bootstrapResult = await ref.watch(localBootstrapProvider.future);
    final repositoryFactory = bootstrapResult.repositoryFactory;
    final assetBundle = ref.watch(localDebugImportAssetBundleProvider);
    final jsonImportService = LocalJsonImportService(
      categoryRepository: repositoryFactory.categoryRepository,
      wordRepository: repositoryFactory.wordRepository,
    );
    final assetImportService = LocalJsonAssetImportService(
      assetBundle: assetBundle,
      jsonImportService: jsonImportService,
    );
    final controlledImportService = LocalControlledAssetImportService(
      assetImportService: assetImportService,
    );

    _controller = LocalDebugImportController(
      controlledImportService: controlledImportService,
    );

    return _controller!.state;
  }

  Future<void> importDefaultWords({required DateTime now}) async {
    final controller = _controller;
    if (controller == null) {
      throw StateError('LocalDebugImportController is not initialized.');
    }

    state = AsyncValue.data(
      controller.state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
        wasSuccessful: false,
      ),
    );

    await controller.importDefaultWords(now: now);
    state = AsyncValue.data(controller.state);
  }
}
