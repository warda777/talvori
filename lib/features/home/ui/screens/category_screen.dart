import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocab Sort')),
      body: SafeArea(
        child: Center(child: Text('Categories', style: TextStyle(fontSize: 20))),
      ),
    );
  }
}
