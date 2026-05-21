import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';

class ImpulseSavedMessage {
  const ImpulseSavedMessage({required this.chat, required this.message});

  final ImpulseChat chat;
  final ImpulseMessage message;
}
