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
        titleSpacing: 20,
        title: const Text(
          'Impuls-Postfach',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: const Color(0xFF050A12),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.chats.isEmpty
          ? const _EmptyInbox()
          : _ChatList(chats: state.chats),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF07111A),
                  border: Border.all(color: const Color(0xFF59D7FF)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x3359D7FF), blurRadius: 28),
                  ],
                ),
                child: const Icon(
                  Icons.mark_unread_chat_alt_rounded,
                  color: Color(0xFF7FFFE7),
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Noch keine Impulse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Deine Tagesimpulse erscheinen hier, sobald Talvori sie gesendet hat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB8C4D9),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  const _ChatList({required this.chats});

  final List<ImpulseChat> chats;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('impulse_inbox_chat_list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: chats.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) return _InboxHeader(chatCount: chats.length);
        return _ChatTile(chat: chats[index - 1]);
      },
    );
  }
}

class _InboxHeader extends StatelessWidget {
  const _InboxHeader({required this.chatCount});

  final int chatCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 4),
      child: Row(
        children: [
          const Icon(Icons.forum_rounded, color: Color(0xFF59D7FF), size: 18),
          const SizedBox(width: 8),
          Text(
            chatCount == 1 ? '1 Verlauf' : '$chatCount Verläufe',
            style: const TextStyle(
              color: Color(0xFFB8C4D9),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('impulse_chat_tile_${chat.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ImpulseChatDetailScreen(chatId: chat.id),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF08111B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: chat.unreadCount > 0
                  ? const Color(0x9959D7FF)
                  : const Color(0x2259D7FF),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A59D7FF),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _ChatAvatar(chat: chat),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        if (chat.lastMessageAt != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            _timeLabel(chat.lastMessageAt!),
                            style: TextStyle(
                              color: chat.unreadCount > 0
                                  ? const Color(0xFF7FFFE7)
                                  : const Color(0xFF7D8BA3),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage == null || lastMessage.isEmpty
                                ? 'Noch keine Nachrichten'
                                : lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: chat.unreadCount > 0
                                  ? Colors.white
                                  : const Color(0xFFB8C4D9),
                              fontWeight: chat.unreadCount > 0
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (chat.unreadCount > 0) ...[
                          const SizedBox(width: 10),
                          _UnreadBadge(count: chat.unreadCount),
                        ],
                      ],
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

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.chat});

  final ImpulseChat chat;

  @override
  Widget build(BuildContext context) {
    final icon = switch (chat.sourceType) {
      ImpulseChatSourceType.dailyImpulse => Icons.auto_awesome_rounded,
      ImpulseChatSourceType.favorites => Icons.favorite_rounded,
      ImpulseChatSourceType.myWords => Icons.library_books_rounded,
      ImpulseChatSourceType.knownWords => Icons.verified_rounded,
      ImpulseChatSourceType.category => Icons.bubble_chart_rounded,
    };
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF07111A),
        border: Border.all(color: const Color(0xFF7FFFE7)),
        boxShadow: const [BoxShadow(color: Color(0x337FFFE7), blurRadius: 18)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x2259D7FF),
              ),
            ),
          ),
          Icon(icon, color: const Color(0xFF7FFFE7), size: 24),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('impulse_inbox_unread_badge'),
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF59D7FF),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Color(0x4459D7FF), blurRadius: 12)],
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF051018),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
