import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/primary_language_provider.dart';

class CategorySettingsDialog extends ConsumerWidget {
  const CategorySettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryLanguage = ref.watch(primaryLanguageProvider);
    final languageNotifier = ref.read(primaryLanguageProvider.notifier);

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titel
            const Text(
              'Einstellungen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // Hauptsprache
            const Text(
              'Hauptsprache',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Wähle die Sprache, die standardmäßig auf der Vorderseite der Karten angezeigt werden soll.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 16),
            
            // Sprachauswahl-Buttons
            Row(
              children: [
                Expanded(
                  child: _LanguageOption(
                    label: 'Englisch',
                    icon: Icons.language,
                    isSelected: primaryLanguage == PrimaryLanguage.english,
                    onTap: () {
                      languageNotifier.setLanguage(PrimaryLanguage.english);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LanguageOption(
                    label: 'Deutsch',
                    icon: Icons.translate,
                    isSelected: primaryLanguage == PrimaryLanguage.german,
                    onTap: () {
                      languageNotifier.setLanguage(PrimaryLanguage.german);
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Schließen-Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB16CFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Schließen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFB16CFF).withOpacity(0.2)
              : const Color(0xFF2A2A2A),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFB16CFF)
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? const Color(0xFFB16CFF)
                  : Colors.white54,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? const Color(0xFFB16CFF)
                    : Colors.white70,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              const Icon(
                Icons.check_circle,
                color: Color(0xFFB16CFF),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

