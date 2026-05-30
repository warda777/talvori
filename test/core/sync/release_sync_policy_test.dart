import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/sync/release_sync_policy.dart';

void main() {
  group('ReleaseSyncPolicy', () {
    test('allows legacy Supabase word auto-sync in debug builds', () {
      const policy = ReleaseSyncPolicy(isDebugBuild: true);

      expect(policy.allowLegacySupabaseWordsAutoSync, isTrue);
    });

    test(
      'disables legacy Supabase word auto-sync in release builds by default',
      () {
        const policy = ReleaseSyncPolicy(isDebugBuild: false);

        expect(policy.allowLegacySupabaseWordsAutoSync, isFalse);
      },
    );

    test(
      'can explicitly allow legacy Supabase word auto-sync for future guards',
      () {
        const policy = ReleaseSyncPolicy(
          isDebugBuild: false,
          allowLegacySupabaseWordsAutoSyncOverride: true,
        );

        expect(policy.allowLegacySupabaseWordsAutoSync, isTrue);
      },
    );
  });
}
