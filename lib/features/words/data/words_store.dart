import 'package:flutter/foundation.dart';

class WordsStore extends ChangeNotifier {
  static final WordsStore I = WordsStore._();
  WordsStore._();

  final List<String> _items = [];
  List<String> get items => List.unmodifiable(_items);

  void add(String w) {
    if (w.trim().isEmpty) return;
    _items.insert(0, w.trim());
    notifyListeners();
  }

  void updateAt(int i, String w) {
    if (i < 0 || i >= _items.length) return;
    _items[i] = w.trim();
    notifyListeners();
  }

  void removeAt(int i) {
    if (i < 0 || i >= _items.length) return;
    _items.removeAt(i);
    notifyListeners();
  }
}
