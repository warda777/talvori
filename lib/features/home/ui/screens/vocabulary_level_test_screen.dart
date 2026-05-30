import 'package:flutter/material.dart';

class VocabularyLevelTestScreen extends StatelessWidget {
  const VocabularyLevelTestScreen({super.key});

  static const _background = Color(0xFF05070D);
  static const _panel = Color(0xFF08131B);
  static const _panelSoft = Color(0xFF0C1823);
  static const _cyan = Color(0xFF78E6FF);
  static const _mint = Color(0xFF7DFFE3);
  static const _muted = Color(0xFF93A2B8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _RoundButton(
                    tooltip: 'Zurück',
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const SizedBox(height: 54),
              ],
            ),
            const SizedBox(height: 42),
            Center(
              child: Container(
                width: 138,
                height: 138,
                decoration: BoxDecoration(
                  color: _mint.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _mint.withValues(alpha: 0.28)),
                  boxShadow: [
                    BoxShadow(
                      color: _cyan.withValues(alpha: 0.16),
                      blurRadius: 36,
                      spreadRadius: -12,
                    ),
                  ],
                ),
                child: const Icon(Icons.school_rounded, color: _mint, size: 72),
              ),
            ),
            const SizedBox(height: 34),
            const Text(
              'Wortschatz-Einstufungstest',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                color: Colors.white,
                fontSize: 31,
                fontWeight: FontWeight.w900,
                height: 1.08,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: _cyan.withValues(alpha: 0.24)),
                boxShadow: [
                  BoxShadow(
                    color: _cyan.withValues(alpha: 0.12),
                    blurRadius: 26,
                    spreadRadius: -12,
                  ),
                ],
              ),
              child: const Column(
                children: [
                  _InfoRow(
                    icon: Icons.info_outline_rounded,
                    text: 'Miss dein aktuelles Level',
                  ),
                  SizedBox(height: 18),
                  _InfoRow(
                    icon: Icons.bar_chart_rounded,
                    text: 'Sieh, wie nah du am nächsten Level bist',
                  ),
                  SizedBox(height: 18),
                  _InfoRow(
                    icon: Icons.style_rounded,
                    text: '30 Fragen (5–6 Min.)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _PrimaryButton(
              label: 'Start',
              onTap: () => _showPreparedSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  static void _showPreparedSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _cyan.withValues(alpha: 0.28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.38),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Einstufungstest in Vorbereitung',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Wir schalten ihn frei, sobald die Auswertung stabil genug ist. Bis dahin wird kein Level geschätzt und dein Lernfortschritt bleibt unverändert.',
                    style: TextStyle(color: _muted, fontSize: 15, height: 1.35),
                  ),
                  const SizedBox(height: 22),
                  _PrimaryButton(
                    label: 'Verstanden',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: VocabularyLevelTestScreen._panelSoft.withValues(alpha: 0.94),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: VocabularyLevelTestScreen._cyan.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: VocabularyLevelTestScreen._cyan, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: VocabularyLevelTestScreen._cyan,
          foregroundColor: VocabularyLevelTestScreen._background,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
