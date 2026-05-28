import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'tap_flash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/ui/talvori_snackbar.dart';
import 'package:talvori/features/words/ui/widgets/word_wheel_core.dart';
import 'package:talvori/features/words/ui/cards/glow_orb.dart';
import 'package:talvori/features/words/ui/cards/center_glow.dart';
import 'package:talvori/features/words/ui/cards/animated_phone_icon.dart';
import 'package:talvori/features/words/ui/cards/arrow_fly_service.dart';
import 'package:talvori/features/home/application/application.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/home/ui/widgets/glow_switch.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_selection_controller.dart';
import 'package:talvori/features/words/ui/cards/spinning_chrome_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore_for_file: use_build_context_synchronously
// ignore_for_file: unnecessary_null_comparison

typedef HomeExternalBrowserLauncher = Future<bool> Function(Uri uri);
typedef HomeBrowserUrlResolver = Future<Uri> Function();

enum HomeBrowserChoice { system, chrome, brave }

@visibleForTesting
final homeExternalBrowserLauncherProvider =
    Provider<HomeExternalBrowserLauncher>((ref) {
      return (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
    });

const _homeBrowserStartUrl = 'https://www.bbc.com';

@visibleForTesting
const homeBrowserCustomStartUrlStorageKey =
    'talvori_browser_custom_start_url_v1';

@visibleForTesting
final homeBrowserUrlResolverProvider = Provider<HomeBrowserUrlResolver>((ref) {
  return () => _resolveHomeBrowserUrl(ref);
});

class WordCard extends ConsumerStatefulWidget {
  // Aktionen
  final ValueChanged<WordUserView?> onSpeak;
  final VoidCallback onMarkWords;
  final Future<TagesimpulsSelectionAddResult> Function(WordUserView word)?
  onQuickSend; // Nimmt das aktuelle Wort aus dem Wheel.
  final VoidCallback? onImpulseInboxTap;
  final int impulseInboxUnreadCount;
  final VoidCallback onGo;

  // Bild
  final ImageProvider? wordImage;
  final VoidCallback? onImageTap;
  final VoidCallback? onImageLongPress; // (derzeit ungenutzt)

  // Zähler
  final int userWordCount;
  final VoidCallback? onCountTap;

  // Größe + Wort
  final double? height; // äußere Zielhöhe der Karte (nur als Mindesthöhe)
  final double? maxWidth; // äußere Zielbreite (Deckel)
  final String? initialWord; // optionales Fallback

  // Feste Innenränder der Karte (bleiben IMMER gleich)
  final EdgeInsets contentPadding;

  // Bild-Modus
  final bool isImageExpanded; // true = großes, randloses Bild
  final VoidCallback? onToggleImage;

  final bool isImageDark; // <- NEU
  final ValueChanged<bool>? onImageBrightnessChanged; // <- NEU
  final GlobalKey?
  progressPillKey; // GlobalKey für Progress Pill (für Flug-Animation)
  final GlobalKey?
  counterKey; // <-- NEU: GlobalKey für Counter in Progress Pill

  const WordCard({
    super.key,
    required this.onSpeak,
    required this.onMarkWords,
    required this.onQuickSend,
    this.onImpulseInboxTap,
    this.impulseInboxUnreadCount = 0,
    required this.onGo,
    this.wordImage,
    this.onImageTap,
    this.onImageLongPress,
    this.userWordCount = 0,
    this.onCountTap,
    this.height,
    this.maxWidth,
    this.initialWord,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 16, 20, 16),
    this.isImageExpanded = false,
    this.onToggleImage,
    this.isImageDark = false,
    this.onImageBrightnessChanged,
    this.progressPillKey,
    this.counterKey, // <-- NEU
  });

  @override
  ConsumerState<WordCard> createState() => _WordCardState();
}

class _WordCardState extends ConsumerState<WordCard> {
  int _currentIndex = 0;
  int _total = 0;
  WordUserView? _currentWord; // Aktuell ausgewähltes Wort aus dem Wheel

  // GlobalKey für Handy-Icon (für Flug-Animation)
  final GlobalKey _phoneIconKey = GlobalKey();
  // GlobalKey für AnimatedPhoneIcon State (um den Pfeil auszublenden)
  final GlobalKey _animatedPhoneIconKey = GlobalKey();

  // Blau-Farbe aus dem Word Wheel
  static const Color _wheelBlue = Color(0xFFB0CCFE);

  void _startArrowFlyAnimation(BuildContext context) {
    if (widget.progressPillKey == null) return;

    // Blende den Pfeil im Handy-Icon aus
    final phoneIconState = _animatedPhoneIconKey.currentState;
    if (phoneIconState != null && phoneIconState is State<AnimatedPhoneIcon>) {
      // Verwende dynamic, um die hideArrow-Methode aufzurufen
      (phoneIconState as dynamic).hideArrow();
    }

    ArrowFlyService.startArrowFlyAnimation(
      context: context,
      phoneIconKey: _phoneIconKey,
      progressPillKey: widget.progressPillKey!,
      counterKey: widget.counterKey, // <-- NEU: Counter Key übergeben
      onComplete: () {
        // Zeige den Pfeil wieder an, nachdem die Animation fertig ist
        final phoneIconState = _animatedPhoneIconKey.currentState;
        if (phoneIconState != null &&
            phoneIconState is State<AnimatedPhoneIcon>) {
          (phoneIconState as dynamic).showArrow();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardRadius = BorderRadius.circular(28);
    final onImageFg = widget.isImageDark
        ? Colors.white
        : Colors.black; // helle/dunkle Schrift/Icons
    final onImageIcon = widget.isImageDark
        ? Colors.white
        : Colors.black87; // Icons minimal kräftiger
    final glowEnabled = ref.watch(
      homeControllerProvider.select((s) => s.glowEnabled),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight:
            widget.height ?? 500, // du nutzt im Home-Screen 570 – das passt
        maxWidth: widget.maxWidth ?? 360,
      ),
      child: Container(
        decoration: (widget.isImageExpanded && glowEnabled)
            ? BoxDecoration(
                borderRadius: cardRadius,
                boxShadow: [
                  // Durchgehender weißer Glow für das erweiterte Bild
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.55),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              )
            : null,
        child: ClipRRect(
          // sorgt dafür, dass die Rundung auch fürs große Bild gilt
          borderRadius: cardRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ───────────────── HINTERGRUND: großes Bild (nur Optik) ─────────────────
              if (widget.isImageExpanded)
                // Bild liegt UNTER dem Inhalt und füllt die Karte komplett aus
                GestureDetector(
                  onTap: widget.onToggleImage ?? widget.onImageTap,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ), // Weißer Rand
                      borderRadius: cardRadius,
                    ),
                    child: ClipRRect(
                      borderRadius: cardRadius,
                      child: _WordImageWithProbe(
                        provider: widget.wordImage,
                        fit: BoxFit.cover,
                        onLuma: widget.onImageBrightnessChanged,
                      ), // <- meldet true = dunkel, false = hell)
                    ),
                  ),
                ),

              // ───────────────── VORDERGRUND (alles mit festen Pixelwerten) ─────────────────
              // Der gesamte Inhalt liegt über dem Bild und hat IMMER dasselbe Padding.
              Padding(
                padding: widget.contentPadding,
                child: Stack(
                  children: [
                    // ─── KLEINES BILD (nur wenn NICHT erweitert) ───
                    if (!widget.isImageExpanded)
                      Positioned(
                        top: 16, // Abstand von oben
                        left: 10, // seitlicher Rand links
                        right: 10, // seitlicher Rand rechts
                        height: 200, // Höhe des kleinen Bildrahmens
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ), // Weißer Rand
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: glowEnabled
                                ? [
                                    // Durchgehender weißer Glow
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.55,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: GestureDetector(
                              onTap: widget.onToggleImage ?? widget.onImageTap,
                              child: _WordImageWithProbe(
                                provider: widget.wordImage,
                                fit: BoxFit.cover,
                                onLuma: widget
                                    .onImageBrightnessChanged, // <- meldet dunkel/hell auch im kleinen Bild
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ─── COUNTER (mit TapFlash) ───
                    Positioned(
                      top: 24,
                      left: 0,
                      right: 0,
                      height: 32,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: 74,
                          height: 32,
                          child: TapFlash(
                            key: const Key('home-my-words-counter-button'),
                            color: _wheelBlue, // Blau aus Word Wheel
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(14),
                            onTapAfter: widget.onCountTap,
                            child: _CounterPill(
                              label: _total > 0
                                  ? '$_currentIndex/$_total'
                                  : '${widget.userWordCount}',
                              textColor: onImageFg,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ─── GLOW SWITCH (rechts oben) ───
                    Positioned(top: 18, right: 16, child: GlowSwitch()),

                    // ─── SPEAKER ───
                    Positioned(
                      top: 110,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: TapFlash(
                          color: _wheelBlue, // Blau aus Word Wheel
                          shape: BoxShape.circle,
                          onTapAfter: () => widget.onSpeak(_currentWord),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.volume_up,
                              size: 28,
                              color: widget.isImageExpanded
                                  ? onImageIcon
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ─── WORT (WordWheelCore) ───
                    Positioned(
                      top: 220,
                      left: 0,
                      right: 0,
                      child: WordWheelCore(
                        onCenterChange: (index, word) {
                          // Aktualisiert den Counter synchron mit dem Wheel und speichert das aktuelle Wort
                          setState(() {
                            _currentIndex = index + 1;
                            _currentWord = word;
                          });

                          // Triggert eine leichte Bewegung des Handy-Icons
                          final phoneIconState =
                              _animatedPhoneIconKey.currentState;
                          if (phoneIconState != null &&
                              phoneIconState is State<AnimatedPhoneIcon>) {
                            (phoneIconState as dynamic).triggerMovement();
                          }
                        },
                        onTotalLoaded: (total) {
                          // Setzt die Gesamtanzahl beim ersten Laden
                          setState(() {
                            _total = total;
                          });
                        },
                      ),
                    ),

                    // ─── PLAY (nur Icon, unten mittig, fix) ───
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          key: const Key('home-my-words-play-button'),
                          onTap: widget
                              .onGo, // ⬇️ FIX: Play-Button verwendet onGo statt onMarkWords
                          behavior: HitTestBehavior
                              .opaque, // Genau die Größe des SizedBox, keine größere Tapfläche
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow: Ovales Gold-Licht (rotierend)
                                GlowOrb(
                                  size: 100,
                                  radius: 45, // Abstand vom Zentrum
                                  orbSize: 8, // Größe der Kugel
                                  duration: const Duration(
                                    milliseconds: 3000,
                                  ), // Langsame Rotation
                                  color: const Color(0xFFF1C86B), // Gold
                                  loop:
                                      false, // Nur eine Umdrehung, dann ausblenden
                                ),

                                // Center Glow: Statischer Glow im Zentrum (innerhalb des Play-Icons)
                                CenterGlow(
                                  size: 100,
                                  glowSize: 18,
                                  duration: const Duration(
                                    milliseconds: 3000,
                                  ), // Gleiche Dauer wie GlowOrb
                                  color: const Color(0xFFF1C86B), // Gold
                                ),

                                // Play-Icon
                                SvgPicture.asset(
                                  'assets/icons/circle-play.svg',
                                  width: 94,
                                  height: 94,
                                  colorFilter: ColorFilter.mode(
                                    widget.isImageExpanded
                                        ? onImageIcon
                                        : cs.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ─── LINKE AKTIONEN (unten links) mit TapFlash ───
                    Positioned(
                      bottom: 16,
                      left: 0,
                      child: SizedBox.square(
                        dimension: 52,
                        child: TapFlash(
                          color: _wheelBlue, // Blau aus Word Wheel
                          shape: BoxShape.circle,
                          onTapAfter: () async {
                            if (_currentWord != null &&
                                widget.onQuickSend != null) {
                              // Führe QuickSend aus und prüfe das Ergebnis
                              final result = widget.onQuickSend!(_currentWord!);

                              // Starte Flug-Animation nur wenn erfolgreich hinzugefügt
                              if (await result ==
                                  TagesimpulsSelectionAddResult.ok) {
                                _startArrowFlyAnimation(context);
                              }
                            }
                          },
                          child: Container(
                            key: _phoneIconKey,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: AnimatedPhoneIcon(
                              key: _animatedPhoneIconKey,
                              assetPath:
                                  'assets/icons/cellphone_arrow_down_icon.svg',
                              size:
                                  52, // Gleiche Größe wie Container (damit Zentrierung identisch ist)
                              colorFilter: widget.isImageExpanded
                                  ? onImageIcon
                                  : cs.onSurface,
                              duration: const Duration(milliseconds: 1500),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (widget.onImpulseInboxTap != null)
                      Positioned(
                        bottom: 76,
                        left: 0,
                        child: SizedBox.square(
                          key: const Key('home-impuls-postfach-button'),
                          dimension: 52,
                          child: TapFlash(
                            color: const Color(0xFF59D7FF),
                            shape: BoxShape.circle,
                            onTapAfter: widget.onImpulseInboxTap,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF07111A),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF59D7FF),
                                      width: 1.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x3359D7FF),
                                        blurRadius: 18,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.mark_unread_chat_alt_rounded,
                                    color: widget.isImageExpanded
                                        ? onImageIcon
                                        : const Color(0xFF7FFFE7),
                                    size: 28,
                                  ),
                                ),
                                if (widget.impulseInboxUnreadCount > 0)
                                  Positioned(
                                    key: const Key(
                                      'home-impuls-postfach-unread-badge',
                                    ),
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF59D7FF),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFF06101A),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        widget.impulseInboxUnreadCount > 9
                                            ? '9+'
                                            : '${widget.impulseInboxUnreadCount}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF041019),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // ─── RECHTES ICON Chrome Button(unten rechts) mit TapFlash ───
                    Positioned(
                      bottom: 16,
                      right: 8,
                      child: Semantics(
                        key: const Key('home-browser-return-button'),
                        label: 'Browser öffnen',
                        child: SizedBox.square(
                          dimension: 52,
                          child: TapFlash(
                            color: _wheelBlue, // Blau aus Word Wheel
                            shape: BoxShape.circle,
                            onTapAfter: () => onChromeButtonTap(context, ref),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: SpinningChromeButton(
                                svgAsset: 'assets/icons/line_chrome.svg',
                                size: 56,
                                baseRotationDuration: const Duration(
                                  milliseconds: 3000,
                                ),
                                loop: false,
                                colorFilter: ColorFilter.mode(
                                  widget.isImageExpanded
                                      ? onImageIcon
                                      : cs.onSurface,
                                  BlendMode.srcIn,
                                ),
                                onTap: () => onChromeButtonTap(context, ref),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ), // <- Schließt den Container
    );
  }
}

Future<void> onChromeButtonTap(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _HomeBrowserOpenSheet(
        onSelect: (choice) async {
          Navigator.of(sheetContext).pop();
          await _openHomeBrowserChoice(context, ref, choice);
        },
        onSetStartPage: () async {
          Navigator.of(sheetContext).pop();
          await _showHomeBrowserStartPageSheet(context);
        },
      );
    },
  );
}

Future<void> _openHomeBrowserChoice(
  BuildContext context,
  WidgetRef ref,
  HomeBrowserChoice choice,
) async {
  final launcher = ref.read(homeExternalBrowserLauncherProvider);
  final targetUrl = await ref.read(homeBrowserUrlResolverProvider)();
  final opened = switch (choice) {
    HomeBrowserChoice.system => await _tryLaunch(launcher, targetUrl),
    HomeBrowserChoice.chrome => await _openChromeOrFallback(
      context,
      launcher,
      targetUrl,
    ),
    HomeBrowserChoice.brave => await _openBraveOrFallback(
      context,
      launcher,
      targetUrl,
    ),
  };
  if (!context.mounted || opened) return;
  _showBrowserOpenToast(context);
}

Future<Uri> _resolveHomeBrowserUrl(Ref ref) async {
  try {
    final bootstrap = await ref.read(localBootstrapProvider.future);
    final source = await bootstrap.repositoryFactory.wordSourceRepository
        .loadLatestSource();
    final uri = Uri.tryParse(source?.sourceUrl ?? '');
    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty) {
      return uri;
    }
  } catch (_) {
    // Browser opening must stay available even when local metadata is absent.
  }
  return _loadHomeBrowserStartUrl();
}

Future<bool> _openChromeOrFallback(
  BuildContext context,
  HomeExternalBrowserLauncher launcher,
  Uri targetUrl,
) async {
  final chromeUri = _chromeUri(targetUrl);
  if (await _tryLaunch(launcher, chromeUri)) return true;
  if (context.mounted) {
    _showBrowserOpenToast(
      context,
      'Chrome ist nicht verfügbar. Standardbrowser wird geöffnet.',
    );
  }
  return _tryLaunch(launcher, targetUrl);
}

Future<bool> _openBraveOrFallback(
  BuildContext context,
  HomeExternalBrowserLauncher launcher,
  Uri targetUrl,
) async {
  final braveUri = _braveUri(targetUrl);
  if (await _tryLaunch(launcher, braveUri)) return true;
  if (context.mounted) {
    _showBrowserOpenToast(
      context,
      'Brave ist nicht verfügbar. Standardbrowser wird geöffnet.',
    );
  }
  return _tryLaunch(launcher, targetUrl);
}

Future<bool> _tryLaunch(HomeExternalBrowserLauncher launcher, Uri uri) async {
  try {
    return await launcher(uri);
  } catch (_) {
    return false;
  }
}

Uri _chromeUri(Uri targetUrl) {
  final pathAndQuery = _browserSchemePathAndQuery(targetUrl);
  if (targetUrl.scheme == 'https') {
    return Uri.parse('googlechromes://${targetUrl.host}$pathAndQuery');
  }
  return Uri.parse('googlechrome://${targetUrl.host}$pathAndQuery');
}

Uri _braveUri(Uri targetUrl) {
  final encoded = Uri.encodeComponent(targetUrl.toString());
  return Uri.parse('brave://open-url?url=$encoded');
}

String _browserSchemePathAndQuery(Uri targetUrl) {
  final path = targetUrl.path == '/' ? '' : targetUrl.path;
  final query = targetUrl.query.isNotEmpty ? '?${targetUrl.query}' : '';
  return '$path$query';
}

Future<Uri> _loadHomeBrowserStartUrl() async {
  return await _loadHomeBrowserCustomStartUrl() ??
      Uri.parse(_homeBrowserStartUrl);
}

Future<Uri?> _loadHomeBrowserCustomStartUrl() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString(homeBrowserCustomStartUrlStorageKey);
  return normalizeHomeBrowserStartUrl(stored);
}

@visibleForTesting
Uri? normalizeHomeBrowserStartUrl(String? input) {
  final trimmed = input?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  if (RegExp(r'\s').hasMatch(trimmed)) return null;
  final candidate = trimmed.contains('://') ? trimmed : 'https://$trimmed';
  final uri = Uri.tryParse(candidate);
  if (uri == null) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  if (uri.host.isEmpty) return null;
  return uri;
}

void _showBrowserOpenToast(
  BuildContext context, [
  String message = 'Externer Browser konnte nicht geöffnet werden.',
]) {
  TalvoriSnackBar.show(
    context,
    key: const Key('home-browser-open-toast'),
    message: message,
    type: TalvoriSnackBarType.warning,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 118),
  );
}

class _HomeBrowserOpenSheet extends StatelessWidget {
  const _HomeBrowserOpenSheet({
    required this.onSelect,
    required this.onSetStartPage,
  });

  final ValueChanged<HomeBrowserChoice> onSelect;
  final VoidCallback onSetStartPage;

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.82;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            key: const Key('home-browser-open-sheet'),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF061018),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF5DDCFF), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5DDCFF).withValues(alpha: 0.22),
                  blurRadius: 28,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Browser öffnen',
                  style: TextStyle(
                    color: Color(0xFFF4F8FF),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Wähle, womit Talvori deine hinterlegte Webseite öffnet. Es wird keine letzte Seite gesucht.',
                  style: TextStyle(
                    color: Color(0xFF93A2B8),
                    fontSize: 12.5,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _HomeBrowserOptionTile(
                  key: const Key('home-browser-option-system'),
                  icon: Icons.travel_explore_rounded,
                  title: 'Standardbrowser',
                  subtitle: 'Öffnet deinen Standardbrowser',
                  onTap: () => onSelect(HomeBrowserChoice.system),
                ),
                const SizedBox(height: 8),
                _HomeBrowserOptionTile(
                  key: const Key('home-browser-option-chrome'),
                  icon: Icons.public_rounded,
                  title: 'Chrome',
                  subtitle: 'Direkt in Chrome öffnen',
                  onTap: () => onSelect(HomeBrowserChoice.chrome),
                ),
                const SizedBox(height: 8),
                _HomeBrowserOptionTile(
                  key: const Key('home-browser-option-brave'),
                  icon: Icons.shield_rounded,
                  title: 'Brave',
                  subtitle: 'Direkt in Brave öffnen',
                  onTap: () => onSelect(HomeBrowserChoice.brave),
                ),
                const SizedBox(height: 10),
                _HomeBrowserStartPageAction(onTap: onSetStartPage),
                const SizedBox(height: 10),
                const Text(
                  'Safari öffnet sich über Standardbrowser, wenn Safari auf deinem Gerät als Standardbrowser eingestellt ist.',
                  style: TextStyle(
                    color: Color(0xFF93A2B8),
                    fontSize: 11.5,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBrowserStartPageAction extends StatelessWidget {
  const _HomeBrowserStartPageAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF061018),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: const Key('home-browser-set-start-url'),
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF5DDCFF).withValues(alpha: 0.24),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.tune_rounded, color: Color(0xFF7DFFE3), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eigene Webseite hinterlegen',
                      style: TextStyle(
                        color: Color(0xFFF4F8FF),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Lege selbst fest, welche Seite geöffnet wird',
                      style: TextStyle(
                        color: Color(0xFF93A2B8),
                        fontSize: 12.2,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showHomeBrowserStartPageSheet(BuildContext context) async {
  final currentUrl = await _loadHomeBrowserCustomStartUrl();
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _HomeBrowserStartPageSheet(
        initialUrl: currentUrl?.toString() ?? '',
        parentContext: context,
      );
    },
  );
}

class _HomeBrowserStartPageSheet extends StatefulWidget {
  const _HomeBrowserStartPageSheet({
    required this.initialUrl,
    required this.parentContext,
  });

  final String initialUrl;
  final BuildContext parentContext;

  @override
  State<_HomeBrowserStartPageSheet> createState() =>
      _HomeBrowserStartPageSheetState();
}

class _HomeBrowserStartPageSheetState
    extends State<_HomeBrowserStartPageSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext sheetContext) {
    return _saveHomeBrowserStartUrl(
      sheetContext,
      widget.parentContext,
      _controller.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 18,
        ),
        child: Container(
          key: const Key('home-browser-start-url-sheet'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF061018),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF5DDCFF), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5DDCFF).withValues(alpha: 0.22),
                blurRadius: 28,
                spreadRadius: -8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Eigene Webseite',
                style: TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Diese Webseite nutzt Talvori, wenn keine gespeicherte Quelle vorhanden ist.',
                style: TextStyle(
                  color: Color(0xFF93A2B8),
                  fontSize: 12.5,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const Key('home-browser-start-url-input'),
                controller: _controller,
                keyboardType: TextInputType.url,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                style: const TextStyle(
                  color: Color(0xFFF4F8FF),
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  hintText: 'z. B. $_homeBrowserStartUrl',
                  hintStyle: const TextStyle(color: Color(0xFF5F6E83)),
                  filled: true,
                  fillColor: const Color(0xFF0B1823),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: const Color(0xFF7DFFE3).withValues(alpha: 0.28),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF7DFFE3),
                      width: 1.2,
                    ),
                  ),
                ),
                onSubmitted: (_) => _save(context),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('home-browser-start-url-cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF4F8FF),
                        side: BorderSide(
                          color: const Color(
                            0xFF93A2B8,
                          ).withValues(alpha: 0.45),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Abbrechen'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      key: const Key('home-browser-start-url-save'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7DFFE3),
                        foregroundColor: const Color(0xFF061018),
                      ),
                      onPressed: () => _save(context),
                      child: const Text('Speichern'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _saveHomeBrowserStartUrl(
  BuildContext sheetContext,
  BuildContext parentContext,
  String input,
) async {
  final uri = normalizeHomeBrowserStartUrl(input);
  if (uri == null) {
    if (parentContext.mounted) {
      _showBrowserOpenToast(
        parentContext,
        'Bitte gib eine gültige Webseite ein.',
      );
    }
    return;
  }
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(homeBrowserCustomStartUrlStorageKey, uri.toString());
  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
  if (parentContext.mounted) {
    _showBrowserOpenToast(parentContext, 'Webseite gespeichert.');
  }
}

class _HomeBrowserOptionTile extends StatelessWidget {
  const _HomeBrowserOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0B1823),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF7DFFE3).withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF78E6FF).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF78E6FF).withValues(alpha: 0.42),
                  ),
                ),
                child: Icon(icon, color: const Color(0xFF7DFFE3), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFF4F8FF),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF93A2B8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF78E6FF)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Optionaler Helfer (falls du den Titel separat brauchst)
// ignore: unused_element
class _MyWordsTitle extends StatelessWidget {
  const _MyWordsTitle();
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Meine Wörter',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({required this.label, required this.textColor});

  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

// Bild + Helligkeitsmessung
class _WordImageWithProbe extends StatefulWidget {
  final ImageProvider? provider;
  final BoxFit fit;
  final ValueChanged<bool>? onLuma;
  const _WordImageWithProbe({
    required this.provider,
    // ignore: unused_element_parameter
    this.fit = BoxFit.cover,
    this.onLuma,
  });

  @override
  State<_WordImageWithProbe> createState() => _WordImageWithProbeState();
}

class _WordImageWithProbeState extends State<_WordImageWithProbe> {
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant _WordImageWithProbe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      _unsubscribe();
      _subscribe();
    }
  }

  void _subscribe() {
    final prov =
        widget.provider ?? const AssetImage('assets/images/placeholder_1.png');
    _stream = prov.resolve(const ImageConfiguration());
    _listener = ImageStreamListener((info, _) async {
      try {
        final ui.Image img = info.image;
        final byteData = await img.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (byteData == null) return;
        final bytes = byteData.buffer.asUint8List();

        // Grobe Stichprobe: 20x20 Pixel aus der Bildmitte mitteln (spart Zeit)
        final sample = 20;
        final startX = (img.width / 2 - sample / 2)
            .clamp(0, img.width - 1)
            .toInt();
        final startY = (img.height / 2 - sample / 2)
            .clamp(0, img.height - 1)
            .toInt();
        int count = 0;
        double lumSum = 0;
        for (int y = 0; y < sample; y += 2) {
          for (int x = 0; x < sample; x += 2) {
            final px = ((startY + y) * img.width + (startX + x)) * 4;
            if (px + 3 >= bytes.length) continue;
            final r = bytes[px].toDouble();
            final g = bytes[px + 1].toDouble();
            final b = bytes[px + 2].toDouble();
            // sRGB Luminanz
            final luma = 0.2126 * r + 0.7152 * g + 0.0722 * b;
            lumSum += luma;
            count++;
          }
        }
        if (count > 0 && widget.onLuma != null) {
          final avg = lumSum / count; // 0..255
          final isDark = avg < 128; // Schwelle: 128
          widget.onLuma!(isDark);
        }
      } catch (_) {
        /* ignorieren */
      }
    });

    _stream?.addListener(_listener!);
  }

  void _unsubscribe() {
    if (_listener != null && _stream != null) {
      _stream!.removeListener(_listener!);
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov =
        widget.provider ?? const AssetImage('assets/images/placeholder_1.png');
    return Image(image: prov, fit: widget.fit);
  }
}
