import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impulse_chat_detail_screen.dart';

class ImpulsPostfachScreen extends ConsumerWidget {
  const ImpulsPostfachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(impulseInboxControllerProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF050A12),
      appBar: AppBar(
        title: const Text('Impuls-Postfach'),
        backgroundColor: const Color(0xFF050A12),
        foregroundColor: Colors.white,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.chats.isEmpty
          ? const _EmptyInbox()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.chats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _ChatTile(chat: state.chats[index]);
              },
            ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mark_unread_chat_alt_rounded,
              color: Color(0xFF59D7FF),
              size: 42,
            ),
            SizedBox(height: 14),
            Text(
              'Noch keine Impulse',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Deine Tagesimpulse erscheinen hier, sobald Talvori sie gesendet hat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFB8C4D9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.chat});

  final ImpulseChat chat;

  @override
  Widget build(BuildContext context) {
    final lastMessage = chat.lastMessageText?.trim();
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImpulseChatDetailScreen(chatId: chat.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1018),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x3359D7FF)),
          boxShadow: const [
            BoxShadow(color: Color(0x2259D7FF), blurRadius: 18),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF07111A),
                border: Border.all(color: const Color(0xFF7FFFE7)),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF7FFFE7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (chat.lastMessageAt != null)
                        Text(
                          _timeLabel(chat.lastMessageAt!),
                          style: const TextStyle(
                            color: Color(0xFF7D8BA3),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lastMessage == null || lastMessage.isEmpty
                        ? 'Noch keine Nachrichten'
                        : lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFB8C4D9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (chat.unreadCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF59D7FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: const TextStyle(
                    color: Color(0xFF051018),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _timeLabel(DateTime value) {
    final now = DateTime.now();
    final sameDay =
        value.year == now.year &&
        value.month == now.month &&
        value.day == now.day;
    if (!sameDay) return '${value.day}.${value.month}.';
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
