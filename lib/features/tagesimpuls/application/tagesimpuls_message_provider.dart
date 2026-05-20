import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:talvori/core/local_database/translation/supabase_function_caller.dart';

import '../ai/supabase_tagesimpuls_ai_client.dart';
import '../ai/tagesimpuls_ai_client.dart';
import 'tagesimpuls_message_controller.dart';

final tagesimpulsFunctionCallerProvider = Provider<TagesimpulsFunctionCaller>((
  ref,
) {
  return supabaseFunctionCallerFromClient(Supabase.instance.client);
});

final tagesimpulsAiClientProvider = Provider<TagesimpulsAiClient>((ref) {
  final functionCaller = ref.watch(tagesimpulsFunctionCallerProvider);
  return SupabaseTagesimpulsAiClient(functionCaller: functionCaller);
});

final tagesimpulsMessageControllerProvider =
    StateNotifierProvider<
      TagesimpulsMessageController,
      TagesimpulsMessageState
    >((ref) {
      final client = ref.watch(tagesimpulsAiClientProvider);
      return TagesimpulsMessageController(client: client);
    });
