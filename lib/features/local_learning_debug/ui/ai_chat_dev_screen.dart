import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/ai/supabase_ai_chat_client.dart';
import 'package:talvori/core/local_database/translation/supabase_function_caller.dart';

class AiChatDevScreen extends StatefulWidget {
  const AiChatDevScreen({super.key, AiChatClient? client}) : _client = client;

  final AiChatClient? _client;

  @override
  State<AiChatDevScreen> createState() => _AiChatDevScreenState();
}

class _AiChatDevScreenState extends State<AiChatDevScreen> {
  final _messageController = TextEditingController();
  final _languageController = TextEditingController(text: 'DE');

  bool _isLoading = false;
  String? _answer;
  String? _error;

  @override
  void dispose() {
    _messageController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() {
        _answer = null;
        _error = 'Bitte gib eine Nachricht ein.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _answer = null;
      _error = null;
    });

    try {
      final client = _resolveClient();
      final result = await client.sendMessage(
        AiChatRequest(
          message: message,
          language: _languageController.text.trim(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _answer = result.reply;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _answer = null;
        _error = _mapError(error);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  AiChatClient _resolveClient() {
    final injected = widget._client;
    if (injected != null) {
      return injected;
    }

    return SupabaseAiChatClient(
      functionCaller: supabaseFunctionCallerFromClient(
        Supabase.instance.client,
      ),
    );
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
      return 'KI-Anfrage fehlgeschlagen.';
    }
    return 'KI-Test konnte nicht ausgeführt werden.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat Test')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Interner Entwicklungstest',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Sendet manuell eine Anfrage an die Supabase Edge Function ai-chat. Keine automatische KI-Anfrage.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _messageController,
              minLines: 4,
              maxLines: 6,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Nachricht',
                hintText: 'Erkläre mir das Wort house auf Deutsch.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _languageController,
              decoration: const InputDecoration(
                labelText: 'Sprache',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('KI testen'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              _DevResultPanel(title: 'Fehler', message: _error!, isError: true),
            if (_answer != null)
              _DevResultPanel(title: 'Antwort', message: _answer!),
          ],
        ),
      ),
    );
  }
}

class _DevResultPanel extends StatelessWidget {
  const _DevResultPanel({
    required this.title,
    required this.message,
    this.isError = false,
  });

  final String title;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.redAccent : Colors.cyanAccent;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withValues(alpha: 0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color)),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }
}
