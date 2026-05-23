import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';

class HomeWordWheel extends ConsumerStatefulWidget {
  const HomeWordWheel({super.key});

  @override
  ConsumerState<HomeWordWheel> createState() => _HomeWordWheelState();
}

class _HomeWordWheelState extends ConsumerState<HomeWordWheel> {
  late FixedExtentScrollController _controller;
  int _centerIndex = 0;
  List<WordUserView> _words = [];

  String _sanitize(String t) {
    // Unicode-Whitespaces inkl. NBSP entfernen
    t = t.replaceAll(RegExp(r'^[\s\u00A0]+|[\s\u00A0]+$'), '');

    // HTML-Entities am Rand
    t = t.replaceAll(RegExp(r'^&quot;|&quot;$'), '');

    // Alle gängigen Quotes am Rand (beliebig viele, auch verschachtelt)
    final edgeQuotes = RegExp(
      r'^[\"“"„‟‚'
      '`´«»‹›＂]+|[\"“"„‟‚'
      '`´«»‹›＂]+\$',
    );
    while (edgeQuotes.hasMatch(t)) {
      t = t.replaceAll(edgeQuotes, '');
    }

    // Unsichtbare Zero-Width chars
    t = t.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u2060]'), '');

    // Fallback: falls wirklich noch ein Quote übrig blieb → komplett raus
    if (RegExp(
      r'[\"“"„‟‚'
      '`´«»‹›＂]',
    ).hasMatch(t)) {
      t = t.replaceAll(
        RegExp(
          r'[\"“"„‟‚'
          '`´«»‹›＂]',
        ),
        '',
      );
    }
    return t.trim();
  }

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController();
    _loadMyWords();
  }

  Future<void> _loadMyWords() async {
    final repo = SupabaseWordRepository();
    final items = await repo.fetchMyWords(limit: 50);
    if (mounted) {
      setState(
        () => _words = items
            .map(
              (e) => WordUserView(
                id: e.id,
                text: _sanitize(e.text),
                translation: e.translation,
              ),
            )
            .toList(),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wheelHeight = 180.0; // zeigt ca. 3–4 Wörter
        final boxHeight = 44.0;
        final centerY = wheelHeight / 2;

        return Stack(
          alignment: Alignment.center,
          children: [
            // 🔹 Counter links in der Box
            Positioned(
              left: 20,
              top: centerY - boxHeight / 2,
              child: Container(
                height: boxHeight,
                width: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: const Color(0xFF6D7473),
                    width: 1.4,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  '${_centerIndex + 1}/${_words.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // 🔹 Wheel
            Positioned(
              left: 0,
              right: 0,
              height: wheelHeight,
              child: ListWheelScrollView.useDelegate(
                controller: _controller,
                physics: const FixedExtentScrollPhysics(),
                itemExtent: 40,
                diameterRatio: 2.2,
                perspective: 0.002,
                onSelectedItemChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() => _centerIndex = i);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: _words.length,
                  builder: (context, i) {
                    final isCenter = i == _centerIndex;
                    final display = _sanitize(_words[i].text);
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Text(
                          display,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: isCenter ? 22 : 18,
                            fontWeight: isCenter
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isCenter
                                ? const Color(0xFFB0CCFE)
                                : Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
