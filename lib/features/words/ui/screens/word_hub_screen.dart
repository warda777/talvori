import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/word_hub_glow_provider.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/word_providers.dart';
import 'package:talvori/features/words/ui/widgets/category_card.dart';
import 'package:talvori/features/words/ui/widgets/glow_toggle_button.dart';

class WordHubScreen extends ConsumerStatefulWidget {
  const WordHubScreen({super.key});

  @override
  ConsumerState<WordHubScreen> createState() => _WordHubScreenState();
}

class _WordHubScreenState extends ConsumerState<WordHubScreen>
    with TickerProviderStateMixin {
  static const double _laneWidth = 210.0;
  static const double _frontButtonWidth = 150.0;
  static const double _maxReveal = _laneWidth - _frontButtonWidth;
  static const Duration _bounceInterval = Duration(seconds: 5);
  static const Duration _bounceOutDuration = Duration(milliseconds: 120);
  static const Duration _bounceBackDuration = Duration(milliseconds: 180);
  static const double _bounceOffset = -40.0;

  double _offset = 0.0;
  bool _dragging = false;
  late final AnimationController _slideController;
  Animation<double>? _slideAnimation;
  Timer? _bounceTimer;
  Timer? _autoCloseTimer;

  bool get _atRest => !_dragging && _offset.abs() < 0.5;

  @override
  void initState() {
    super.initState();
    _slideController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 260),
        )..addListener(() {
          if (_slideAnimation != null && !_dragging) {
            setState(() {
              _offset = _slideAnimation!.value;
            });
          }
        });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBounceTimer(initial: true);
    });
  }

  @override
  void dispose() {
    _bounceTimer?.cancel();
    _autoCloseTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _animateTo(
    double target, {
    Duration duration = const Duration(milliseconds: 260),
    Curve curve = Curves.easeOut,
  }) async {
    target = target.clamp(-_maxReveal, 0.0);
    if ((_offset - target).abs() < 0.5) {
      setState(() => _offset = target);
      return;
    }

    _slideController.stop();
    _slideController.duration = duration;
    _slideAnimation = Tween<double>(
      begin: _offset,
      end: target,
    ).chain(CurveTween(curve: curve)).animate(_slideController);

    final completer = Completer<void>();
    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _slideController.removeStatusListener(statusListener);
        _slideAnimation = null;
        completer.complete();
      }
    }

    _slideController.addStatusListener(statusListener);
    _slideController.forward(from: 0);
    await completer.future;
    if (_offset.abs() < 0.5) {
      setState(() => _offset = 0.0);
    }
  }

  Future<void> _runBounce() async {
    if (!_atRest || _dragging) return;
    await _animateTo(
      _bounceOffset,
      duration: _bounceOutDuration,
      curve: Curves.easeOut,
    );
    if (_dragging) {
      return;
    }
    await _animateTo(
      0,
      duration: _bounceBackDuration,
      curve: Curves.easeOutBack,
    );
  }

  void _startBounceTimer({bool initial = false}) {
    _bounceTimer?.cancel();

    void scheduleNext() {
      _bounceTimer = Timer(_bounceInterval, () async {
        await _runBounce();
        scheduleNext();
      });
    }

    if (initial) {
      _bounceTimer = Timer(const Duration(milliseconds: 900), () async {
        await _runBounce();
        scheduleNext();
      });
    } else {
      scheduleNext();
    }
  }

  void _handleGlowToggle(bool glowEnabled) {
    ref.read(wordHubGlowProvider.notifier).state = !glowEnabled;
    _animateTo(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
    );
    _startBounceTimer();
  }

  void _scheduleAutoClose() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(const Duration(seconds: 2), () {
      if (_dragging) return;
      _animateTo(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
      ).then((_) => _startBounceTimer());
    });
  }

  Widget _buildFrontButton() {
    return SizedBox(
      width: _frontButtonWidth,
      height: 36,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: const StadiumBorder(),
          foregroundColor: const Color(0xFFAFCCFE),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          side: const BorderSide(color: Color(0xFFAFCCFE), width: 1.8),
          shadowColor: const Color(0x550D1A2E),
          elevation: 6,
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Alles freischalten'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final repo = ref.read(wordHubControllerProvider.notifier).repo;
    final glowEnabled = ref.watch(wordHubGlowProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text('Word Hub'),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: _laneWidth,
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GlowToggleButton(
                      glowEnabled: glowEnabled,
                      onToggle: () => _handleGlowToggle(glowEnabled),
                    ),
                  ),
                  _SlidingFrontButton(
                    offset: _offset,
                    maxReveal: _maxReveal,
                    laneWidth: _laneWidth,
                    childWidth: _frontButtonWidth,
                    child: _buildFrontButton(),
                    onOffsetUpdate: (delta) {
                      setState(() {
                        _offset = (_offset + delta).clamp(-_maxReveal, 0.0);
                      });
                    },
                    onDragStart: () {
                      _dragging = true;
                      _bounceTimer?.cancel();
                      _autoCloseTimer?.cancel();
                      _slideController.stop();
                      _slideAnimation = null;
                    },
                    onDragEnd: (velocity) {
                      _dragging = false;
                      final bool shouldReveal =
                          _offset < -_maxReveal * 0.55 || velocity < -400;
                      if (shouldReveal) {
                        _animateTo(
                          -_maxReveal,
                          curve: Curves.easeOut,
                        ).then((_) => _scheduleAutoClose());
                      } else {
                        _animateTo(
                          0,
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutBack,
                        ).then((_) => _startBounceTimer());
                      }
                    },
                    onTapClosed: () {
                      if (_offset < 0 && !_dragging) {
                        _animateTo(
                          0,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutBack,
                        ).then((_) => _startBounceTimer());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Suche
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                textInputAction: TextInputAction.search,
                onSubmitted: (q) {
                  final query = q.trim();
                  if (query.isEmpty) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WordListScreen(
                        filter: WordListFilter(WordFilterKind.query, query),
                      ),
                    ),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Suchen',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFF1C86B),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(
                      color: const Color(0xFFF1C86B).withOpacity(0.85),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(
                      color: Color(0xFFF1C86B),
                      width: 1.6,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(
                      color: Color(0xFFF1C86B),
                      width: 2.2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Sektionen
          for (final section in hubSections) ...[
            _SectionHeader(section.title),
            _GridSection(
              sectionKey: section.key,
              subs: section.subcats,
              repo: repo,
              onTapSub: (sub) async {
                String? catId;
                try {
                  catId = (sub.supabaseId != null && sub.supabaseId!.isNotEmpty)
                      ? sub.supabaseId
                      : await repo.findCategoryIdByName(sub.label);
                } catch (_) {
                  catId = null;
                }

                if (!context.mounted) return;
                if (catId == null && sub.supabaseId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Hinweis: Kategorie-Lookup nicht möglich. Fallback aktiv.',
                      ),
                    ),
                  );
                }

                if (catId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailScreen(
                        title: sub.label,
                        categoryId: catId!,
                        categorySlug: null,
                        listFilter: WordListFilter(
                          WordFilterKind.category,
                          catId,
                        ),
                      ),
                    ),
                  );
                } else {
                  final (kind, value) = _mapToFilter(section.key, sub.label);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailScreen(
                        title: sub.label,
                        categoryId: null,
                        categorySlug: _slugifyLocal(sub.label),
                        listFilter: WordListFilter(kind, value),
                      ),
                    ),
                  );
                }
              },
            ),
          ],

          SliverToBoxAdapter(child: SizedBox(height: bottomInset + 10)),
        ],
      ),
    );
  }
}

(WordFilterKind, String) _mapToFilter(String sectionKey, String label) {
  if (sectionKey == 'levels_progress') {
    return (WordFilterKind.level, label);
  }
  return (WordFilterKind.about, label);
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _SlidingFrontButton extends StatelessWidget {
  final double offset;
  final double maxReveal;
  final double laneWidth;
  final double childWidth;
  final Widget child;
  final ValueChanged<double> onOffsetUpdate;
  final VoidCallback onDragStart;
  final void Function(double velocity) onDragEnd;
  final VoidCallback onTapClosed;

  const _SlidingFrontButton({
    required this.offset,
    required this.maxReveal,
    required this.laneWidth,
    required this.childWidth,
    required this.child,
    required this.onOffsetUpdate,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onTapClosed,
  });

  @override
  Widget build(BuildContext context) {
    final double revealPx = (-offset).clamp(0.0, maxReveal);
    final bool revealOpen = revealPx >= maxReveal * 0.85;

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: laneWidth,
        child: Padding(
          padding: EdgeInsets.only(right: revealPx),
          child: Opacity(
            opacity: revealOpen ? 0.35 : 1.0,
            child: SizedBox(
              width: childWidth,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (_) => onDragStart(),
                onHorizontalDragUpdate: (details) =>
                    onOffsetUpdate(details.delta.dx),
                onHorizontalDragEnd: (details) =>
                    onDragEnd(details.primaryVelocity ?? 0),
                onHorizontalDragCancel: () => onDragEnd(0),
                onTap: onTapClosed,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridSection extends StatelessWidget {
  final String sectionKey;
  final List<HubSubcat> subs;
  final SupabaseWordRepository repo;
  final void Function(HubSubcat sub)? onTapSub;

  const _GridSection({
    required this.sectionKey,
    required this.subs,
    required this.repo,
    this.onTapSub,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => CategoryCard(
            sectionKey: sectionKey,
            sub: subs[i],
            onTap: onTapSub == null ? null : () => onTapSub!(subs[i]),
          ),
          childCount: subs.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
      ),
    );
  }
}

String _slugifyLocal(String s) {
  return s
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
