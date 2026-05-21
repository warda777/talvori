import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_voice_input_service.dart';
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
    extends ConsumerState<ImpulseChatDetailScreen>
    with WidgetsBindingObserver {
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final Map<String, GlobalKey> _messageKeys = {};
  Timer? _highlightTimer;
  ImpulseMessage? _replyToMessage;
  String? _highlightedMessageId;
  bool _initialTargetHandled = false;
  bool _highlightClearScheduled = false;

  @override
  void initState() {
    super.initState();
    final initialTarget = widget.initialMessageId?.trim();
    _highlightedMessageId = initialTarget == null || initialTarget.isEmpty
        ? null
        : initialTarget;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = ref.read(impulseInboxControllerProvider.notifier);
      final loadedMessages = await controller.loadMessages(widget.chatId);
      await controller.markChatRead(widget.chatId);
      if (widget.initialMessageId == null) {
        _scrollToBottom();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusInitialMessage(loadedMessages);
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _highlightTimer?.cancel();
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialMessageId == null || _initialTargetHandled) {
        _scrollToBottom();
      }
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
    final isResponding = state.respondingChatIds.contains(widget.chatId);
    final error = state.chatErrors[widget.chatId];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialMessageId != null && !_initialTargetHandled) {
        _focusInitialMessage(messages);
      } else if (widget.initialMessageId == null) {
        _scrollToBottom();
      }
      final highlightedId = _highlightedMessageId;
      if (highlightedId != null &&
          !_highlightClearScheduled &&
          messages.any((message) => message.id == highlightedId)) {
        _scheduleHighlightClear(highlightedId);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF050A12),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xFF050A12),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _ChatHeader(chat: chat),
        actions: [
          if (chat != null &&
              (chat.sourceType == ImpulseChatSourceType.category ||
                  chat.sourceType == ImpulseChatSourceType.customAi))
            IconButton(
              key: const Key('chat_avatar_change_button'),
              tooltip: 'Bild ändern',
              onPressed: () => _pickAvatarImage(chat),
              icon: const Icon(Icons.add_photo_alternate_rounded),
            ),
          if (chat?.sourceType == ImpulseChatSourceType.category &&
              chat?.sourceId?.trim().isNotEmpty == true)
            IconButton(
              key: const Key('category_chat_options_button'),
              tooltip: 'Kategorie-Chat Optionen',
              onPressed: () => _confirmDisableCategoryChat(chat!),
              icon: const Icon(Icons.more_vert_rounded),
            ),
          if (chat?.sourceType == ImpulseChatSourceType.customAi)
            IconButton(
              key: const Key('custom_chat_options_button'),
              tooltip: 'Eigenen Chat ausblenden',
              onPressed: () => _confirmDisableCustomChat(chat!),
              icon: const Icon(Icons.more_vert_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          if (error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _ChatErrorMessage(message: error),
            ),
          Expanded(
            child: Stack(
              children: [
                const Positioned.fill(child: _ChatPatternBackground()),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: messages.isEmpty && !isResponding
                      ? _EmptyChat(chat: chat)
                      : _MessageTimeline(
                          scrollController: _scrollController,
                          buildAllMessagesForTarget:
                              widget.initialMessageId != null,
                          messages: messages,
                          isResponding: isResponding,
                          messageBuilder: _buildMessageEntry,
                        ),
                ),
              ],
            ),
          ),
          _ChatInputBar(
            controller: _inputController,
            enabled: !isResponding,
            replyToMessage: _replyToMessage,
            onCancelReply: () => setState(() => _replyToMessage = null),
            onSend: _sendMessage,
            onVoiceInput: _startVoiceInput,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final replyTo = _replyToMessage;
    _inputController.clear();
    setState(() => _replyToMessage = null);
    _scrollToBottom();
    await ref
        .read(impulseInboxControllerProvider.notifier)
        .sendChatMessage(widget.chatId, text, replyTo: replyTo);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Widget _buildMessageEntry(List<ImpulseMessage> messages, int index) {
    final previous = index == 0 ? null : messages[index - 1];
    final next = index == messages.length - 1 ? null : messages[index + 1];
    final current = messages[index];
    final sameGroup =
        previous != null &&
        _isSameMessageDay(previous.createdAt, current.createdAt) &&
        previous.source == current.source;
    final sameGroupAsNext =
        next != null &&
        _isSameMessageDay(next.createdAt, current.createdAt) &&
        next.source == current.source;
    final showDateSeparator =
        previous == null ||
        !_isSameMessageDay(previous.createdAt, current.createdAt);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDateSeparator) _DateSeparator(date: current.createdAt),
        KeyedSubtree(
          key: _messageKeyFor(current.id),
          child: _MessageBubble(
            message: current,
            highlighted: current.id == _highlightedMessageId,
            sameGroupAsPrevious: sameGroup,
            sameGroupAsNext: sameGroupAsNext,
            onLongPress: () => _openMessageActions(current),
          ),
        ),
      ],
    );
  }

  GlobalKey _messageKeyFor(String messageId) {
    return _messageKeys.putIfAbsent(messageId, GlobalKey.new);
  }

  Future<void> _focusInitialMessage(List<ImpulseMessage> messages) async {
    final targetId = widget.initialMessageId?.trim();
    if (targetId == null || targetId.isEmpty || _initialTargetHandled) return;
    if (messages.isEmpty) return;

    _initialTargetHandled = true;
    final targetIndex = messages.indexWhere(
      (message) => message.id == targetId,
    );
    if (targetIndex < 0) {
      if (!mounted) return;
      setState(() => _highlightedMessageId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gespeicherte Nachricht wurde nicht gefunden.'),
        ),
      );
      return;
    }

    setState(() => _highlightedMessageId = targetId);
    await _waitForScrollableLayout();
    if (!mounted) return;
    var targetContext = _messageKeys[targetId]?.currentContext;
    if (targetContext == null) {
      await _scrollNearTargetIndex(targetIndex, messages.length);
      if (!mounted) return;
      targetContext = _messageKeys[targetId]?.currentContext;
    }
    if (targetContext != null && targetContext.mounted) {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.36,
      );
    }
    _scheduleHighlightClear(targetId);
  }

  void _scheduleHighlightClear(String targetId) {
    if (_highlightClearScheduled && _highlightedMessageId == targetId) return;
    _highlightClearScheduled = true;
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _highlightedMessageId == targetId) {
        setState(() => _highlightedMessageId = null);
      }
    });
  }

  Future<void> _waitForScrollableLayout() async {
    for (var attempt = 0; attempt < 6; attempt++) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        return;
      }
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }
  }

  Future<void> _scrollNearTargetIndex(int targetIndex, int messageCount) async {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final denominator = messageCount <= 1 ? 1 : messageCount - 1;
    final targetOffset = max * (targetIndex / denominator);
    _scrollController.jumpTo(targetOffset.clamp(0.0, max).toDouble());
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<ImpulseVoiceInputResult> _startVoiceInput() {
    return ref.read(impulseVoiceInputServiceProvider).listenForText();
  }

  Future<void> _pickAvatarImage(ImpulseChat chat) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 82,
    );
    if (picked == null) return;
    await ref
        .read(impulseInboxControllerProvider.notifier)
        .updateChatAvatarImagePath(chatId: chat.id, imagePath: picked.path);
  }

  Future<void> _openMessageActions(ImpulseMessage message) async {
    FocusScope.of(context).unfocus();
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xAA000000),
      builder: (context) => _MessageActionSheet(
        message: message,
        onReaction: (reaction) async {
          Navigator.of(context).pop();
          await ref
              .read(impulseInboxControllerProvider.notifier)
              .updateReaction(widget.chatId, message.id, reaction);
        },
        onReply: () {
          Navigator.of(context).pop();
          setState(() => _replyToMessage = message);
        },
        onForward: () {
          Navigator.of(context).pop();
          _showSnack('Weiterleiten folgt später.');
        },
        onCopy: () async {
          Navigator.of(context).pop();
          final text = message.text.trim();
          if (text.isEmpty) return;
          await Clipboard.setData(ClipboardData(text: text));
          _showSnack('Nachricht kopiert');
        },
        onToggleStar: () async {
          Navigator.of(context).pop();
          await ref
              .read(impulseInboxControllerProvider.notifier)
              .toggleStarred(widget.chatId, message);
        },
        onDelete: () async {
          Navigator.of(context).pop();
          await _confirmDeleteMessage(message);
        },
        onMore: () {
          Navigator.of(context).pop();
          _openMoreActions(message);
        },
      ),
    );
  }

  Future<void> _openMoreActions(ImpulseMessage message) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MessageMoreActionSheet(
        onPin: () async {
          Navigator.of(context).pop();
          await ref
              .read(impulseInboxControllerProvider.notifier)
              .togglePinned(widget.chatId, message);
          _showSnack(
            message.isPinned ? 'Fixierung entfernt.' : 'Nachricht fixiert.',
          );
        },
        onSpeak: () {
          Navigator.of(context).pop();
          _showSnack('Vorlesen folgt später.');
        },
        onTranslate: () {
          Navigator.of(context).pop();
          _showSnack('Übersetzen folgt später.');
        },
      ),
    );
  }

  Future<void> _confirmDeleteMessage(ImpulseMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111820),
        title: const Text(
          'Nachricht löschen?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Diese Nachricht wird nur lokal aus diesem Chat entfernt.',
          style: TextStyle(color: Color(0xFFB8C4D9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            key: const Key('impulse_message_delete_confirm_button'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Löschen',
              style: TextStyle(color: Color(0xFFFF7A89)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(impulseInboxControllerProvider.notifier)
        .deleteMessage(widget.chatId, message.id);
  }

  Future<void> _confirmDisableCategoryChat(ImpulseChat chat) async {
    final categoryId = chat.sourceId?.trim();
    if (chat.sourceType != ImpulseChatSourceType.category ||
        categoryId == null ||
        categoryId.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111820),
        title: const Text(
          'Kategorie-Chat deaktivieren?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Der Chat wird aus dem Impuls-Postfach ausgeblendet. Deine lokalen Nachrichten bleiben erhalten.',
          style: TextStyle(color: Color(0xFFB8C4D9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            key: const Key('category_chat_disable_confirm_button'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Deaktivieren',
              style: TextStyle(color: Color(0xFFFFB05A)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(impulseInboxControllerProvider.notifier)
        .setCategoryChatEnabled(categoryId: categoryId, enabled: false);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _confirmDisableCustomChat(ImpulseChat chat) async {
    if (chat.sourceType != ImpulseChatSourceType.customAi) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111820),
        title: const Text(
          'Chat ausblenden?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Der eigene KI-Chat wird aus dem Impuls-Postfach ausgeblendet. Deine lokalen Nachrichten bleiben erhalten.',
          style: TextStyle(color: Color(0xFFB8C4D9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            key: const Key('custom_chat_disable_confirm_button'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Ausblenden',
              style: TextStyle(color: Color(0xFFFFB05A)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(impulseInboxControllerProvider.notifier)
        .setChatEnabled(chatId: chat.id, enabled: false);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF07111A),
      ),
    );
  }

  bool _isSameMessageDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.chat});

  final ImpulseChat? chat;

  @override
  Widget build(BuildContext context) {
    final isCategory = chat?.sourceType == ImpulseChatSourceType.category;
    final isCustom = chat?.sourceType == ImpulseChatSourceType.customAi;
    return Row(
      children: [
        _HeaderAvatar(
          chat: chat,
          icon: isCategory
              ? Icons.mark_unread_chat_alt_rounded
              : isCustom
              ? Icons.psychology_alt_rounded
              : Icons.auto_awesome_rounded,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chat?.title ?? 'Impuls',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                isCategory
                    ? 'Kategorie-Chat'
                    : isCustom
                    ? 'Eigener KI-Chat'
                    : 'Talvori Impulse',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF7D8BA3),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.chat, required this.icon});

  final ImpulseChat? chat;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final path = chat?.avatarImagePath?.trim();
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF07111A),
        border: Border.all(color: const Color(0xFF7FFFE7)),
        boxShadow: const [BoxShadow(color: Color(0x227FFFE7), blurRadius: 14)],
      ),
      clipBehavior: Clip.antiAlias,
      child: path != null && path.isNotEmpty
          ? Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(icon, color: const Color(0xFF7FFFE7), size: 18),
            )
          : Icon(icon, color: const Color(0xFF7FFFE7), size: 18),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.chat});

  final ImpulseChat? chat;

  @override
  Widget build(BuildContext context) {
    final isCategory = chat?.sourceType == ImpulseChatSourceType.category;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Noch keine Nachrichten',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFB8C4D9),
                fontWeight: FontWeight.w800,
              ),
            ),
            if (isCategory) ...[
              const SizedBox(height: 8),
              const Text(
                'Stelle Talvori eine Frage zu dieser Kategorie.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7D8BA3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          key: const Key('impulse_chat_date_separator'),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xE60D1218),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x1859D7FF)),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 12),
            ],
          ),
          child: Text(
            _labelForDate(date),
            style: const TextStyle(
              color: Color(0xFFE9F0FA),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }

  String _labelForDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) return 'Heute';
    if (day == today.subtract(const Duration(days: 1))) return 'Gestern';
    const weekdays = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
    if (today.difference(day).inDays < 7 && today.isAfter(day)) {
      return weekdays[date.weekday - 1];
    }
    return '${date.day}.${date.month}.${date.year}';
  }
}

class _ChatPatternBackground extends StatelessWidget {
  const _ChatPatternBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ChatPatternPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ChatPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF050A12), BlendMode.src);

    final linePaint = Paint()
      ..color = const Color(0x1459D7FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;
    final dotPaint = Paint()
      ..color = const Color(0x0F7FFFE7)
      ..style = PaintingStyle.fill;

    const step = 86.0;
    for (var y = -20.0; y < size.height + step; y += step) {
      for (var x = -20.0; x < size.width + step; x += step) {
        final offset = Offset(x + ((y ~/ step).isEven ? 0 : step / 2), y);
        canvas.drawCircle(offset.translate(16, 16), 3.2, dotPaint);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(offset.dx + 34, offset.dy + 14, 28, 18),
            const Radius.circular(7),
          ),
          linePaint,
        );
        canvas.drawLine(
          offset.translate(8, 52),
          offset.translate(42, 30),
          linePaint,
        );
        canvas.drawCircle(offset.translate(58, 58), 12, linePaint);
        canvas.drawPath(
          Path()
            ..moveTo(offset.dx + 12, offset.dy + 78)
            ..quadraticBezierTo(
              offset.dx + 28,
              offset.dy + 60,
              offset.dx + 46,
              offset.dy + 78,
            )
            ..quadraticBezierTo(
              offset.dx + 28,
              offset.dy + 70,
              offset.dx + 12,
              offset.dy + 78,
            ),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChatPatternPainter oldDelegate) => false;
}

typedef _TimelineMessageBuilder =
    Widget Function(List<ImpulseMessage> messages, int index);

class _MessageTimeline extends StatelessWidget {
  const _MessageTimeline({
    required this.scrollController,
    required this.buildAllMessagesForTarget,
    required this.messages,
    required this.isResponding,
    required this.messageBuilder,
  });

  final ScrollController scrollController;
  final bool buildAllMessagesForTarget;
  final List<ImpulseMessage> messages;
  final bool isResponding;
  final _TimelineMessageBuilder messageBuilder;

  @override
  Widget build(BuildContext context) {
    if (buildAllMessagesForTarget) {
      return ListView(
        key: const Key('impulse_chat_message_list'),
        controller: scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
        children: [
          for (var index = 0; index < messages.length; index++)
            messageBuilder(messages, index),
          if (isResponding) const _ThinkingBubble(),
        ],
      );
    }

    return ListView.builder(
      key: const Key('impulse_chat_message_list'),
      controller: scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      itemCount: messages.length + (isResponding ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < messages.length) {
          return messageBuilder(messages, index);
        }
        if (isResponding && index == messages.length) {
          return const _ThinkingBubble();
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.highlighted,
    required this.sameGroupAsPrevious,
    required this.sameGroupAsNext,
    required this.onLongPress,
  });

  final ImpulseMessage message;
  final bool highlighted;
  final bool sameGroupAsPrevious;
  final bool sameGroupAsNext;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isUser = message.source == ImpulseMessageSource.user;
    final emojiOnly = _isEmojiOnly(message.text);
    if (emojiOnly) {
      return _EmojiMessage(
        message: message,
        isUser: isUser,
        highlighted: highlighted,
        sameGroupAsPrevious: sameGroupAsPrevious,
        sameGroupAsNext: sameGroupAsNext,
        onLongPress: onLongPress,
      );
    }

    final bubbleColor = isUser
        ? const Color(0xFF0B342D)
        : const Color(0xFF1A2026);
    final showTail = !sameGroupAsNext;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          key: highlighted
              ? Key('impulse_message_highlight_${message.id}')
              : null,
          behavior: HitTestBehavior.opaque,
          onLongPress: onLongPress,
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.76,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    key: Key('impulse_message_bubble_${message.id}'),
                    padding: EdgeInsets.only(
                      top: sameGroupAsPrevious ? 2 : 9,
                      bottom: sameGroupAsNext ? 1 : 7,
                    ),
                    child: CustomPaint(
                      painter: _ChatBubblePainter(
                        color: bubbleColor,
                        isUser: isUser,
                        showTail: showTail,
                        highlighted: highlighted,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isUser ? 10 : 16,
                          7,
                          isUser ? 16 : 10,
                          5,
                        ),
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (message.replyPreviewText != null) ...[
                              _ReplyPreview(message: message, isUser: isUser),
                              const SizedBox(height: 5),
                            ],
                            Text(
                              message.text,
                              textAlign: isUser
                                  ? TextAlign.right
                                  : TextAlign.left,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (!isUser && message.usedWords.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                runSpacing: 3,
                                children: [
                                  for (final word in message.usedWords)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x3307111A),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: const Color(0x2259D7FF),
                                        ),
                                      ),
                                      child: Text(
                                        word,
                                        style: const TextStyle(
                                          color: Color(0xCC7FFFE7),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 3),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (message.isStarred) ...[
                                  const Icon(
                                    Icons.star_rounded,
                                    key: Key('impulse_message_star_icon'),
                                    color: Color(0xFFFFD166),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  _timeLabel(message.createdAt),
                                  style: TextStyle(
                                    color: isUser
                                        ? const Color(0xB8A8D7CE)
                                        : const Color(0xB87D8BA3),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (isUser) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.done_all_rounded,
                                    color: Color(0xB859D7FF),
                                    size: 14,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (showTail)
                    Positioned(
                      bottom: 9,
                      left: isUser ? null : 0,
                      right: isUser ? 0 : null,
                      child: SizedBox(
                        key: Key('impulse_message_tail_${message.id}'),
                        width: 1,
                        height: 1,
                      ),
                    ),
                  if (message.reaction != null)
                    Positioned(
                      right: isUser ? 6 : null,
                      left: isUser ? null : 10,
                      bottom: -3,
                      child: _ReactionBadge(
                        reaction: message.reaction!,
                        messageId: message.id,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _timeLabel(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _isEmojiOnly(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(trimmed)) {
      return false;
    }
    return RegExp(
      r'^[\s\u{200D}\u{FE0E}\u{FE0F}\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}]+$',
      unicode: true,
    ).hasMatch(trimmed);
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        key: const Key('impulse_chat_thinking_bubble'),
        margin: const EdgeInsets.only(top: 8, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2026),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(17),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(17),
          ),
        ),
        child: const Text(
          'Talvori denkt...',
          style: TextStyle(
            color: Color(0xFFB8C4D9),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({required this.message, required this.isUser});

  final ImpulseMessage message;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final source = message.replyPreviewSource == ImpulseMessageSource.user
        ? 'Du'
        : 'Talvori';
    return Container(
      key: Key('impulse_message_reply_preview_${message.id}'),
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
      decoration: BoxDecoration(
        color: isUser ? const Color(0x3307111A) : const Color(0x33000000),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Color(0xFF59D7FF), width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            source,
            style: const TextStyle(
              color: Color(0xFF7FFFE7),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            message.replyPreviewText ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionBadge extends StatelessWidget {
  const _ReactionBadge({required this.reaction, required this.messageId});

  final String reaction;
  final String messageId;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('impulse_message_reaction_$messageId'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xF20D1218),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x2259D7FF)),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 8)],
      ),
      child: Text(reaction, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _EmojiMessage extends StatelessWidget {
  const _EmojiMessage({
    required this.message,
    required this.isUser,
    required this.highlighted,
    required this.sameGroupAsPrevious,
    required this.sameGroupAsNext,
    required this.onLongPress,
  });

  final ImpulseMessage message;
  final bool isUser;
  final bool highlighted;
  final bool sameGroupAsPrevious;
  final bool sameGroupAsNext;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: highlighted ? Key('impulse_message_highlight_${message.id}') : null,
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          key: Key('impulse_message_emoji_${message.id}'),
          margin: EdgeInsets.only(
            top: sameGroupAsPrevious ? 1 : 9,
            bottom: sameGroupAsNext ? 1 : 8,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: highlighted
                  ? Border.all(color: const Color(0x887FFFE7))
                  : null,
              boxShadow: highlighted
                  ? const [BoxShadow(color: Color(0x557FFFE7), blurRadius: 18)]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.text.trim(),
                      style: const TextStyle(fontSize: 48, height: 1.0),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.isStarred) ...[
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD166),
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                        ],
                        Text(
                          _timeLabel(message.createdAt),
                          style: const TextStyle(
                            color: Color(0xB87D8BA3),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.done_all_rounded,
                            color: Color(0xB859D7FF),
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (message.reaction != null)
                  Positioned(
                    right: isUser ? -6 : null,
                    left: isUser ? null : -6,
                    bottom: 13,
                    child: _ReactionBadge(
                      reaction: message.reaction!,
                      messageId: message.id,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _timeLabel(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ChatBubblePainter extends CustomPainter {
  const _ChatBubblePainter({
    required this.color,
    required this.isUser,
    required this.showTail,
    required this.highlighted,
  });

  final Color color;
  final bool isUser;
  final bool showTail;
  final bool highlighted;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final bubbleRect = _bubbleRect(size);
    final tailPath = showTail ? _tailPath(size) : null;
    if (tailPath != null) {
      canvas.drawPath(tailPath, fill);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(bubbleRect, const Radius.circular(18)),
      fill,
    );

    if (highlighted) {
      final stroke = Paint()
        ..color = const Color(0x887FFFE7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..isAntiAlias = true;
      canvas.drawRRect(
        RRect.fromRectAndRadius(bubbleRect, const Radius.circular(18)),
        stroke,
      );
      if (tailPath != null) {
        canvas.drawPath(tailPath, stroke);
      }
    }
  }

  Rect _bubbleRect(Size size) {
    const tail = 8.0;
    final left = isUser || !showTail ? 0.0 : tail;
    final right = isUser && showTail ? size.width - tail : size.width;
    return Rect.fromLTRB(left, 0, right, size.height);
  }

  Path _tailPath(Size size) {
    const tail = 8.0;
    final left = isUser || !showTail ? 0.0 : tail;
    final right = isUser && showTail ? size.width - tail : size.width;
    final baseY = size.height - 13;
    final tipY = size.height - 2;
    final path = Path();
    if (isUser) {
      path
        ..moveTo(right - 4, baseY - 1)
        ..cubicTo(
          right + 1,
          baseY + 4,
          size.width - 2.5,
          tipY - 1,
          size.width,
          tipY,
        )
        ..cubicTo(
          right + 0.5,
          tipY + 0.5,
          right - 4,
          tipY - 1,
          right - 10,
          tipY - 5,
        )
        ..cubicTo(
          right - 6,
          tipY - 7,
          right - 5,
          tipY - 10,
          right - 4,
          baseY - 1,
        )
        ..close();
    } else {
      path
        ..moveTo(left + 4, baseY - 1)
        ..cubicTo(left - 1, baseY + 4, 2.5, tipY - 1, 0, tipY)
        ..cubicTo(
          left - 0.5,
          tipY + 0.5,
          left + 4,
          tipY - 1,
          left + 10,
          tipY - 5,
        )
        ..cubicTo(left + 6, tipY - 7, left + 5, tipY - 10, left + 4, baseY - 1)
        ..close();
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _ChatBubblePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isUser != isUser ||
        oldDelegate.showTail != showTail ||
        oldDelegate.highlighted != highlighted;
  }
}

class _ChatErrorMessage extends StatelessWidget {
  const _ChatErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        key: const Key('impulse_chat_error_message'),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF241018),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFF6B8A)),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Color(0xFFFFB3C1),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InputReplyPreview extends StatelessWidget {
  const _InputReplyPreview({required this.message, required this.onCancel});

  final ImpulseMessage message;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final source = message.source == ImpulseMessageSource.user
        ? 'Du'
        : 'Talvori';
    final preview = message.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    return Container(
      key: const Key('impulse_chat_reply_preview'),
      margin: const EdgeInsets.fromLTRB(44, 0, 48, 7),
      padding: const EdgeInsets.fromLTRB(10, 7, 6, 7),
      decoration: BoxDecoration(
        color: const Color(0xFF101820),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x2259D7FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF59D7FF),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  source,
                  style: const TextStyle(
                    color: Color(0xFF7FFFE7),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('impulse_chat_reply_cancel_button'),
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            padding: EdgeInsets.zero,
            onPressed: onCancel,
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFFB8C4D9),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageActionSheet extends StatelessWidget {
  const _MessageActionSheet({
    required this.message,
    required this.onReaction,
    required this.onReply,
    required this.onForward,
    required this.onCopy,
    required this.onToggleStar,
    required this.onDelete,
    required this.onMore,
  });

  final ImpulseMessage message;
  final ValueChanged<String> onReaction;
  final VoidCallback onReply;
  final VoidCallback onForward;
  final VoidCallback onCopy;
  final VoidCallback onToggleStar;
  final VoidCallback onDelete;
  final VoidCallback onMore;

  static const _reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏', '🥰'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Column(
        key: const Key('impulse_message_action_menu'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xF21A2026),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x1859D7FF)),
              boxShadow: const [
                BoxShadow(color: Color(0x88000000), blurRadius: 22),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final reaction in _reactions)
                  _ReactionButton(reaction: reaction, onTap: onReaction),
                IconButton(
                  key: const Key('impulse_message_reaction_more_button'),
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFFB8C4D9),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xF21D242A),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0x1459D7FF)),
              boxShadow: const [
                BoxShadow(color: Color(0x99000000), blurRadius: 24),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MessageActionTile(
                  label: 'Antworten',
                  icon: Icons.reply_rounded,
                  onTap: onReply,
                ),
                _MessageActionTile(
                  label: 'Weiterleiten',
                  icon: Icons.forward_rounded,
                  onTap: onForward,
                ),
                _MessageActionTile(
                  label: 'Kopieren',
                  icon: Icons.copy_rounded,
                  onTap: onCopy,
                ),
                _MessageActionTile(
                  label: message.isStarred
                      ? 'Stern entfernen'
                      : 'Mit Stern markieren',
                  icon: message.isStarred
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  onTap: onToggleStar,
                ),
                _MessageActionTile(
                  label: 'Löschen',
                  icon: Icons.delete_outline_rounded,
                  destructive: true,
                  onTap: onDelete,
                ),
                Container(height: 8, color: const Color(0xFF101610)),
                _MessageActionTile(
                  label: 'Mehr ...',
                  icon: Icons.more_horiz_rounded,
                  onTap: onMore,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageMoreActionSheet extends StatelessWidget {
  const _MessageMoreActionSheet({
    required this.onPin,
    required this.onSpeak,
    required this.onTranslate,
  });

  final VoidCallback onPin;
  final VoidCallback onSpeak;
  final VoidCallback onTranslate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Container(
        key: const Key('impulse_message_more_menu'),
        decoration: BoxDecoration(
          color: const Color(0xF21D242A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x1459D7FF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MessageActionTile(
              label: 'Fixieren',
              icon: Icons.push_pin_outlined,
              onTap: onPin,
            ),
            _MessageActionTile(
              label: 'Sprechen',
              icon: Icons.record_voice_over_outlined,
              onTap: onSpeak,
            ),
            _MessageActionTile(
              label: 'Übersetzen',
              icon: Icons.translate_rounded,
              onTap: onTranslate,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({required this.reaction, required this.onTap});

  final String reaction;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('impulse_message_reaction_$reaction'),
      borderRadius: BorderRadius.circular(999),
      onTap: () => onTap(reaction),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(reaction, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}

class _MessageActionTile extends StatelessWidget {
  const _MessageActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFFF7A89) : Colors.white;
    return ListTile(
      key: Key('impulse_message_action_$label'),
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Icon(icon, color: color, size: 22),
      onTap: onTap,
    );
  }
}

class _ChatInputBar extends StatefulWidget {
  const _ChatInputBar({
    required this.controller,
    required this.enabled,
    required this.replyToMessage,
    required this.onCancelReply,
    required this.onSend,
    required this.onVoiceInput,
  });

  final TextEditingController controller;
  final bool enabled;
  final ImpulseMessage? replyToMessage;
  final VoidCallback onCancelReply;
  final Future<void> Function() onSend;
  final Future<ImpulseVoiceInputResult> Function() onVoiceInput;

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
  bool _hasText = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncTextState);
    _syncTextState();
  }

  @override
  void didUpdateWidget(covariant _ChatInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncTextState);
      widget.controller.addListener(_syncTextState);
      _syncTextState();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncTextState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.enabled && _hasText;
    final canUseVoice = widget.enabled && !_hasText && !_isListening;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        decoration: const BoxDecoration(
          color: Color(0xFF050A12),
          border: Border(top: BorderSide(color: Color(0x1859D7FF))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.replyToMessage != null)
              _InputReplyPreview(
                message: widget.replyToMessage!,
                onCancel: widget.onCancelReply,
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  key: const Key('impulse_chat_attachment_button'),
                  tooltip: 'Anhänge folgen später',
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Anhänge folgen später.'),
                        backgroundColor: Color(0xFF07111A),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, color: Color(0xFF59D7FF)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151C23),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0x1F59D7FF)),
                    ),
                    child: TextField(
                      key: const Key('impulse_chat_message_input'),
                      controller: widget.controller,
                      enabled: widget.enabled,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        hintText: 'Nachricht schreiben...',
                        hintStyle: TextStyle(color: Color(0xFF7D8BA3)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                if (_hasText)
                  IconButton.filled(
                    key: const Key('impulse_chat_send_button'),
                    tooltip: 'Senden',
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: canSend ? widget.onSend : null,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF59D7FF),
                      disabledBackgroundColor: const Color(0x22151C23),
                      foregroundColor: const Color(0xFF041016),
                      disabledForegroundColor: const Color(0x887D8BA3),
                    ),
                    icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                  )
                else
                  IconButton.filled(
                    key: const Key('impulse_chat_microphone_button'),
                    tooltip: 'Spracheingabe',
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: canUseVoice ? _startVoiceInput : null,
                    style: IconButton.styleFrom(
                      backgroundColor: _isListening
                          ? const Color(0xFF7FFFE7)
                          : const Color(0xFF101B24),
                      disabledBackgroundColor: const Color(0x22151C23),
                      foregroundColor: _isListening
                          ? const Color(0xFF041016)
                          : const Color(0xFF59D7FF),
                      disabledForegroundColor: const Color(0x887D8BA3),
                    ),
                    icon: Icon(
                      _isListening
                          ? Icons.graphic_eq_rounded
                          : Icons.mic_rounded,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _syncTextState() {
    final next = widget.controller.text.trim().isNotEmpty;
    if (_hasText == next) return;
    setState(() => _hasText = next);
  }

  Future<void> _startVoiceInput() async {
    if (_isListening) return;
    setState(() => _isListening = true);
    final result = await widget.onVoiceInput();
    if (!mounted) return;
    setState(() => _isListening = false);

    switch (result.status) {
      case ImpulseVoiceInputStatus.success:
        final text = result.text?.trim();
        if (text == null || text.isEmpty) return;
        widget.controller.text = text;
        widget.controller.selection = TextSelection.collapsed(
          offset: widget.controller.text.length,
        );
      case ImpulseVoiceInputStatus.permissionDenied:
        _showVoiceInputMessage('Mikrofon und Spracherkennung erlauben.');
      case ImpulseVoiceInputStatus.unavailable:
        _showVoiceInputMessage('Spracheingabe ist nicht verfügbar.');
      case ImpulseVoiceInputStatus.noSpeech:
        _showVoiceInputMessage('Keine Sprache erkannt.');
      case ImpulseVoiceInputStatus.failed:
        _showVoiceInputMessage('Spracheingabe konnte nicht gestartet werden.');
    }
  }

  void _showVoiceInputMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF07111A),
      ),
    );
  }
}
