import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';
import 'package:talvori/core/local_database/providers/local_category_detail_group_items_provider.dart';
import 'package:talvori/features/home/application/profile_preferences_controller.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impulse_chat_detail_screen.dart';
import 'package:talvori/features/words/application/sort/category_stroke_colors.dart';
import 'package:talvori/features/words/application/word_hub_glow_provider.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/data/word_world_display_names.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/word_providers.dart';
import 'package:talvori/features/words/application/category_stats_provider.dart';
import 'package:talvori/features/words/ui/widgets/category_card.dart';
// ⬇️ NEU
import 'package:talvori/features/words/application/radial_palette_controller.dart';
import 'package:talvori/features/words/application/word_hub_tile_overrides_provider.dart';
import 'package:talvori/features/words/ui/widgets/glow_toggle_button.dart';
import 'package:talvori/features/words/ui/widgets/radial_palette_tools.dart';
import 'package:talvori/features/words/ui/widgets/radial_palette_sheet.dart';
import 'package:talvori/features/words/ui/widgets/slide_hint_button.dart';

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
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: effectivePadding,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [], // Kein Glow mehr, nur Rahmen
      ),
      child: child,
    );
  }
}

class WordHubScreen extends ConsumerStatefulWidget {
  const WordHubScreen({super.key, this.useLocalOfflineFlow = false});

  final bool useLocalOfflineFlow;

  @override
  ConsumerState<WordHubScreen> createState() => _WordHubScreenState();
}

class _WordHubScreenState extends ConsumerState<WordHubScreen> {
  static const double _frontButtonWidth = 120.0;
  static const double _maxReveal = 90.0;

  final SlideHintController _slideCtrl = SlideHintController();
  final ScrollController _scroll = ScrollController();
  bool _allowHints = true;
  bool _isRadialOpen = false;
  bool _callbackSet =
      false; // Flag um zu verhindern, dass Callback mehrfach gesetzt wird
  bool _headerTargetsRegistered =
      false; // Flag um zu verhindern, dass Header-Targets mehrfach registriert werden

  // Farb-Overrides für Header-Elemente
  Color? _searchFieldStrokeColor;
  Color? _searchFieldFillColor;
  Color? _searchFieldIconColor;
  Color? _unlockButtonStrokeColor;
  Color? _unlockButtonFillColor;
  Color? _unlockButtonTextColor;
  Color? _hubBackgroundColor;

  static const String _headerOverridesKey = 'word_hub_header_overrides';

  /// Lädt die gespeicherten Header-Overrides aus SharedPreferences
  Future<void> _loadHeaderOverrides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final overridesJson = prefs.getString(_headerOverridesKey);

      if (overridesJson != null) {
        final Map<String, dynamic> overridesMap = json.decode(overridesJson);

        if (mounted) {
          setState(() {
            _searchFieldStrokeColor =
                overridesMap['searchFieldStrokeColor'] != null
                ? Color(
                    int.parse(overridesMap['searchFieldStrokeColor'] as String),
                  )
                : null;
            _searchFieldFillColor = overridesMap['searchFieldFillColor'] != null
                ? Color(
                    int.parse(overridesMap['searchFieldFillColor'] as String),
                  )
                : null;
            _searchFieldIconColor = overridesMap['searchFieldIconColor'] != null
                ? Color(
                    int.parse(overridesMap['searchFieldIconColor'] as String),
                  )
                : null;
            _unlockButtonStrokeColor =
                overridesMap['unlockButtonStrokeColor'] != null
                ? Color(
                    int.parse(
                      overridesMap['unlockButtonStrokeColor'] as String,
                    ),
                  )
                : null;
            _unlockButtonFillColor =
                overridesMap['unlockButtonFillColor'] != null
                ? Color(
                    int.parse(overridesMap['unlockButtonFillColor'] as String),
                  )
                : null;
            _unlockButtonTextColor =
                overridesMap['unlockButtonTextColor'] != null
                ? Color(
                    int.parse(overridesMap['unlockButtonTextColor'] as String),
                  )
                : null;
            _hubBackgroundColor = overridesMap['hubBackgroundColor'] != null
                ? Color(int.parse(overridesMap['hubBackgroundColor'] as String))
                : null;
          });
        }
      }
    } catch (e) {}
  }

  /// Speichert die Header-Overrides in SharedPreferences
  Future<void> _saveHeaderOverrides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> overridesMap = {};

      if (_searchFieldStrokeColor != null) {
        overridesMap['searchFieldStrokeColor'] = _searchFieldStrokeColor!.value
            .toString();
      }
      if (_searchFieldFillColor != null) {
        overridesMap['searchFieldFillColor'] = _searchFieldFillColor!.value
            .toString();
      }
      if (_searchFieldIconColor != null) {
        overridesMap['searchFieldIconColor'] = _searchFieldIconColor!.value
            .toString();
      }
      if (_unlockButtonStrokeColor != null) {
        overridesMap['unlockButtonStrokeColor'] = _unlockButtonStrokeColor!
            .value
            .toString();
      }
      if (_unlockButtonFillColor != null) {
        overridesMap['unlockButtonFillColor'] = _unlockButtonFillColor!.value
            .toString();
      }
      if (_unlockButtonTextColor != null) {
        overridesMap['unlockButtonTextColor'] = _unlockButtonTextColor!.value
            .toString();
      }
      if (_hubBackgroundColor != null) {
        overridesMap['hubBackgroundColor'] = _hubBackgroundColor!.value
            .toString();
      }

      final overridesJson = json.encode(overridesMap);
      await prefs.setString(_headerOverridesKey, overridesJson);
    } catch (e) {}
  }

  // Keys für Auto-Scroll
  final _keysById = <String, GlobalKey>{
    'wordHub.title': GlobalKey(),
    'wordHub.search': GlobalKey(),
    'wordHub.searchIcon': GlobalKey(),
    'wordHub.unlockButton': GlobalKey(),
    'wordHub.glowToggle': GlobalKey(), // NEU: Key für GlowToggleButton
  };
  String? _lastPrimaryId;

  // Header-Keys (werden nur einmal erstellt)
  late final GlobalKey _titleKey = GlobalKey();
  late final GlobalKey _backKey = GlobalKey();
  late final GlobalKey _unlockKey = GlobalKey();
  late final GlobalKey _searchKey = GlobalKey();
  late final GlobalKey _searchIconKey = GlobalKey();
  late final GlobalKey _glowToggleKey =
      GlobalKey(); // NEU: Key für GlowToggleButton

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
              ref.read(radialPaletteProvider.notifier).onFocusChange =
                  _handleFocusChange;
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
    if (!mounted || !_isRadialOpen) {
      return;
    }

    // 1) Primäre ID bestimmen
    final String? primaryId = ids.isEmpty ? null : ids.first;

    // WICHTIG: Wenn leere IDs gesendet werden, setze _lastPrimaryId zurück (für Position-Wiederherstellung)
    if (primaryId == null) {
      _lastPrimaryId = null;
      return;
    }

    // 2) Basis-ID extrahieren (falls es .title oder .count ist, zur Kachel-ID zurückfallen)
    final baseId = primaryId.replaceAll(RegExp(r'\.(title|count)$'), '');

    // WICHTIG: Wenn die ID gleich _lastPrimaryId ist, prüfe ob wir trotzdem scrollen sollten
    // (z.B. wenn die Position wiederhergestellt wurde und das Widget noch nicht gerendert ist)
    final bool shouldScroll = primaryId != _lastPrimaryId;
    if (!shouldScroll) {
      // Prüfe, ob das Widget bereits gerendert ist
      final paletteState = ref.read(radialPaletteProvider);
      PaletteTarget? target;
      for (final t in paletteState.targets) {
        if (t.id == baseId && t.kind == TargetKind.tile) {
          target = t;
          break;
        }
      }
      if (target == null) {
        for (final t in paletteState.targets) {
          if (t.id == primaryId) {
            target = t;
            break;
          }
        }
      }
      if (target != null) {
        final ctx = target.key.currentContext;
        if (ctx == null) {
          // Widget noch nicht gerendert - trotzdem scrollen versuchen
          // Setze _lastPrimaryId zurück, damit das Scrollen ausgelöst wird
          _lastPrimaryId = null;
        } else {
          return;
        }
      } else {
        return;
      }
    }
    _lastPrimaryId = primaryId;

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

    if (target == null) {
      return;
    }

    final key = target.key;

    // 4) Scrollen, so dass das Element VOR dem Rad sichtbar ist (smooth Animation)
    // WICHTIG: Wenn die Kachel nicht gerendert ist, zuerst zum Section-Title scrollen
    void _tryScroll(int attempt, {bool scrolledToSectionTitle = false}) {
      if (!mounted || !_isRadialOpen) {
        return;
      }

      final ctx = key.currentContext;
      if (ctx == null) {
        // Widget noch nicht gerendert
        if (!scrolledToSectionTitle && attempt < 3) {
          // Versuche zuerst zum Section-Title zu scrollen, damit die Kachel in den Viewport kommt
          // baseId ist z.B. "wordHub.society_systems.school_studies" -> Section-Title ist "wordHub.sectionTitle.society_systems"
          final parts = baseId.split('.');
          if (parts.length >= 3) {
            final sectionKey = parts[1]; // z.B. "society_systems"
            final sectionTitleId = 'wordHub.sectionTitle.$sectionKey';

            final paletteState = ref.read(radialPaletteProvider);
            PaletteTarget? sectionTitleTarget;
            for (final t in paletteState.targets) {
              if (t.id == sectionTitleId) {
                sectionTitleTarget = t;
                break;
              }
            }

            if (sectionTitleTarget != null) {
              final sectionTitleCtx = sectionTitleTarget.key.currentContext;
              if (sectionTitleCtx != null) {
                try {
                  Scrollable.ensureVisible(
                    sectionTitleCtx,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOutCubic,
                    alignment: 0.18,
                  );
                  // Nach kurzer Verzögerung erneut versuchen, zur Kachel zu scrollen
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _tryScroll(attempt + 1, scrolledToSectionTitle: true);
                  });
                  return;
                } catch (e) {
                  // Fehler ignorieren
                }
              }
            }
          }
        }

        if (attempt < 20) {
          // Widget noch nicht gerendert - erneut versuchen nach längerer Verzögerung
          final delay = (attempt < 5)
              ? 100
              : (attempt < 10)
              ? 200
              : 300;
          Future.delayed(Duration(milliseconds: delay), () {
            _tryScroll(
              attempt + 1,
              scrolledToSectionTitle: scrolledToSectionTitle,
            );
          });
        }
        return;
      }

      try {
        // Smooth Animation mit längerer Duration und besserer Curve
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(
            milliseconds: 300,
          ), // Längere Duration für smooth Animation
          curve: Curves.easeInOutCubic, // Smooth, fließende Kurve
          // 0 = ganz oben, 1 = ganz unten
          // etwas über der Mitte, damit es nicht vom Rad verdeckt wird
          alignment: 0.18,
        );
      } catch (e) {
        // Scroll-Fehler ignorieren
      }
    }

    // Starte den ersten Versuch nach einem Frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryScroll(0);
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
    if (widget.useLocalOfflineFlow) {
      return _buildLocalOfflineFlow(context);
    }

    // ✅ Einmalig beim WordHub-Start: Ensure Progress-Rows für alle Kategorien
    // Fehler werden ignoriert, damit WordHub trotzdem lädt
    final ensureAsync = ref.watch(ensureAllProgressProvider);
    ensureAsync.when(
      data: (count) => debugPrint('✅ ensureAllProgress: $count Rows'),
      loading: () => debugPrint('⏳ ensureAllProgress: Loading...'),
      error: (err, st) =>
          debugPrint('⚠️ ensureAllProgress Fehler (ignoriert): $err'),
    );

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final repo = ref.read(wordHubControllerProvider.notifier).repo;
    final glowEnabled = ref.watch(wordHubGlowProvider);
    final radialPalette = ref.watch(radialPaletteProvider);
    final focusedIds = radialPalette.focusedIds;
    final nativeLanguage = ref.watch(
      profilePreferencesControllerProvider.select(
        (preferences) => preferences.nativeLanguage,
      ),
    );

    // Extra Platz nur, wenn der Fokus auf den letzten sichtbaren Wortwelt-Kacheln ist.
    final bool isNearBottom =
        _isRadialOpen &&
        focusedIds.isNotEmpty &&
        focusedIds.first.contains('culture_creativity');

    // Header-Overrides beim ersten Build laden
    if (!_headerTargetsRegistered) {
      _loadHeaderOverrides();
    }

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
          // "Alles freischalten" Button ist NICHT selektierbar (keine Tools)
          PaletteTarget(
            id: 'wordHub.unlockButton',
            key: _unlockKey,
            kind: TargetKind.button,
            tools: {}, // NEU: Keine Tools, nicht selektierbar
          ),
          // NEU: GlowToggleButton ist selektierbar
          PaletteTarget(
            id: 'wordHub.glowToggle',
            key: _glowToggleKey,
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
                _saveHeaderOverrides();
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
                _saveHeaderOverrides();
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
                _saveHeaderOverrides();
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
                _saveHeaderOverrides();
              }
            },
          ),
        ];
        ref.read(radialPaletteProvider.notifier).registerTargets(headerTargets);
      });
    }

    // Sektionen-Widgets erstellen
    final sectionWidgets = <Widget>[];
    for (final section in wordWorldHubSections) {
      sectionWidgets.add(
        _SectionHeader(
          wordHubGroupDisplayName(
            section.key,
            fallbackName: section.title,
            nativeLanguage: nativeLanguage,
          ),
          section.key,
        ),
      );
      sectionWidgets.add(
        _GridSection(
          sectionKey: section.key,
          subs: section.subcats,
          repo: repo,
          nativeLanguage: nativeLanguage,
          onTapSub: (sub) async {
            String? catId;
            try {
              catId = (sub.supabaseId != null && sub.supabaseId!.isNotEmpty)
                  ? sub.supabaseId
                  : await repo.findCategoryIdByName(sub.label);
            } catch (_) {
              catId = null;
            }

            final displayLabel = wordHubItemDisplayName(
              sub.key,
              fallbackName: sub.label,
              nativeLanguage: nativeLanguage,
            );

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

            final categoryRoute = catId != null
                ? MaterialPageRoute(
                    builder: (_) => CategoryDetailScreen(
                      title: displayLabel,
                      categoryId: catId,
                      categorySlug: null,
                      listFilter: WordListFilter(
                        WordFilterKind.category,
                        catId!,
                      ),
                    ),
                  )
                : MaterialPageRoute(
                    builder: (_) {
                      final (kind, value) = _mapToFilter(
                        section.key,
                        sub.label,
                      );
                      return CategoryDetailScreen(
                        title: displayLabel,
                        categoryId: null,
                        categorySlug: _slugifyLocal(sub.label),
                        listFilter: WordListFilter(kind, value),
                      );
                    },
                  );

            Navigator.of(context).push(categoryRoute);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: _hubBackgroundColor ?? Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:
            _hubBackgroundColor?.withOpacity(0.87) ?? Colors.black87,
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
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // kleine Radien an den Ecken
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
                child: KeyedSubtree(
                  key: _keysById['wordHub.glowToggle'],
                  child: FocusGlow(
                    isFocused: focusedIds.contains('wordHub.glowToggle'),
                    borderRadius: BorderRadius.circular(
                      24,
                    ), // Gleiche Form wie Button
                    padding: EdgeInsets.zero, // kein Padding für Buttons
                    child: GlowToggleButton(
                      key: _glowToggleKey,
                      glowEnabled: glowEnabled,
                      onToggle: () => _handleGlowToggle(glowEnabled),
                      strokeColor:
                          _unlockButtonStrokeColor, // NEU: Override-Farbe für Border
                      fillColor:
                          _unlockButtonFillColor, // NEU: Override-Farbe für Fill
                      textColor:
                          _unlockButtonTextColor, // NEU: Override-Farbe für Icon
                    ),
                  ),
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
                    child: _buildFrontButton(
                      key: _unlockKey,
                    ), // NEU: Kein FocusGlow mehr, nicht selektierbar
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
                          borderRadius: BorderRadius.circular(
                            999,
                          ), // gleiche Pill-Form wie Feld
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
                                    filter: WordListFilter(
                                      WordFilterKind.query,
                                      query,
                                    ),
                                  ),
                                ),
                              );
                            },
                            decoration: InputDecoration(
                              hintText: 'Suchen',
                              prefixIcon: KeyedSubtree(
                                key: _keysById['wordHub.searchIcon'],
                                child: FocusGlow(
                                  isFocused: focusedIds.contains(
                                    'wordHub.searchIcon',
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  padding: EdgeInsets.zero,
                                  child: Icon(
                                    Icons.search,
                                    key: _searchIconKey,
                                    color:
                                        _searchFieldIconColor ??
                                        const Color(0xFFF1C86B),
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  _searchFieldFillColor ??
                                  Colors.white.withOpacity(0.12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: BorderSide(
                                  color:
                                      _searchFieldStrokeColor ??
                                      const Color(0xFFF1C86B).withOpacity(0.85),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: BorderSide(
                                  color:
                                      _searchFieldStrokeColor ??
                                      const Color(0xFFF1C86B),
                                  width: 1.6,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: BorderSide(
                                  color:
                                      _searchFieldStrokeColor ??
                                      const Color(0xFFF1C86B),
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
                  onToolReset: (tool) {
                    // Header-Elemente zurücksetzen basierend auf Tool
                    if (mounted) {
                      setState(() {
                        switch (tool) {
                          case PaletteTool.stroke:
                            _searchFieldStrokeColor = null;
                            _unlockButtonStrokeColor = null;
                            break;
                          case PaletteTool.fill:
                            _searchFieldFillColor = null;
                            _unlockButtonFillColor = null;
                            break;
                          case PaletteTool.text:
                            _unlockButtonTextColor = null;
                            break;
                          case PaletteTool.icon:
                            _searchFieldIconColor = null;
                            break;
                          case PaletteTool.hubBackground:
                            _hubBackgroundColor = null;
                            break;
                          case PaletteTool.paint:
                          case PaletteTool.image:
                            break;
                        }
                      });
                      _saveHeaderOverrides();
                    }
                  },
                  onResetAll: () {
                    // NEU: Alle Overrides und Header-Elemente zurücksetzen
                    if (mounted) {
                      // Alle Tile-Overrides zurücksetzen
                      ref
                          .read(wordHubTileOverridesProvider.notifier)
                          .resetAllOverrides();

                      // Alle Header-Elemente zurücksetzen
                      setState(() {
                        _searchFieldStrokeColor = null;
                        _searchFieldFillColor = null;
                        _searchFieldIconColor = null;
                        _unlockButtonStrokeColor = null;
                        _unlockButtonFillColor = null;
                        _unlockButtonTextColor = null;
                        _hubBackgroundColor = null;
                      });
                      _saveHeaderOverrides();
                    }
                  },
                  onResetAllStart: () {
                    // NEU: Reset-Start (Label wird angezeigt)
                  },
                  onResetAllEnd: () {
                    // NEU: Reset-Ende (Label wird ausgeblendet)
                  },
                ),
              ),
            ),

          // 4) Toggle-Button unten rechts – immer ganz oben
          Positioned(right: 24, bottom: 24, child: _buildRadialToggleButton()),

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

  Widget _buildLocalOfflineFlow(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final glowEnabled = ref.watch(wordHubGlowProvider);
    final radialPalette = ref.watch(radialPaletteProvider);
    final focusedIds = radialPalette.focusedIds;
    final nativeLanguage = ref.watch(
      profilePreferencesControllerProvider.select(
        (preferences) => preferences.nativeLanguage,
      ),
    );

    return Scaffold(
      backgroundColor: _hubBackgroundColor ?? Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:
            _hubBackgroundColor?.withValues(alpha: 0.87) ?? Colors.black87,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          key: _backKey,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
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
                      borderRadius: BorderRadius.circular(12),
                      child: Text(
                        'Wortwelten',
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
                child: KeyedSubtree(
                  key: _keysById['wordHub.glowToggle'],
                  child: FocusGlow(
                    isFocused: focusedIds.contains('wordHub.glowToggle'),
                    borderRadius: BorderRadius.circular(24),
                    padding: EdgeInsets.zero,
                    child: GlowToggleButton(
                      key: _glowToggleKey,
                      glowEnabled: glowEnabled,
                      onToggle: () => _handleGlowToggle(glowEnabled),
                      strokeColor: _unlockButtonStrokeColor,
                      fillColor: _unlockButtonFillColor,
                      textColor: _unlockButtonTextColor,
                    ),
                  ),
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
                    child: _buildFrontButton(key: _unlockKey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: KeyedSubtree(
                    key: _keysById['wordHub.search'],
                    child: FocusGlow(
                      isFocused: focusedIds.contains('wordHub.search'),
                      borderRadius: BorderRadius.circular(999),
                      padding: EdgeInsets.zero,
                      child: TextField(
                        key: _searchKey,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (q) {
                          final query = q.trim();
                          if (query.isEmpty) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Lokale Suche ist noch nicht angebunden',
                              ),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Suchen',
                          prefixIcon: KeyedSubtree(
                            key: _keysById['wordHub.searchIcon'],
                            child: FocusGlow(
                              isFocused: focusedIds.contains(
                                'wordHub.searchIcon',
                              ),
                              borderRadius: BorderRadius.circular(999),
                              padding: EdgeInsets.zero,
                              child: Icon(
                                Icons.search,
                                key: _searchIconKey,
                                color:
                                    _searchFieldIconColor ??
                                    const Color(0xFFF1C86B),
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor:
                              _searchFieldFillColor ??
                              Colors.white.withValues(alpha: 0.12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color:
                                  _searchFieldStrokeColor ??
                                  const Color(
                                    0xFFF1C86B,
                                  ).withValues(alpha: 0.85),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color:
                                  _searchFieldStrokeColor ??
                                  const Color(0xFFF1C86B),
                              width: 1.6,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color:
                                  _searchFieldStrokeColor ??
                                  const Color(0xFFF1C86B),
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
              for (final section in wordWorldHubSections) ...[
                _SectionHeader(
                  wordHubGroupDisplayName(
                    section.key,
                    fallbackName: section.title,
                    nativeLanguage: nativeLanguage,
                  ),
                  section.key,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final sub = section.subcats[index];
                      final localCategoryItems =
                          ref
                              .watch(
                                localCategoryDetailGroupItemsProvider(sub.key),
                              )
                              .valueOrNull ??
                          const <LocalCategoryDetailGroupItem>[];
                      final localCategoryIds = localCategoryItems
                          .map((item) => item.localCategoryId)
                          .whereType<String>()
                          .toList(growable: false);
                      final tappedLocalItem = _localItemForWordHubKey(
                        localCategoryItems,
                        sub.key,
                      );
                      final mappedLocalCategoryId =
                          tappedLocalItem?.localCategoryId;
                      final displayLabel = wordHubItemDisplayName(
                        sub.key,
                        fallbackName: sub.label,
                        nativeLanguage: nativeLanguage,
                      );
                      return _LocalTaxonomyCategoryCard(
                        sub: sub,
                        displayLabel: displayLabel,
                        localCategoryId: mappedLocalCategoryId,
                        localWordCount: tappedLocalItem?.vocabsCount,
                        glowEnabled: glowEnabled,
                        onChatTap: mappedLocalCategoryId == null
                            ? null
                            : () {
                                final navigator = Navigator.of(context);
                                ref
                                    .read(
                                      impulseInboxControllerProvider.notifier,
                                    )
                                    .ensureCategoryChat(
                                      categoryId: mappedLocalCategoryId,
                                      title: displayLabel,
                                    )
                                    .then((chat) {
                                      if (!context.mounted) return;
                                      unawaited(
                                        navigator.push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ImpulseChatDetailScreen(
                                                  chatId: chat.id,
                                                ),
                                          ),
                                        ),
                                      );
                                    });
                              },
                        onTap: () {
                          if (mappedLocalCategoryId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Noch nicht lokal verfügbar'),
                              ),
                            );
                            return;
                          }

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CategoryDetailScreen(
                                categoryId: mappedLocalCategoryId,
                                title: displayLabel,
                                listFilter: WordListFilter(
                                  WordFilterKind.category,
                                  mappedLocalCategoryId,
                                ),
                                useLocalOfflineFlow: true,
                                localCategoryId: mappedLocalCategoryId,
                                localCategoryIds: localCategoryIds,
                                localCategoryItems: localCategoryItems,
                                localSelectedWordHubKey: sub.key,
                              ),
                            ),
                          );
                        },
                      );
                    }, childCount: section.subcats.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                  ),
                ),
              ],
              SliverToBoxAdapter(child: SizedBox(height: bottomInset + 10)),
            ],
          ),
        ],
      ),
    );
  }
}

LocalCategoryDetailGroupItem? _localItemForWordHubKey(
  List<LocalCategoryDetailGroupItem> items,
  String wordHubKey,
) {
  final normalizedKey = wordHubKey.trim().toLowerCase();
  for (final item in items) {
    if (item.wordHubKey == normalizedKey) {
      return item;
    }
  }
  return null;
}

class _LocalTaxonomyCategoryCard extends StatelessWidget {
  const _LocalTaxonomyCategoryCard({
    required this.sub,
    required this.displayLabel,
    required this.localCategoryId,
    required this.localWordCount,
    required this.glowEnabled,
    required this.onChatTap,
    required this.onTap,
  });

  final HubSubcat sub;
  final String displayLabel;
  final String? localCategoryId;
  final int? localWordCount;
  final bool glowEnabled;
  final VoidCallback? onChatTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strokeColor = CategoryStrokeColors.getStrokeColor(sub.label);
    final fillColor = Color.lerp(const Color(0xFF050505), strokeColor, 0.10)!;
    return Material(
      key: Key('word_hub_category_card_${sub.key}'),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.none,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        overlayColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        ),
        splashFactory: InkRipple.splashFactory,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: glowEnabled
                ? [
                    BoxShadow(
                      color: strokeColor.withValues(alpha: 0.20),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: strokeColor.withValues(alpha: 0.10),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ]
                : const [],
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [fillColor, const Color(0xFF050507)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: strokeColor.withValues(alpha: 0.72),
                width: 1.6,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 1,
                    ),
                    color: const Color(0xFF08080A).withValues(alpha: 0.74),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayLabel,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textWidthBasis: TextWidthBasis.parent,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1.12,
                              ),
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (onChatTap != null)
                              _CategoryChatButton(
                                categoryId: localCategoryId!,
                                color: strokeColor,
                                onTap: onChatTap!,
                              )
                            else
                              const SizedBox(width: 34, height: 34),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      localCategoryId == null
                                          ? 'local pending'
                                          : '${localWordCount ?? 0}',
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: localCategoryId == null
                                            ? Colors.white54
                                            : strokeColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChatButton extends StatelessWidget {
  const _CategoryChatButton({
    required this.categoryId,
    required this.color,
    required this.onTap,
  });

  final String categoryId;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: Key('word_hub_category_chat_button_$categoryId'),
      width: 34,
      height: 34,
      child: DecoratedBox(
        key: Key('word_hub_category_chat_circle_$categoryId'),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF07111A).withValues(alpha: 0.92),
          border: Border.all(color: color.withValues(alpha: 0.75)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 14),
          ],
        ),
        child: ClipOval(
          child: IconButton(
            tooltip: 'Kategorie-Chat öffnen',
            padding: EdgeInsets.zero,
            splashRadius: 18,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF7FFFE7),
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: color.withValues(alpha: 0.12),
            ),
            onPressed: onTap,
            icon: const Icon(
              Icons.mark_unread_chat_alt_rounded,
              color: Color(0xFF7FFFE7),
              size: 17,
            ),
          ),
        ),
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
            tools: {PaletteTool.text, PaletteTool.paint},
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
  final String nativeLanguage;
  final void Function(HubSubcat sub)? onTapSub;

  const _GridSection({
    required this.sectionKey,
    required this.subs,
    required this.repo,
    required this.nativeLanguage,
    this.onTapSub,
  });

  @override
  ConsumerState<_GridSection> createState() => _GridSectionState();
}

class _GridSectionState extends ConsumerState<_GridSection> {
  late final List<GlobalKey> _tileKeys;
  late final List<GlobalKey> _titleKeys;
  late final List<GlobalKey> _countKeys;
  late final List<GlobalKey> _iconKeys; // NEU: Keys für Icons/Emojis
  Map<String, bool>?
  _lastIconEmojiState; // NEU: Speichert vorherigen Zustand der Icons/Emojis
  bool _registered = false; // NEU: Flag für einmalige Registrierung

  @override
  void initState() {
    super.initState();
    final len = widget.subs.length;
    _tileKeys = List.generate(len, (_) => GlobalKey());
    _titleKeys = List.generate(len, (_) => GlobalKey());
    _countKeys = List.generate(len, (_) => GlobalKey());
    _iconKeys = List.generate(
      len,
      (_) => GlobalKey(),
    ); // NEU: Keys für Icons/Emojis
  }

  // Hilfsmethode zum Vergleichen von Maps
  bool _mapsEqual(Map<String, bool> map1, Map<String, bool> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Aktuelle Overrides lesen, um zu prüfen, welche Kacheln Icons/Emojis haben
    final overrides = ref.watch(wordHubTileOverridesProvider);

    // NEU: Prüfe, ob sich der Icon/Emoji-Zustand geändert hat
    final currentIconEmojiState = <String, bool>{};
    for (var i = 0; i < widget.subs.length; i++) {
      final sub = widget.subs[i];
      final baseId = 'wordHub.${widget.sectionKey}.${sub.key}';
      final tileOverrides = overrides[baseId];
      currentIconEmojiState[baseId] =
          tileOverrides?.icon != null || tileOverrides?.emoji != null;
    }

    final iconEmojiStateChanged =
        _lastIconEmojiState == null ||
        !_mapsEqual(_lastIconEmojiState!, currentIconEmojiState);

    // 2) Zu JEDEM Sub: Tile + Titel + Counter als eigene Targets
    final targets = <PaletteTarget>[];
    for (var i = 0; i < widget.subs.length; i++) {
      final sub = widget.subs[i];
      final baseId = 'wordHub.${widget.sectionKey}.${sub.key}';
      final tileOverrides = overrides[baseId];
      final hasIconOrEmoji =
          tileOverrides?.icon != null || tileOverrides?.emoji != null;

      // a) Ganze Kachel
      targets.add(
        PaletteTarget(
          id: baseId,
          key: _tileKeys[i],
          kind: TargetKind.tile,
          tools: {
            PaletteTool.stroke,
            PaletteTool.fill,
            // PaletteTool.icon wird NICHT unterstützt - nur Icon-Targets haben Icon-Tool
            // Tile-Targets werden nur zum Platzieren von Icons/Emojis verwendet, nicht zum Einfärben
            PaletteTool.image,
            PaletteTool.paint,
            // Text-Tool wird NICHT unterstützt - nur Titel und Counter haben Text-Tool
          },
          onApply: (tool, color, scope) {
            // WICHTIG: Tile-Targets unterstützen nur stroke und fill, NICHT icon!
            if (tool == PaletteTool.stroke) {
              ref
                  .read(wordHubTileOverridesProvider.notifier)
                  .setStrokeColor(baseId, color);
            } else if (tool == PaletteTool.fill) {
              ref
                  .read(wordHubTileOverridesProvider.notifier)
                  .setFillColor(baseId, color);
            }
          },
          onApplyIcon: (icon, scope) {
            ref
                .read(wordHubTileOverridesProvider.notifier)
                .setIcon(baseId, icon);
          },
          onApplyEmoji: (emoji, scope) {
            ref
                .read(wordHubTileOverridesProvider.notifier)
                .setEmoji(baseId, emoji);
          },
          onClearIconEmoji: (scope) {
            ref
                .read(wordHubTileOverridesProvider.notifier)
                .clearIconEmoji(baseId);
          },
        ),
      );

      // NEU: d) Icon/Emoji in der Kachel (nur wenn vorhanden)
      if (hasIconOrEmoji) {
        targets.add(
          PaletteTarget(
            id: '$baseId.icon',
            key: _iconKeys[i],
            kind: TargetKind.icon,
            tools: {PaletteTool.icon}, // Nur Icon Tool unterstützt
            onApply: (tool, color, scope) {
              if (tool == PaletteTool.icon) {
                ref
                    .read(wordHubTileOverridesProvider.notifier)
                    .setIconColor(baseId, color);
              }
            },
          ),
        );
      }

      // b) Titel-Text in der Kachel
      targets.add(
        PaletteTarget(
          id: '$baseId.title',
          key: _titleKeys[i],
          kind: TargetKind.text,
          tools: {PaletteTool.text, PaletteTool.paint},
          onApply: (tool, color, scope) {
            if (tool == PaletteTool.text) {
              ref
                  .read(wordHubTileOverridesProvider.notifier)
                  .setTitleColor(baseId, color);
            }
          },
        ),
      );

      // c) Counter-Zahl in der Kachel
      targets.add(
        PaletteTarget(
          id: '$baseId.count',
          key: _countKeys[i],
          kind: TargetKind.text,
          tools: {PaletteTool.text, PaletteTool.paint},
          onApply: (tool, color, scope) {
            if (tool == PaletteTool.text) {
              ref
                  .read(wordHubTileOverridesProvider.notifier)
                  .setCountColor(baseId, color);
            }
          },
        ),
      );
    }

    // 3) Targets nach dem Frame registrieren (nur wenn sich etwas geändert hat)
    if (!_registered || iconEmojiStateChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || targets.isEmpty) return;
        ref.read(radialPaletteProvider.notifier).registerTargets(targets);
        if (!_registered) {
          _registered = true;
        }
        if (iconEmojiStateChanged) {
          _lastIconEmojiState = Map<String, bool>.from(currentIconEmojiState);
          // WICHTIG: Fokus NICHT aktualisieren, damit der Selektor auf der aktuellen Kachel bleibt
          // Die Icon-Targets werden automatisch erkannt, wenn sie hinzugefügt werden
        }
      });
    }

    // 4) Grid ganz normal bauen, aber die vorbereiteten Keys verwenden
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, i) {
          final sub = widget.subs[i];
          final baseId = 'wordHub.${widget.sectionKey}.${sub.key}';
          final displayLabel = wordHubItemDisplayName(
            sub.key,
            fallbackName: sub.label,
            nativeLanguage: widget.nativeLanguage,
          );

          return _HighlightableTarget(
            id: baseId, // ganze Kachel
            child: CategoryCard(
              key: _tileKeys[i],
              paletteId: baseId,
              sectionKey: widget.sectionKey,
              sub: sub,
              displayLabel: displayLabel,
              // 🔽 NEU: Keys für Titel & Counter in die Kachel hineinreichen
              titleKey: _titleKeys[i],
              countKey: _countKeys[i],
              iconKey: _iconKeys[i], // NEU: Icon-Key übergeben
              onTap: widget.onTapSub == null
                  ? null
                  : () => widget.onTapSub!(sub),
            ),
          );
        }, childCount: widget.subs.length),
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
  const _HighlightableTarget({required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(radialPaletteProvider);

    bool isFocused = false;

    if (palette.activeTool != null) {
      // Bei ONE: nur aktuelles Target
      // Bei ALL: alle Targets, die das Tool unterstützen (werden in toggleScope() gesetzt)
      isFocused = palette.focusedIds.contains(id);
    }

    if (!isFocused) {
      return child;
    }

    // Rahmenfarbe: Rot wenn gelockt, sonst weiß
    final borderColor = palette.isBallLocked ? Colors.redAccent : Colors.white;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  24,
                ), // Angepasst an Kachel-Radius
                border: Border.all(
                  color: borderColor, // Rot wenn gelockt, sonst weiß
                  width: 6, // Deutlich fetterer Rahmen
                ),
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
