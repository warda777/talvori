import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'tap_flash.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:talvori/core/services/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// ignore_for_file: use_build_context_synchronously
// ignore_for_file: unnecessary_null_comparison

class WordCard extends ConsumerStatefulWidget {
  // Aktionen
  final VoidCallback onSpeak;
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

                    // ─── "Meine Wörter" (immer identisch) ───
                    Positioned(
                      top: 70,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'Meine Wörter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: onImageFg, // Weiß
                            shadows: const [
                              Shadow(color: Colors.black54, blurRadius: 6),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ─── SPEAKER unter "Meine Wörter" ───
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
                          onTapAfter: widget.onSpeak,
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
                        label:
                            'Zuletzt geteilte Quelle öffnen (Long-press: zurücksetzen)',
                        child: SizedBox.square(
                          dimension: 52,
                          child: TapFlash(
                            color: _wheelBlue, // Blau aus Word Wheel
                            shape: BoxShape.circle,
                            onTapAfter: () => onChromeButtonTap(context),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: GestureDetector(
                                // ⬅️ Long-Press Handler (außerhalb von SpinningChromeButton)
                                onLongPress: () async {
                                  final ok =
                                      await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text(
                                            'Gespeicherten Link löschen?',
                                          ),
                                          content: const Text(
                                            'Die „Zurück zum Browser"-Position wird zurückgesetzt.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('Abbrechen'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('Löschen'),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;

                                  if (!context.mounted) return;
                                  if (ok) {
                                    await BrowserReturnService.clear();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Zurück-Position gelöscht',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                behavior: HitTestBehavior
                                    .translucent, // Erlaube Pan-Gesten durchzulassen
                                child: SpinningChromeButton(
                                  svgAsset: 'assets/icons/line_chrome.svg',
                                  size: 56,
                                  baseRotationDuration: const Duration(
                                    milliseconds: 3000,
                                  ),
                                  loop:
                                      false, // Farbrotation & Auto-Spin deaktiviert
                                  colorFilter: ColorFilter.mode(
                                    widget.isImageExpanded
                                        ? onImageIcon
                                        : cs.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                  onTap: () =>
                                      onChromeButtonTap(context), // wie zuvor
                                ),
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

void onChromeButtonTap(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);

  BrowserReturnService.getLastUrl().then((url) async {
    if (!context.mounted) return;

    if (url == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Kein geteilter Link gefunden')),
      );
      return;
    }

    final isPdf = looksLikePdf(url);

    // vorher: SnackBar mit Action „Kopieren“
    // nachher: kurzer Auto-Dismiss, kein Button
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isPdf
                ? 'Öffne zuletzt geteilte PDF …'
                : 'Öffne zuletzt geteilte Quelle …',
          ),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          dismissDirection: DismissDirection.horizontal,
        ),
      );

    // Primär öffnen
    final Uri primary = url.startsWith('/') ? Uri.file(url) : Uri.parse(url);
    final ok = await launchUrl(primary, mode: LaunchMode.externalApplication);

    // PDF-Fallback (nur http/https)
    if (!ok &&
        isPdf &&
        (primary.scheme == 'http' || primary.scheme == 'https')) {
      final gview = Uri.parse(
        'https://docs.google.com/gview?embedded=1&url=${Uri.encodeComponent(url)}',
      );
      await launchUrl(gview, mode: LaunchMode.externalApplication);
    }
  });
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
