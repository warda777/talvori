import 'package:flutter/material.dart';

class VocabSortScreen extends StatelessWidget {
  const VocabSortScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocab Sort')), // 👈 back button
      body: SafeArea(
        child: Center(child: Text('Vocab Sort', style: TextStyle(fontSize: 20))),
      ),
    );
  }
}
