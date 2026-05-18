import '../models/local_word.dart';

enum SharedTextImportStatus { imported, duplicate, empty, invalid, error }

class SharedTextImportResult {
  const SharedTextImportResult({
    required this.status,
    required this.message,
    this.word,
  });

  final SharedTextImportStatus status;
  final String message;
  final LocalWord? word;

  bool get didImport => status == SharedTextImportStatus.imported;
}
