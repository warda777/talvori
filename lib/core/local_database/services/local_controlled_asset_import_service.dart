import 'local_json_asset_import_service.dart';

class LocalControlledAssetImportService {
  const LocalControlledAssetImportService({
    required LocalJsonAssetImportService assetImportService,
  }) : _assetImportService = assetImportService;

  final LocalJsonAssetImportService _assetImportService;

  Future<void> importRegisteredAsset({
    required String assetKey,
    required DateTime now,
  }) {
    return _assetImportService.importFromAsset(assetKey: assetKey, now: now);
  }
}
