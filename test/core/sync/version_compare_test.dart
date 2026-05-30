import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/sync/version_compare.dart';

void main() {
  group('VersionCompare', () {
    test('detects same semantic versions', () {
      expect(VersionCompare.compare('1.0.0', '1.0.0'), VersionComparison.same);
      expect(VersionCompare.compare('1.0', '1.0.0'), VersionComparison.same);
    });

    test('detects newer and older semantic versions', () {
      expect(VersionCompare.compare('1.2.0', '1.1.9'), VersionComparison.newer);
      expect(VersionCompare.compare('1.2.0', '2.0.0'), VersionComparison.older);
    });

    test('does not crash on invalid versions', () {
      expect(
        VersionCompare.compare('1.two.0', '1.0.0'),
        VersionComparison.invalid,
      );
      expect(VersionCompare.compare('', '1.0.0'), VersionComparison.invalid);
      expect(
        VersionCompare.compare('1..0', '1.0.0'),
        VersionComparison.invalid,
      );
    });
  });
}
