import 'package:flutter/material.dart';

enum TalvoriSnackBarType { info, success, warning, error }

class TalvoriSnackBar {
  const TalvoriSnackBar._();

  static const Color surface = Color(0xFF07101A);
  static const Color textColor = Color(0xFFF4F8FF);
  static const Color infoAccent = Color(0xFF5DDCFF);
  static const Color successAccent = Color(0xFF7DFFE3);
  static const Color warningAccent = Color(0xFFFFC66A);
  static const Color errorAccent = Color(0xFFFF6B9A);

  static Color accentFor(TalvoriSnackBarType type) {
    return switch (type) {
      TalvoriSnackBarType.info => infoAccent,
      TalvoriSnackBarType.success => successAccent,
      TalvoriSnackBarType.warning => warningAccent,
      TalvoriSnackBarType.error => errorAccent,
    };
  }

  static IconData iconFor(TalvoriSnackBarType type) {
    return switch (type) {
      TalvoriSnackBarType.info => Icons.info_outline_rounded,
      TalvoriSnackBarType.success => Icons.check_circle_rounded,
      TalvoriSnackBarType.warning => Icons.warning_amber_rounded,
      TalvoriSnackBarType.error => Icons.error_outline_rounded,
    };
  }

  static void show(
    BuildContext context, {
    required String message,
    TalvoriSnackBarType type = TalvoriSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Duration? duration,
    Key? key,
    EdgeInsetsGeometry? margin,
    bool hideCurrent = true,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    if (hideCurrent) messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      build(
        message: message,
        type: type,
        actionLabel: actionLabel,
        onAction: onAction,
        icon: icon,
        duration: duration,
        key: key,
        margin: margin,
      ),
    );
  }

  static SnackBar build({
    required String message,
    TalvoriSnackBarType type = TalvoriSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Duration? duration,
    Key? key,
    EdgeInsetsGeometry? margin,
  }) {
    final accent = accentFor(type);
    return SnackBar(
      key: key,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: surface,
      margin: margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      duration: duration ?? const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accent.withValues(alpha: 0.72), width: 1.2),
      ),
      action: actionLabel == null || onAction == null
          ? null
          : SnackBarAction(
              label: actionLabel,
              textColor: accent,
              disabledTextColor: accent.withValues(alpha: 0.45),
              onPressed: onAction,
            ),
      content: Row(
        children: [
          Icon(icon ?? iconFor(type), color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showCustom(
    BuildContext context, {
    required Widget content,
    TalvoriSnackBarType type = TalvoriSnackBarType.info,
    Duration? duration,
    Key? key,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    bool hideCurrent = true,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    if (hideCurrent) messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        key: key,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: surface,
        margin: margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: padding,
        duration: duration ?? const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: accentFor(type).withValues(alpha: 0.72),
            width: 1.2,
          ),
        ),
        content: content,
      ),
    );
  }
}
