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
// ⬇️ NEU
import 'package:talvori/features/words/application/radial_palette_controller.dart';
import 'package:talvori/features/words/application/word_hub_tile_overrides_provider.dart';
import 'package:talvori/features/words/ui/widgets/glow_toggle_button.dart';
import 'package:talvori/features/words/ui/widgets/radial_palette_tools.dart';
import 'package:talvori/features/words/ui/widgets/radial_palette_sheet.dart';
import 'package:talvori/features/words/ui/widgets/slide_hint_button.dart';
import 'package:talvori/features/words/ui/widgets/floating_palette_button.dart';

Widget debugBorder(Widget child, {bool focused = false}) {
  // nur noch Platzhalter – Fokus wird komplett von FocusGlow übernommen
  return child;
}

class FocusGlow extends ConsumerWidget {
  final bool isFocused;
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding; // 🔹 optionales Padding

  const FocusGlow({
    super.key,
    required this.isFocused,
    required this.child,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isFocused) return child;

    final radius = borderRadius ?? BorderRadius.circular(16);
    // Standard-Padding für Texte, aber überschreibbar für Buttons/Suchfeld
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: effectivePadding,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [], // Kein Glow mehr, nur Rahmen
      ),
      child: child,
    );
  }
}

class WordHubScreen extends ConsumerStatefulWidget {
  const WordHubScreen({super.key});

  @override
  ConsumerState<WordHubScreen> createState() => _WordHubScreenState();
}

class _WordHubScreenState extends ConsumerState<WordHubScreen> {
  static const double _frontButtonWidth = 120.0;
  static const double _maxReveal = 90.0;
  static const double _laneWidth = _frontButtonWidth + _maxReveal;

  final SlideHintController _slideCtrl = SlideHintController();
  final ScrollController _scroll = ScrollController();
  bool _allowHints = true;
  bool _isRadialOpen = false;
  bool _callbackSet = false; // Flag um zu verhindern, dass Callback mehrfach gesetzt wird
  bool _headerTargetsRegistered = false; // Flag um zu verhindern, dass Header-Targets mehrfach registriert werden
  
  // Farb-Overrides für Header-Elemente
  Color? _searchFieldStrokeColor;
  Color? _searchFieldFillColor;
  Color? _searchFieldIconColor;
  Color? _unlockButtonStrokeColor;
  Color? _unlockButtonFillColor;
  Color? _unlockButtonTextColor;
  Color? _hubBackgroundColor;
  
  // Keys für Auto-Scroll
  final _keysById = <String, GlobalKey>{
    'wordHub.title': GlobalKey(),
    'wordHub.search': GlobalKey(),
    'wordHub.searchIcon': GlobalKey(),
    'wordHub.unlockButton': GlobalKey(),
  };
  String? _lastPrimaryId;
  
  // Header-Keys (werden nur einmal erstellt)
  late final GlobalKey _titleKey = GlobalKey();
  late final GlobalKey _backKey = GlobalKey();
  late final GlobalKey _unlockKey = GlobalKey();
  late final GlobalKey _searchKey = GlobalKey();
  late final GlobalKey _searchIconKey = GlobalKey();

  Future<void> _handleGlowToggle(bool glowEnabled) async {
    if (mounted) setState(() => _allowHints = false);
    await _slideCtrl.closeAndFreeze();
    ref.read(wordHubGlowProvider.notifier).state = !glowEnabled;
  }

  void _toggleRadial() {
    setState(() {
      if (_isRadialOpen) {
        _closeRadial();
      } else {
        _isRadialOpen = true;
        _callbackSet = false;
        // Callback setzen, wenn Rad geöffnet wird (nur einmal)
        if (!_callbackSet) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _isRadialOpen && !_callbackSet) {
              ref.read(radialPaletteProvider.notifier).onFocusChange = _handleFocusChange;
              _callbackSet = true;
            }
          });
        }
      }
    });
  }

  void _closeRadial() {
    // 1) Fokus im Controller komplett löschen
    final ctrl = ref.read(radialPaletteProvider.notifier);
    ctrl.clearFocus();
    ctrl.onFocusChange = null;

    // 2) Lokalen State zurücksetzen
    if (!mounted) return;
    setState(() {
      _isRadialOpen = false;
      _lastPrimaryId = null;
      _callbackSet = false;
    });
  }

  void _handleFocusChange(Set<String> ids) {
    if (!mounted || !_isRadialOpen) return;

    // 1) Primäre ID bestimmen
    final String? primaryId = ids.isEmpty ? null : ids.first;
    if (primaryId == null || primaryId == _lastPrimaryId) return;
    _lastPrimaryId = primaryId;

    // 2) Basis-ID extrahieren (falls es .title oder .count ist, zur Kachel-ID zurückfallen)
    final baseId = primaryId.replaceAll(RegExp(r'\.(title|count)$'), '');

    // 3) Passenden PaletteTarget über die Basis-ID finden (immer die Kachel, nicht Titel/Counter)
    final paletteState = ref.read(radialPaletteProvider);

    PaletteTarget? target;
    for (final t in paletteState.targets) {
      // Suche nach der Basis-Kachel-ID (ohne .title/.count)
      if (t.id == baseId && t.kind == TargetKind.tile) {
        target = t;
        break;
      }
    }
    
    // Fallback: Falls keine Tile gefunden wurde, versuche die ursprüngliche ID
    if (target == null) {
      for (final t in paletteState.targets) {
        if (t.id == primaryId) {
          target = t;
          break;
        }
      }
    }
    
    if (target == null) return;

    final key = target.key;

    // 4) Scrollen, so dass das Element VOR dem Rad sichtbar ist (smooth Animation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isRadialOpen) return;
      final ctx = key.currentContext;
      if (ctx == null) return;

      try {
        // Smooth Animation mit längerer Duration und besserer Curve
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 200), // Längere Duration für smooth Animation
          curve: Curves.easeInOutCubic, // Smooth, fließende Kurve
          // 0 = ganz oben, 1 = ganz unten
          // etwas über der Mitte, damit es nicht vom Rad verdeckt wird
          alignment: 0.18,
        );
      } catch (_) {
        // Scroll-Fehler ignorieren
      }
    });
  }

  Widget _buildFrontButton({Key? key}) {
    return SizedBox(
      width: _frontButtonWidth,
      height: 36,
      child: TextButton(
        key: key,
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
    final radialPalette = ref.watch(radialPaletteProvider);
    final focusedIds = radialPalette.focusedIds;

    // Extra Platz nur, wenn der Fokus auf einer der letzten Kacheln ist (Levels & Progress)
    final bool isNearBottom = _isRadialOpen && focusedIds.isNotEmpty && () {
      // Basis-ID extrahieren (ohne .title oder .count)
      final primaryId = focusedIds.first;
      final baseId = primaryId.replaceAll(RegExp(r'\.(title|count)$'), '');
      
      // Prüfen, ob es eine Levels & Progress Kachel ist (a1, a2, b1, b2, c1, c2)
      final lastTileKeys = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];
      for (final key in lastTileKeys) {
        if (baseId.endsWith('levels_progress.$key')) {
          return true;
        }
      }
      return false;
    }();

    // Header-Targets registrieren (nur einmal)
    if (!_headerTargetsRegistered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _headerTargetsRegistered) return;
        _headerTargetsRegistered = true;
        final headerTargets = <PaletteTarget>[
          PaletteTarget(
            id: 'wordHub.title',
            key: _titleKey,
            kind: TargetKind.header,
            tools: {PaletteTool.text},
          ),
          PaletteTarget(
            id: 'wordHub.backButton',
            key: _backKey,
            kind: TargetKind.icon,
            tools: {PaletteTool.icon, PaletteTool.stroke},
          ),
          PaletteTarget(
            id: 'wordHub.unlockButton',
            key: _unlockKey,
            kind: TargetKind.button,
            tools: {PaletteTool.stroke, PaletteTool.fill, PaletteTool.text},
            onApply: (tool, color, scope) {
              if (mounted) {
                setState(() {
                  if (tool == PaletteTool.stroke) {
                    _unlockButtonStrokeColor = color;
                  } else if (tool == PaletteTool.fill) {
                    _unlockButtonFillColor = color;
                  } else if (tool == PaletteTool.text) {
                    _unlockButtonTextColor = color;
                  }
                });
              }
            },
          ),
          PaletteTarget(
            id: 'wordHub.search',
            key: _searchKey,
            kind: TargetKind.searchBar,
            tools: {PaletteTool.stroke, PaletteTool.fill},
            onApply: (tool, color, scope) {
              if (mounted) {
                setState(() {
                  if (tool == PaletteTool.stroke) {
                    _searchFieldStrokeColor = color;
                  } else if (tool == PaletteTool.fill) {
                    _searchFieldFillColor = color;
                  }
                });
              }
            },
          ),
          PaletteTarget(
            id: 'wordHub.searchIcon',
            key: _searchIconKey,
            kind: TargetKind.icon,
            tools: {PaletteTool.icon, PaletteTool.stroke},
            onApply: (tool, color, scope) {
              if (mounted) {
                setState(() {
                  if (tool == PaletteTool.icon) {
                    _searchFieldIconColor = color;
                  }
                });
              }
            },
          ),
          PaletteTarget(
            id: 'wordHub.background',
            key: GlobalKey(), // Hintergrund braucht keinen Key für Scroll
            kind: TargetKind.hubBackground,
            tools: {PaletteTool.hubBackground},
            onApply: (tool, color, scope) {
              if (mounted) {
                setState(() {
                  if (tool == PaletteTool.hubBackground) {
                    _hubBackgroundColor = color;
                  }
                });
              }
            },
          ),
        ];
        ref.read(radialPaletteProvider.notifier).registerTargets(headerTargets);
      });
    }

    // Sektionen-Widgets erstellen
    final sectionWidgets = <Widget>[];
    for (final section in hubSections) {
      sectionWidgets.add(_SectionHeader(section.title, section.key));
      sectionWidgets.add(_GridSection(
        sectionKey: section.key,
        subs: section.subcats,
        repo: repo,
        onTapSub: (sub) async {
          String? catId;
          try {
            catId =
                (sub.supabaseId != null && sub.supabaseId!.isNotEmpty)
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
            final (kind, value) = _mapToFilter(
              section.key,
              sub.label,
            );
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
      ));
    }

    return Scaffold(
      backgroundColor: _hubBackgroundColor ?? Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _hubBackgroundColor?.withOpacity(0.87) ?? Colors.black87,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          key: _backKey,
          icon: const Icon(Icons.close),
          onPressed: _isRadialOpen
              ? null // 🔒 gesperrt, solange das Rad offen ist
              : () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
        titleSpacing: 8,
        title: SizedBox(
          height: 56,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: KeyedSubtree(
                    key: _keysById['wordHub.title'],
                    child: FocusGlow(
                      isFocused: focusedIds.contains('wordHub.title'),
                      borderRadius: BorderRadius.circular(12), // kleine Radien an den Ecken
                      child: Text(
                        'Word Hub',
                        key: _titleKey,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 8,
                child: GlowToggleButton(
                  glowEnabled: glowEnabled,
                  onToggle: () => _handleGlowToggle(glowEnabled),
                ),
              ),
              Positioned(
                right: 12,
                top: 6,
                child: SlideHintButton(
                  key: ValueKey(_allowHints),
                  controller: _slideCtrl,
                  buttonWidth: _frontButtonWidth,
                  reveal: _maxReveal,
                  enableDrag: true,
                  autoHint: _allowHints,
                  firstHintDelay: const Duration(milliseconds: 800),
                  hintInterval: const Duration(seconds: 5),
                  hintFraction: 2 / 3,
                  hintOutDuration: const Duration(milliseconds: 1200),
                  hintBackDuration: const Duration(milliseconds: 600),
                  onUnderlayTap: () {
                    if (mounted) setState(() => _allowHints = false);
                    final glow = ref.read(wordHubGlowProvider);
                    ref.read(wordHubGlowProvider.notifier).state = !glow;
                  },
                  child: KeyedSubtree(
                    key: _keysById['wordHub.unlockButton'],
                    child: FocusGlow(
                      isFocused: focusedIds.contains('wordHub.unlockButton'),
                      borderRadius: BorderRadius.circular(999), // Button-Form (Stadium)
                      padding: EdgeInsets.zero, // kein Padding für Buttons
                      child: _buildFrontButton(key: _unlockKey),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1) Inhalt (Kacheln, Header, etc.)
          IgnorePointer(
            ignoring: _isRadialOpen,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              // nur wenn der Fokus am Ende ist, schaffen wir unten extra Platz
              padding: EdgeInsets.only(bottom: isNearBottom ? 260.0 : 0.0),
              child: CustomScrollView(
                controller: _scroll,
                slivers: [
                // Suche
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: KeyedSubtree(
                      key: _keysById['wordHub.search'],
                      child: FocusGlow(
                        isFocused: focusedIds.contains('wordHub.search'),
                        borderRadius: BorderRadius.circular(999), // gleiche Pill-Form wie Feld
                        padding: EdgeInsets.zero, // kein Padding für Suchfeld
                        child: TextField(
                          key: _searchKey,
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
                            prefixIcon: KeyedSubtree(
                              key: _keysById['wordHub.searchIcon'],
                              child: FocusGlow(
                                isFocused: focusedIds.contains('wordHub.searchIcon'),
                                borderRadius: BorderRadius.circular(999),
                                padding: EdgeInsets.zero,
                                child: Icon(
                                  Icons.search,
                                  key: _searchIconKey,
                                  color: _searchFieldIconColor ?? const Color(0xFFF1C86B),
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: _searchFieldFillColor ?? Colors.white.withOpacity(0.12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide(
                                color: _searchFieldStrokeColor ?? const Color(0xFFF1C86B).withOpacity(0.85),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide(
                                color: _searchFieldStrokeColor ?? const Color(0xFFF1C86B),
                                width: 1.6,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide(
                                color: _searchFieldStrokeColor ?? const Color(0xFFF1C86B),
                                width: 2.2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Sektionen
                ...sectionWidgets,

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: bottomInset + (isNearBottom ? 260 : 10),
                  ),
                ),
              ],
              ),
            ),
          ),

          // 2) Overlay zum Schließen – fängt Taps außerhalb des Rades ab
          if (_isRadialOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeRadial,
                child: const SizedBox.shrink(),
              ),
            ),

          // 3) Rad selbst (liegt über Overlay, damit Drag noch funktioniert)
          if (_isRadialOpen)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: RadialPaletteSheet(
                  onClose: _closeRadial,
                  heroTag: 'floating-palette',
                ),
              ),
            ),

          // 4) Toggle-Button unten rechts – immer ganz oben
          Positioned(
            right: 24,
            bottom: 24,
            child: _buildRadialToggleButton(),
          ),

          const RadialDebugBanner(),
        ],
      ),
    );
  }

  Widget _buildRadialToggleButton() {
    return FloatingActionButton(
      onPressed: _toggleRadial,
      backgroundColor: Colors.black,
      child: Icon(
        _isRadialOpen ? Icons.close : Icons.palette_outlined,
        color: Colors.white,
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

class _SectionHeader extends ConsumerStatefulWidget {
  final String title;
  final String sectionKey;
  
  const _SectionHeader(this.title, this.sectionKey);

  @override
  ConsumerState<_SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends ConsumerState<_SectionHeader> {
  final _titleKey = GlobalKey();
  bool _registered = false;
  Color? _textColor; // Override-Farbe für diesen Section Header

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(radialPaletteProvider);
    final focusedIds = palette.focusedIds;
    final sectionId = 'wordHub.sectionTitle.${widget.sectionKey}';
    final isFocused = focusedIds.contains(sectionId);
    
    // Target registrieren (nur einmal)
    if (!_registered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _registered) return;
        _registered = true;
        ref.read(radialPaletteProvider.notifier).registerTargets([
          PaletteTarget(
            id: sectionId,
            key: _titleKey,
            kind: TargetKind.sectionTitle,
            tools: {
              PaletteTool.text,
              PaletteTool.paint,
            },
            onApply: (tool, color, scope) {
              if (tool == PaletteTool.text && mounted) {
                setState(() {
                  _textColor = color;
                });
              }
            },
          ),
        ]);
      });
    }
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: FocusGlow(
          isFocused: isFocused,
          borderRadius: BorderRadius.circular(12), // kleine Radien an den Ecken
          child: Text(
            widget.title,
            key: _titleKey,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _textColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _GridSection extends ConsumerStatefulWidget {
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
  ConsumerState<_GridSection> createState() => _GridSectionState();
}

class _GridSectionState extends ConsumerState<_GridSection> {
  late final List<GlobalKey> _tileKeys;
  late final List<GlobalKey> _titleKeys;
  late final List<GlobalKey> _countKeys;
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    final len = widget.subs.length;
    _tileKeys  = List.generate(len, (_) => GlobalKey());
    _titleKeys = List.generate(len, (_) => GlobalKey());
    _countKeys = List.generate(len, (_) => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    // 2) Zu JEDEM Sub: Tile + Titel + Counter als eigene Targets
    final targets = <PaletteTarget>[];
    for (var i = 0; i < widget.subs.length; i++) {
      final sub = widget.subs[i];
      final baseId = 'wordHub.${widget.sectionKey}.${sub.key}';

      // a) Ganze Kachel
      targets.add(PaletteTarget(
        id: baseId,
        key: _tileKeys[i],
        kind: TargetKind.tile,
        tools: {
          PaletteTool.stroke,
          PaletteTool.fill,
          PaletteTool.icon,
          PaletteTool.image,
          PaletteTool.paint,
          // Text-Tool wird NICHT unterstützt - nur Titel und Counter haben Text-Tool
        },
        onApply: (tool, color, scope) {
          if (tool == PaletteTool.stroke) {
            ref.read(wordHubTileOverridesProvider.notifier)
                .setStrokeColor(baseId, color);
          } else if (tool == PaletteTool.fill) {
            ref.read(wordHubTileOverridesProvider.notifier)
                .setFillColor(baseId, color);
          }
        },
      ));

      // b) Titel-Text in der Kachel
      targets.add(PaletteTarget(
        id: '$baseId.title',
        key: _titleKeys[i],
        kind: TargetKind.text,
        tools: {
          PaletteTool.text,
          PaletteTool.paint,
        },
        onApply: (tool, color, scope) {
          if (tool == PaletteTool.text) {
            ref.read(wordHubTileOverridesProvider.notifier)
                .setTitleColor(baseId, color);
          }
        },
      ));

      // c) Counter-Zahl in der Kachel
      targets.add(PaletteTarget(
        id: '$baseId.count',
        key: _countKeys[i],
        kind: TargetKind.text,
        tools: {
          PaletteTool.text,
          PaletteTool.paint,
        },
        onApply: (tool, color, scope) {
          if (tool == PaletteTool.text) {
            ref.read(wordHubTileOverridesProvider.notifier)
                .setCountColor(baseId, color);
          }
        },
      ));
    }

    // 3) Targets nach dem Frame einmalig registrieren
    if (!_registered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _registered || targets.isEmpty) return;
        _registered = true;
        ref.read(radialPaletteProvider.notifier).registerTargets(targets);
      });
    }

    // 4) Grid ganz normal bauen, aber die vorbereiteten Keys verwenden
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final sub = widget.subs[i];
            final baseId = 'wordHub.${widget.sectionKey}.${sub.key}';

            return _HighlightableTarget(
              id: baseId, // ganze Kachel
              child: CategoryCard(
                key: _tileKeys[i],
                paletteId: baseId,
                sectionKey: widget.sectionKey,
                sub: sub,
                // 🔽 NEU: Keys für Titel & Counter in die Kachel hineinreichen
                titleKey: _titleKeys[i],
                countKey: _countKeys[i],
                onTap: widget.onTapSub == null ? null : () => widget.onTapSub!(sub),
              ),
            );
          },
          childCount: widget.subs.length,
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

class _HighlightableTarget extends ConsumerWidget {
  const _HighlightableTarget({
    super.key,
    required this.id,
    required this.child,
  });

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(radialPaletteProvider);

    final glowColor = palette.selectionGlowColor ?? Colors.white.withOpacity(0.6);
    bool isFocused = false;

    if (palette.activeTool != null) {
      // Bei ONE: nur aktuelles Target
      // Bei ALL: alle Targets, die das Tool unterstützen (werden in toggleScope() gesetzt)
      isFocused = palette.focusedIds.contains(id);
    }

    if (!isFocused) {
      return child;
    }

    // Bei ONE und ALL: nur Rahmen, kein Glow
    final showGlow = false; // Kein Glow mehr, nur Rahmen
    
    // Rahmenfarbe: Rot wenn gelockt, sonst weiß
    final borderColor = palette.isBallLocked ? Colors.redAccent : Colors.white;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24), // Angepasst an Kachel-Radius
                border: Border.all(
                  color: borderColor, // Rot wenn gelockt, sonst weiß
                  width: 6, // Deutlich fetterer Rahmen
                ),
                boxShadow: showGlow
                    ? [
                        BoxShadow(
                          color: glowColor.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : [], // Leere Liste statt null, damit kein Glow angezeigt wird
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
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
