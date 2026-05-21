import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';
import 'package:talvori/core/local_database/providers/local_category_detail_group_items_provider.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_ai_profile.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_saved_message.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impulse_chat_detail_screen.dart';

enum _InboxTab { chats, categories, saved, you }

enum _ChatFilter { all, unread, dailyImpulse, categories, customAi, saved }

class ImpulsPostfachScreen extends ConsumerStatefulWidget {
  const ImpulsPostfachScreen({super.key});

  @override
  ConsumerState<ImpulsPostfachScreen> createState() =>
      _ImpulsPostfachScreenState();
}

class _ImpulsPostfachScreenState extends ConsumerState<ImpulsPostfachScreen> {
  final _searchController = TextEditingController();
  _InboxTab _tab = _InboxTab.chats;
  _ChatFilter _chatFilter = _ChatFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(impulseInboxControllerProvider);
    final categories = _tab == _InboxTab.categories
        ? ref.watch(localCategoryDetailGroupItemsProvider('health_fitness'))
        : null;
    final starredChatIds = state.savedMessages
        .map((item) => item.chat.id)
        .toSet();
    final filteredChats = _filterChats(
      state.chats,
      _query,
      _chatFilter,
      starredChatIds,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF050A12),
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: const Color(0xFF050A12),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impuls-Postfach',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            Text(
              'Chats mit Talvori',
              style: TextStyle(
                color: Color(0xFF7D8BA3),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton.filled(
            key: const Key('impulse_inbox_add_chat_button'),
            onPressed: _openAddChatSheet,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF0C1A25),
              foregroundColor: const Color(0xFF7FFFE7),
              side: const BorderSide(color: Color(0x8859D7FF)),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _SearchField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: switch (_tab) {
                _InboxTab.chats =>
                  state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _ChatsTab(
                          chats: filteredChats,
                          selectedFilter: _chatFilter,
                          query: _query,
                          onFilterChanged: (filter) =>
                              setState(() => _chatFilter = filter),
                          onOpen: _openChat,
                        ),
                _InboxTab.categories => categories!.when(
                  data: (items) => _CategoryHubList(
                    items: items,
                    chats: state.allChats,
                    query: _query,
                    onOpenCategory: _openCategoryChat,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const _PanelEmpty(
                    title: 'Kategorien konnten nicht geladen werden',
                    text: 'Öffne WordHub und versuche es danach erneut.',
                  ),
                ),
                _InboxTab.saved => _SavedMessagesTab(
                  savedMessages: state.savedMessages,
                  onOpen: _openSavedMessage,
                ),
                _InboxTab.you => _YouTab(
                  profile: state.aiProfile,
                  activeChatCount: state.chats.length,
                  hiddenChats: state.hiddenChats,
                  onChanged: (profile) => ref
                      .read(impulseInboxControllerProvider.notifier)
                      .updateAiProfile(profile),
                  onManageHidden: _openHiddenChatsSheet,
                ),
              },
            ),
            _InboxBottomTabs(
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
          ],
        ),
      ),
    );
  }

  List<ImpulseChat> _filterChats(
    List<ImpulseChat> chats,
    String query,
    _ChatFilter filter,
    Set<String> starredChatIds,
  ) {
    final normalized = query.trim().toLowerCase();
    return chats
        .where(
          (chat) => switch (filter) {
            _ChatFilter.all => true,
            _ChatFilter.unread => chat.unreadCount > 0,
            _ChatFilter.dailyImpulse =>
              chat.sourceType == ImpulseChatSourceType.dailyImpulse,
            _ChatFilter.categories =>
              chat.sourceType == ImpulseChatSourceType.category,
            _ChatFilter.customAi =>
              chat.sourceType == ImpulseChatSourceType.customAi,
            _ChatFilter.saved => starredChatIds.contains(chat.id),
          },
        )
        .where(
          (chat) =>
              normalized.isEmpty ||
              chat.title.toLowerCase().contains(normalized) ||
              (chat.lastMessageText ?? '').toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  void _openChat(ImpulseChat chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImpulseChatDetailScreen(chatId: chat.id),
      ),
    );
  }

  Future<void> _openSavedMessage(ImpulseSavedMessage item) async {
    if (!item.chat.enabled) {
      await ref
          .read(impulseInboxControllerProvider.notifier)
          .setChatEnabled(chatId: item.chat.id, enabled: true);
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImpulseChatDetailScreen(
          chatId: item.chat.id,
          initialMessageId: item.message.id,
        ),
      ),
    );
  }

  Future<void> _openCategoryChat(LocalCategoryDetailGroupItem item) async {
    final categoryId = item.localCategoryId?.trim();
    if (categoryId == null || categoryId.isEmpty) return;
    final chat = await ref
        .read(impulseInboxControllerProvider.notifier)
        .ensureCategoryChat(categoryId: categoryId, title: item.displayLabel);
    if (!mounted) return;
    _openChat(chat);
  }

  Future<void> _createCustomChat(String title) async {
    final chat = await ref
        .read(impulseInboxControllerProvider.notifier)
        .createCustomAiChat(title: title);
    if (!mounted) return;
    _openChat(chat);
  }

  Future<void> _reactivateChat(ImpulseChat chat) async {
    await ref
        .read(impulseInboxControllerProvider.notifier)
        .reactivateChat(chat.id);
    if (!mounted) return;
    _openChat(chat.copyWith(enabled: true));
  }

  Future<void> _confirmDeleteCustomChat(ImpulseChat chat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101923),
        title: const Text(
          'Eigenen Chat löschen?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Dieser Chat und seine lokalen Nachrichten werden nur auf diesem Gerät gelöscht.',
          style: TextStyle(color: Color(0xFFB8C4D9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            key: const Key('custom_chat_delete_confirm_button'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(impulseInboxControllerProvider.notifier)
        .deleteCustomAiChat(chat.id);
  }

  Future<void> _openHiddenChatsSheet() {
    final hiddenChats = ref.read(impulseInboxControllerProvider).hiddenChats;
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _HiddenChatsSheet(
        hiddenChats: hiddenChats,
        onReactivate: (chat) async {
          Navigator.of(sheetContext).pop();
          await _reactivateChat(chat);
        },
        onDeleteCustom: (chat) async {
          Navigator.of(sheetContext).pop();
          await _confirmDeleteCustomChat(chat);
        },
      ),
    );
  }

  Future<void> _openAddChatSheet() {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddChatSheet(
        onCategories: () {
          Navigator.of(context).pop();
          setState(() => _tab = _InboxTab.categories);
        },
        onCustomChat: () {
          Navigator.of(context).pop();
          _showCreateCustomChatDialog();
        },
        onDailyImpulse: () async {
          Navigator.of(context).pop();
          final chat = await ref
              .read(impulseInboxControllerProvider.notifier)
              .ensureDailyImpulseChat();
          if (!mounted) return;
          _openChat(chat);
        },
      ),
    );
  }

  Future<void> _showCreateCustomChatDialog() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101923),
        title: const Text(
          'Eigenen KI-Chat erstellen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: TextField(
          key: const Key('custom_chat_name_field'),
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Chat-Name',
            hintStyle: TextStyle(color: Color(0xFF7D8BA3)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            key: const Key('custom_chat_create_confirm_button'),
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
    // Keep the controller alive until the closing dialog animation has removed
    // the TextField from the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    if (title == null || title.trim().isEmpty) return;
    await _createCustomChat(title);
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
      child: TextField(
        key: const Key('impulse_inbox_search_field'),
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF59D7FF),
          ),
          hintText: 'Chats oder Kategorien suchen',
          hintStyle: const TextStyle(color: Color(0xFF7D8BA3)),
          filled: true,
          fillColor: const Color(0xFF08111B),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0x2259D7FF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF59D7FF)),
          ),
        ),
      ),
    );
  }
}

class _ChatsTab extends StatelessWidget {
  const _ChatsTab({
    required this.chats,
    required this.selectedFilter,
    required this.query,
    required this.onFilterChanged,
    required this.onOpen,
  });

  final List<ImpulseChat> chats;
  final _ChatFilter selectedFilter;
  final String query;
  final ValueChanged<_ChatFilter> onFilterChanged;
  final ValueChanged<ImpulseChat> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChatFilterChips(selected: selectedFilter, onSelected: onFilterChanged),
        Expanded(
          child: chats.isEmpty
              ? _ChatFilterEmpty(
                  filter: selectedFilter,
                  hasQuery: query.trim().isNotEmpty,
                )
              : _ChatList(chats: chats, onOpen: onOpen),
        ),
      ],
    );
  }
}

class _ChatFilterChips extends StatelessWidget {
  const _ChatFilterChips({required this.selected, required this.onSelected});

  final _ChatFilter selected;
  final ValueChanged<_ChatFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        key: const Key('impulse_inbox_chat_filter_chips'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemBuilder: (context, index) {
          final filter = _ChatFilter.values[index];
          final isSelected = filter == selected;
          return ChoiceChip(
            key: Key('chat_filter_${filter.name}'),
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (_) => onSelected(filter),
            selectedColor: const Color(0xFF0F5D4A),
            backgroundColor: const Color(0xFF08111B),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF7FFFE7)
                  : const Color(0x2259D7FF),
            ),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFC8D6E6),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _ChatFilter.values.length,
      ),
    );
  }
}

class _ChatFilterEmpty extends StatelessWidget {
  const _ChatFilterEmpty({required this.filter, required this.hasQuery});

  final _ChatFilter filter;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    if (hasQuery) return const _SearchEmpty();
    return _PanelEmpty(title: filter.emptyTitle, text: filter.emptyText);
  }
}

extension _ChatFilterLabels on _ChatFilter {
  String get label => switch (this) {
    _ChatFilter.all => 'Alle',
    _ChatFilter.unread => 'Ungelesen',
    _ChatFilter.dailyImpulse => 'Tagesimpuls',
    _ChatFilter.categories => 'Kategorien',
    _ChatFilter.customAi => 'Eigene Chats',
    _ChatFilter.saved => 'Gespeichert',
  };

  String get emptyTitle => switch (this) {
    _ChatFilter.all => 'Noch keine Chats',
    _ChatFilter.unread => 'Keine ungelesenen Chats',
    _ChatFilter.dailyImpulse => 'Kein Tagesimpuls-Chat',
    _ChatFilter.categories => 'Keine Kategorie-Chats',
    _ChatFilter.customAi => 'Keine eigenen Chats',
    _ChatFilter.saved => 'Keine gespeicherten Nachrichten in Chats',
  };

  String get emptyText => switch (this) {
    _ChatFilter.all =>
      'Erstelle einen Kategorie-Chat oder starte mit deinem Tagesimpuls.',
    _ChatFilter.unread => 'Neue Impulse und Antworten erscheinen hier.',
    _ChatFilter.dailyImpulse => 'Der Tagesimpuls-Chat entsteht automatisch.',
    _ChatFilter.categories =>
      'Füge im Kategorien-Tab einen Kategorie-Chat hinzu.',
    _ChatFilter.customAi => 'Erstelle über Plus einen eigenen lokalen KI-Chat.',
    _ChatFilter.saved =>
      'Markiere Nachrichten mit Stern, damit ihr Chat hier auftaucht.',
  };
}

class _ChatList extends StatelessWidget {
  const _ChatList({required this.chats, required this.onOpen});

  final List<ImpulseChat> chats;
  final ValueChanged<ImpulseChat> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('impulse_inbox_chat_list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: chats.length + 1,
      separatorBuilder: (_, index) =>
          index == 0 ? const SizedBox(height: 10) : const _ChatDivider(),
      itemBuilder: (context, index) {
        if (index == 0) return _InboxHeader(chatCount: chats.length);
        return _ChatTile(chat: chats[index - 1], onOpen: onOpen);
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
  const _ChatTile({required this.chat, required this.onOpen});

  final ImpulseChat chat;
  final ValueChanged<ImpulseChat> onOpen;

  @override
  Widget build(BuildContext context) {
    final lastMessage = chat.lastMessageText?.trim();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('impulse_chat_tile_${chat.id}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () => onOpen(chat),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              _ChatAvatar(chat: chat),
              const SizedBox(width: 13),
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
                            style: TextStyle(
                              color: chat.unreadCount > 0
                                  ? const Color(0xFF7FFFE7)
                                  : const Color(0xFF7D8BA3),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage == null || lastMessage.isEmpty
                                ? _emptyPreview(chat)
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

  String _emptyPreview(ImpulseChat chat) {
    return switch (chat.sourceType) {
      ImpulseChatSourceType.category =>
        'Stelle Talvori eine Frage zur Kategorie',
      ImpulseChatSourceType.customAi => 'Eigener lokaler KI-Chat',
      _ => 'Noch keine Nachrichten',
    };
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

class _ChatDivider extends StatelessWidget {
  const _ChatDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 76, right: 4),
      child: Divider(height: 1, color: Color(0x1F59D7FF)),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.chat, this.size = 54});

  final ImpulseChat chat;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = chat.avatarImagePath?.trim();
    final icon = switch (chat.sourceType) {
      ImpulseChatSourceType.dailyImpulse => Icons.auto_awesome_rounded,
      ImpulseChatSourceType.category => Icons.bubble_chart_rounded,
      ImpulseChatSourceType.customAi => Icons.psychology_alt_rounded,
      ImpulseChatSourceType.favorites => Icons.favorite_rounded,
      ImpulseChatSourceType.myWords => Icons.library_books_rounded,
      ImpulseChatSourceType.knownWords => Icons.verified_rounded,
    };
    final color = switch (chat.sourceType) {
      ImpulseChatSourceType.category => const Color(0xFF7FFFE7),
      ImpulseChatSourceType.customAi => const Color(0xFFFFD166),
      _ => const Color(0xFF59D7FF),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF07111A),
        border: Border.all(color: color.withValues(alpha: 0.95)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 18),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: path != null && path.isNotEmpty
          ? Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(icon, color: color, size: size * 0.46),
            )
          : Icon(icon, color: color, size: size * 0.46),
    );
  }
}

class _CategoryHubList extends StatelessWidget {
  const _CategoryHubList({
    required this.items,
    required this.chats,
    required this.query,
    required this.onOpenCategory,
  });

  final List<LocalCategoryDetailGroupItem> items;
  final List<ImpulseChat> chats;
  final String query;
  final ValueChanged<LocalCategoryDetailGroupItem> onOpenCategory;

  @override
  Widget build(BuildContext context) {
    final normalized = query.trim().toLowerCase();
    final visible = items
        .where((item) => item.localCategoryId != null)
        .where(
          (item) =>
              normalized.isEmpty ||
              item.displayLabel.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
    if (visible.isEmpty) {
      return const _PanelEmpty(
        title: 'Keine Kategorie gefunden',
        text: 'Versuche einen anderen Suchbegriff.',
      );
    }
    return ListView.separated(
      key: const Key('impulse_inbox_category_tab_list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: visible.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _PanelIntro(
            title: 'Kategorien',
            text: 'Wähle eine Kategorie, um mit Talvori darüber zu sprechen.',
          );
        }
        final item = visible[index - 1];
        final chat = chats.cast<ImpulseChat?>().firstWhere(
          (chat) =>
              chat?.sourceType == ImpulseChatSourceType.category &&
              chat?.sourceId == item.localCategoryId,
          orElse: () => null,
        );
        return _CategoryChatTile(
          item: item,
          chat: chat,
          onTap: () => onOpenCategory(item),
        );
      },
    );
  }
}

class _CategoryChatTile extends StatelessWidget {
  const _CategoryChatTile({
    required this.item,
    required this.chat,
    required this.onTap,
  });

  final LocalCategoryDetailGroupItem item;
  final ImpulseChat? chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = chat?.enabled == true;
    final exists = chat != null;
    final statusLabel = active
        ? 'Aktiv'
        : exists
        ? 'Ausgeblendet'
        : 'Noch kein Chat';
    final actionLabel = active
        ? 'Öffnen'
        : exists
        ? 'Wieder einblenden'
        : 'Hinzufügen';
    return InkWell(
      key: Key('impulse_inbox_category_tile_${item.localCategoryId}'),
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF08111B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x2259D7FF)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x2214F1D9),
              ),
              child: const Icon(
                Icons.bubble_chart_rounded,
                color: Color(0xFF7FFFE7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.vocabsCount ?? 0} Wörter',
                    style: const TextStyle(
                      color: Color(0xFFB8C4D9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusPill(label: statusLabel),
                const SizedBox(height: 6),
                Text(
                  actionLabel,
                  style: const TextStyle(
                    color: Color(0xFF7FFFE7),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedMessagesTab extends StatelessWidget {
  const _SavedMessagesTab({required this.savedMessages, required this.onOpen});

  final List<ImpulseSavedMessage> savedMessages;
  final ValueChanged<ImpulseSavedMessage> onOpen;

  @override
  Widget build(BuildContext context) {
    if (savedMessages.isEmpty) {
      return const _PanelEmpty(
        title: 'Noch nichts gespeichert',
        text:
            'Markiere wichtige Impulse, Erklärungen oder Beispielsätze mit einem Stern.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: savedMessages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = savedMessages[index];
        return _SavedMessageTile(item: item, onTap: () => onOpen(item));
      },
    );
  }
}

class _SavedMessageTile extends StatelessWidget {
  const _SavedMessageTile({required this.item, required this.onTap});

  final ImpulseSavedMessage item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final message = item.message;
    final chat = item.chat;
    return InkWell(
      key: Key('saved_message_tile_${message.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF08111B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x2259D7FF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChatAvatar(chat: chat, size: 38),
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
                            color: Color(0xFF7FFFE7),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        _formatSavedTime(message.createdAt),
                        style: const TextStyle(
                          color: Color(0xFF7D8BA3),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _sourceLabel(chat.sourceType),
                    style: const TextStyle(
                      color: Color(0xFF7D8BA3),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, height: 1.35),
                  ),
                  if (message.reaction != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      message.reaction!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sourceLabel(ImpulseChatSourceType sourceType) {
    return switch (sourceType) {
      ImpulseChatSourceType.dailyImpulse => 'Tagesimpuls',
      ImpulseChatSourceType.category => 'Kategorie-Chat',
      ImpulseChatSourceType.favorites => 'Favoriten',
      ImpulseChatSourceType.myWords => 'Meine Wörter',
      ImpulseChatSourceType.knownWords => 'Bekannte Wörter',
      ImpulseChatSourceType.customAi => 'Eigener KI-Chat',
    };
  }

  String _formatSavedTime(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(value.year, value.month, value.day);
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    if (day == today) return time;
    if (day == today.subtract(const Duration(days: 1))) return 'Gestern';
    return '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.';
  }
}

class _YouTab extends StatelessWidget {
  const _YouTab({
    required this.profile,
    required this.activeChatCount,
    required this.hiddenChats,
    required this.onChanged,
    required this.onManageHidden,
  });

  final ImpulseAiProfile profile;
  final int activeChatCount;
  final List<ImpulseChat> hiddenChats;
  final ValueChanged<ImpulseAiProfile> onChanged;
  final VoidCallback onManageHidden;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('impulse_inbox_you_tab_list'),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        const _ProfileIntro(),
        const SizedBox(height: 14),
        _ProfileSection<ImpulseAiStyle>(
          title: 'KI-Stil',
          values: ImpulseAiStyle.values,
          selected: profile.style,
          labelOf: (value) => value.label,
          onSelected: (value) => onChanged(profile.copyWith(style: value)),
        ),
        _ProfileSection<ImpulseAnswerLength>(
          title: 'Antwortlänge',
          values: ImpulseAnswerLength.values,
          selected: profile.answerLength,
          labelOf: (value) => value.label,
          onSelected: (value) =>
              onChanged(profile.copyWith(answerLength: value)),
        ),
        _ProfileSection<ImpulseLearningGoal>(
          title: 'Lernziel',
          values: ImpulseLearningGoal.values,
          selected: profile.learningGoal,
          labelOf: (value) => value.label,
          onSelected: (value) =>
              onChanged(profile.copyWith(learningGoal: value)),
        ),
        _ProfileSection<ImpulseExplanationLanguage>(
          title: 'Erklärungssprache',
          values: ImpulseExplanationLanguage.values,
          selected: profile.explanationLanguage,
          labelOf: (value) => value.label,
          onSelected: (value) =>
              onChanged(profile.copyWith(explanationLanguage: value)),
        ),
        _ProfilePreview(profile: profile),
        const SizedBox(height: 16),
        _ChatManagementPanel(
          activeChatCount: activeChatCount,
          hiddenChatCount: hiddenChats.length,
          onManageHidden: onManageHidden,
        ),
      ],
    );
  }
}

class _ChatManagementPanel extends StatelessWidget {
  const _ChatManagementPanel({
    required this.activeChatCount,
    required this.hiddenChatCount,
    required this.onManageHidden,
  });

  final int activeChatCount;
  final int hiddenChatCount;
  final VoidCallback onManageHidden;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('chat_management_panel'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF08111B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x2259D7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chat-Verwaltung',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ChatCountPill(label: 'Aktiv', count: activeChatCount),
              const SizedBox(width: 8),
              _ChatCountPill(label: 'Ausgeblendet', count: hiddenChatCount),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            key: const Key('manage_hidden_chats_button'),
            borderRadius: BorderRadius.circular(16),
            onTap: onManageHidden,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF0A141E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x2259D7FF)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.visibility_off_rounded,
                    color: Color(0xFF7FFFE7),
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ausgeblendete Chats verwalten',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Color(0xFF7D8BA3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatCountPill extends StatelessWidget {
  const _ChatCountPill({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0A141E),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x2259D7FF)),
      ),
      child: Text(
        '$label · $count',
        style: const TextStyle(
          color: Color(0xFFC8D6E6),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ProfileIntro extends StatelessWidget {
  const _ProfileIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF08111B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x2259D7FF)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Du und Talvori',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Passe an, wie Talvori dir im Chat antwortet.',
            style: TextStyle(color: Color(0xFF9FB0C7), height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection<T> extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final String title;
  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF7D8BA3),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in values)
                ChoiceChip(
                  key: Key('ai_profile_${title}_$value'),
                  label: Text(labelOf(value)),
                  selected: value == selected,
                  onSelected: (_) => onSelected(value),
                  selectedColor: const Color(0xFF0F5D4A),
                  backgroundColor: const Color(0xFF0A141E),
                  side: BorderSide(
                    color: value == selected
                        ? const Color(0xFF7FFFE7)
                        : const Color(0x2259D7FF),
                  ),
                  labelStyle: TextStyle(
                    color: value == selected
                        ? Colors.white
                        : const Color(0xFFC8D6E6),
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfilePreview extends StatelessWidget {
  const _ProfilePreview({required this.profile});

  final ImpulseAiProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF08111B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x2259D7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'So antwortet Talvori ungefähr:',
            style: TextStyle(
              color: Color(0xFF7FFFE7),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _previewText(profile),
            style: const TextStyle(color: Colors.white, height: 1.35),
          ),
        ],
      ),
    );
  }

  String _previewText(ImpulseAiProfile profile) {
    final tone = switch (profile.style) {
      ImpulseAiStyle.direct => 'Kurz gesagt:',
      ImpulseAiStyle.motivating => 'Stark, das packen wir:',
      ImpulseAiStyle.casual => 'Easy, schauen wir kurz drauf:',
      ImpulseAiStyle.trainer => 'Trainer-Modus:',
    };
    final goal = profile.learningGoal.label.toLowerCase();
    final length = profile.answerLength == ImpulseAnswerLength.short
        ? 'in einem knackigen Satz'
        : profile.answerLength == ImpulseAnswerLength.detailed
        ? 'mit Erklärung und Beispiel'
        : 'mit einem klaren Beispiel';
    return '$tone Ich helfe dir $length für dein Ziel $goal.';
  }
}

class _InboxBottomTabs extends StatelessWidget {
  const _InboxBottomTabs({required this.selected, required this.onChanged});

  final _InboxTab selected;
  final ValueChanged<_InboxTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      decoration: const BoxDecoration(
        color: Color(0xFF050A12),
        border: Border(top: BorderSide(color: Color(0x1F59D7FF))),
      ),
      child: Row(
        children: [
          _TabButton(
            selected: selected == _InboxTab.chats,
            icon: Icons.chat_bubble_rounded,
            label: 'Chats',
            onTap: () => onChanged(_InboxTab.chats),
          ),
          _TabButton(
            selected: selected == _InboxTab.categories,
            icon: Icons.category_rounded,
            label: 'Kategorien',
            onTap: () => onChanged(_InboxTab.categories),
          ),
          _TabButton(
            selected: selected == _InboxTab.saved,
            icon: Icons.star_rounded,
            label: 'Gespeichert',
            onTap: () => onChanged(_InboxTab.saved),
          ),
          _TabButton(
            selected: selected == _InboxTab.you,
            icon: Icons.person_rounded,
            label: 'Du',
            onTap: () => onChanged(_InboxTab.you),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected
                    ? const Color(0xFF7FFFE7)
                    : const Color(0xFF7D8BA3),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF7FFFE7)
                      : const Color(0xFF7D8BA3),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddChatSheet extends StatelessWidget {
  const _AddChatSheet({
    required this.onCategories,
    required this.onCustomChat,
    required this.onDailyImpulse,
  });

  final VoidCallback onCategories;
  final VoidCallback onCustomChat;
  final VoidCallback onDailyImpulse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF101923),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0x2259D7FF)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AddChatOption(
                  key: const Key('add_category_chat_option'),
                  icon: Icons.category_rounded,
                  title: 'Kategorie-Chat hinzufügen',
                  text: 'Wähle eine Wortwelt für einen eigenen Chat.',
                  onTap: onCategories,
                ),
                _AddChatOption(
                  key: const Key('add_custom_ai_chat_option'),
                  icon: Icons.psychology_alt_rounded,
                  title: 'Eigenen KI-Chat erstellen',
                  text: 'Starte einen lokalen Chat mit eigenem Thema.',
                  onTap: onCustomChat,
                ),
                _AddChatOption(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Tagesimpuls öffnen',
                  text: 'Zurück zum Tagesimpuls-Verlauf.',
                  onTap: onDailyImpulse,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HiddenChatsSheet extends StatelessWidget {
  const _HiddenChatsSheet({
    required this.hiddenChats,
    required this.onReactivate,
    required this.onDeleteCustom,
  });

  final List<ImpulseChat> hiddenChats;
  final ValueChanged<ImpulseChat> onReactivate;
  final ValueChanged<ImpulseChat> onDeleteCustom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF101923),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0x2259D7FF)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ausgeblendete Chats',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Verläufe bleiben lokal erhalten.',
                  style: TextStyle(color: Color(0xFF9FB0C7)),
                ),
                const SizedBox(height: 14),
                if (hiddenChats.isEmpty)
                  const _PanelEmpty(
                    title: 'Keine ausgeblendeten Chats',
                    text:
                        'Ausgeblendete Kategorie- und eigene Chats erscheinen hier.',
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      key: const Key('hidden_chats_list'),
                      shrinkWrap: true,
                      itemCount: hiddenChats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final chat = hiddenChats[index];
                        return _HiddenChatTile(
                          chat: chat,
                          onReactivate: () => onReactivate(chat),
                          onDeleteCustom:
                              chat.sourceType == ImpulseChatSourceType.customAi
                              ? () => onDeleteCustom(chat)
                              : null,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HiddenChatTile extends StatelessWidget {
  const _HiddenChatTile({
    required this.chat,
    required this.onReactivate,
    this.onDeleteCustom,
  });

  final ImpulseChat chat;
  final VoidCallback onReactivate;
  final VoidCallback? onDeleteCustom;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('hidden_chat_tile_${chat.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF08111B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x2259D7FF)),
      ),
      child: Row(
        children: [
          _ChatAvatar(chat: chat, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  chat.sourceType == ImpulseChatSourceType.category
                      ? 'Kategorie-Chat'
                      : 'Eigener KI-Chat',
                  style: const TextStyle(
                    color: Color(0xFF9FB0C7),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            key: Key('hidden_chat_reactivate_${chat.id}'),
            onPressed: onReactivate,
            child: const Text('Wieder einblenden'),
          ),
          if (onDeleteCustom != null)
            IconButton(
              key: Key('hidden_chat_delete_${chat.id}'),
              tooltip: 'Lokal löschen',
              onPressed: onDeleteCustom,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFFF7A8A),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddChatOption extends StatelessWidget {
  const _AddChatOption({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      leading: Icon(icon, color: const Color(0xFF7FFFE7)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(text, style: const TextStyle(color: Color(0xFFB8C4D9))),
      onTap: onTap,
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0x2214F1D9),
        border: Border.all(color: const Color(0x4459D7FF)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF7FFFE7),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty();

  @override
  Widget build(BuildContext context) {
    return const _PanelEmpty(
      title: 'Nichts gefunden',
      text: 'Versuche einen anderen Suchbegriff.',
    );
  }
}

class _PanelIntro extends StatelessWidget {
  const _PanelIntro({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFB8C4D9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelEmpty extends StatelessWidget {
  const _PanelEmpty({required this.title, required this.text});

  final String title;
  final String text;

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
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
