import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = NotifierProvider<CounterNotifier, int>(() => CounterNotifier());

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  
  void increment() => state++;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Talvori')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hello, Talvori'),
            const SizedBox(height: 12),
            Text('$count'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(counterProvider.notifier).increment(),
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
