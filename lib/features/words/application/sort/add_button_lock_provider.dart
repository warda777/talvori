import 'package:flutter_riverpod/flutter_riverpod.dart';

/// true = Add Button gesperrt (kann keine Wörter hinzufügen)
final addButtonLockedProvider = StateProvider<bool>((ref) => false);

