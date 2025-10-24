// lib/features/words/application/sfx_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SFX Service für Sounds und Haptik
class SfxService {
  final _player = AudioPlayer();

  /// Korrekte Antwort - Sound oder Haptik
  Future<void> correct() async {
    try {
      await _player.play(AssetSource('sounds/correct.mp3'));
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }

  /// Falsche Antwort - Sound oder Haptik
  Future<void> wrong() async {
    try {
      await _player.play(AssetSource('sounds/incorrect.mp3'));
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Neue Karte - Sound oder Haptik
  Future<void> newCard() async {
    try {
      await _player.play(AssetSource('sounds/new_card.mp3'));
    } catch (_) {
      HapticFeedback.selectionClick();
    }
  }

  /// Ressourcen freigeben
  void dispose() => _player.dispose();
}

/// Provider für SFX Service
final sfxProvider = Provider((_) => SfxService());
