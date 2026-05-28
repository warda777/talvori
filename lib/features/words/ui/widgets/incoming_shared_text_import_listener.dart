import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/import/shared_text_import_result.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/providers/incoming_shared_text_import_controller_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/core/ui/talvori_snackbar.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';

class IncomingSharedTextImportListener extends ConsumerStatefulWidget {
  const IncomingSharedTextImportListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<IncomingSharedTextImportListener> createState() =>
      _IncomingSharedTextImportListenerState();
}

class _IncomingSharedTextImportListenerState
    extends ConsumerState<IncomingSharedTextImportListener> {
  static const _surface = Color(0xFF061018);
  static const _cyan = Color(0xFF5DDCFF);
  static const _green = Color(0xFF36F58A);
  static const _violet = Color(0xFFB36BFF);
  static const _red = Color(0xFFFF4E6A);
  static const _textPrimary = Color(0xFFF4F8FF);
  static const _textSecondary = Color(0xFFB8C7D9);
  static const _feedbackDuration = Duration(seconds: 3);

  StreamSubscription<SharedTextImportResult>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_start());
    });
  }

  Future<void> _start() async {
    try {
      final controller = await ref.read(
        incomingSharedTextImportControllerProvider.future,
      );
      final initialResults = await controller.importInitialSharedTexts();
      if (initialResults.isNotEmpty) {
        _showResults(initialResults);
      }
      _subscription = controller.watchIncomingSharedText().listen(
        _showResult,
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Shared text listener disabled: $error');
        },
      );
    } on Object catch (error, stackTrace) {
      debugPrint('Shared text startup skipped: $error');
      debugPrint('$stackTrace');
    }
  }

  void _showResults(List<SharedTextImportResult> results) {
    if (results.length == 1) {
      _showResult(results.single);
      return;
    }
    for (final result in results) {
      if (result.status == SharedTextImportStatus.imported ||
          result.status == SharedTextImportStatus.duplicate) {
        _refreshMyWordsProviders();
      }
    }
    final imported = results
        .where((result) => result.status == SharedTextImportStatus.imported)
        .length;
    final duplicates = results
        .where((result) => result.status == SharedTextImportStatus.duplicate)
        .length;
    if (imported == 0 && duplicates == 0) {
      _showResult(results.last);
      return;
    }
    _showCompactMessage(
      title: '$imported ${imported == 1 ? 'Wort' : 'Wörter'} gespeichert',
      subtitle: duplicates > 0
          ? '$duplicates bereits vorhanden · Übersetzung läuft im Hintergrund'
          : 'Gespeichert in Meine Wörter · Übersetzung läuft im Hintergrund',
      accentColor: _green,
    );
  }

  void _showResult(SharedTextImportResult result) {
    if (!mounted) return;
    if (result.status == SharedTextImportStatus.imported ||
        result.status == SharedTextImportStatus.duplicate) {
      _refreshMyWordsProviders();
    }
    TalvoriSnackBar.showCustom(
      context,
      content: _TalvoriImportSnackBarContent(
        result: result,
        title: _titleFor(result),
        subtitle: _messageFor(result),
        accentColor: _accentFor(result),
        onOpenMyWords:
            result.status == SharedTextImportStatus.imported ||
                result.status == SharedTextImportStatus.duplicate
            ? () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LocalWordListScreen(
                      categoryId: localMyWordsCategoryId,
                      title: localMyWordsCategoryLabel,
                    ),
                  ),
                );
              }
            : null,
      ),
      duration: _feedbackDuration,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 112),
    );
  }

  void _showCompactMessage({
    required String title,
    required String subtitle,
    required Color accentColor,
  }) {
    if (!mounted) return;
    TalvoriSnackBar.showCustom(
      context,
      content: _TalvoriImportSummarySnackBarContent(
        title: title,
        subtitle: subtitle,
        accentColor: accentColor,
      ),
      duration: _feedbackDuration,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 112),
    );
  }

  void _refreshMyWordsProviders() {
    ref
      ..invalidate(localWordsForCategoryProvider(localMyWordsCategoryId))
      ..invalidate(localWordCountProvider(localMyWordsCategoryId));
    for (final source in LocalLearningSource.values) {
      ref.invalidate(localWordsForSourceProvider(source));
    }
  }

  String _titleFor(SharedTextImportResult result) {
    return switch (result.status) {
      SharedTextImportStatus.imported => 'Wort importiert',
      SharedTextImportStatus.duplicate => 'Bereits vorhanden',
      SharedTextImportStatus.empty => 'Nichts importiert',
      SharedTextImportStatus.invalid => 'Import nicht möglich',
      SharedTextImportStatus.error => 'Import fehlgeschlagen',
    };
  }

  String _messageFor(SharedTextImportResult result) {
    return switch (result.status) {
      SharedTextImportStatus.imported => 'Gespeichert in Meine Wörter',
      SharedTextImportStatus.duplicate =>
        'Dieses Wort ist bereits in Meine Wörter.',
      SharedTextImportStatus.empty => result.message,
      SharedTextImportStatus.invalid => result.message,
      SharedTextImportStatus.error =>
        'Import konnte nicht abgeschlossen werden.',
    };
  }

  Color _accentFor(SharedTextImportResult result) {
    return switch (result.status) {
      SharedTextImportStatus.imported => _green,
      SharedTextImportStatus.duplicate => _violet,
      SharedTextImportStatus.empty ||
      SharedTextImportStatus.invalid ||
      SharedTextImportStatus.error => _red,
    };
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _TalvoriImportSnackBarContent extends StatelessWidget {
  const _TalvoriImportSnackBarContent({
    required this.result,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onOpenMyWords,
  });

  final SharedTextImportResult result;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback? onOpenMyWords;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _IncomingSharedTextImportListenerState._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.22),
            blurRadius: 24,
            spreadRadius: -4,
          ),
          const BoxShadow(
            color: Colors.black87,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.13),
                border: Border.all(color: accentColor.withValues(alpha: 0.75)),
              ),
              child: Icon(
                _iconFor(result.status),
                color: accentColor,
                size: 19,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                          _IncomingSharedTextImportListenerState._textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                          _IncomingSharedTextImportListenerState._textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onOpenMyWords != null) ...[
              const SizedBox(width: 8),
              TextButton(
                key: const Key('incoming-share-open-my-words-action'),
                onPressed: onOpenMyWords,
                style: TextButton.styleFrom(
                  foregroundColor: _IncomingSharedTextImportListenerState._cyan,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: _IncomingSharedTextImportListenerState._cyan
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ),
                child: const Text(
                  'Meine Wörter öffnen',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(SharedTextImportStatus status) {
    return switch (status) {
      SharedTextImportStatus.imported => Icons.check_rounded,
      SharedTextImportStatus.duplicate => Icons.info_outline_rounded,
      SharedTextImportStatus.empty ||
      SharedTextImportStatus.invalid ||
      SharedTextImportStatus.error => Icons.error_outline_rounded,
    };
  }
}

class _TalvoriImportSummarySnackBarContent extends StatelessWidget {
  const _TalvoriImportSummarySnackBarContent({
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _IncomingSharedTextImportListenerState._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.22),
            blurRadius: 24,
            spreadRadius: -4,
          ),
          const BoxShadow(
            color: Colors.black87,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.13),
                border: Border.all(color: accentColor.withValues(alpha: 0.75)),
              ),
              child: Icon(Icons.library_add_check_rounded, color: accentColor),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                          _IncomingSharedTextImportListenerState._textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                          _IncomingSharedTextImportListenerState._textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
}
