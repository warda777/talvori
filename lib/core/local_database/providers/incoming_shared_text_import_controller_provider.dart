import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../platform/shared_text_platform_receiver.dart';
import '../services/incoming_shared_text_import_controller.dart';
import 'shared_text_import_service_provider.dart';

final sharedTextPlatformReceiverProvider = Provider<SharedTextPlatformReceiver>(
  (ref) {
    return SharedTextPlatformReceiver();
  },
);

final incomingSharedTextImportControllerProvider =
    FutureProvider<IncomingSharedTextImportController>((ref) async {
      final importService = await ref.watch(
        sharedTextImportServiceProvider.future,
      );
      return IncomingSharedTextImportController(
        receiver: ref.watch(sharedTextPlatformReceiverProvider),
        importText: importService.importRawText,
      );
    });
