import 'package:flutter/material.dart';

class VocabPromoCard extends StatelessWidget {
  const VocabPromoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF07101A),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFF5DDCFF).withValues(alpha: 0.62),
          width: 1.2,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071A22), Color(0xFF100B26), Color(0xFF03060C)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5DDCFF).withValues(alpha: 0.18),
            blurRadius: 30,
            spreadRadius: -5,
          ),
          BoxShadow(
            color: const Color(0xFFB36BFF).withValues(alpha: 0.1),
            blurRadius: 38,
            spreadRadius: -8,
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Color(0xFF7DFFE3), size: 28),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kurze Spiele für deine Wörter',
                  style: TextStyle(
                    color: Color(0xFFF4F8FF),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Wähle kurze Runden für deine Wörter. Einige Modi nutzen KI oder sind als Ausblick klar gekennzeichnet.',
                  style: TextStyle(
                    color: Color(0xFFB8C7D9),
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
