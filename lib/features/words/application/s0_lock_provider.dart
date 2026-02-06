import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';

/// Liest S0-Lock aus dem Backend (pro Category + Mode).
/// - Hybrid: immer false (UI soll es ausblenden)
final s0LockedProvider = FutureProvider.family.autoDispose<bool, String>((ref, categoryId) async {
  final srs = ref.watch(srsModeControllerProvider).mode;

  // Hybrid darf keinen S0-Lock haben
  if (srs == SrsSystem.hybrid) return false;

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) return false;

  final mode = (srs == SrsSystem.time) ? 'time' : 'adaptive';

  final res = await supabase.rpc('fn_get_s0_locked', params: {
    'p_user': user.id,
    'p_mode': mode,
    'p_category_id': categoryId,
  });

  return (res as bool?) ?? false;
});

/// Setzt S0-Lock im Backend und invalidiert anschließend den Provider.
final s0LockServiceProvider = Provider<_S0LockService>((ref) => _S0LockService(ref));

class _S0LockService {
  _S0LockService(this.ref);
  final Ref ref;

  Future<void> setLocked({
    required String categoryId,
    required bool locked,
  }) async {
    final srs = ref.read(srsModeControllerProvider).mode;

    // Hybrid: nicht zulassen (Backend wirft sowieso Error)
    if (srs == SrsSystem.hybrid) return;

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final mode = (srs == SrsSystem.time) ? 'time' : 'adaptive';

    await supabase.rpc('fn_set_s0_locked', params: {
      'p_user': user.id,
      'p_mode': mode,
      'p_locked': locked,
      'p_category_id': categoryId,
    });

    // Cache refresh
    ref.invalidate(s0LockedProvider(categoryId));
  }
}


