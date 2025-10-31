import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/mix/mix_groups.dart';
import 'package:talvori/features/words/application/mix/mix_search_providers.dart';
import 'package:talvori/features/words/application/mix/mix_selection_controller.dart';

class MixPickOrSearchBar extends ConsumerWidget {
  const MixPickOrSearchBar({super.key});

  static const gold = Color(0xFFF1C86B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isSearch = ref.watch(mixIsSearchModeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: SizedBox(
        height: 46,
        child: isSearch
            ? TextField(
                autofocus: true,
                onSubmitted: (_) => ref.read(mixIsSearchModeProvider.notifier).state = false,
                onChanged: (t) => ref.read(mixSearchTextProvider.notifier).state = t,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Suchen...',
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () => ref.read(mixIsSearchModeProvider.notifier).state = false,
                    color: Colors.white,
                    style: IconButton.styleFrom(backgroundColor: Colors.transparent),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              )
            : FilledButton(
                onPressed: () {
                  final sel = ref.read(mixSelectionProvider.notifier);
                  sel.toggleAll(mixGroups.expand((g) => g.items));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  padding: EdgeInsets.zero,
                ),
                child: SizedBox(
                  height: 46,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8), // Verschiebt Icon nach rechts
                      GestureDetector(
                        onTap: () => ref.read(mixIsSearchModeProvider.notifier).state = true,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 52,
                          height: 46,
                          alignment: const Alignment(0, 0.3), // Etwas tiefer
                          child: const Icon(
                            Icons.search_rounded,
                            size: 36,
                            color: Color(0xFF2D2D2E),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Pick all',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 60), // Balance für zentrierte Ausrichtung (52 Icon + 8 Spacer)
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
