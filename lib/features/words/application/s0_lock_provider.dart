import 'package:flutter_riverpod/flutter_riverpod.dart';

/// true = S0 gesperrt (keine neuen Karten ausgeben)
final s0LockedProvider = StateProvider<bool>((ref) => false);
