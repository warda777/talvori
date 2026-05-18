import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/mix/mix_search_providers.dart';

class MixPickOrSearchBar extends ConsumerWidget {
  const MixPickOrSearchBar({super.key});

  static const cyan = Color(0xFF5DDCFF);
  static const surface = Color(0xFF0B1420);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSearch = ref.watch(mixIsSearchModeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: SizedBox(
        height: 52,
        child: isSearch
            ? TextField(
                autofocus: true,
                onSubmitted: (_) =>
                    ref.read(mixIsSearchModeProvider.notifier).state = false,
                onChanged: (t) =>
                    ref.read(mixSearchTextProvider.notifier).state = t,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Suchen...',
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () =>
                        ref.read(mixIsSearchModeProvider.notifier).state =
                            false,
                    color: cyan,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  filled: true,
                  fillColor: surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: cyan.withValues(alpha: 0.45)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: cyan.withValues(alpha: 0.45)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: cyan, width: 1.4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                  ),
                ),
              )
            : FilledButton(
                onPressed: () {
                  ref.read(mixIsSearchModeProvider.notifier).state = true;
                },
                style: FilledButton.styleFrom(
                  backgroundColor: surface,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: cyan.withValues(alpha: 0.74)),
                  ),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  shadowColor: cyan.withValues(alpha: 0.22),
                ),
                child: SizedBox(
                  height: 52,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8),
                      Container(
                        width: 52,
                        height: 52,
                        alignment: const Alignment(0, 0.2),
                        child: const Icon(
                          Icons.search_rounded,
                          size: 30,
                          color: cyan,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Suchen',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 60),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
