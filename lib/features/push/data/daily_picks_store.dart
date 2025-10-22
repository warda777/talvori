import 'package:flutter/foundation.dart';

class DailyPicksStore extends ChangeNotifier {
  static final DailyPicksStore I = DailyPicksStore._();
  DailyPicksStore._();

  int maxCount = 5; // später aus Settings
  final List<String> _items = [];
  List<String> get items => List.unmodifiable(_items);

  AddResult add(String word) {
    final w = word.trim();
    if (w.isEmpty) return AddResult.invalid;
    if (_items.contains(w)) return AddResult.duplicate;
    if (_items.length >= maxCount) return AddResult.full;
    _items.add(w);
    notifyListeners();
    return AddResult.ok;
  }

  bool remove(String word) {
    final ok = _items.remove(word);
    if (ok) notifyListeners();
    return ok;
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}

enum AddResult { ok, duplicate, full, invalid }
