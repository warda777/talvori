import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final releaseSyncPolicyProvider = Provider<ReleaseSyncPolicy>((ref) {
  return ReleaseSyncPolicy.current();
});

class ReleaseSyncPolicy {
  const ReleaseSyncPolicy({
    required this.isDebugBuild,
    this.allowLegacySupabaseWordsAutoSyncOverride,
  });

  factory ReleaseSyncPolicy.current() {
    return const ReleaseSyncPolicy(isDebugBuild: kDebugMode);
  }

  final bool isDebugBuild;

  /// Temporary escape hatch for the legacy word-count based Supabase import.
  ///
  /// The current auto-sync reads Supabase and writes into local SQLite based on
  /// local word count only. Release builds keep it disabled until versioned,
  /// approved content packages with language-pair guards exist.
  final bool? allowLegacySupabaseWordsAutoSyncOverride;

  bool get allowLegacySupabaseWordsAutoSync {
    return allowLegacySupabaseWordsAutoSyncOverride ?? isDebugBuild;
  }
}
