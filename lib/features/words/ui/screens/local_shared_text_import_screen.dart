import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/core/local_database/import/shared_text_import_result.dart';
import 'package:talvori/core/local_database/providers/shared_text_import_service_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';

typedef LocalSharedTextImportCallback =
    Future<SharedTextImportResult> Function(String rawText);

class LocalSharedTextImportScreen extends ConsumerStatefulWidget {
  const LocalSharedTextImportScreen({super.key, this.importText});

  final LocalSharedTextImportCallback? importText;

  @override
  ConsumerState<LocalSharedTextImportScreen> createState() =>
      _LocalSharedTextImportScreenState();
}

class _LocalSharedTextImportScreenState
    extends ConsumerState<LocalSharedTextImportScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isImporting = false;
  SharedTextImportResult? _result;

  static const Color _background = Color(0xFF02050A);
  static const Color _panel = Color(0xFF07101A);
  static const Color _cyan = Color(0xFF5DDCFF);
  static const Color _violet = Color(0xFFB36BFF);
  static const Color _red = Color(0xFFFF4E6A);
  static const Color _green = Color(0xFF55F6A3);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isImporting) return;
    setState(() {
      _isImporting = true;
      _result = null;
    });

    try {
      final importText = widget.importText;
      final result = importText != null
          ? await importText(_controller.text)
          : await _importWithLocalService(_controller.text);
      if (!mounted) return;
      setState(() {
        _result = result;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Future<SharedTextImportResult> _importWithLocalService(String rawText) async {
    final service = await ref.read(sharedTextImportServiceProvider.future);
    return service.importRawText(rawText: rawText, now: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Wort importieren'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _ImportPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meine Wörter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lokaler Testimport ohne DeepL und ohne Share Extension.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    key: const Key('local-shared-text-import-input'),
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: 'Wort eingeben',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.42),
                      ),
                      prefixIcon: const Icon(
                        Icons.edit_note_rounded,
                        color: _cyan,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF030A12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: _cyan.withValues(alpha: 0.55),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: _cyan, width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('local-shared-text-import-button'),
                      onPressed: _isImporting ? null : _submit,
                      icon: _isImporting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_download_done_rounded),
                      label: const Text('Importieren'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _panel,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _panel.withValues(alpha: 0.55),
                        disabledForegroundColor: Colors.white54,
                        side: BorderSide(color: _violet.withValues(alpha: 0.8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (result != null) ...[
              const SizedBox(height: 18),
              _ResultPanel(result: result),
              if (result.status == SharedTextImportStatus.imported) ...[
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  key: const Key('open-local-my-words-button'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LocalWordListScreen(
                          categoryId: localMyWordsCategoryId,
                          title: localMyWordsCategoryLabel,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list_alt_rounded),
                  label: const Text('Meine Wörter öffnen'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: _cyan.withValues(alpha: 0.82)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ImportPanel extends StatelessWidget {
  const _ImportPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _LocalSharedTextImportScreenState._panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _LocalSharedTextImportScreenState._cyan.withValues(
            alpha: 0.45,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: _LocalSharedTextImportScreenState._cyan.withValues(
              alpha: 0.13,
            ),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.result});

  final SharedTextImportResult result;

  @override
  Widget build(BuildContext context) {
    final color = switch (result.status) {
      SharedTextImportStatus.imported =>
        _LocalSharedTextImportScreenState._green,
      SharedTextImportStatus.duplicate =>
        _LocalSharedTextImportScreenState._violet,
      SharedTextImportStatus.empty ||
      SharedTextImportStatus.invalid ||
      SharedTextImportStatus.error => _LocalSharedTextImportScreenState._red,
    };
    final title = switch (result.status) {
      SharedTextImportStatus.imported => 'Erfolgreich importiert',
      SharedTextImportStatus.duplicate => 'Bereits vorhanden',
      SharedTextImportStatus.empty => 'Leere Eingabe',
      SharedTextImportStatus.invalid => 'Ungültiger Text',
      SharedTextImportStatus.error => 'Fehler',
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF050D16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.13),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconForStatus(result.status), color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.message,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForStatus(SharedTextImportStatus status) {
    return switch (status) {
      SharedTextImportStatus.imported => Icons.check_circle_rounded,
      SharedTextImportStatus.duplicate => Icons.info_rounded,
      SharedTextImportStatus.empty ||
      SharedTextImportStatus.invalid ||
      SharedTextImportStatus.error => Icons.error_rounded,
    };
  }
}
