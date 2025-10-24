import 'package:flutter/material.dart';

class MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const MenuItemData(this.icon, this.label, this.onTap);
}

Future<void> showWordsMenuSheet(
  BuildContext context, {
  required List<MenuItemData> items,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black.withOpacity(0.75),
    barrierColor: Colors.black.withOpacity(0.85),
    builder: (_) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((it) => _MenuItem(it)).toList(),
        ),
      ),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final MenuItemData data;
  const _MenuItem(this.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1.0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Navigator.of(context).pop();
              data.onTap();
            },
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(data.icon, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(data.label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
