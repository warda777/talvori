import '../services/local_controlled_asset_import_service.dart';

enum LocalDebugImportControllerAction {
  none,
  importDefaultWords,
  importDefaultWordsFailed,
  resetDebugState,
}

class LocalDebugImportControllerState {
  const LocalDebugImportControllerState({
    this.isLoading = false,
    this.errorMessage,
    this.wasSuccessful = false,
    this.lastImportedAt,
    this.lastAction = LocalDebugImportControllerAction.none,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool wasSuccessful;
  final DateTime? lastImportedAt;
  final LocalDebugImportControllerAction lastAction;

  LocalDebugImportControllerState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? wasSuccessful,
    DateTime? lastImportedAt,
    bool clearLastImportedAt = false,
    LocalDebugImportControllerAction? lastAction,
  }) {
    return LocalDebugImportControllerState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      lastImportedAt: clearLastImportedAt
          ? null
          : (lastImportedAt ?? this.lastImportedAt),
      lastAction: lastAction ?? this.lastAction,
    );
  }
}

class LocalDebugImportController {
  LocalDebugImportController({
    required LocalControlledAssetImportService controlledImportService,
  }) : _controlledImportService = controlledImportService;

  static const defaultWordsAssetKey =
      'assets/local_import/default_words_v1.json';

  final LocalControlledAssetImportService _controlledImportService;

  LocalDebugImportControllerState state =
      const LocalDebugImportControllerState();

  Future<void> importDefaultWords({required DateTime now}) async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      wasSuccessful: false,
    );

    try {
      await _controlledImportService.importRegisteredAsset(
        assetKey: defaultWordsAssetKey,
        now: now,
      );

      state = state.copyWith(
        isLoading: false,
        clearErrorMessage: true,
        wasSuccessful: true,
        lastImportedAt: now,
        lastAction: LocalDebugImportControllerAction.importDefaultWords,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
        wasSuccessful: false,
        lastAction: LocalDebugImportControllerAction.importDefaultWordsFailed,
      );
    }
  }

  void resetDebugState() {
    state = state.copyWith(
      isLoading: false,
      clearErrorMessage: true,
      wasSuccessful: false,
      clearLastImportedAt: true,
      lastAction: LocalDebugImportControllerAction.resetDebugState,
    );
  }
}
