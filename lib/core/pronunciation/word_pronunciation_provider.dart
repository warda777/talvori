import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'word_pronunciation_service.dart';

final wordPronunciationServiceProvider = Provider<WordPronunciationService>((
  ref,
) {
  final service = FlutterWordPronunciationService();
  ref.onDispose(service.stop);
  return service;
});
