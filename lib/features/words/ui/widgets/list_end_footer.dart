import 'package:flutter/material.dart';

class ListEndFooter extends StatelessWidget {
  final bool loading;
  final bool showDone;
  const ListEndFooter({super.key, required this.loading, this.showDone = false});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (showDone) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('— alles geladen —')),
      );
    }
    return const SizedBox.shrink();
  }
}
