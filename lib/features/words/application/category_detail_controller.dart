import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'category_detail_state.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/ui/widgets/stats_helpers.dart';
import 'package:talvori/core/events/events.dart';
import 'package:talvori/features/words/application/word_providers.dart';

final categoryDetailControllerProvider =
  NotifierProvider<CategoryDetailController, CategoryDetailState>(
    () => CategoryDetailController(),
  );

class CategoryDetailController extends Notifier<CategoryDetailState> {
  @override
  CategoryDetailState build() => const CategoryDetailState();

  Timer? _switchDebounce;
  StreamSubscription<String>? _resetSub;
  StreamSubscription<StageTransitionEvent>? _stageSub;

  // === lifecycle ===
  Future<void> init({String? categoryId, String? categorySlug, required String fallbackTitle}) async {
    state = state.copyWith(loading: true);
    try {
      final cats = await fetchAllCategories();
      final idx = _findInitialIndex(cats, categoryId, categorySlug, fallbackTitle);
      state = state.copyWith(categories: cats, selectedIndex: idx);

      if (cats.isNotEmpty) {
        final selId = _currentCatId;
        await ensureTodayBucket(selId);
        await _loadProgress(selId, preferLocal: true);
        await _loadVocabsTotal(selId);
      }

      // events
      _resetSub?.cancel();
      _resetSub = ResetEvent.stream.listen((catId) async {
        if (catId == _currentCatId) {
          await applyLocalReset(catId);
          await reload();
        }
      });

      _stageSub?.cancel();
      _stageSub = StageTransitionEvent.stream.listen((e) async {
        if (e.categoryId != _currentCatId) return;
        await ensureTodayBucket(e.categoryId);
        final prefs = await SharedPreferences.getInstance();
        var todayNew = prefs.getInt('today_new_${e.categoryId}') ?? 0;
        var todayRep = prefs.getInt('today_repeats_${e.categoryId}') ?? 0;

        if (e.fromStage == 0 && e.toStage >= 1) todayNew += 1;
        else if (e.fromStage >= 1 && e.toStage == 0) todayNew = (todayNew - 1).clamp(0, 1<<30);
        if (e.wasDueBefore == true) todayRep += 1;

        await prefs.setInt('today_new_${e.categoryId}', todayNew);
        await prefs.setInt('today_repeats_${e.categoryId}', todayRep);
        state = state.copyWith(dailyNew: todayNew, dailyRepeats: todayRep);
      });
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> disposeSubscriptions() async {
    _switchDebounce?.cancel();
    await _resetSub?.cancel();
    await _stageSub?.cancel();
  }

  // === intents ===
  Future<void> switchTo(int idx) async {
    if (idx < 0 || idx >= state.categories.length) return;
    state = state.copyWith(selectedIndex: idx);
    _switchDebounce?.cancel();
    _switchDebounce = Timer(const Duration(milliseconds: 180), () async {
      final selId = _currentCatId;
      await _loadProgress(selId, preferLocal: false);
      await _loadVocabsTotal(selId);
    });
  }

  Future<void> reload() async {
    if (state.categories.isEmpty) return;
    final selId = _currentCatId;
    await ensureTodayBucket(selId);
    await _loadProgress(selId, preferLocal: false);
    await _loadVocabsTotal(selId);
  }

  Future<void> applyLocalReset(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('learn_stages_$categoryId', '0,0,0,0,0,0');
    await prefs.setInt('today_new_$categoryId', 0);
    await prefs.setInt('today_repeats_$categoryId', 0);
    await prefs.setBool('just_reset_$categoryId', true);
  }

  Future<void> seedForStart(String categoryId) async {
    final sb = Supabase.instance.client;
    await sb.rpc('fn_seed_user_category', params: {'p_category_id': categoryId});
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('learn_stages_$categoryId');
    await prefs.remove('just_reset_$categoryId');
    await prefs.setBool('just_seeded_$categoryId', true);
  }

  // === private ===
  String get _currentCatId => state.categories.isNotEmpty ? state.categories[state.selectedIndex].id : '';

  Future<void> _loadVocabsTotal(String catId) async {
    final sb = Supabase.instance.client;
    final res = await sb.rpc('fn_category_word_count', params: {'p_category_id': catId});
    state = state.copyWith(vocabsTotal: (res as int?) ?? 0);
  }

  Future<void> _loadProgress(String selId, {required bool preferLocal}) async {
    final prefs = await SharedPreferences.getInstance();
    final stageKey = 'learn_stages_$selId';
    final stored = prefs.getString(stageKey);
    List<int>? localStages;
    if (stored != null) {
      try {
        final parsed = stored.split(',').map(int.parse).toList();
        if (parsed.length == 6) localStages = parsed;
      } catch (_) {}
    }
    final justReset  = prefs.getBool('just_reset_$selId')  ?? false;
    final justSeeded = prefs.getBool('just_seeded_$selId') ?? false;

    if (justSeeded) {
      final repo = ref.read(supabaseWordRepositoryProvider);
      final prog = await repo.fetchCategoryProgress(
        selId,
        srsSystem: ref.read(srsModeControllerProvider).mode,
      );
      final wl   = await repo.fetchWorkloadToday(selId);
      await prefs.remove('just_seeded_$selId');

      final daily = await loadDailyLearningStats(selId);
      state = state.copyWith(
        progress: CategoryProgress(
          total: prog.total,
          stages: prog.stages,
          dueToday: prog.dueToday,
          newTotal: prog.newTotal,
        ),
        workload: wl,
        dailyNew: daily.$1,
        dailyRepeats: daily.$2,
      );
      return;
    }

    if (justReset && localStages != null) {
      await prefs.remove('just_reset_$selId');
      state = state.copyWith(
        progress: CategoryProgress(total: 0, stages: localStages, dueToday: 0, newTotal: 0),
        workload: WorkloadToday(dueToday: 0, newTotal: 0),
        dailyNew: 0,
        dailyRepeats: 0,
      );
      return;
    }

    final repo = ref.read(supabaseWordRepositoryProvider);
    final prog = await repo.fetchCategoryProgress(
      selId,
      srsSystem: ref.read(srsModeControllerProvider).mode,
    );
    final wl   = await repo.fetchWorkloadToday(selId);
    final daily = await loadDailyLearningStats(selId);

    final stages = (preferLocal && localStages != null) ? localStages : prog.stages;
    state = state.copyWith(
      progress: CategoryProgress(total: prog.total, stages: stages, dueToday: prog.dueToday, newTotal: prog.newTotal),
      workload: wl,
      dailyNew: daily.$1,
      dailyRepeats: daily.$2,
    );
  }

  int _findInitialIndex(List<CategoryInfo> cats, String? id, String? slug, String title) {
    if (id != null && id.isNotEmpty) {
      final i = cats.indexWhere((c) => c.id == id);
      if (i >= 0) return i;
    }
    if (slug != null && slug.isNotEmpty) {
      final i = cats.indexWhere((c) => c.slug == slug);
      if (i >= 0) return i;
    }
    final name = title.trim().toLowerCase();
    var i = cats.indexWhere((c) => c.name.trim().toLowerCase() == name);
    if (i >= 0) return i;
    final tslug = title.toLowerCase().replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
    i = cats.indexWhere((c) => c.slug == tslug);
    return i >= 0 ? i : 0;
  }
}

/// Mode-abhängiger Category Progress Provider
/// Provider-Key ist (catId, srs) -> wird bei Mode-Wechsel automatisch neu geladen
final categoryProgressProvider =
    FutureProvider.family<CategoryProgress, ({String catId, SrsSystem srs})>((ref, args) async {
  final repo = ref.read(supabaseWordRepositoryProvider);

  // Muss die MODE-AWARE RPC benutzen (nicht die alte ohne mode)
  return repo.fetchCategoryProgress(args.catId, srsSystem: args.srs);
});
