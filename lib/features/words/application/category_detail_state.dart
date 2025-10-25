import 'package:talvori/features/words/data/supabase_word_repository.dart';

class CategoryDetailState {
  final bool loading;
  final List<CategoryInfo> categories;
  final int selectedIndex;
  final CategoryProgress? progress;
  final WorkloadToday? workload;
  final int vocabsTotal;
  final int dailyNew;
  final int dailyRepeats;

  const CategoryDetailState({
    this.loading = false,
    this.categories = const [],
    this.selectedIndex = 0,
    this.progress,
    this.workload,
    this.vocabsTotal = 0,
    this.dailyNew = 0,
    this.dailyRepeats = 0,
  });

  CategoryDetailState copyWith({
    bool? loading,
    List<CategoryInfo>? categories,
    int? selectedIndex,
    CategoryProgress? progress,
    WorkloadToday? workload,
    int? vocabsTotal,
    int? dailyNew,
    int? dailyRepeats,
  }) {
    return CategoryDetailState(
      loading: loading ?? this.loading,
      categories: categories ?? this.categories,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      progress: progress ?? this.progress,
      workload: workload ?? this.workload,
      vocabsTotal: vocabsTotal ?? this.vocabsTotal,
      dailyNew: dailyNew ?? this.dailyNew,
      dailyRepeats: dailyRepeats ?? this.dailyRepeats,
    );
  }
}