import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

abstract class ImpulseVoiceInputService {
  Future<ImpulseVoiceInputResult> listenForText();
}

class ImpulseVoiceInputResult {
  const ImpulseVoiceInputResult._({
    required this.status,
    this.text,
    this.errorMessage,
  });

  const ImpulseVoiceInputResult.success(String text)
    : this._(status: ImpulseVoiceInputStatus.success, text: text);

  const ImpulseVoiceInputResult.permissionDenied()
    : this._(status: ImpulseVoiceInputStatus.permissionDenied);

  const ImpulseVoiceInputResult.unavailable()
    : this._(status: ImpulseVoiceInputStatus.unavailable);

  const ImpulseVoiceInputResult.noSpeech()
    : this._(status: ImpulseVoiceInputStatus.noSpeech);

  const ImpulseVoiceInputResult.failed([String? errorMessage])
    : this._(
        status: ImpulseVoiceInputStatus.failed,
        errorMessage: errorMessage,
      );

  final ImpulseVoiceInputStatus status;
  final String? text;
  final String? errorMessage;
}

enum ImpulseVoiceInputStatus {
  success,
  permissionDenied,
  unavailable,
  noSpeech,
  failed,
}

class SpeechToTextImpulseVoiceInputService implements ImpulseVoiceInputService {
  SpeechToTextImpulseVoiceInputService({SpeechToText? speech})
    : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;

  @override
  Future<ImpulseVoiceInputResult> listenForText() async {
    try {
      final hasPermission = await _speech.hasPermission;
      final available = await _speech.initialize(
        onError: (error) {
          // The final result is mapped below through the recognizer state.
        },
        onStatus: (_) {},
        options: [SpeechToText.iosNoBluetooth],
      );
      if (!available) {
        return hasPermission
            ? const ImpulseVoiceInputResult.unavailable()
            : const ImpulseVoiceInputResult.permissionDenied();
      }

      final completer = Completer<String?>();
      var latestText = '';
      Timer? timeout;

      timeout = Timer(const Duration(seconds: 9), () async {
        if (_speech.isListening) {
          await _speech.stop();
        }
        if (!completer.isCompleted) {
          completer.complete(latestText.trim().isEmpty ? null : latestText);
        }
      });

      await _speech.listen(
        onResult: (result) {
          latestText = result.recognizedWords.trim();
          if (result.finalResult && !completer.isCompleted) {
            completer.complete(latestText);
          }
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
          listenFor: const Duration(seconds: 8),
          pauseFor: const Duration(seconds: 2),
        ),
      );

      final text = (await completer.future)?.trim() ?? '';
      timeout.cancel();
      if (text.isEmpty) return const ImpulseVoiceInputResult.noSpeech();
      return ImpulseVoiceInputResult.success(text);
    } on Object catch (error) {
      return ImpulseVoiceInputResult.failed('$error');
    }
  }
}
