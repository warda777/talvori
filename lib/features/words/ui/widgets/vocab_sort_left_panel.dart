import 'package:flutter/material.dart';

class VocabSortLeftPanel extends StatelessWidget {
  final String title;          // "Words I know"
  final int knownCount;        // große Zahl
  final int betweenArrows;     // Zahl zwischen ↑  ↓

  const VocabSortLeftPanel({
    super.key,
    required this.title,
    required this.knownCount,
    required this.betweenArrows,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          // Große Zahl zentriert über Counter-Box
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16), // Gleicher Padding wie Counter-Box
              child: Text('$knownCount',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 8),
          // Pfeile + Counter: Pfeile über der Zahl in der Counter-Box
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16), // Gleicher Padding wie Counter-Box
                child: const Icon(Icons.arrow_upward_rounded, size: 18),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '$betweenArrows',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 16), // Gleicher Padding wie Counter-Box
                child: const Icon(Icons.arrow_downward_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
