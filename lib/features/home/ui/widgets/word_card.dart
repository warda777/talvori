import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'counter_badge.dart';
import 'dart:ui' as ui;
import 'glow_sweep_ring.dart';
import 'tap_flash.dart';


class WordCard extends StatelessWidget {
  // Aktionen
  final VoidCallback onSpeak;
  final VoidCallback onMarkWords;
  final VoidCallback onQuickSend;
  final VoidCallback onGo;

  // Bild
  final ImageProvider? wordImage;
  final VoidCallback? onImageTap;
  final VoidCallback? onImageLongPress; // (derzeit ungenutzt)

  // Zähler
  final int userWordCount;
  final VoidCallback? onCountTap;

  // Größe + Wort
  final double? height;      // äußere Zielhöhe der Karte (nur als Mindesthöhe)
  final double? maxWidth;    // äußere Zielbreite (Deckel)
  final String mainWord;

  // Feste Innenränder der Karte (bleiben IMMER gleich)
  final EdgeInsets contentPadding;

  // Bild-Modus
  final bool isImageExpanded;     // true = großes, randloses Bild
  final VoidCallback? onToggleImage;

  final bool isImageDark;                           // <- NEU
  final ValueChanged<bool>? onImageBrightnessChanged; // <- NEU

  const WordCard({
    super.key,
    required this.onSpeak,
    required this.onMarkWords,
    required this.onQuickSend,
    required this.onGo,
    this.wordImage,
    this.onImageTap,
    this.onImageLongPress,
    this.userWordCount = 0,
    this.onCountTap,
    this.height,
    this.maxWidth,
    this.mainWord = 'to assume',
    this.contentPadding = const EdgeInsets.fromLTRB(20, 16, 20, 16),
    this.isImageExpanded = false,
    this.onToggleImage,
    this.isImageDark = false,
    this.onImageBrightnessChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardRadius = BorderRadius.circular(28);
    final onImageFg = isImageDark ? Colors.white : Colors.black;          // helle/dunkle Schrift/Icons
    final onImageIcon = isImageDark ? Colors.white : Colors.black87;      // Icons minimal kräftiger


    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height ?? 500,   // du nutzt im Home-Screen 570 – das passt
        maxWidth:  maxWidth ?? 360,
      ),
      child: ClipRRect(
        // sorgt dafür, dass die Rundung auch fürs große Bild gilt
        borderRadius: cardRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ───────────────── HINTERGRUND: großes Bild (nur Optik) ─────────────────
            if (isImageExpanded)
              // Bild liegt UNTER dem Inhalt und füllt die Karte komplett aus
              GestureDetector(
                onTap: onToggleImage ?? onImageTap,
                child: _WordImageWithProbe(provider: wordImage, fit: BoxFit.cover, onLuma: onImageBrightnessChanged) // <- meldet true = dunkel, false = hell)
              ),

            // ───────────────── VORDERGRUND (alles mit festen Pixelwerten) ─────────────────
            // Der gesamte Inhalt liegt über dem Bild und hat IMMER dasselbe Padding.
            Padding(
              padding: contentPadding,
              child: Stack(
                children: [
                  // ─── KLEINES BILD (nur wenn NICHT erweitert) ───
                  if (!isImageExpanded)
                    Positioned(
                      top: 16,       // Abstand von oben
                      left: 10,      // seitlicher Rand links
                      right: 10,     // seitlicher Rand rechts
                      height: 200,   // Höhe des kleinen Bildrahmens
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: GestureDetector(
                          onTap: onToggleImage ?? onImageTap,
                          child: _WordImageWithProbe(
                            provider: wordImage,
                            fit: BoxFit.cover,
                            onLuma: onImageBrightnessChanged, // <- meldet dunkel/hell auch im kleinen Bild
                          ),
                        ),
                      ),
                    ),

                  // ─── COUNTER (mit TapFlash) ───
                  Positioned(
                    top: 16, left: 0, right: 0,
                    child: Center(
                      child: TapFlash(
                        color: Theme.of(context).colorScheme.primary, // Flash-Farbe
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(14),
                        onTapAfter: onCountTap,
                        child: CounterBadge(
                          count: userWordCount,
                          onTap: null,            // TapFlash übernimmt das Tippen
                          color: onImageFg,
                        ),
                      ),
                    ),
                  ),

                  // ─── "My Words" (immer identisch) ───
                  Positioned(
                    top: 70, left: 0, right: 0,
                    child: Center(
                      child: Text(
                        'My Words',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          // <- NUR EINE Farbe und NICHT const außenrum:
                          color: onImageFg, // <- immer dynamisch (hell/dunkel) – auch im kleinen Bild
                          shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
                        ),
                      ),
                    ),
                  ),

                  // ─── WORT (immer identisch) ───
                  Positioned(
                    top: 220, left: 0, right: 0,
                    child: Text(
                      mainWord,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        // nur Farbe/Schatten ändert sich, NICHT die Position
                        color: isImageExpanded ? onImageFg : cs.onSurface,  // <- hier onImageFg verwenden
                        shadows: isImageExpanded
                            ? const [Shadow(color: Colors.black54, blurRadius: 8)]
                            : const [],
                      ),
                    ),
                  ),

                  // ─── SPEAKER (mit TapFlash) ───
                  Positioned(
                    top: 276, left: 0, right: 0, // 220 + 56
                    child: SizedBox(
                      width: 44, height: 44,
                      child: TapFlash(
                        color: Theme.of(context).colorScheme.primary, // Flash-Farbe
                        shape: BoxShape.circle,
                        onTapAfter: onSpeak,                     // nach Flash ausführen
                        child: Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.volume_up,
                            size: 28,
                            color: isImageExpanded ? onImageIcon : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ─── PLAY (nur Icon, unten mittig, fix) ───
                  Positioned(
                    bottom: 30, left: 0, right: 0,
                    child: GestureDetector(
                      onTap: onMarkWords,
                      behavior: HitTestBehavior.translucent,
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow: 1 Runden -> 5s Pause -> wiederholen
                            GlowSweepRing(
                              size: 100,
                              strokeWidth: 5,
                              duration: const Duration(milliseconds: 1200), // 1 Runde ≈ 1.2s
                              cyclesPerBurst: 1,
                              idle: const Duration(seconds: 5),
                              loop: true,
                              color: cs.primary, // deine alte Play-Farbe, NICHT Gold
                            ),

                            // Play-Icon
                            SvgPicture.asset(
                              'assets/icons/circle-play.svg',
                              width: 94,
                              height: 94,
                              colorFilter: ColorFilter.mode(
                                isImageExpanded ? onImageIcon : cs.onSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── LINKES ICON (unten links) mit TapFlash ───
                  Positioned(
                    bottom: 16, left: 8,
                    child: SizedBox.square(
                      dimension: 52,
                      child: TapFlash(
                        color: Theme.of(context).colorScheme.primary, // deine App-Farbe, NICHT Gold
                        shape: BoxShape.circle,
                        onTapAfter: onQuickSend,
                        child: Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/cellphone_arrow_down_icon.svg',
                            width: 40, height: 40,
                            colorFilter: ColorFilter.mode(
                              isImageExpanded ? onImageIcon : cs.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ─── RECHTES ICON (unten rechts) mit TapFlash ───
                  Positioned(
                    bottom: 16, right: 8,
                    child: SizedBox.square(
                      dimension: 52,
                      child: TapFlash(
                        color: Theme.of(context).colorScheme.primary, // gleiche Flash-Logik
                        shape: BoxShape.circle,
                        onTapAfter: onGo,
                        child: Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/line_chrome.svg',
                            width: 56, height: 56,
                            colorFilter: ColorFilter.mode(
                              isImageExpanded ? onImageIcon : cs.onSurface,
                              BlendMode.srcIn,
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
      'My Words',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
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
    final prov = widget.provider ?? const AssetImage('assets/images/placeholder_1.png');
    _stream = prov.resolve(const ImageConfiguration());
    _listener = ImageStreamListener((info, _) async {
      try {
        final ui.Image img = info.image;
        final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (byteData == null) return;
        final bytes = byteData.buffer.asUint8List();

        // Grobe Stichprobe: 20x20 Pixel aus der Bildmitte mitteln (spart Zeit)
        final sample = 20;
        final startX = (img.width / 2 - sample / 2).clamp(0, img.width - 1).toInt();
        final startY = (img.height / 2 - sample / 2).clamp(0, img.height - 1).toInt();
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
          final isDark = avg < 128;   // Schwelle: 128
          widget.onLuma!(isDark);
        }
      } catch (_) {/* ignorieren */}
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
    final prov = widget.provider ?? const AssetImage('assets/images/placeholder_1.png');
    return Image(image: prov, fit: widget.fit);
  }
}