enum TranslationStatus {
  pending('pending'),
  translated('translated'),
  failed('failed');

  const TranslationStatus(this.dbValue);

  final String dbValue;

  static TranslationStatus fromDbValue(Object? value) {
    return switch (value) {
      'pending' => TranslationStatus.pending,
      'failed' => TranslationStatus.failed,
      _ => TranslationStatus.translated,
    };
  }
}
