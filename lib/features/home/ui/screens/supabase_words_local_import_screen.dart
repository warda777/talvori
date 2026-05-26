import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/providers/supabase_words_local_import_controller_provider.dart';
import 'package:talvori/core/local_database/services/supabase_words_local_import_service.dart';

class SupabaseWordsLocalImportScreen extends ConsumerWidget {
  const SupabaseWordsLocalImportScreen({super.key});

  static const _background = Color(0xFF05070D);
  static const _panel = Color(0xFF0B121C);
  static const _tile = Color(0xFF111B28);
  static const _cyan = Color(0xFF78E6FF);
  static const _mint = Color(0xFF7DFFE3);
  static const _danger = Color(0xFFFF8F8F);
  static const _muted = Color(0xFF93A2B8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supabaseWordsLocalAdminImportControllerProvider);
    final controller = ref.read(
      supabaseWordsLocalAdminImportControllerProvider.notifier,
    );

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
              child: Row(
                children: [
                  _CircleButton(
                    tooltip: 'Zurück',
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Supabase-Wörter lokal importieren',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.08,
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  const _InfoCard(),
                  const SizedBox(height: 16),
                  _ActionCard(
                    state: state,
                    onPreview: () => controller.runPreview(),
                    onApply: () => _confirmApply(context, controller),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 14),
                    _MessageCard(
                      icon: Icons.error_outline_rounded,
                      color: _danger,
                      title: 'Import nicht möglich',
                      body: state.errorMessage!,
                    ),
                  ],
                  if (state.report != null) ...[
                    const SizedBox(height: 16),
                    _ReportCard(report: state.report!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _confirmApply(
    BuildContext context,
    SupabaseWordsLocalAdminImportController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _panel,
          title: const Text(
            'Lokalen Import wirklich starten?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Dieser Vorgang kann etwas dauern. Supabase wird nur gelesen; '
            'geschrieben wird ausschließlich in die lokale App-Datenbank.',
            style: TextStyle(color: _muted, height: 1.35),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Import starten'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await controller.runApply();
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SupabaseWordsLocalImportScreen._panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: SupabaseWordsLocalImportScreen._cyan.withValues(alpha: 0.16),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings_rounded,
                color: SupabaseWordsLocalImportScreen._mint,
              ),
              SizedBox(width: 10),
              Text(
                'Debug-Import',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Liest Wörter aus Supabase und speichert sie lokal auf diesem '
            'Gerät. SRS-Fortschritt bleibt unverändert.',
            style: TextStyle(
              color: SupabaseWordsLocalImportScreen._muted,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.state,
    required this.onPreview,
    required this.onApply,
  });

  final SupabaseWordsLocalAdminImportState state;
  final VoidCallback onPreview;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SupabaseWordsLocalImportScreen._tile,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.isLoading) ...[
            const LinearProgressIndicator(minHeight: 5),
            const SizedBox(height: 14),
            const Text(
              'Import läuft. Dieser Vorgang kann etwas dauern.',
              style: TextStyle(
                color: SupabaseWordsLocalImportScreen._muted,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
          ],
          _PrimaryButton(
            label: 'Preview ausführen',
            icon: Icons.visibility_rounded,
            onTap: state.isLoading ? null : onPreview,
          ),
          const SizedBox(height: 10),
          _PrimaryButton(
            label: 'Import starten',
            icon: Icons.download_done_rounded,
            onTap: state.canApply ? onApply : null,
            emphasized: true,
          ),
          if (!state.hasSuccessfulPreview) ...[
            const SizedBox(height: 10),
            const Text(
              'Import starten wird erst nach einer erfolgreichen Preview aktiv.',
              style: TextStyle(
                color: SupabaseWordsLocalImportScreen._muted,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final SupabaseWordsLocalImportReport report;

  @override
  Widget build(BuildContext context) {
    final title = report.isDryRun
        ? 'Preview abgeschlossen'
        : 'Import abgeschlossen';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SupabaseWordsLocalImportScreen._panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: report.isDryRun
              ? SupabaseWordsLocalImportScreen._cyan.withValues(alpha: 0.18)
              : SupabaseWordsLocalImportScreen._mint.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _MetricRow('Remote-Wörter gelesen', report.remoteWordsRead),
          _MetricRow('Lokal neu angelegt', report.localWordsCreated),
          _MetricRow('Lokal wiederverwendet', report.localWordsReused),
          _MetricRow('Memberships angelegt', report.membershipsCreated),
          _MetricRow('Level gesetzt', report.levelsSet),
          _MetricRow(
            'Übersetzungskonflikte',
            report.translationConflicts.length,
          ),
          _MetricTextRow(
            'word_progress vor/nach',
            '${report.wordProgressRowsBefore} / ${report.wordProgressRowsAfter}',
          ),
          const SizedBox(height: 12),
          _MessageCard(
            icon: Icons.shield_rounded,
            color: report.wordProgressRowsBefore == report.wordProgressRowsAfter
                ? SupabaseWordsLocalImportScreen._mint
                : SupabaseWordsLocalImportScreen._danger,
            title: report.wordProgressRowsBefore == report.wordProgressRowsAfter
                ? 'SRS unverändert'
                : 'SRS-Prüfung auffällig',
            body:
                'Der Import verändert keine word_progress-Daten und schreibt '
                'keine SRS-Felder.',
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => _MetricTextRow(label, '$value');
}

class _MetricTextRow extends StatelessWidget {
  const _MetricTextRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: SupabaseWordsLocalImportScreen._muted,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.compact = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: SupabaseWordsLocalImportScreen._muted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = emphasized
        ? SupabaseWordsLocalImportScreen._mint
        : SupabaseWordsLocalImportScreen._cyan;
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: enabled
            ? color
            : SupabaseWordsLocalImportScreen._muted.withValues(alpha: 0.22),
        foregroundColor: SupabaseWordsLocalImportScreen._background,
        disabledBackgroundColor: SupabaseWordsLocalImportScreen._muted
            .withValues(alpha: 0.16),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.42),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
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
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: SupabaseWordsLocalImportScreen._tile,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: SupabaseWordsLocalImportScreen._cyan.withValues(
                  alpha: 0.12,
                ),
                blurRadius: 18,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
