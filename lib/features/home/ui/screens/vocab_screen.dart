import 'package:flutter/material.dart';

class VocabScreen extends StatelessWidget {
  const VocabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocab Sort')),
      body: SafeArea(
        child: Center(child: Text('Vocab', style: TextStyle(fontSize: 20))),
      ),
    );
  }
}
