import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';

class ImpulseChatDetailScreen extends ConsumerStatefulWidget {
  const ImpulseChatDetailScreen({
    super.key,
    required this.chatId,
    this.initialMessageId,
  });

  final String chatId;
  final String? initialMessageId;

  @override
  ConsumerState<ImpulseChatDetailScreen> createState() =>
      _ImpulseChatDetailScreenState();
}

class _ImpulseChatDetailScreenState
    extends ConsumerState<ImpulseChatDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = ref.read(impulseInboxControllerProvider.notifier);
      await controller.loadMessages(widget.chatId);
      await controller.markChatRead(widget.chatId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(impulseInboxControllerProvider);
    final chat = state.chats.cast<ImpulseChat?>().firstWhere(
      (chat) => chat?.id == widget.chatId,
      orElse: () => null,
    );
    final messages = state.messagesByChat[widget.chatId] ?? const [];

    return Scaffold(
      backgroundColor: const Color(0xFF050A12),
      appBar: AppBar(
        title: Text(chat?.title ?? 'Impuls'),
        backgroundColor: const Color(0xFF050A12),
        foregroundColor: Colors.white,
      ),
      body: messages.isEmpty
          ? const Center(
              child: Text(
                'Noch keine Nachrichten',
                style: TextStyle(
                  color: Color(0xFFB8C4D9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _MessageBubble(message: messages[index]);
              },
            ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ImpulseMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1018),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: const Color(0x4459D7FF)),
          boxShadow: const [
            BoxShadow(color: Color(0x2259D7FF), blurRadius: 16),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (message.usedWords.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final word in message.usedWords)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF07111A),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0x3359D7FF)),
                      ),
                      child: Text(
                        word,
                        style: const TextStyle(
                          color: Color(0xFF7FFFE7),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _dateLabel(message.createdAt),
              style: const TextStyle(
                color: Color(0xFF7D8BA3),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.day}.${value.month}. · $hour:$minute';
  }
}
