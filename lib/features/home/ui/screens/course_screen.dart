import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/ai/supabase_ai_chat_client.dart';
import 'package:talvori/core/local_database/translation/supabase_function_caller.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_selection_provider.dart';
import 'package:talvori/features/tagesimpuls/models/tagesimpuls_selection_item.dart';

class CourseScreen extends ConsumerStatefulWidget {
  const CourseScreen({super.key, AiChatClient? aiChatClient})
    : _aiChatClient = aiChatClient;

  final AiChatClient? _aiChatClient;

  @override
  ConsumerState<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends ConsumerState<CourseScreen> {
  bool _isGenerating = false;
  String? _message;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(tagesimpulsSelectionControllerProvider);
    final controller = ref.read(
      tagesimpulsSelectionControllerProvider.notifier,
    );
    final count = selection.count;
    final max = selection.maxCount;
    final full = selection.isFull;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tagesimpuls  •  $count/$max'),
        actions: [
          IconButton(
            tooltip: count == 0 ? 'Keine Wörter ausgewählt' : 'Auswahl leeren',
            onPressed: count == 0
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Tagesimpuls leeren?'),
                        content: Text(
                          full
                              ? 'Alle $count Wörter aus der Auswahl entfernen?'
                              : 'Du hast $count von $max Wörtern ausgewählt. Auswahl leeren?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Abbrechen'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Leeren'),
                          ),
                        ],
                      ),
                    );
                    if (!context.mounted) return;

                    if (ok == true) {
                      await controller.clear();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tagesimpuls-Auswahl geleert'),
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.outbound_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _TagesimpulsPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    full
                        ? 'Bereit: Du hast $max Wörter für den Tagesimpuls gewählt.'
                        : 'Wähle noch ${max - count} Wort${max - count == 1 ? '' : 'er'} aus.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selection.items.isEmpty)
                    const Text(
                      'Noch keine Wörter ausgewählt. Nutze den Pfeil auf der Home-Karte oder die Quick-Action im Lernmodus.',
                      style: TextStyle(
                        color: Color(0xFFB8C4D9),
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final item in selection.items)
                          Chip(
                            label: Text(item.text),
                            onDeleted: () => controller.remove(item),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _TagesimpulsPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Impuls planen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bereite aus 3 bis 5 Wörtern eine manuelle Vorschau vor. Später kann daraus eine Messenger-ähnliche Tagesnachricht entstehen.',
                    style: TextStyle(
                      color: Color(0xFFB8C4D9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Standard bleibt später 1 Impuls pro Tag. Mehrere Impulse brauchen eine bewusste Einstellung.',
                    style: TextStyle(
                      color: Color(0xFF7D8BA3),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isGenerating
                          ? null
                          : () => _generateMessage(selection.items),
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded),
                      label: Text(
                        _isGenerating
                            ? 'Impuls wird vorbereitet...'
                            : 'Impuls vorbereiten',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0D2530),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(
                            color: Color(0xFF59D7FF),
                            width: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    _TagesimpulsResultCard(
                      title: 'Hinweis',
                      message: _error!,
                      isError: true,
                    ),
                  if (_message != null)
                    _TagesimpulsResultCard(
                      title: 'Impuls-Vorschau',
                      message: _message!,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateMessage(List<TagesimpulsSelectionItem> items) async {
    if (items.length < 3) {
      setState(() {
        _message = null;
        _error = 'Wähle mindestens 3 Wörter aus.';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _message = null;
      _error = null;
    });

    try {
      final client = _resolveClient();
      final result = await client.sendMessage(
        AiChatRequest(
          message: _buildPrompt(items),
          language: 'EN',
          context: {
            'feature': 'tagesimpuls_preview',
            'words': [
              for (final item in items)
                {
                  'word': item.text,
                  if ((item.translation ?? '').trim().isNotEmpty)
                    'translation': item.translation!.trim(),
                },
            ],
          },
        ),
      );
      if (!mounted) return;
      setState(() => _message = result.reply.trim());
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _mapError(error));
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  AiChatClient _resolveClient() {
    final injected = widget._aiChatClient;
    if (injected != null) return injected;

    return SupabaseAiChatClient(
      functionCaller: supabaseFunctionCallerFromClient(
        Supabase.instance.client,
      ),
    );
  }

  String _buildPrompt(List<TagesimpulsSelectionItem> items) {
    final words = items
        .map((item) {
          final translation = (item.translation ?? '').trim();
          if (translation.isEmpty) return item.text;
          return '${item.text} ($translation)';
        })
        .join(', ');

    return 'Erstelle eine einzelne kurze natürliche Nachricht auf Englisch mit diesen Wörtern: $words. '
        'Die Nachricht soll sich wie eine echte Alltagsnachricht anfühlen und für einen Sprachlernenden verständlich sein. '
        'Gib nur die Nachricht zurück. Keine Push-Benachrichtigung planen.';
  }

  String _mapError(Object error) {
    final raw = error.toString();
    if (raw.contains('ai_not_configured')) {
      return 'KI ist noch nicht konfiguriert.';
    }
    if (raw.contains('quota_exceeded') || raw.contains('ai_rate_limited')) {
      return 'Limit erreicht oder Anbieter begrenzt Anfrage.';
    }
    if (raw.contains('ai_request_failed') || raw.contains('ai_auth_failed')) {
      return 'Tagesimpuls konnte nicht erzeugt werden.';
    }
    return 'Tagesimpuls konnte nicht geladen werden.';
  }
}

class _TagesimpulsPanel extends StatelessWidget {
  const _TagesimpulsPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1018),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF59D7FF), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x2259D7FF), blurRadius: 20),
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TagesimpulsResultCard extends StatelessWidget {
  const _TagesimpulsResultCard({
    required this.title,
    required this.message,
    this.isError = false,
  });

  final String title;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFFFC857) : const Color(0xFF7FFFE7);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.58)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.14), blurRadius: 18),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
