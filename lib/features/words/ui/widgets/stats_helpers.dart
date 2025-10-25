import 'package:shared_preferences/shared_preferences.dart';

/// Lädt tägliche Lernstatistiken (heute) für eine Kategorie.
/// Returns: (newCount, repeatCount)
Future<(int, int)> loadDailyLearningStats(String categoryId) async {
  final prefs = await SharedPreferences.getInstance();
  final newToday = prefs.getInt('today_new_$categoryId') ?? 0;
  final repsToday = prefs.getInt('today_repeats_$categoryId') ?? 0;
  return (newToday, repsToday);
}

/// Stellt sicher, dass der "heute"-Bucket korrekt initialisiert ist (Tageswechsel reset).
Future<void> ensureTodayBucket(String categoryId) async {
  final prefs = await SharedPreferences.getInstance();
  final keyDate = 'today_date_$categoryId';
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final last = prefs.getString(keyDate);
  if (last != today) {
    prefs
      ..setString(keyDate, today)
      ..setInt('today_new_$categoryId', 0)
      ..setInt('today_repeats_$categoryId', 0);
  }
}
