import 'package:flutter/material.dart';
import 'package:talvori/features/local_learning_debug/routing/local_learning_debug_routes.dart';
import 'package:talvori/features/local_learning_debug/ui/local_learn_mode_screen.dart';
import 'package:talvori/features/local_learning_debug/ui/local_wordhub_debug_screen.dart';
import 'package:talvori/features/words/ui/screens/local_shared_text_import_screen.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';

class LocalDebugHubScreen extends StatelessWidget {
  const LocalDebugHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lokaler Debug-Hub')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Lokaler Lernscreen'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LocalLearnModeScreen(
                    categoryId: localLearningDebugDefaultCategoryId,
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Lokale Kategorien'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LocalWordHubDebugScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Lokaler WordHub'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const WordHubScreen(useLocalOfflineFlow: true),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Lokaler Wortimport'),
            subtitle: const Text('Manueller Testimport in Meine Wörter'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LocalSharedTextImportScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
