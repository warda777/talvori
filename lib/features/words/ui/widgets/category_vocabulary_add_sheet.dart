import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/ui/talvori_snackbar.dart';
import 'package:talvori/features/words/application/category_vocabulary/category_vocabulary_controller.dart';

Future<void> showCategoryVocabularyAddSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String categoryId,
  required String categoryLabel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategoryVocabularyAddSheet(
      categoryId: categoryId,
      categoryLabel: categoryLabel,
    ),
  );
}

class _CategoryVocabularyAddSheet extends ConsumerStatefulWidget {
  const _CategoryVocabularyAddSheet({
    required this.categoryId,
    required this.categoryLabel,
  });

  final String categoryId;
  final String categoryLabel;

  @override
  ConsumerState<_CategoryVocabularyAddSheet> createState() =>
      _CategoryVocabularyAddSheetState();
}

class _CategoryVocabularyAddSheetState
    extends ConsumerState<_CategoryVocabularyAddSheet> {
  final _termController = TextEditingController();
  final _translationController = TextEditingController();
  final _exampleController = TextEditingController();
  var _mode = _CategoryVocabularyAddMode.menu;

  @override
  void dispose() {
    _termController.dispose();
    _translationController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryVocabularyControllerProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF070A10),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF59D7FF), width: 1),
            boxShadow: const [
              BoxShadow(color: Color(0x3340D9FF), blurRadius: 26),
              BoxShadow(color: Color(0xAA000000), blurRadius: 24),
            ],
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            child: switch (_mode) {
              _CategoryVocabularyAddMode.menu => _buildMenu(context),
              _CategoryVocabularyAddMode.manual => _buildManualForm(
                context,
                state,
              ),
              _CategoryVocabularyAddMode.suggestions => _buildSuggestions(
                context,
                state,
              ),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SheetHeader(
          title: 'Wörter verwalten',
          subtitle: widget.categoryLabel,
          onClose: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 16),
        _SheetActionTile(
          icon: Icons.edit_rounded,
          title: 'Wort hinzufügen',
          subtitle: 'Ein eigenes Wort direkt in diese Kategorie legen.',
          onTap: () =>
              setState(() => _mode = _CategoryVocabularyAddMode.manual),
        ),
        const SizedBox(height: 12),
        _SheetActionTile(
          icon: Icons.auto_awesome_rounded,
          title: 'KI-Vorschläge',
          subtitle: 'Aktiv neue passende Wörter vorschlagen lassen.',
          onTap: () {
            setState(() => _mode = _CategoryVocabularyAddMode.suggestions);
            ref
                .read(categoryVocabularyControllerProvider.notifier)
                .loadSuggestions(
                  categoryId: widget.categoryId,
                  categoryName: widget.categoryLabel,
                );
          },
        ),
      ],
    );
  }

  Widget _buildManualForm(BuildContext context, CategoryVocabularyState state) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(
            title: 'Wort hinzufügen',
            subtitle: widget.categoryLabel,
            onBack: () =>
                setState(() => _mode = _CategoryVocabularyAddMode.menu),
            onClose: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 16),
          _SheetTextField(controller: _termController, label: 'Wort'),
          const SizedBox(height: 10),
          _SheetTextField(
            controller: _translationController,
            label: 'Übersetzung',
          ),
          const SizedBox(height: 10),
          _SheetTextField(
            controller: _exampleController,
            label: 'Beispiel / Satz optional',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _SheetPrimaryButton(
            label: state.isSaving ? 'Speichert...' : 'Speichern',
            icon: Icons.check_rounded,
            onPressed: state.isSaving ? null : () => _saveManualWord(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(
    BuildContext context,
    CategoryVocabularyState state,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(
            title: 'KI-Vorschläge',
            subtitle: widget.categoryLabel,
            onBack: () =>
                setState(() => _mode = _CategoryVocabularyAddMode.menu),
            onClose: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 12),
          if (state.isLoadingSuggestions)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF59D7FF)),
              ),
            )
          else if (state.errorMessage != null)
            _SheetInfoBox(
              icon: Icons.error_outline_rounded,
              text: state.errorMessage!,
              color: const Color(0xFFFF6F91),
            )
          else if (state.suggestions.isEmpty)
            const _SheetInfoBox(
              icon: Icons.info_outline_rounded,
              text: 'Keine neuen Vorschläge gefunden.',
              color: Color(0xFF8DBBFF),
            )
          else ...[
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = state.suggestions[index];
                  return CheckboxListTile(
                    value: suggestion.selected,
                    onChanged: (value) => ref
                        .read(categoryVocabularyControllerProvider.notifier)
                        .toggleSuggestion(suggestion.term, value ?? false),
                    activeColor: const Color(0xFF59D7FF),
                    checkColor: const Color(0xFF061018),
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      suggestion.term,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      suggestion.translation,
                      style: const TextStyle(
                        color: Color(0xFFB8C4D9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _SheetPrimaryButton(
              label: state.isSaving ? 'Übernimmt...' : 'Ausgewählte übernehmen',
              icon: Icons.playlist_add_check_rounded,
              onPressed: state.isSaving ? null : () => _addSuggestions(context),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveManualWord(BuildContext context) async {
    final result = await ref
        .read(categoryVocabularyControllerProvider.notifier)
        .addManualWord(
          categoryId: widget.categoryId,
          term: _termController.text,
          translation: _translationController.text,
          exampleSentence: _exampleController.text,
        );
    if (!context.mounted) return;
    final message = switch (result) {
      CategoryVocabularyAddResult.created => 'Wort hinzugefügt.',
      CategoryVocabularyAddResult.linkedExisting =>
        'Bestehendes Wort mit dieser Kategorie verknüpft.',
      CategoryVocabularyAddResult.duplicateInCategory =>
        'Dieses Wort ist bereits in dieser Kategorie.',
      CategoryVocabularyAddResult.invalid =>
        'Bitte Wort und Übersetzung ausfüllen.',
      CategoryVocabularyAddResult.failed =>
        'Wort konnte nicht gespeichert werden.',
    };
    TalvoriSnackBar.show(
      context,
      message: message,
      type:
          result == CategoryVocabularyAddResult.created ||
              result == CategoryVocabularyAddResult.linkedExisting
          ? TalvoriSnackBarType.success
          : TalvoriSnackBarType.warning,
    );
    if (result == CategoryVocabularyAddResult.created ||
        result == CategoryVocabularyAddResult.linkedExisting) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _addSuggestions(BuildContext context) async {
    final added = await ref
        .read(categoryVocabularyControllerProvider.notifier)
        .addSelectedSuggestions(categoryId: widget.categoryId);
    if (!context.mounted) return;
    TalvoriSnackBar.show(
      context,
      message: added == 1
          ? '1 Vorschlag übernommen.'
          : '$added Vorschläge übernommen.',
      type: added > 0 ? TalvoriSnackBarType.success : TalvoriSnackBarType.info,
    );
    if (added > 0) Navigator.of(context).pop();
  }
}

enum _CategoryVocabularyAddMode { menu, manual, suggestions }

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.subtitle,
    this.onBack,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          )
        else
          const SizedBox(width: 48),
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF8DBBFF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded, color: Colors.white),
        ),
      ],
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  const _SheetActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0D12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2F557D)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF59D7FF)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9EA9BC),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      cursorColor: const Color(0xFF59D7FF),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF8DBBFF),
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: const Color(0xFF0C0D12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2F557D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF59D7FF)),
        ),
      ),
    );
  }
}

class _SheetPrimaryButton extends StatelessWidget {
  const _SheetPrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF59D7FF),
          foregroundColor: const Color(0xFF061018),
          disabledBackgroundColor: const Color(0xFF1A2430),
          disabledForegroundColor: const Color(0xFF7F8494),
          padding: const EdgeInsets.symmetric(vertical: 13),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _SheetInfoBox extends StatelessWidget {
  const _SheetInfoBox({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
