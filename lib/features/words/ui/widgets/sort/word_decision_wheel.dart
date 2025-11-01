import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';

class WordDecisionWheel extends StatefulWidget {
  final List<WordUserView> words;
  final void Function(WordUserView crossedUp)? onCrossUp; // „über die Linie" gegangen
  final void Function(WordUserView crossedDown)? onCrossDown; // 👈 neu: wieder unter die Linie
  final void Function(WordUserView center)? onCenterChange; // Haptik-Tick

  const WordDecisionWheel({
    super.key,
    required this.words,
    this.onCrossUp,
    this.onCrossDown,
    this.onCenterChange,
  });

  @override
  State<WordDecisionWheel> createState() => _WordDecisionWheelState();
}

class _WordDecisionWheelState extends State<WordDecisionWheel> {
  late FixedExtentScrollController _c;
  int _center = 0;
  final Map<String, bool> _wasAboveCenter = {}; // wordId -> vorher über Linie?

  @override
  void initState() {
    super.initState();
    _c = FixedExtentScrollController();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.words;
    
    // Map bereinigen: Nur IDs behalten, die noch in der Liste sind
    final currentIds = items.map((w) => w.id).toSet();
    _wasAboveCenter.removeWhere((id, _) => !currentIds.contains(id));

    return ListWheelScrollView.useDelegate(
      controller: _c,
      physics: const FixedExtentScrollPhysics(),
      itemExtent: 42, // Text-Höhe sauber wählen
      perspective: 0.002,
      diameterRatio: 2.2,
      onSelectedItemChanged: (idx) {
        final old = _center;
        _center = idx;
        
        // Alle Items prüfen auf Übergänge
        for (int i = 0; i < items.length; i++) {
          final w = items[i];
          final nowAbove = i < _center; // Index kleiner = oberhalb der Linie
          final prevAbove = _wasAboveCenter[w.id] ?? false;
          
          // Übergangslogik
          if (!prevAbove && nowAbove) {
            // Übergang von unten -> oben
            widget.onCrossUp?.call(w);
            HapticFeedback.mediumImpact();
          } else if (prevAbove && !nowAbove) {
            // Übergang von oben -> unten (rollback)
            widget.onCrossDown?.call(w);
            HapticFeedback.selectionClick();
          }
          
          _wasAboveCenter[w.id] = nowAbove;
        }
        
        widget.onCenterChange?.call(items[idx]);
        setState(() {}); // für Recoloring (Gold oberhalb der Linie)
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: items.length,
        builder: (context, i) {
          final passedUp = i < _center; // alles oberhalb der Linie
          return LayoutBuilder(
            builder: (context, constraints) {
              // Platz für Zahl reservieren: Start bei 34px (16 Box + 18 Padding)
              // Maximal 4-stellige Zahl (z.B. 1399) + Abstand = ~90px + 12px = 102px
              const numberAreaWidth = 102.0; // Platz für Zahl + Abstand
              const rightPadding = 34.0; // 16 (Box right) + 18 (Box padding)
              
              // Maximale Textbreite: verfügbare Breite minus Zahl-Bereich minus rechts Padding
              final maxWidth = constraints.maxWidth - numberAreaWidth - rightPadding;
              
              return Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: rightPadding),
                  child: SizedBox(
                    width: maxWidth,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        items[i].text,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: i == _center ? 24 : 20,
                          fontWeight: i == _center ? FontWeight.w800 : FontWeight.w700,
                          color: i == _center
                              ? const Color(0xFFB0CCFE) // Farbe für Wort in der Box
                              : passedUp
                                  ? const Color(0xFFF1C86B) // Gold für Wörter oberhalb
                                  : Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
