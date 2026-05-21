import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/features/home/application/application.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';

/// Kompaktes Word-Wheel für die HomeCard.
/// Zeigt 3–4 Wörter aus „My Words", rechtsbündig und zentriert.
/// Kein Counter, keine Box – nur Scroll-Logik + Text.
class WordWheelCore extends ConsumerStatefulWidget {
  final void Function(int index, WordUserView word)? onCenterChange;
  final void Function(int total)? onTotalLoaded; // Callback für Gesamtanzahl

  const WordWheelCore({super.key, this.onCenterChange, this.onTotalLoaded});

  @override
  ConsumerState<WordWheelCore> createState() => _WordWheelCoreState();
}

class _WordWheelCoreState extends ConsumerState<WordWheelCore> {
  late FixedExtentScrollController _controller;
  List<WordUserView> _words = [];
  int _center = 0;
  bool _isLoading = true;
  bool _loadInFlight = false;
  bool _reloadRequested = false;
  int _loadToken = 0;

  String _sanitize(String t) {
    // Unicode-Whitespaces inkl. NBSP entfernen
    t = t.replaceAll(RegExp(r'^[\s\u00A0]+|[\s\u00A0]+$'), '');

    // HTML-Entities am Rand
    t = t.replaceAll(RegExp(r'^&quot;|&quot;$'), '');

    // Alle gängigen Quotes am Rand (beliebig viele, auch verschachtelt)
    final edgeQuotes = RegExp(r'''^["“„‟‚'`´«»‹›＂]+|["“„‟‚'`´«»‹›＂]+$''');
    while (edgeQuotes.hasMatch(t)) {
      t = t.replaceAll(edgeQuotes, '');
    }

    // Unsichtbare Zero-Width chars
    t = t.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u2060]'), '');

    // Fallback: falls wirklich noch ein Quote übrig blieb → komplett raus
    if (RegExp(r'''["“„‟‚'`´«»‹›＂]''').hasMatch(t)) {
      t = t.replaceAll(RegExp(r'''["“„‟‚'`´«»‹›＂]'''), '');
    }
    return t.trim();
  }

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController();
    _load();
  }

  Future<void> _load() async {
    if (_loadInFlight) {
      _reloadRequested = true;
      return;
    }

    _loadInFlight = true;
    final token = ++_loadToken;
    try {
      final words = await ref.read(
        localWordsForCategoryProvider(localMyWordsCategoryId).future,
      );
      if (!mounted || token != _loadToken) return;

      debugPrint('🎡 WordWheelCore: Loaded ${words.length} local My Words');

      setState(() {
        _isLoading = false;
        _words = words.map(_mapLocalWord).toList(growable: false);
        if (_center >= _words.length) {
          _center = _words.isEmpty ? 0 : _words.length - 1;
        }
      });

      if (_words.isNotEmpty) {
        widget.onCenterChange?.call(_center, _words[_center]);
        widget.onTotalLoaded?.call(_words.length);
      } else {
        widget.onTotalLoaded?.call(0);
        debugPrint('⚠️ WordWheelCore: No local words found in Meine Wörter');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ WordWheelCore._load error: $e');
      debugPrint('Stack: $stackTrace');
      if (mounted && token == _loadToken) {
        setState(() {
          _isLoading = false;
        });
        widget.onTotalLoaded?.call(0);
      }
    } finally {
      _loadInFlight = false;
      if (_reloadRequested && mounted) {
        _reloadRequested = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _load();
        });
      }
    }
  }

  WordUserView _mapLocalWord(LocalWord word) {
    return WordUserView(
      id: word.id,
      text: _sanitize(word.term),
      translation: _translationLabel(word),
      inMyWords: true,
      userAddedAt: word.createdAt,
    );
  }

  String _translationLabel(LocalWord word) {
    final translation = word.translation.trim();
    if (translation.isNotEmpty) return translation;

    return switch (word.translationStatus) {
      TranslationStatus.pending => 'Übersetzung ausstehend',
      TranslationStatus.failed => 'Übersetzung fehlgeschlagen',
      TranslationStatus.translated => 'Noch keine Übersetzung',
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Optional live-Refresh wenn sich der Counter ändert:
    ref.listen<int>(homeControllerProvider.select((s) => s.myWordsCount), (
      previous,
      next,
    ) {
      if (previous != next) {
        _load();
      }
    });
    ref.listen<AsyncValue<List<LocalWord>>>(
      localWordsForCategoryProvider(localMyWordsCategoryId),
      (previous, next) {
        final previousWords = previous?.valueOrNull;
        final nextWords = next.valueOrNull;
        if (nextWords == null || identical(previousWords, nextWords)) return;
        _load();
      },
    );

    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_words.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Text(
              'Mark your first word\nin the browser',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.3,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ClipRect(
        child: ShaderMask(
          shaderCallback: (Rect r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.00, 0.12, 0.88, 1.00],
          ).createShader(r),
          blendMode: BlendMode.dstIn, // nur Alpha zählt
          child: ListWheelScrollView.useDelegate(
            controller: _controller,
            physics: const FixedExtentScrollPhysics(),
            itemExtent: 36,
            diameterRatio: 2.4,
            perspective: 0.002,
            overAndUnderCenterOpacity: 1.0, // ← Eigenfading aus
            onSelectedItemChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _center = i);
              widget.onCenterChange?.call(i, _words[i]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _words.length,
              builder: (context, i) {
                final isCenter = i == _center;
                final display = _sanitize(_words[i].text);
                return Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Text(
                      display,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: isCenter ? 26 : 20,
                        fontWeight: isCenter
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isCenter
                            ? const Color(0xFFB0CCFE)
                            : Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
