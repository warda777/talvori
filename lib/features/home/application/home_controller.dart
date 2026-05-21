import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/local_database/import/shared_text_import_result.dart';
import 'package:talvori/core/local_database/providers/incoming_shared_text_import_controller_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/features/home/application/home_state.dart';
import 'package:talvori/features/home/data/share_ingest_service.dart';
import 'package:talvori/features/words/data/last_shared_word_provider.dart';

class HomeController extends Notifier<HomeState> with WidgetsBindingObserver {
  final ShareIngestService _shareService = ShareIngestService();
  static const String _glowEnabledKey = 'glow_enabled';

  @override
  HomeState build() {
    _loadGlowEnabled(); // Load saved preference
    refreshMyWordsCount(); // Initial load
    return const HomeState();
  }

  Future<void> _loadGlowEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_glowEnabledKey) ?? true; // Default: true
      state = state.copyWith(glowEnabled: enabled);
    } catch (_) {
      // Wenn Fehler, verwende Default
    }
  }

  Future<void> setGlowEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_glowEnabledKey, enabled);
      state = state.copyWith(glowEnabled: enabled);
    } catch (_) {
      // Wenn Fehler, setze trotzdem den State
      state = state.copyWith(glowEnabled: enabled);
    }
  }

  Future<void> init(BuildContext context) async {
    WidgetsBinding.instance.addObserver(this);

    await _shareService.init(
      onIncomingText: (text) async {
        await _importSharedTextLocally(text);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Inhalt erfasst')));
        }
      },
      onSavedUrl: ({required bool isPdf}) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isPdf
                    ? 'PDF-Position gespeichert'
                    : 'Seitenposition gespeichert',
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _shareService.dispose();
  }

  // Lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(lastSharedWordProvider);
    }
  }

  // UI toggles
  void toggleImage() =>
      state = state.copyWith(imageExpanded: !state.imageExpanded);
  void setImageDark(bool v) => state = state.copyWith(imageIsDark: v);
  void setCategoriesActive(bool v) =>
      state = state.copyWith(categoriesActive: v);
  void toggleGlow() => setGlowEnabled(!state.glowEnabled);

  // Data
  Future<void> refreshMyWordsCount() async {
    try {
      ref.invalidate(localWordCountProvider(localMyWordsCategoryId));
      final c = await ref.read(
        localWordCountProvider(localMyWordsCategoryId).future,
      );
      if (state.myWordsCount == c) return;
      state = state.copyWith(myWordsCount: c);
    } catch (_) {}
  }

  Future<String?> handleIncomingShare(String rawText) async {
    final result = await _importSharedTextLocally(rawText);
    return result?.word?.term;
  }

  Future<SharedTextImportResult?> _importSharedTextLocally(
    String rawText,
  ) async {
    final controller = await ref.read(
      incomingSharedTextImportControllerProvider.future,
    );
    final result = await controller.importSharedText(rawText);
    ref
      ..invalidate(lastSharedWordProvider)
      ..invalidate(localWordsForCategoryProvider(localMyWordsCategoryId))
      ..invalidate(localWordCountProvider(localMyWordsCategoryId));
    await refreshMyWordsCount();
    return result;
  }
}
