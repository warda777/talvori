import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/sync/content_package_import_marker.dart';
import 'package:talvori/core/sync/content_package_metadata.dart';
import 'package:talvori/core/sync/content_package_sync_policy.dart';

void main() {
  group('ContentPackageSyncPolicy', () {
    const policy = ContentPackageSyncPolicy();
    final importedAt = DateTime.utc(2026, 5, 30, 12);

    ContentPackageMetadata remote({
      String contentPackageId = 'core-en-de-a1',
      String languagePair = 'en-de',
      String baseLanguage = 'en',
      String learningLanguage = 'en',
      String translationLanguage = 'de',
      String version = '1.0.0',
      String status = 'approved',
      String? checksum = 'abc123',
      String source = 'supabase',
      String? minAppVersion = '1.0.0',
      String? packageFamily,
      String? packageStage,
      String? packageType,
      String? levelRange,
      int wordCount = 1200,
      int categoryCount = 24,
    }) {
      return ContentPackageMetadata(
        contentPackageId: contentPackageId,
        languagePair: languagePair,
        baseLanguage: baseLanguage,
        learningLanguage: learningLanguage,
        translationLanguage: translationLanguage,
        version: version,
        status: status,
        checksum: checksum,
        source: source,
        minAppVersion: minAppVersion,
        packageFamily: packageFamily,
        packageStage: packageStage,
        packageType: packageType,
        levelRange: levelRange,
        wordCount: wordCount,
        categoryCount: categoryCount,
      );
    }

    ContentPackageImportMarker marker({
      String contentPackageId = 'core-en-de-a1',
      String languagePair = 'en-de',
      String version = '1.0.0',
      String? checksum = 'abc123',
      String source = 'supabase',
      int wordCount = 1200,
      int categoryCount = 24,
    }) {
      return ContentPackageImportMarker(
        contentPackageId: contentPackageId,
        languagePair: languagePair,
        version: version,
        checksum: checksum,
        source: source,
        importedAt: importedAt,
        wordCount: wordCount,
        categoryCount: categoryCount,
      );
    }

    ContentPackageSyncDecision decide(
      ContentPackageMetadata package, {
      ContentPackageImportMarker? localMarker,
      String desiredLanguagePair = 'en-de',
      String currentAppVersion = '1.0.0',
    }) {
      return policy.decide(
        remotePackage: package,
        desiredLanguagePair: desiredLanguagePair,
        currentAppVersion: currentAppVersion,
        localMarker: localMarker,
      );
    }

    test('approved package without local marker can be imported', () {
      final decision = decide(remote());

      expect(decision.shouldImport, isTrue);
      expect(
        decision.reasonCode,
        ContentPackageSyncReasonCode.approvedPackageMissingLocally,
      );
    });

    test('draft review and ai_suggested packages are blocked', () {
      for (final status in ['draft', 'review', 'ai_suggested']) {
        final decision = decide(remote(status: status));

        expect(decision.blocked, isTrue);
        expect(decision.reasonCode, ContentPackageSyncReasonCode.notApproved);
      }
    });

    test('wrong language pair is blocked', () {
      final decision = decide(remote(languagePair: 'en-es'));

      expect(decision.blocked, isTrue);
      expect(
        decision.reasonCode,
        ContentPackageSyncReasonCode.languagePairMismatch,
      );
    });

    test('same version and same checksum is skipped', () {
      final decision = decide(remote(), localMarker: marker());

      expect(decision.skip, isTrue);
      expect(decision.reasonCode, ContentPackageSyncReasonCode.alreadyImported);
    });

    test('same version and different checksum is blocked', () {
      final decision = decide(
        remote(checksum: 'different'),
        localMarker: marker(),
      );

      expect(decision.blocked, isTrue);
      expect(
        decision.reasonCode,
        ContentPackageSyncReasonCode.checksumChangedForSameVersion,
      );
    });

    test('newer approved version can be imported', () {
      final decision = decide(remote(version: '1.1.0'), localMarker: marker());

      expect(decision.shouldImport, isTrue);
      expect(
        decision.reasonCode,
        ContentPackageSyncReasonCode.newerApprovedVersionAvailable,
      );
    });

    test('older remote version is skipped', () {
      final decision = decide(remote(version: '0.9.0'), localMarker: marker());

      expect(decision.skip, isTrue);
      expect(decision.reasonCode, ContentPackageSyncReasonCode.olderVersion);
    });

    test('minAppVersion above current app version is blocked', () {
      final decision = decide(remote(minAppVersion: '2.0.0'));

      expect(decision.blocked, isTrue);
      expect(
        decision.reasonCode,
        ContentPackageSyncReasonCode.minAppVersionTooHigh,
      );
    });

    test('invalid versions do not crash and are blocked', () {
      final invalidRemote = decide(remote(version: 'not-a-version'));
      final invalidApp = decide(remote(), currentAppVersion: 'x.y.z');

      expect(invalidRemote.blocked, isTrue);
      expect(
        invalidRemote.reasonCode,
        ContentPackageSyncReasonCode.invalidPackageMetadata,
      );
      expect(invalidApp.blocked, isTrue);
      expect(
        invalidApp.reasonCode,
        ContentPackageSyncReasonCode.invalidPackageMetadata,
      );
    });

    test('language codes and statuses are normalized', () {
      final package = remote(
        languagePair: 'Englisch-Deutsch',
        baseLanguage: 'EN',
        learningLanguage: 'EN',
        translationLanguage: 'DE',
        status: 'APPROVED',
      );
      final decision = decide(package, desiredLanguagePair: 'EN-DE');

      expect(package.languagePair, 'en-de');
      expect(package.baseLanguage, 'en');
      expect(package.learningLanguage, 'en');
      expect(package.translationLanguage, 'de');
      expect(package.status, 'approved');
      expect(decision.shouldImport, isTrue);
    });

    test('invalid required fields are blocked', () {
      final decision = decide(remote(contentPackageId: ''));

      expect(decision.blocked, isTrue);
      expect(
        decision.reasonCode,
        ContentPackageSyncReasonCode.invalidPackageMetadata,
      );
    });

    test(
      'policy does not touch user data because it only decides metadata',
      () {
        final decision = decide(
          remote(),
          localMarker: marker(version: '0.9.0'),
        );

        expect(decision.shouldImport, isTrue);
        expect(decision.message, isNotEmpty);
      },
    );

    test('top words package still requires approved status', () {
      final decision = decide(
        remote(
          contentPackageId: 'top-500-en-de-v1',
          status: 'review',
          packageFamily: 'Top 500 Words',
          packageStage: 'Top 500',
          packageType: 'frequency',
          levelRange: 'A1-B2',
        ),
      );

      expect(decision.blocked, isTrue);
      expect(decision.reasonCode, ContentPackageSyncReasonCode.notApproved);
    });

    test('TOEFL package still requires approved status', () {
      final decision = decide(
        remote(
          contentPackageId: 'toefl-academic-en-de-v1',
          status: 'draft',
          packageFamily: 'TOEFL',
          packageStage: 'academic',
          packageType: 'exam',
          levelRange: 'B2-C1',
        ),
      );

      expect(decision.blocked, isTrue);
      expect(decision.reasonCode, ContentPackageSyncReasonCode.notApproved);
    });

    test('approved top words package can be imported when missing locally', () {
      final package = remote(
        contentPackageId: 'top-100-en-de-v1',
        packageFamily: 'Top 500 Words',
        packageStage: 'Top 1-100',
        packageType: 'frequency',
        levelRange: 'A1-B1',
      );
      final decision = decide(package);

      expect(package.packageFamily, 'top_words');
      expect(package.packageStage, '1-100');
      expect(package.packageType, 'frequency');
      expect(decision.shouldImport, isTrue);
      expect(
        decision.reasonCode,
        ContentPackageSyncReasonCode.approvedPackageMissingLocally,
      );
    });

    test('approved special package with wrong language pair is blocked', () {
      final decision = decide(
        remote(
          contentPackageId: 'business-english-b1-b2-en-es-v1',
          languagePair: 'en-es',
          translationLanguage: 'es',
          packageFamily: 'Business English',
          packageStage: 'B1-B2',
          packageType: 'business',
          levelRange: 'B1-B2',
        ),
        desiredLanguagePair: 'en-de',
      );

      expect(decision.blocked, isTrue);
      expect(
        decision.reasonCode,
        ContentPackageSyncReasonCode.languagePairMismatch,
      );
    });
  });
}
