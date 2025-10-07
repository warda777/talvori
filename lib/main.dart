import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/home/ui/home_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
  ],
);

void main() {
  runApp(const ProviderScope(child: TalvoriApp()));
}

class TalvoriApp extends ConsumerWidget {
  const TalvoriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Talvori',
      routerConfig: _router,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF7BB1AA),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
