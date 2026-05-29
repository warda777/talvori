import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talvori/core/assets/talvori_mascot_assets.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';
import 'package:talvori/core/local_database/providers/local_category_detail_group_items_provider.dart';
import 'package:talvori/core/ui/talvori_snackbar.dart';
import 'package:talvori/features/companion/domain/companion_chat_constants.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_ai_profile.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_saved_message.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impulse_chat_detail_screen.dart';

enum _InboxTab { chats, categories, saved, you }

enum _ChatFilter {
  all,
  favorites,
  unread,
  dailyImpulse,
  categories,
  customAi,
  saved,
}

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

    return PopScope(
      canPop: _tab == _InboxTab.chats,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _tab == _InboxTab.chats) return;
        setState(() => _tab = _InboxTab.chats);
      },
      child: Scaffold(
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
                'Talvori Chat',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                'Dein Ort für Tali, Wortwelten und fokussierte Lernchats.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
              onPressed: _showCreateCustomChatDialog,
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
                            onLongPress: _openChatActionsSheet,
                            onMore: _openChatMoreSheet,
                            onHide: _hideChatFromList,
                            onMarkRead: _markChatReadFromList,
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
                    favoriteChats: state.chats
                        .where((chat) => chat.isFavorite)
                        .toList(growable: false),
                    onOpenFavorite: _openChat,
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
    final filtered = chats
        .where(
          (chat) => switch (filter) {
            _ChatFilter.all => true,
            _ChatFilter.favorites => chat.isFavorite,
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
    if (filter != _ChatFilter.all) return filtered;
    return [...filtered]..sort((a, b) {
      if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
      return _chatSortDate(b).compareTo(_chatSortDate(a));
    });
  }

  void _openChat(ImpulseChat chat, {String? initialMessageId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImpulseChatDetailScreen(
          chatId: chat.id,
          initialMessageId: initialMessageId,
        ),
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
    if (chat.sourceType != ImpulseChatSourceType.customAi) return;
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
    if (!mounted) return;
    _showImpulseToast('Chat gelöscht', icon: Icons.delete_outline_rounded);
  }

  Future<void> _openChatActionsSheet(ImpulseChat chat) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ChatActionsSheet(
        chat: chat,
        onOpen: () {
          Navigator.of(sheetContext).pop();
          _openChat(chat);
        },
        onMarkRead: chat.unreadCount > 0
            ? () async {
                Navigator.of(sheetContext).pop();
                await _markChatReadFromList(chat);
              }
            : null,
        onHide: _canHideChat(chat)
            ? () async {
                Navigator.of(sheetContext).pop();
                await _hideChatFromList(chat);
              }
            : null,
        onRename: chat.sourceType == ImpulseChatSourceType.customAi
            ? () {
                Navigator.of(sheetContext).pop();
                _renameCustomChat(chat);
              }
            : null,
        onMore: () {
          Navigator.of(sheetContext).pop();
          _openChatMoreSheet(chat);
        },
        onFavorite: () {
          Navigator.of(sheetContext).pop();
          _toggleChatFavorite(chat);
        },
        onMute: () {
          Navigator.of(sheetContext).pop();
          _toggleChatMuted(chat);
        },
        onAiPreferences: () {
          Navigator.of(sheetContext).pop();
          _openChatAiPreferencesSheet(chat);
        },
      ),
    );
  }

  Future<void> _openChatMoreSheet(ImpulseChat chat) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ChatMoreActionsSheet(
        chat: chat,
        onOpen: () {
          Navigator.of(sheetContext).pop();
          _openChat(chat);
        },
        onMarkRead: chat.unreadCount > 0
            ? () async {
                Navigator.of(sheetContext).pop();
                await _markChatReadFromList(chat);
              }
            : null,
        onHide: _canHideChat(chat)
            ? () async {
                Navigator.of(sheetContext).pop();
                await _hideChatFromList(chat);
              }
            : null,
        onRename: chat.sourceType == ImpulseChatSourceType.customAi
            ? () {
                Navigator.of(sheetContext).pop();
                _renameCustomChat(chat);
              }
            : null,
        onChangeImage:
            chat.sourceType == ImpulseChatSourceType.category ||
                chat.sourceType == ImpulseChatSourceType.customAi
            ? () {
                Navigator.of(sheetContext).pop();
                _pickAvatarImage(chat);
              }
            : null,
        onClear: chat.sourceType == ImpulseChatSourceType.customAi
            ? () {
                Navigator.of(sheetContext).pop();
                _confirmClearCustomChat(chat);
              }
            : null,
        onDelete: chat.sourceType == ImpulseChatSourceType.customAi
            ? () {
                Navigator.of(sheetContext).pop();
                _confirmDeleteCustomChat(chat);
              }
            : null,
        onSaved: () {
          Navigator.of(sheetContext).pop();
          _openChatSavedMessagesSheet(chat);
        },
        onMute: () {
          Navigator.of(sheetContext).pop();
          _toggleChatMuted(chat);
        },
        onInfo: () {
          Navigator.of(sheetContext).pop();
          _openChatInfoSheet(chat);
        },
        onAiPreferences: () {
          Navigator.of(sheetContext).pop();
          _openChatAiPreferencesSheet(chat);
        },
      ),
    );
  }

  Future<void> _toggleChatMuted(ImpulseChat chat) async {
    await ref
        .read(impulseInboxControllerProvider.notifier)
        .toggleChatMuted(chat);
    if (!mounted) return;
    _showImpulseToast(
      chat.isMuted ? 'Stumm aus' : 'Chat stumm geschaltet',
      icon: chat.isMuted
          ? Icons.notifications_active_rounded
          : Icons.notifications_off_rounded,
    );
  }

  Future<void> _toggleChatFavorite(ImpulseChat chat) async {
    await ref
        .read(impulseInboxControllerProvider.notifier)
        .toggleChatFavorite(chat);
    if (!mounted) return;
    _showImpulseToast(
      chat.isFavorite ? 'Favorit entfernt' : 'Favorit gesetzt',
      icon: chat.isFavorite ? Icons.star_border_rounded : Icons.star_rounded,
    );
  }

  Future<void> _openChatSavedMessagesSheet(ImpulseChat chat) async {
    final saved = await ref
        .read(impulseInboxControllerProvider.notifier)
        .loadStarredMessagesForChat(chat.id);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ChatSavedMessagesSheet(
        chat: chat,
        savedMessages: saved,
        onOpen: (item) {
          Navigator.of(sheetContext).pop();
          _openChat(item.chat, initialMessageId: item.message.id);
        },
      ),
    );
  }

  Future<void> _openChatInfoSheet(ImpulseChat chat) async {
    final messages = await ref
        .read(impulseInboxControllerProvider.notifier)
        .loadMessages(chat.id);
    final saved = await ref
        .read(impulseInboxControllerProvider.notifier)
        .loadStarredMessagesForChat(chat.id);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ChatInfoSheet(
        chat: chat,
        messageCount: messages.length,
        savedCount: saved.length,
        globalProfile: ref.read(impulseInboxControllerProvider).aiProfile,
        onRename: chat.sourceType == ImpulseChatSourceType.customAi
            ? () {
                Navigator.of(sheetContext).pop();
                _renameCustomChat(chat);
              }
            : null,
        onAiPreferences: () {
          Navigator.of(sheetContext).pop();
          _openChatAiPreferencesSheet(chat);
        },
      ),
    );
  }

  Future<void> _openChatAiPreferencesSheet(ImpulseChat chat) {
    final globalProfile = ref.read(impulseInboxControllerProvider).aiProfile;
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ChatAiPreferencesSheet(
        chat: chat,
        globalProfile: globalProfile,
        onSave: (override) async {
          await ref
              .read(impulseInboxControllerProvider.notifier)
              .updateChatAiProfileOverride(chatId: chat.id, override: override);
          if (!mounted || !sheetContext.mounted) return;
          Navigator.of(sheetContext).pop();
          _showImpulseToast('Chat-KI-Stil gespeichert', icon: Icons.tune);
        },
        onReset: () async {
          await ref
              .read(impulseInboxControllerProvider.notifier)
              .resetChatAiProfileOverride(chat.id);
          if (!mounted || !sheetContext.mounted) return;
          Navigator.of(sheetContext).pop();
          _showImpulseToast('Globaler KI-Standard aktiv', icon: Icons.public);
        },
      ),
    );
  }

  Future<void> _markChatReadFromList(ImpulseChat chat) async {
    await ref
        .read(impulseInboxControllerProvider.notifier)
        .markChatRead(chat.id);
    if (!mounted) return;
    _showImpulseToast(
      'Chat als gelesen markiert',
      icon: Icons.mark_chat_read_rounded,
    );
  }

  Future<void> _hideChatFromList(ImpulseChat chat) async {
    if (!_canHideChat(chat)) return;
    await ref
        .read(impulseInboxControllerProvider.notifier)
        .setChatEnabled(chatId: chat.id, enabled: false);
    if (!mounted) return;
    _showImpulseToast('Chat ausgeblendet', icon: Icons.visibility_off_rounded);
  }

  Future<void> _renameCustomChat(ImpulseChat chat) async {
    if (chat.sourceType != ImpulseChatSourceType.customAi) return;
    final controller = TextEditingController(text: chat.title);
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101923),
        title: const Text(
          'Eigenen Chat umbenennen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: TextField(
          key: const Key('custom_chat_rename_field'),
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
            key: const Key('custom_chat_rename_confirm_button'),
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    final normalized = title?.trim();
    if (normalized == null || normalized.isEmpty) return;
    await ref
        .read(impulseInboxControllerProvider.notifier)
        .renameCustomAiChat(chatId: chat.id, title: normalized);
    if (!mounted) return;
    _showImpulseToast('Chat umbenannt', icon: Icons.edit_rounded);
  }

  Future<void> _confirmClearCustomChat(ImpulseChat chat) async {
    if (chat.sourceType != ImpulseChatSourceType.customAi) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101923),
        title: const Text(
          'Chat leeren?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Alle lokalen Nachrichten in diesem Chat werden gelöscht. Der Chat bleibt erhalten.',
          style: TextStyle(color: Color(0xFFB8C4D9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            key: const Key('custom_chat_clear_confirm_button'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leeren'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(impulseInboxControllerProvider.notifier)
        .clearCustomAiChatMessages(chat.id);
    if (!mounted) return;
    _showImpulseToast('Chat geleert', icon: Icons.cleaning_services_rounded);
  }

  Future<void> _pickAvatarImage(ImpulseChat chat) async {
    if (chat.sourceType == ImpulseChatSourceType.dailyImpulse) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 82,
    );
    if (picked == null) return;
    await ref
        .read(impulseInboxControllerProvider.notifier)
        .updateChatAvatarImagePath(chatId: chat.id, imagePath: picked.path);
    if (!mounted) return;
    _showImpulseToast('Bild geändert', icon: Icons.image_rounded);
  }

  bool _canHideChat(ImpulseChat chat) {
    return chat.sourceType == ImpulseChatSourceType.category ||
        chat.sourceType == ImpulseChatSourceType.customAi;
  }

  void _showImpulseToast(
    String message, {
    IconData icon = Icons.check_rounded,
  }) {
    TalvoriSnackBar.show(
      context,
      key: const Key('impulse_toast'),
      message: message,
      type: TalvoriSnackBarType.success,
      icon: icon,
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 104),
    );
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
    required this.onLongPress,
    required this.onMore,
    required this.onHide,
    required this.onMarkRead,
  });

  final List<ImpulseChat> chats;
  final _ChatFilter selectedFilter;
  final String query;
  final ValueChanged<_ChatFilter> onFilterChanged;
  final ValueChanged<ImpulseChat> onOpen;
  final ValueChanged<ImpulseChat> onLongPress;
  final ValueChanged<ImpulseChat> onMore;
  final ValueChanged<ImpulseChat> onHide;
  final ValueChanged<ImpulseChat> onMarkRead;

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
              : _ChatList(
                  chats: chats,
                  onOpen: onOpen,
                  onLongPress: onLongPress,
                  onMore: onMore,
                  onHide: onHide,
                  onMarkRead: onMarkRead,
                ),
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
    _ChatFilter.favorites => 'Favoriten',
    _ChatFilter.unread => 'Ungelesen',
    _ChatFilter.dailyImpulse => 'Tagesimpuls',
    _ChatFilter.categories => 'Kategorien',
    _ChatFilter.customAi => 'Eigene Chats',
    _ChatFilter.saved => 'Gespeichert',
  };

  String get emptyTitle => switch (this) {
    _ChatFilter.all => 'Noch keine Chats',
    _ChatFilter.favorites => 'Keine Favoriten',
    _ChatFilter.unread => 'Keine ungelesenen Chats',
    _ChatFilter.dailyImpulse => 'Kein Tagesimpuls-Chat',
    _ChatFilter.categories => 'Keine Kategorie-Chats',
    _ChatFilter.customAi => 'Keine eigenen Chats',
    _ChatFilter.saved => 'Keine gespeicherten Nachrichten in Chats',
  };

  String get emptyText => switch (this) {
    _ChatFilter.all =>
      'Erstelle einen Kategorie-Chat oder starte mit deinem Tagesimpuls.',
    _ChatFilter.favorites =>
      'Markiere wichtige Chats als Favorit, damit du sie schneller wiederfindest.',
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
  const _ChatList({
    required this.chats,
    required this.onOpen,
    required this.onLongPress,
    required this.onMore,
    required this.onHide,
    required this.onMarkRead,
  });

  final List<ImpulseChat> chats;
  final ValueChanged<ImpulseChat> onOpen;
  final ValueChanged<ImpulseChat> onLongPress;
  final ValueChanged<ImpulseChat> onMore;
  final ValueChanged<ImpulseChat> onHide;
  final ValueChanged<ImpulseChat> onMarkRead;

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
        return _ChatTile(
          chat: chats[index - 1],
          onOpen: onOpen,
          onLongPress: onLongPress,
          onMore: onMore,
          onHide: onHide,
          onMarkRead: onMarkRead,
        );
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

class _ChatTile extends StatefulWidget {
  const _ChatTile({
    required this.chat,
    required this.onOpen,
    required this.onLongPress,
    required this.onMore,
    required this.onHide,
    required this.onMarkRead,
  });

  final ImpulseChat chat;
  final ValueChanged<ImpulseChat> onOpen;
  final ValueChanged<ImpulseChat> onLongPress;
  final ValueChanged<ImpulseChat> onMore;
  final ValueChanged<ImpulseChat> onHide;
  final ValueChanged<ImpulseChat> onMarkRead;

  @override
  State<_ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<_ChatTile> {
  bool _actionsOpen = false;

  bool get _canHide =>
      widget.chat.sourceType == ImpulseChatSourceType.category ||
      widget.chat.sourceType == ImpulseChatSourceType.customAi;

  int get _actionCount =>
      1 + (_canHide ? 1 : 0) + (widget.chat.unreadCount > 0 ? 1 : 0);

  double get _actionWidth => _actionCount * 82 + 14;

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final actionWidth = _actionWidth;
    return GestureDetector(
      key: Key('impulse_chat_swipe_area_${chat.id}'),
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < -2 && !_actionsOpen) {
          setState(() => _actionsOpen = true);
        } else if (details.delta.dx > 2 && _actionsOpen) {
          setState(() => _actionsOpen = false);
        }
      },
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -80) {
          setState(() => _actionsOpen = true);
        } else if (velocity > 80) {
          setState(() => _actionsOpen = false);
        }
      },
      child: Stack(
        alignment: Alignment.centerRight,
        clipBehavior: Clip.hardEdge,
        children: [
          if (_actionsOpen)
            Positioned.fill(
              right: 0,
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: actionWidth,
                  child: _SwipeActions(chat: chat, actionWidth: actionWidth),
                ),
              ),
            ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(
              right: _actionsOpen ? actionWidth + 12 : 0,
            ),
            child: Material(
              color: const Color(0xFF050A12),
              child: InkWell(
                key: Key('impulse_chat_tile_${chat.id}'),
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  if (_actionsOpen) {
                    setState(() => _actionsOpen = false);
                    return;
                  }
                  widget.onOpen(chat);
                },
                onLongPress: () => widget.onLongPress(chat),
                child: _ChatTileContent(chat: chat),
              ),
            ),
          ),
          if (_actionsOpen)
            Positioned(
              right: 7,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (chat.unreadCount > 0)
                    _SwipeActionButton(
                      key: Key('chat_swipe_read_${chat.id}'),
                      icon: Icons.mark_chat_read_rounded,
                      label: 'Gelesen',
                      color: const Color(0xFF59D7FF),
                      onTap: () {
                        setState(() => _actionsOpen = false);
                        widget.onMarkRead(chat);
                      },
                    ),
                  if (_canHide)
                    _SwipeActionButton(
                      key: Key('chat_swipe_hide_${chat.id}'),
                      icon: Icons.archive_rounded,
                      label: 'Ausbl.',
                      color: const Color(0xFFFFD166),
                      onTap: () {
                        setState(() => _actionsOpen = false);
                        widget.onHide(chat);
                      },
                    ),
                  _SwipeActionButton(
                    key: Key('chat_swipe_more_${chat.id}'),
                    icon: Icons.more_horiz_rounded,
                    label: 'Mehr',
                    color: const Color(0xFF7FFFE7),
                    onTap: () {
                      setState(() => _actionsOpen = false);
                      widget.onMore(chat);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatTileContent extends StatelessWidget {
  const _ChatTileContent({required this.chat});

  final ImpulseChat chat;

  @override
  Widget build(BuildContext context) {
    final lastMessage = chat.lastMessageText?.trim();
    return Padding(
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
                    if (chat.isFavorite) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.star_rounded,
                        key: Key('chat_favorite_indicator_${chat.id}'),
                        color: const Color(0xFFFFD166),
                        size: 15,
                      ),
                    ],
                    if (chat.isMuted) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.notifications_off_rounded,
                        key: Key('chat_muted_indicator_${chat.id}'),
                        color: const Color(0xFF7D8BA3),
                        size: 15,
                      ),
                    ],
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

class _SwipeActions extends StatelessWidget {
  const _SwipeActions({required this.chat, required this.actionWidth});

  final ImpulseChat chat;
  final double actionWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('chat_swipe_actions_${chat.id}'),
      width: actionWidth,
      height: 72,
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF08111B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x2259D7FF)),
      ),
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 76,
          height: 58,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.42)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: TextStyle(
                  color: color,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatActionsSheet extends StatelessWidget {
  const _ChatActionsSheet({
    required this.chat,
    required this.onOpen,
    required this.onMore,
    required this.onFavorite,
    required this.onMute,
    required this.onAiPreferences,
    this.onMarkRead,
    this.onHide,
    this.onRename,
  });

  final ImpulseChat chat;
  final VoidCallback onOpen;
  final VoidCallback? onMarkRead;
  final VoidCallback? onHide;
  final VoidCallback? onRename;
  final VoidCallback onMore;
  final VoidCallback onFavorite;
  final VoidCallback onMute;
  final VoidCallback onAiPreferences;

  @override
  Widget build(BuildContext context) {
    return _ChatActionSheetFrame(
      key: Key('chat_actions_sheet_${chat.id}'),
      chat: chat,
      title: 'Chat-Aktionen',
      children: [
        _ChatActionRow(
          key: Key('chat_action_open_${chat.id}'),
          icon: Icons.open_in_new_rounded,
          label: 'Öffnen',
          onTap: onOpen,
        ),
        if (onMarkRead != null)
          _ChatActionRow(
            key: Key('chat_action_read_${chat.id}'),
            icon: Icons.mark_chat_read_rounded,
            label: 'Als gelesen markieren',
            onTap: onMarkRead!,
          ),
        _ChatActionRow(
          key: Key('chat_action_favorite_${chat.id}'),
          icon: chat.isFavorite
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          label: chat.isFavorite
              ? 'Aus Favoriten entfernen'
              : 'Zu Favoriten hinzufügen',
          onTap: onFavorite,
        ),
        _ChatActionRow(
          key: Key('chat_action_mute_${chat.id}'),
          icon: chat.isMuted
              ? Icons.notifications_active_rounded
              : Icons.notifications_off_outlined,
          label: chat.isMuted ? 'Stumm aus' : 'Chat stumm schalten',
          onTap: onMute,
        ),
        _ChatActionRow(
          key: Key('chat_action_ai_preferences_${chat.id}'),
          icon: Icons.tune_rounded,
          label: 'KI-Stil anpassen',
          onTap: onAiPreferences,
        ),
        if (onRename != null)
          _ChatActionRow(
            key: Key('chat_action_rename_${chat.id}'),
            icon: Icons.edit_rounded,
            label: 'Umbenennen',
            onTap: onRename!,
          ),
        if (onHide != null)
          _ChatActionRow(
            key: Key('chat_action_hide_${chat.id}'),
            icon: Icons.visibility_off_rounded,
            label: chat.sourceType == ImpulseChatSourceType.category
                ? 'Kategorie-Chat ausblenden'
                : 'Chat ausblenden',
            onTap: onHide!,
          ),
        _ChatActionRow(
          key: Key('chat_action_more_${chat.id}'),
          icon: Icons.more_horiz_rounded,
          label: 'Mehr ...',
          onTap: onMore,
        ),
      ],
    );
  }
}

class _ChatMoreActionsSheet extends StatelessWidget {
  const _ChatMoreActionsSheet({
    required this.chat,
    required this.onOpen,
    required this.onSaved,
    required this.onMute,
    required this.onInfo,
    required this.onAiPreferences,
    this.onMarkRead,
    this.onHide,
    this.onRename,
    this.onChangeImage,
    this.onClear,
    this.onDelete,
  });

  final ImpulseChat chat;
  final VoidCallback onOpen;
  final VoidCallback? onMarkRead;
  final VoidCallback? onHide;
  final VoidCallback? onRename;
  final VoidCallback? onChangeImage;
  final VoidCallback? onClear;
  final VoidCallback? onDelete;
  final VoidCallback onSaved;
  final VoidCallback onMute;
  final VoidCallback onInfo;
  final VoidCallback onAiPreferences;

  @override
  Widget build(BuildContext context) {
    return _ChatActionSheetFrame(
      key: Key('chat_more_actions_sheet_${chat.id}'),
      chat: chat,
      title: 'Mehr',
      children: [
        _ChatActionRow(
          key: Key('chat_more_open_${chat.id}'),
          icon: Icons.open_in_new_rounded,
          label: 'Öffnen',
          onTap: onOpen,
        ),
        if (onRename != null)
          _ChatActionRow(
            key: Key('chat_more_rename_${chat.id}'),
            icon: Icons.edit_rounded,
            label: 'Umbenennen',
            onTap: onRename!,
          ),
        if (onChangeImage != null)
          _ChatActionRow(
            key: Key('chat_more_image_${chat.id}'),
            icon: Icons.image_rounded,
            label: 'Bild ändern',
            onTap: onChangeImage!,
          ),
        if (onMarkRead != null)
          _ChatActionRow(
            key: Key('chat_more_read_${chat.id}'),
            icon: Icons.mark_chat_read_rounded,
            label: 'Als gelesen markieren',
            onTap: onMarkRead!,
          ),
        if (onHide != null)
          _ChatActionRow(
            key: Key('chat_more_hide_${chat.id}'),
            icon: Icons.visibility_off_rounded,
            label: chat.sourceType == ImpulseChatSourceType.category
                ? 'Kategorie-Chat ausblenden'
                : 'Chat ausblenden',
            onTap: onHide!,
          ),
        if (onClear != null)
          _ChatActionRow(
            key: Key('chat_more_clear_${chat.id}'),
            icon: Icons.cleaning_services_rounded,
            label: 'Chat leeren',
            onTap: onClear!,
          ),
        _ChatActionRow(
          key: Key('chat_more_saved_${chat.id}'),
          icon: Icons.star_rounded,
          label: 'Gespeicherte Nachrichten anzeigen',
          onTap: onSaved,
        ),
        _ChatActionRow(
          key: Key('chat_more_mute_${chat.id}'),
          icon: chat.isMuted
              ? Icons.notifications_active_rounded
              : Icons.notifications_off_outlined,
          label: chat.isMuted ? 'Stumm aus' : 'Stumm schalten',
          onTap: onMute,
        ),
        _ChatActionRow(
          key: Key('chat_more_ai_preferences_${chat.id}'),
          icon: Icons.tune_rounded,
          label: 'KI-Stil für diesen Chat',
          onTap: onAiPreferences,
        ),
        _ChatActionRow(
          key: Key('chat_more_info_${chat.id}'),
          icon: Icons.info_outline_rounded,
          label: 'Chatinfo',
          onTap: onInfo,
        ),
        if (onDelete != null)
          _ChatActionRow(
            key: Key('chat_more_delete_${chat.id}'),
            icon: Icons.delete_outline_rounded,
            label: 'Chat lokal löschen',
            destructive: true,
            onTap: onDelete!,
          ),
      ],
    );
  }
}

class _ChatActionSheetFrame extends StatelessWidget {
  const _ChatActionSheetFrame({
    super.key,
    required this.chat,
    required this.title,
    required this.children,
  });

  final ImpulseChat chat;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.86;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xF20A111A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x2259D7FF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 36,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0x3359D7FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
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
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Color(0xFF7D8BA3),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF101923),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0x1F59D7FF)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < children.length; i++) ...[
                            if (i > 0)
                              const Divider(
                                height: 1,
                                color: Color(0x1839D8D8),
                              ),
                            children[i],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatActionRow extends StatelessWidget {
  const _ChatActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFFF7A88) : Colors.white;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(icon, color: color, size: 21),
          ],
        ),
      ),
    );
  }
}

class _ChatSavedMessagesSheet extends StatelessWidget {
  const _ChatSavedMessagesSheet({
    required this.chat,
    required this.savedMessages,
    required this.onOpen,
  });

  final ImpulseChat chat;
  final List<ImpulseSavedMessage> savedMessages;
  final ValueChanged<ImpulseSavedMessage> onOpen;

  @override
  Widget build(BuildContext context) {
    final content = savedMessages.isEmpty
        ? const [
            Padding(
              padding: EdgeInsets.all(18),
              child: _PanelEmpty(
                title: 'Keine gespeicherten Nachrichten in diesem Chat.',
                text: 'Markiere wichtige Nachrichten mit einem Stern.',
              ),
            ),
          ]
        : savedMessages
              .map<Widget>(
                (item) => _SavedMessageMiniTile(
                  key: Key('chat_saved_message_${item.message.id}'),
                  item: item,
                  onTap: () => onOpen(item),
                ),
              )
              .toList(growable: false);
    return _ChatActionSheetFrame(
      key: Key('chat_saved_messages_sheet_${chat.id}'),
      chat: chat,
      title: 'Gespeicherte Nachrichten',
      children: content,
    );
  }
}

class _SavedMessageMiniTile extends StatelessWidget {
  const _SavedMessageMiniTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final ImpulseSavedMessage item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final message = item.message;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCompactDateTime(message.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF7D8BA3),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (message.reaction != null) ...[
              const SizedBox(width: 8),
              Text(message.reaction!, style: const TextStyle(fontSize: 18)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChatInfoSheet extends StatelessWidget {
  const _ChatInfoSheet({
    required this.chat,
    required this.messageCount,
    required this.savedCount,
    required this.globalProfile,
    required this.onAiPreferences,
    this.onRename,
  });

  final ImpulseChat chat;
  final int messageCount;
  final int savedCount;
  final ImpulseAiProfile globalProfile;
  final VoidCallback onAiPreferences;
  final VoidCallback? onRename;

  @override
  Widget build(BuildContext context) {
    return _ChatActionSheetFrame(
      key: Key('chat_info_sheet_${chat.id}'),
      chat: chat,
      title: 'Chatinfo',
      children: [
        _ChatInfoRow(label: 'Typ', value: _chatTypeLabel(chat.sourceType)),
        _ChatInfoRow(
          label: 'Erstellt',
          value: _formatCompactDateTime(chat.createdAt),
        ),
        _ChatInfoRow(
          label: 'Letzte Nachricht',
          value: chat.lastMessageAt == null
              ? 'Noch keine'
              : _formatCompactDateTime(chat.lastMessageAt!),
        ),
        _ChatInfoRow(label: 'Nachrichten', value: '$messageCount lokal'),
        _ChatInfoRow(label: 'Gespeichert', value: '$savedCount'),
        _ChatInfoRow(
          label: 'Status',
          value: chat.enabled ? 'Aktiv' : 'Ausgeblendet',
        ),
        _ChatInfoRow(label: 'Stumm', value: chat.isMuted ? 'Ja' : 'Nein'),
        _ChatInfoRow(label: 'Favorit', value: chat.isFavorite ? 'Ja' : 'Nein'),
        _ChatInfoRow(
          label: 'KI-Stil',
          value: chat.hasAiProfileOverride ? 'Eigene Einstellungen' : 'Global',
        ),
        if (chat.hasAiProfileOverride)
          _ChatInfoRow(
            label: 'Chat-KI',
            value: chat.aiProfileOverride.compactSummary(globalProfile),
          ),
        if (chat.sourceType == ImpulseChatSourceType.category) ...[
          _ChatInfoRow(label: 'Kategorie', value: chat.title),
          _ChatInfoRow(
            label: 'Kategorie-ID',
            value: chat.sourceId == null || chat.sourceId!.isEmpty
                ? '-'
                : chat.sourceId!,
          ),
          const _ChatInfoNote(
            text: 'Kategorie-Wörter werden nur lesend als KI-Kontext genutzt.',
          ),
        ],
        if (chat.sourceType == ImpulseChatSourceType.dailyImpulse)
          const _ChatInfoNote(
            text:
                'Tagesimpulse werden lokal gespeichert und über lokale Notifications geöffnet.',
          ),
        const _ChatInfoNote(
          text: 'Dieser Verlauf ist lokal auf diesem Gerät gespeichert.',
        ),
        if (onRename != null)
          _ChatActionRow(
            key: Key('chat_info_rename_${chat.id}'),
            icon: Icons.edit_rounded,
            label: 'Umbenennen',
            onTap: onRename!,
          ),
        _ChatActionRow(
          key: Key('chat_info_ai_preferences_${chat.id}'),
          icon: Icons.tune_rounded,
          label: 'KI-Stil anpassen',
          onTap: onAiPreferences,
        ),
      ],
    );
  }
}

class _ChatInfoRow extends StatelessWidget {
  const _ChatInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8EA0B8),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInfoNote extends StatelessWidget {
  const _ChatInfoNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFB8C4D9),
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }
}

class _ChatAiPreferencesSheet extends StatefulWidget {
  const _ChatAiPreferencesSheet({
    required this.chat,
    required this.globalProfile,
    required this.onSave,
    required this.onReset,
  });

  final ImpulseChat chat;
  final ImpulseAiProfile globalProfile;
  final ValueChanged<ImpulseChatAiProfileOverride> onSave;
  final VoidCallback onReset;

  @override
  State<_ChatAiPreferencesSheet> createState() =>
      _ChatAiPreferencesSheetState();
}

class _ChatAiPreferencesSheetState extends State<_ChatAiPreferencesSheet> {
  ImpulseAiStyle? _style;
  ImpulseAnswerLength? _answerLength;
  ImpulseLearningGoal? _learningGoal;
  ImpulseExplanationLanguage? _explanationLanguage;

  @override
  void initState() {
    super.initState();
    _style = widget.chat.aiProfileOverride.style;
    _answerLength = widget.chat.aiProfileOverride.answerLength;
    _learningGoal = widget.chat.aiProfileOverride.learningGoal;
    _explanationLanguage = widget.chat.aiProfileOverride.explanationLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final override = ImpulseChatAiProfileOverride(
      style: _style,
      answerLength: _answerLength,
      learningGoal: _learningGoal,
      explanationLanguage: _explanationLanguage,
    );
    final effective = override.applyTo(widget.globalProfile);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xF20A111A),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0x2259D7FF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 36,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0x3359D7FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _ChatAvatar(chat: widget.chat, size: 42),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KI-Stil für diesen Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Diese Einstellungen gelten nur für diesen Chat.',
                              style: TextStyle(
                                color: Color(0xFF8EA0B8),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ChatAiOverrideSection<ImpulseAiStyle>(
                    title: 'KI-Stil',
                    keyPrefix: 'style',
                    values: ImpulseAiStyle.values,
                    selected: _style,
                    globalLabel: widget.globalProfile.style.label,
                    labelOf: (value) => value.label,
                    onSelected: (value) => setState(() => _style = value),
                  ),
                  _ChatAiOverrideSection<ImpulseAnswerLength>(
                    title: 'Antwortlänge',
                    keyPrefix: 'answer_length',
                    values: ImpulseAnswerLength.values,
                    selected: _answerLength,
                    globalLabel: widget.globalProfile.answerLength.label,
                    labelOf: (value) => value.label,
                    onSelected: (value) =>
                        setState(() => _answerLength = value),
                  ),
                  _ChatAiOverrideSection<ImpulseLearningGoal>(
                    title: 'Lernziel',
                    keyPrefix: 'learning_goal',
                    values: ImpulseLearningGoal.values,
                    selected: _learningGoal,
                    globalLabel: widget.globalProfile.learningGoal.label,
                    labelOf: (value) => value.label,
                    onSelected: (value) =>
                        setState(() => _learningGoal = value),
                  ),
                  _ChatAiOverrideSection<ImpulseExplanationLanguage>(
                    title: 'Erklärungssprache',
                    keyPrefix: 'explanation_language',
                    values: ImpulseExplanationLanguage.values,
                    selected: _explanationLanguage,
                    globalLabel: widget.globalProfile.explanationLanguage.label,
                    labelOf: (value) => value.label,
                    onSelected: (value) =>
                        setState(() => _explanationLanguage = value),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 2, bottom: 14),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFF08111B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x2259D7FF)),
                    ),
                    child: Text(
                      override.hasOverrides
                          ? 'Aktiv: ${effective.style.label} · ${effective.answerLength.label} · ${effective.learningGoal.label} · ${effective.explanationLanguage.label}'
                          : 'Globaler Standard aktiv',
                      key: const Key('chat_ai_effective_summary'),
                      style: const TextStyle(
                        color: Color(0xFFC8D6E6),
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('chat_ai_reset_button'),
                          onPressed: widget.onReset,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFC8D6E6),
                            side: const BorderSide(color: Color(0x2259D7FF)),
                          ),
                          child: const Text('Global verwenden'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          key: const Key('chat_ai_save_button'),
                          onPressed: () => widget.onSave(
                            ImpulseChatAiProfileOverride(
                              style: _style,
                              answerLength: _answerLength,
                              learningGoal: _learningGoal,
                              explanationLanguage: _explanationLanguage,
                              updatedAt: DateTime.now(),
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0F5D4A),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Speichern'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatAiOverrideSection<T> extends StatelessWidget {
  const _ChatAiOverrideSection({
    required this.title,
    required this.keyPrefix,
    required this.values,
    required this.selected,
    required this.globalLabel,
    required this.labelOf,
    required this.onSelected,
  });

  final String title;
  final String keyPrefix;
  final List<T> values;
  final T? selected;
  final String globalLabel;
  final String Function(T value) labelOf;
  final ValueChanged<T?> onSelected;

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
              ChoiceChip(
                key: Key('chat_ai_${keyPrefix}_global'),
                label: Text('Global verwenden ($globalLabel)'),
                selected: selected == null,
                onSelected: (_) => onSelected(null),
                selectedColor: const Color(0xFF0F5D4A),
                backgroundColor: const Color(0xFF0A141E),
                side: BorderSide(
                  color: selected == null
                      ? const Color(0xFF7FFFE7)
                      : const Color(0x2259D7FF),
                ),
                labelStyle: TextStyle(
                  color: selected == null
                      ? Colors.white
                      : const Color(0xFFC8D6E6),
                  fontWeight: FontWeight.w800,
                ),
              ),
              for (final value in values)
                ChoiceChip(
                  key: Key('chat_ai_${keyPrefix}_$value'),
                  label: Text(labelOf(value)),
                  selected: selected == value,
                  onSelected: (_) => onSelected(value),
                  selectedColor: const Color(0xFF0F5D4A),
                  backgroundColor: const Color(0xFF0A141E),
                  side: BorderSide(
                    color: selected == value
                        ? const Color(0xFF7FFFE7)
                        : const Color(0x2259D7FF),
                  ),
                  labelStyle: TextStyle(
                    color: selected == value
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

String _chatTypeLabel(ImpulseChatSourceType sourceType) {
  return switch (sourceType) {
    ImpulseChatSourceType.dailyImpulse => 'Tagesimpuls',
    ImpulseChatSourceType.category => 'Kategorie-Chat',
    ImpulseChatSourceType.customAi => 'Eigener KI-Chat',
    ImpulseChatSourceType.favorites => 'Favoriten',
    ImpulseChatSourceType.myWords => 'Meine Wörter',
    ImpulseChatSourceType.knownWords => 'Bekannte Wörter',
  };
}

String _formatCompactDateTime(DateTime value) {
  final date =
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
  final time =
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  return '$date · $time';
}

DateTime _chatSortDate(ImpulseChat chat) {
  return chat.lastMessageAt ?? chat.createdAt;
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
    final isCompanion = CompanionChatConstants.isCompanionChatId(chat.id);
    final companionStyle = CompanionChatConstants.styleForChatId(chat.id);
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
      key: Key('impulse_chat_avatar_${chat.id}'),
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
      child: isCompanion
          ? Padding(
              padding: EdgeInsets.all(size * 0.08),
              child: Image.asset(
                TalvoriMascotAssets.neutralSpiritPathFor(style: companionStyle),
                key: const Key('impulse_chat_companion_avatar_image'),
                fit: BoxFit.contain,
              ),
            )
          : path != null && path.isNotEmpty
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
    required this.favoriteChats,
    required this.onOpenFavorite,
    required this.onChanged,
    required this.onManageHidden,
  });

  final ImpulseAiProfile profile;
  final int activeChatCount;
  final List<ImpulseChat> hiddenChats;
  final List<ImpulseChat> favoriteChats;
  final ValueChanged<ImpulseChat> onOpenFavorite;
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
        const SizedBox(height: 16),
        _FavoriteChatsPanel(
          favoriteChats: favoriteChats,
          onOpen: onOpenFavorite,
        ),
      ],
    );
  }
}

class _FavoriteChatsPanel extends StatelessWidget {
  const _FavoriteChatsPanel({
    required this.favoriteChats,
    required this.onOpen,
  });

  final List<ImpulseChat> favoriteChats;
  final ValueChanged<ImpulseChat> onOpen;

  @override
  Widget build(BuildContext context) {
    final visible = favoriteChats.take(3).toList(growable: false);
    return Container(
      key: const Key('favorite_chats_panel'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF08111B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x2259D7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFD166),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Favoriten',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              _ChatCountPill(label: 'Chats', count: favoriteChats.length),
            ],
          ),
          const SizedBox(height: 10),
          if (favoriteChats.isEmpty)
            const Text(
              'Noch keine Favoriten.',
              style: TextStyle(
                color: Color(0xFF8EA0B8),
                fontWeight: FontWeight.w700,
              ),
            )
          else
            for (final chat in visible)
              _FavoriteChatMiniTile(chat: chat, onTap: () => onOpen(chat)),
        ],
      ),
    );
  }
}

class _FavoriteChatMiniTile extends StatelessWidget {
  const _FavoriteChatMiniTile({required this.chat, required this.onTap});

  final ImpulseChat chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('favorite_chat_tile_${chat.id}'),
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            _ChatAvatar(chat: chat, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                chat.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF7D8BA3)),
          ],
        ),
      ),
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
            'Chat-Übersicht',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Alltagsaktionen findest du direkt per Long-Press oder Swipe in der Chatliste.',
            style: TextStyle(
              color: Color(0xFF8EA0B8),
              fontWeight: FontWeight.w600,
              height: 1.35,
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
