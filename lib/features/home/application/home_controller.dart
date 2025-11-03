import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/application/home_state.dart';
import 'package:talvori/features/home/data/share_ingest_service.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/data/last_shared_word_provider.dart';

class HomeController extends Notifier<HomeState> with WidgetsBindingObserver {
  final SupabaseWordRepository _wordRepo = SupabaseWordRepository();
  final ShareIngestService _shareService = ShareIngestService();

  @override
  HomeState build() {
    refreshMyWordsCount(); // Initial load
    return const HomeState();
  }

  Future<void> init(BuildContext context) async {
    WidgetsBinding.instance.addObserver(this);

    await _shareService.init(
      onIncomingText: (text) async {
        await _shareService.handleIncomingShare(text);
        ref.invalidate(lastSharedWordProvider);
        await refreshMyWordsCount();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inhalt erfasst')),
          );
        }
      },
      onSavedUrl: ({required bool isPdf}) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isPdf ? 'PDF-Position gespeichert' : 'Seitenposition gespeichert')),
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
  void toggleImage() => state = state.copyWith(imageExpanded: !state.imageExpanded);
  void setImageDark(bool v) => state = state.copyWith(imageIsDark: v);
  void setCategoriesActive(bool v) => state = state.copyWith(categoriesActive: v);

  // Data
  Future<void> refreshMyWordsCount() async {
    try {
      final c = await _wordRepo.countMyWords(browserOnly: true); // ✅
      state = state.copyWith(myWordsCount: c);
    } catch (_) {}
  }

  Future<String?> handleIncomingShare(String rawText) async {
    final markedWord = await _shareService.handleIncomingShare(rawText);
    if (markedWord != null) {
      ref.invalidate(lastSharedWordProvider); // Trigger UI refresh for last shared word
      await refreshMyWordsCount();
    }
    return markedWord;
  }
}
