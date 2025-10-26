import 'package:flutter/material.dart';
import 'package:talvori/features/words/domain/word.dart';

class WordListItem extends StatelessWidget {
  final Word word;
  final bool picked;
  final VoidCallback onTogglePick;
  final VoidCallback? onTap;

  const WordListItem({
    super.key,
    required this.word,
    required this.picked,
    required this.onTogglePick,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(word.text),
      subtitle: Text(word.translation),
      trailing: IconButton(
        icon: Icon(picked ? Icons.check_circle : Icons.add_circle_outline),
        onPressed: onTogglePick,
      ),
      onTap: onTap,
    );
  }
}
