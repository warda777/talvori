import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/import/shared_text_import_result.dart';
import 'package:talvori/core/local_database/providers/incoming_shared_text_import_controller_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
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
  StreamSubscription<SharedTextImportResult>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_start());
    });
  }

  Future<void> _start() async {
    final controller = await ref.read(
      incomingSharedTextImportControllerProvider.future,
    );
    final initialResult = await controller.importInitialSharedText();
    if (initialResult != null) {
      _showResult(initialResult);
    }
    _subscription = controller.watchIncomingSharedText().listen(_showResult);
  }

  void _showResult(SharedTextImportResult result) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(_messageFor(result)),
          action:
              result.status == SharedTextImportStatus.imported ||
                  result.status == SharedTextImportStatus.duplicate
              ? SnackBarAction(
                  label: 'Meine Wörter',
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
                )
              : null,
        ),
      );
  }

  String _messageFor(SharedTextImportResult result) {
    return switch (result.status) {
      SharedTextImportStatus.imported => 'Wort in Meine Wörter importiert.',
      SharedTextImportStatus.duplicate =>
        'Dieses Wort ist bereits in Meine Wörter.',
      SharedTextImportStatus.empty => 'Der geteilte Text war leer.',
      SharedTextImportStatus.invalid => result.message,
      SharedTextImportStatus.error =>
        'Import konnte nicht abgeschlossen werden.',
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
