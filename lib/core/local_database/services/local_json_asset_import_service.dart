import 'package:flutter/services.dart';

import 'local_json_import_service.dart';

class LocalJsonAssetImportService {
  const LocalJsonAssetImportService({
    required AssetBundle assetBundle,
    LocalJsonImportService? jsonImportService,
  }) : _assetBundle = assetBundle,
       _jsonImportService = jsonImportService;

  final AssetBundle _assetBundle;
  final LocalJsonImportService? _jsonImportService;

  Future<String> loadJsonFromAsset(String assetKey) {
    return _assetBundle.loadString(assetKey);
  }

  Future<void> importFromAsset({
    required String assetKey,
    required DateTime now,
  }) async {
    final jsonImportService = _jsonImportService;
    if (jsonImportService == null) {
      throw StateError('LocalJsonImportService is required for asset import.');
    }

    final json = await loadJsonFromAsset(assetKey);
    await jsonImportService.importFromJsonString(json: json, now: now);
  }
}
