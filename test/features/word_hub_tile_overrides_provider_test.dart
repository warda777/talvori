import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/words/application/word_hub_tile_overrides_provider.dart';

void main() {
  test('restores stored word hub icons from the static icon palette', () {
    final restoredIcon = wordHubIconFromStoredValueForTest(
      Icons.school.codePoint.toString(),
    );

    expect(restoredIcon, Icons.school);
  });

  test('falls back safely for unknown stored word hub icon values', () {
    expect(
      wordHubIconFromStoredValueForTest('not-a-codepoint'),
      Icons.auto_stories,
    );
    expect(wordHubIconFromStoredValueForTest('123456789'), Icons.auto_stories);
  });
}
