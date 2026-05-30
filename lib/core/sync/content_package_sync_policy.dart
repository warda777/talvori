import 'content_package_import_marker.dart';
import 'content_package_metadata.dart';
import 'package:talvori/core/language/language_code.dart';
import 'version_compare.dart';

enum ContentPackageSyncDecisionType { shouldImport, skip, blocked }

enum ContentPackageSyncReasonCode {
  approvedPackageMissingLocally,
  newerApprovedVersionAvailable,
  alreadyImported,
  notApproved,
  languagePairMismatch,
  minAppVersionTooHigh,
  checksumChangedForSameVersion,
  olderVersion,
  invalidPackageMetadata,
}

class ContentPackageSyncDecision {
  const ContentPackageSyncDecision({
    required this.type,
    required this.reasonCode,
    required this.message,
  });

  final ContentPackageSyncDecisionType type;
  final ContentPackageSyncReasonCode reasonCode;
  final String message;

  bool get shouldImport => type == ContentPackageSyncDecisionType.shouldImport;
  bool get skip => type == ContentPackageSyncDecisionType.skip;
  bool get blocked => type == ContentPackageSyncDecisionType.blocked;
}

class ContentPackageSyncPolicy {
  const ContentPackageSyncPolicy();

  ContentPackageSyncDecision decide({
    required ContentPackageMetadata remotePackage,
    required String desiredLanguagePair,
    required String currentAppVersion,
    ContentPackageImportMarker? localMarker,
  }) {
    final normalizedDesiredLanguagePair =
        TalvoriLanguages.normalizeLanguagePair(desiredLanguagePair);
    if (!remotePackage.hasRequiredFields ||
        normalizedDesiredLanguagePair.isEmpty ||
        VersionCompare.compare(remotePackage.version, '0.0.0') ==
            VersionComparison.invalid ||
        VersionCompare.compare(currentAppVersion, '0.0.0') ==
            VersionComparison.invalid ||
        (localMarker != null && !localMarker.hasRequiredFields)) {
      return _blocked(
        ContentPackageSyncReasonCode.invalidPackageMetadata,
        'Content package metadata is incomplete or invalid.',
      );
    }

    if (!remotePackage.isApproved) {
      return _blocked(
        ContentPackageSyncReasonCode.notApproved,
        'Only approved content packages may be imported.',
      );
    }

    if (remotePackage.languagePair != normalizedDesiredLanguagePair) {
      return _blocked(
        ContentPackageSyncReasonCode.languagePairMismatch,
        'Content package language pair does not match the requested pair.',
      );
    }

    final minAppVersion = remotePackage.minAppVersion;
    if (minAppVersion != null) {
      final appVersionComparison = VersionCompare.compare(
        currentAppVersion,
        minAppVersion,
      );
      if (appVersionComparison == VersionComparison.invalid) {
        return _blocked(
          ContentPackageSyncReasonCode.invalidPackageMetadata,
          'Content package minAppVersion is invalid.',
        );
      }
      if (appVersionComparison == VersionComparison.older) {
        return _blocked(
          ContentPackageSyncReasonCode.minAppVersionTooHigh,
          'Content package requires a newer app version.',
        );
      }
    }

    if (localMarker == null) {
      return _shouldImport(
        ContentPackageSyncReasonCode.approvedPackageMissingLocally,
        'Approved content package has not been imported locally yet.',
      );
    }

    if (localMarker.languagePair != remotePackage.languagePair ||
        localMarker.contentPackageId != remotePackage.contentPackageId) {
      return _shouldImport(
        ContentPackageSyncReasonCode.approvedPackageMissingLocally,
        'Approved content package has no matching local marker.',
      );
    }

    final packageVersionComparison = VersionCompare.compare(
      remotePackage.version,
      localMarker.version,
    );
    if (packageVersionComparison == VersionComparison.invalid) {
      return _blocked(
        ContentPackageSyncReasonCode.invalidPackageMetadata,
        'Content package version metadata is invalid.',
      );
    }

    if (packageVersionComparison == VersionComparison.older) {
      return _skip(
        ContentPackageSyncReasonCode.olderVersion,
        'Remote content package is older than the local marker.',
      );
    }

    if (packageVersionComparison == VersionComparison.newer) {
      return _shouldImport(
        ContentPackageSyncReasonCode.newerApprovedVersionAvailable,
        'A newer approved content package version is available.',
      );
    }

    if (_normalizeChecksum(remotePackage.checksum) !=
        _normalizeChecksum(localMarker.checksum)) {
      return _blocked(
        ContentPackageSyncReasonCode.checksumChangedForSameVersion,
        'Content package checksum changed for the same version.',
      );
    }

    return _skip(
      ContentPackageSyncReasonCode.alreadyImported,
      'Content package version and checksum are already imported.',
    );
  }

  ContentPackageSyncDecision _shouldImport(
    ContentPackageSyncReasonCode reasonCode,
    String message,
  ) {
    return ContentPackageSyncDecision(
      type: ContentPackageSyncDecisionType.shouldImport,
      reasonCode: reasonCode,
      message: message,
    );
  }

  ContentPackageSyncDecision _skip(
    ContentPackageSyncReasonCode reasonCode,
    String message,
  ) {
    return ContentPackageSyncDecision(
      type: ContentPackageSyncDecisionType.skip,
      reasonCode: reasonCode,
      message: message,
    );
  }

  ContentPackageSyncDecision _blocked(
    ContentPackageSyncReasonCode reasonCode,
    String message,
  ) {
    return ContentPackageSyncDecision(
      type: ContentPackageSyncDecisionType.blocked,
      reasonCode: reasonCode,
      message: message,
    );
  }

  String _normalizeChecksum(String? value) {
    return value?.trim().toLowerCase() ?? '';
  }
}
