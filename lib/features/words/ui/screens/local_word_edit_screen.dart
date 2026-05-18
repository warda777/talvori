import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/providers/local_word_detail_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_edit_controller_provider.dart';

class LocalWordEditScreen extends ConsumerStatefulWidget {
  const LocalWordEditScreen({
    super.key,
    required this.wordId,
    required this.categoryId,
    required this.title,
  });

  final String wordId;
  final String categoryId;
  final String title;

  @override
  ConsumerState<LocalWordEditScreen> createState() =>
      _LocalWordEditScreenState();
}

class _LocalWordEditScreenState extends ConsumerState<LocalWordEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _termController = TextEditingController();
  final _translationController = TextEditingController();
  bool _didFillInitialValues = false;

  @override
  void dispose() {
    _termController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = LocalWordDetailRequest(
      wordId: widget.wordId,
      categoryId: widget.categoryId,
    );
    final detailAsync = ref.watch(localWordDetailProvider(request));
    final editState = ref.watch(localWordEditControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050507),
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text(
            'Lokales Wort konnte nicht geladen werden',
            style: TextStyle(color: Colors.white),
          ),
        ),
        data: (detail) {
          if (detail == null) {
            return const Center(
              child: Text(
                'Lokales Wort nicht gefunden',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (!_didFillInitialValues) {
            _termController.text = detail.word.term;
            _translationController.text = detail.word.translation;
            _didFillInitialValues = true;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _EditPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Wort bearbeiten',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _termController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Wort'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Wort darf nicht leer sein';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _translationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Übersetzung'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Übersetzung darf nicht leer sein';
                          }
                          return null;
                        },
                      ),
                      if (editState.error != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          editState.error!,
                          style: const TextStyle(color: Color(0xFFFFB3C2)),
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: editState.isSaving
                            ? null
                            : () => _save(context),
                        child: editState.isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Speichern'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: editState.isSaving
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: const Text('Abbrechen'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFB9CFFF)),
      filled: true,
      fillColor: const Color(0xFF0B0B0D),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF3E5F99)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF8DBBFF), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFFFB3C2)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFFFB3C2), width: 1.4),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedWord = await ref
        .read(localWordEditControllerProvider.notifier)
        .updateWord(
          wordId: widget.wordId,
          categoryId: widget.categoryId,
          term: _termController.text.trim(),
          translation: _translationController.text.trim(),
          updatedAt: DateTime.now(),
        );

    if (!context.mounted || updatedWord == null) {
      return;
    }

    Navigator.of(context).pop(true);
  }
}

class _EditPanel extends StatelessWidget {
  const _EditPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF18181C), Color(0xFF0B0B0D)],
        ),
        border: Border.all(color: const Color(0xFF8DBBFF), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x228DBBFF), blurRadius: 16, spreadRadius: 1),
        ],
      ),
      child: child,
    );
  }
}
