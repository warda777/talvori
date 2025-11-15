import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Icon-Palette-Dialog für die Auswahl von Icons und Emojis
class IconPickerDialog extends StatefulWidget {
  const IconPickerDialog({
    super.key,
    this.selectedIcon,
    this.selectedEmoji,
    required this.onIconSelected,
    this.onEmojiSelected,
  });

  final IconData? selectedIcon;
  final String? selectedEmoji;
  final ValueChanged<IconData> onIconSelected;
  final ValueChanged<String>? onEmojiSelected;

  // Liste von Icons für die Palette (bereinigt, keine Duplikate)
  static final List<IconData> icons = [
    Icons.star,
    Icons.favorite,
    Icons.thumb_up,
    Icons.thumb_down,
    Icons.check_circle,
    Icons.cancel,
    Icons.add_circle,
    Icons.remove_circle,
    Icons.edit,
    Icons.delete,
    Icons.settings,
    Icons.home,
    Icons.search,
    Icons.menu,
    Icons.close,
    Icons.arrow_back,
    Icons.arrow_forward,
    Icons.arrow_upward,
    Icons.arrow_downward,
    Icons.expand_more,
    Icons.expand_less,
    Icons.more_vert,
    Icons.more_horiz,
    Icons.share,
    Icons.download,
    Icons.upload,
    Icons.refresh,
    Icons.save,
    Icons.open_in_new,
    Icons.link,
    Icons.copy,
    Icons.cut,
    Icons.paste,
    Icons.undo,
    Icons.redo,
    Icons.filter_list,
    Icons.sort,
    Icons.grid_view,
    Icons.list,
    Icons.view_module,
    Icons.dashboard,
    Icons.folder,
    Icons.folder_open,
    Icons.insert_drive_file,
    Icons.image,
    Icons.video_library,
    Icons.audiotrack,
    Icons.description,
    Icons.code,
    Icons.lock,
    Icons.lock_open,
    Icons.visibility,
    Icons.visibility_off,
    Icons.person,
    Icons.person_add,
    Icons.group,
    Icons.notifications,
    Icons.notifications_off,
    Icons.email,
    Icons.phone,
    Icons.chat,
    Icons.message,
    Icons.send,
    Icons.reply,
    Icons.forward,
    Icons.archive,
    Icons.inbox,
    Icons.outbox,
    Icons.drafts,
    Icons.star_border,
    Icons.star_half,
    Icons.bookmark,
    Icons.bookmark_border,
    Icons.label,
    Icons.label_outline,
    Icons.tag,
    Icons.local_offer,
    Icons.category,
    Icons.collections,
    Icons.photo_library,
    Icons.camera_alt,
    Icons.camera,
    Icons.videocam,
    Icons.mic,
    Icons.mic_off,
    Icons.volume_up,
    Icons.volume_down,
    Icons.volume_off,
    Icons.volume_mute,
    Icons.play_arrow,
    Icons.pause,
    Icons.stop,
    Icons.skip_next,
    Icons.skip_previous,
    Icons.fast_forward,
    Icons.fast_rewind,
    Icons.replay,
    Icons.shuffle,
    Icons.repeat,
    Icons.equalizer,
    Icons.graphic_eq,
    Icons.tune,
    Icons.brightness_high,
    Icons.brightness_low,
    Icons.brightness_medium,
    Icons.contrast,
    Icons.color_lens,
    Icons.palette,
    Icons.brush,
    Icons.format_paint,
    Icons.format_color_fill,
    Icons.format_color_text,
    Icons.text_fields,
    Icons.title,
    Icons.format_bold,
    Icons.format_italic,
    Icons.format_underlined,
    Icons.format_strikethrough,
    Icons.format_align_left,
    Icons.format_align_center,
    Icons.format_align_right,
    Icons.format_align_justify,
    Icons.format_list_bulleted,
    Icons.format_list_numbered,
    Icons.format_quote,
    Icons.format_indent_increase,
    Icons.format_indent_decrease,
    Icons.format_size,
    Icons.format_line_spacing,
    Icons.space_bar,
    Icons.wrap_text,
    Icons.subscript,
    Icons.superscript,
    Icons.functions,
    Icons.calculate,
    Icons.percent,
    Icons.attach_money,
    Icons.euro,
    Icons.currency_pound,
    Icons.currency_yen,
    Icons.monetization_on,
    Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.credit_card,
    Icons.payment,
    Icons.receipt,
    Icons.shopping_cart,
    Icons.shopping_bag,
    Icons.store,
    Icons.storefront,
    Icons.local_grocery_store,
    Icons.local_mall,
    Icons.local_shipping,
    Icons.local_dining,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.local_hotel,
    Icons.local_gas_station,
    Icons.local_parking,
    Icons.local_pharmacy,
    Icons.local_hospital,
    Icons.local_police,
    Icons.local_fire_department,
    Icons.local_library,
    Icons.school,
    Icons.work,
    Icons.business,
    Icons.apartment,
    Icons.house,
    Icons.hotel,
    Icons.restaurant,
    Icons.coffee,
    Icons.wine_bar,
    Icons.sports_bar,
    Icons.nightlife,
    Icons.movie,
    Icons.movie_filter,
    Icons.theaters,
    Icons.live_tv,
    Icons.tv,
    Icons.radio,
    Icons.music_note,
    Icons.music_video,
    Icons.album,
    Icons.library_music,
    Icons.headphones,
    Icons.speaker,
    Icons.speaker_group,
    Icons.hearing,
    Icons.hearing_disabled,
    Icons.accessibility,
    Icons.accessibility_new,
    Icons.accessible,
    Icons.accessible_forward,
    Icons.wheelchair_pickup,
    Icons.airline_seat_recline_normal,
    Icons.airline_seat_recline_extra,
    Icons.child_care,
    Icons.child_friendly,
    Icons.elderly,
    Icons.elderly_woman,
    Icons.pregnant_woman,
    Icons.stroller,
    Icons.baby_changing_station,
    Icons.family_restroom,
    Icons.wc,
    Icons.wash,
    Icons.soap,
    Icons.cleaning_services,
    Icons.dry_cleaning,
    Icons.local_laundry_service,
    Icons.local_car_wash,
    Icons.car_repair,
    Icons.build,
    Icons.build_circle,
    Icons.construction,
    Icons.hardware,
    Icons.power,
    Icons.power_off,
    Icons.battery_charging_full,
    Icons.battery_full,
    Icons.battery_std,
    Icons.battery_alert,
    Icons.battery_unknown,
    Icons.signal_cellular_alt,
    Icons.signal_wifi_4_bar,
    Icons.signal_wifi_off,
    Icons.network_check,
    Icons.network_locked,
    Icons.wifi,
    Icons.wifi_off,
    Icons.bluetooth,
    Icons.bluetooth_connected,
    Icons.bluetooth_disabled,
    Icons.bluetooth_searching,
    Icons.nfc,
    Icons.usb,
    Icons.usb_off,
    Icons.cable,
    Icons.cast,
    Icons.cast_connected,
    Icons.cast_for_education,
    Icons.screen_share,
    Icons.desktop_mac,
    Icons.desktop_windows,
    Icons.laptop,
    Icons.laptop_chromebook,
    Icons.laptop_mac,
    Icons.laptop_windows,
    Icons.tablet,
    Icons.tablet_android,
    Icons.tablet_mac,
    Icons.phone_android,
    Icons.phone_iphone,
    Icons.smartphone,
    Icons.watch,
    Icons.watch_later,
    Icons.access_time,
    Icons.access_alarm,
    Icons.alarm,
    Icons.alarm_add,
    Icons.alarm_off,
    Icons.alarm_on,
    Icons.timer,
    Icons.timer_off,
    Icons.timer_10,
    Icons.timer_3,
    Icons.hourglass_empty,
    Icons.hourglass_full,
    Icons.schedule,
    Icons.update,
    Icons.update_disabled,
    Icons.history,
    Icons.restore,
    Icons.restore_from_trash,
    Icons.delete_forever,
    Icons.delete_outline,
    Icons.delete_sweep,
    Icons.clear_all,
    Icons.clear,
    Icons.backspace,
    Icons.check,
    Icons.check_box,
    Icons.check_box_outline_blank,
    Icons.indeterminate_check_box,
    Icons.radio_button_checked,
    Icons.radio_button_unchecked,
    Icons.toggle_on,
    Icons.toggle_off,
    Icons.switch_camera,
    Icons.switch_video,
    Icons.swap_horiz,
    Icons.swap_vert,
    Icons.swap_vertical_circle,
    Icons.swap_horizontal_circle,
    Icons.compare_arrows,
    Icons.compare,
    Icons.drag_handle,
    Icons.drag_indicator,
    Icons.reorder,
    Icons.unfold_more,
    Icons.unfold_less,
    Icons.close_fullscreen,
    Icons.fullscreen,
    Icons.fullscreen_exit,
    Icons.zoom_in,
    Icons.zoom_out,
    Icons.zoom_out_map,
    Icons.fit_screen,
    Icons.aspect_ratio,
    Icons.crop,
    Icons.crop_free,
    Icons.crop_landscape,
    Icons.crop_portrait,
    Icons.crop_rotate,
    Icons.crop_square,
    Icons.crop_din,
    Icons.crop_16_9,
    Icons.crop_3_2,
    Icons.crop_5_4,
    Icons.crop_7_5,
    Icons.transform,
    Icons.rotate_left,
    Icons.rotate_right,
    Icons.rotate_90_degrees_ccw,
    Icons.rotate_90_degrees_cw,
    Icons.flip,
    Icons.flip_camera_android,
    Icons.flip_camera_ios,
    Icons.straighten,
    Icons.auto_fix_high,
    Icons.auto_fix_normal,
    Icons.auto_fix_off,
    Icons.auto_awesome,
    Icons.auto_awesome_mosaic,
    Icons.auto_awesome_motion,
    Icons.auto_stories,
    Icons.auto_graph,
    Icons.auto_delete,
    Icons.auto_mode,
    Icons.auto_awesome_outlined,
    Icons.auto_fix_off_outlined,
    Icons.auto_fix_normal_outlined,
    Icons.auto_fix_high_outlined,
    Icons.auto_awesome_mosaic_outlined,
    Icons.auto_awesome_motion_outlined,
    Icons.auto_stories_outlined,
    Icons.auto_graph_outlined,
    Icons.auto_delete_outlined,
    Icons.auto_mode_outlined,
  ];

  // Liste von Emojis (iPhone-ähnliche Smileys)
  static final List<String> emojis = [
    // Smileys & Emotionen
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃',
    '😉', '😊', '😇', '🥰', '😍', '🤩', '😘', '😗', '😚', '😙',
    '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭', '🤫', '🤔',
    '🤐', '🤨', '😐', '😑', '😶', '😏', '😒', '🙄', '😬', '🤥',
    '😌', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕', '🤢', '🤮',
    '🤧', '🥵', '🥶', '😶‍🌫️', '😵', '😵‍💫', '🤯', '🤠', '🥳', '😎',
    '🤓', '🧐', '😕', '😟', '🙁', '☹️', '😮', '😯', '😲', '😳',
    '🥺', '😦', '😧', '😨', '😰', '😥', '😢', '😭', '😱', '😖',
    '😣', '😞', '😓', '😩', '😫', '🥱', '😤', '😡', '😠', '🤬',
    '😈', '👿', '💀', '☠️', '💩', '🤡', '👹', '👺', '👻', '👽',
    '👾', '🤖', '😺', '😸', '😹', '😻', '😼', '😽', '🙀', '😿',
    '😾',
    
    // Gesten & Körperteile
    '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏', '✌️', '🤞',
    '🤟', '🤘', '🤙', '👈', '👉', '👆', '🖕', '👇', '☝️', '👍',
    '👎', '✊', '👊', '🤛', '🤜', '👏', '🙌', '👐', '🤲', '🤝',
    '🙏', '✍️', '💪', '🦾', '🦿', '🦵', '🦶', '👂', '🦻', '👃',
    '🧠', '🫀', '🫁', '🦷', '🦴', '👀', '👁️', '👅', '👄',
    
    // Menschen
    '👶', '🧒', '👦', '👧', '🧑', '👱', '👨', '🧔', '👨‍🦰', '👨‍🦱',
    '👨‍🦳', '👨‍🦲', '👩', '👩‍🦰', '🧑‍🦰', '👩‍🦱', '🧑‍🦱', '👩‍🦳', '🧑‍🦳', '👩‍🦲',
    '🧑‍🦲', '👱‍♀️', '👱‍♂️', '🧓', '👴', '👵', '🙍', '🙎', '🙅', '🙆',
    '💁', '🙋', '🧏', '🙇', '🤦', '🤦‍♂️', '🤦‍♀️', '🤷', '🤷‍♂️', '🤷‍♀️',
    '🧑‍⚕️', '👨‍⚕️', '👩‍⚕️', '🧑‍🎓', '👨‍🎓', '👩‍🎓', '🧑‍🏫', '👨‍🏫', '👩‍🏫', '🧑‍⚖️',
    '👨‍⚖️', '👩‍⚖️', '🧑‍🌾', '👨‍🌾', '👩‍🌾', '🧑‍🍳', '👨‍🍳', '👩‍🍳', '🧑‍🔧', '👨‍🔧',
    '👩‍🔧', '🧑‍🏭', '👨‍🏭', '👩‍🏭', '🧑‍💼', '👨‍💼', '👩‍💼', '🧑‍🔬', '👨‍🔬', '👩‍🔬',
    '🧑‍💻', '👨‍💻', '👩‍💻', '🧑‍🎤', '👨‍🎤', '👩‍🎤', '🧑‍🎨', '👨‍🎨', '👩‍🎨', '🧑‍✈️',
    '👨‍✈️', '👩‍✈️', '🧑‍🚀', '👨‍🚀', '👩‍🚀', '🧑‍🚒', '👨‍🚒', '👩‍🚒', '👮', '👮‍♂️',
    '👮‍♀️', '🕵️', '🕵️‍♂️', '🕵️‍♀️', '💂', '💂‍♂️', '💂‍♀️', '🥷', '👷', '👷‍♂️',
    '👷‍♀️', '🤴', '👸', '👳', '👳‍♂️', '👳‍♀️', '👲', '🧕', '🤵', '🤵‍♂️',
    '🤵‍♀️', '👰', '👰‍♂️', '👰‍♀️', '🤰', '🤱', '👼', '🎅', '🤶', '🦸',
    '🦸‍♂️', '🦸‍♀️', '🦹', '🦹‍♂️', '🦹‍♀️', '🧙', '🧙‍♂️', '🧙‍♀️', '🧚', '🧚‍♂️',
    '🧚‍♀️', '🧛', '🧛‍♂️', '🧛‍♀️', '🧜', '🧜‍♂️', '🧜‍♀️', '🧝', '🧝‍♂️', '🧝‍♀️',
    '🧞', '🧞‍♂️', '🧞‍♀️', '🧟', '🧟‍♂️', '🧟‍♀️', '💆', '💆‍♂️', '💆‍♀️', '💇',
    '💇‍♂️', '💇‍♀️', '🚶', '🚶‍♂️', '🚶‍♀️', '🧍', '🧍‍♂️', '🧍‍♀️', '🧎', '🧎‍♂️',
    '🧎‍♀️', '🏃', '🏃‍♂️', '🏃‍♀️', '💃', '🕺', '🕴️', '👯', '👯‍♂️', '👯‍♀️',
    '🧘', '🧘‍♂️', '🧘‍♀️', '🛀', '🛌', '👭', '👫', '👬', '💏', '💑',
    '👪', '👨‍👩‍👦', '👨‍👩‍👧', '👨‍👩‍👧‍👦', '👨‍👩‍👦‍👦', '👨‍👩‍👧‍👧', '👨‍👨‍👦', '👨‍👨‍👧', '👨‍👨‍👧‍👦', '👨‍👨‍👦‍👦',
    '👨‍👨‍👧‍👧', '👩‍👩‍👦', '👩‍👩‍👧', '👩‍👩‍👧‍👦', '👩‍👩‍👦‍👦', '👩‍👩‍👧‍👧', '👨‍👦', '👨‍👦‍👦', '👨‍👧', '👨‍👧‍👦',
    '👨‍👧‍👧', '👩‍👦', '👩‍👦‍👦', '👩‍👧', '👩‍👧‍👦', '👩‍👧‍👧', '🗣️', '👤', '👥', '👣',
  ];

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  IconData? _selectedIcon;
  String? _selectedEmoji;
  final ScrollController _scrollController = ScrollController();
  int _selectedTab = 1; // 0 = Icons, 1 = Emojis (Standard: Emojis)

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;
    _selectedEmoji = widget.selectedEmoji;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectIcon(IconData icon) {
    setState(() {
      _selectedIcon = icon;
    });
    HapticFeedback.selectionClick();
    widget.onIconSelected(icon);
    Navigator.of(context).pop();
  }

  void _selectEmoji(String emoji) {
    setState(() {
      _selectedEmoji = emoji;
    });
    HapticFeedback.selectionClick();
    widget.onEmojiSelected?.call(emoji);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Icon auswählen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            // Tabs für Icons und Emojis
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Icons',
                      isSelected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TabButton(
                      label: 'Emojis',
                      isSelected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            // Scrollable Content (Icons oder Emojis)
            Flexible(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: false,
                thickness: 6,
                radius: const Radius.circular(3),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: _selectedTab == 0
                      ? Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.start,
                          children: IconPickerDialog.icons.map((icon) {
                            final isSelected = _selectedIcon == icon;
                            return _IconItem(
                              icon: icon,
                              isSelected: isSelected,
                              onTap: () => _selectIcon(icon),
                            );
                          }).toList(),
                        )
                      : Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.start,
                          children: IconPickerDialog.emojis.map((emoji) {
                            final isSelected = _selectedEmoji == emoji;
                            return _EmojiItem(
                              emoji: emoji,
                              isSelected: isSelected,
                              onTap: () => _selectEmoji(emoji),
                            );
                          }).toList(),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconItem extends StatelessWidget {
  const _IconItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _EmojiItem extends StatelessWidget {
  const _EmojiItem({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}

