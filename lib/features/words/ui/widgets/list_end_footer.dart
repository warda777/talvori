import 'package:flutter/material.dart';

class ListEndFooter extends StatelessWidget {
  final bool loading;
  const ListEndFooter({super.key, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(child: Text('— alles geladen —')),
    );
  }
}
