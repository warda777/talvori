import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_voice_input_service.dart';

void main() {
  group('LocalImpulseVoiceMessageService', () {
    test('startRecording returns denied without throwing', () async {
      final service = LocalImpulseVoiceMessageService(
        recorder: _FakeRecorder(permission: false),
        transcriber: _FakeTranscriber(),
        directoryProvider: _tempDirectory,
      );

      final result = await service.startRecording();

      expect(result.status, ImpulseVoiceMessageStatus.denied);
      expect(service.state, ImpulseVoiceRecordingState.denied);
    });

    test('stopRecording returns local audio path and duration', () async {
      var now = DateTime(2026, 5, 21, 12);
      final service = LocalImpulseVoiceMessageService(
        recorder: _FakeRecorder(),
        transcriber: _FakeTranscriber(transcript: 'Wie nutze ich move?'),
        directoryProvider: _tempDirectory,
        clock: () => now,
      );

      expect(
        (await service.startRecording()).status,
        ImpulseVoiceMessageStatus.started,
      );
      now = now.add(const Duration(seconds: 2));
      final result = await service.stopRecording();

      expect(result.status, ImpulseVoiceMessageStatus.completed);
      expect(result.audioPath, isNotNull);
      expect(result.durationMs, greaterThanOrEqualTo(2000));
      expect(result.transcript, 'Wie nutze ich move?');
      expect(result.language, isNull);
      expect(await File(result.audioPath!).exists(), isTrue);
    });

    test('empty transcription completes without transcript', () async {
      var now = DateTime(2026, 5, 21, 12);
      final transcriber = _FakeTranscriber();
      final service = LocalImpulseVoiceMessageService(
        recorder: _FakeRecorder(),
        transcriber: transcriber,
        directoryProvider: _tempDirectory,
        clock: () => now,
      );

      await service.startRecording(localeId: 'de_DE');
      now = now.add(const Duration(seconds: 2));
      final result = await service.stopRecording();

      expect(result.status, ImpulseVoiceMessageStatus.completed);
      expect(result.transcript, isNull);
      expect(result.language, 'de_DE');
      expect(transcriber.lastLocaleId, 'de_DE');
    });

    test('cancelRecording deletes temporary audio file', () async {
      final recorder = _FakeRecorder();
      final service = LocalImpulseVoiceMessageService(
        recorder: recorder,
        transcriber: _FakeTranscriber(),
        directoryProvider: _tempDirectory,
      );

      await service.startRecording();
      final path = recorder.path;
      expect(path, isNotNull);
      expect(await File(path!).exists(), isTrue);

      final result = await service.cancelRecording();

      expect(result.status, ImpulseVoiceMessageStatus.cancelled);
      expect(await File(path).exists(), isFalse);
    });

    test('parallel start is prevented', () async {
      final service = LocalImpulseVoiceMessageService(
        recorder: _FakeRecorder(),
        transcriber: _FakeTranscriber(),
        directoryProvider: _tempDirectory,
      );

      expect(
        (await service.startRecording()).status,
        ImpulseVoiceMessageStatus.started,
      );
      expect(
        (await service.startRecording()).status,
        ImpulseVoiceMessageStatus.alreadyRecording,
      );
    });

    test('missing playback file is reported without crashing', () async {
      final service = LocalImpulseVoiceMessageService(
        recorder: _FakeRecorder(),
        transcriber: _FakeTranscriber(),
        directoryProvider: _tempDirectory,
      );

      final result = await service.play('/tmp/talvori-missing-audio.m4a');

      expect(result.success, isFalse);
      expect(result.errorMessage, 'missing_file');
    });
  });
}

Future<Directory> _tempDirectory() async {
  final directory = Directory.systemTemp.createTempSync('talvori_voice_test_');
  addTearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });
  return directory;
}

class _FakeRecorder implements ImpulseAudioRecorder {
  _FakeRecorder({this.permission = true});

  final bool permission;
  String? path;
  var recording = false;

  @override
  Future<bool> hasPermission({bool request = true}) async => permission;

  @override
  Future<bool> isEncoderSupported(AudioEncoder encoder) async {
    return encoder == AudioEncoder.aacLc;
  }

  @override
  Stream<Amplitude> onAmplitudeChanged(Duration interval) {
    return Stream<Amplitude>.value(Amplitude(current: -60, max: -60));
  }

  @override
  Future<void> start(RecordConfig config, {required String path}) async {
    this.path = path;
    recording = true;
    await File(path).writeAsString('audio');
  }

  @override
  Future<String?> stop() async {
    recording = false;
    return path;
  }

  @override
  Future<void> cancel() async {
    recording = false;
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> dispose() async {}
}

class _FakeTranscriber implements ImpulseSpeechTranscriber {
  _FakeTranscriber({this.transcript = ''});

  final String transcript;
  String? lastLocaleId;
  var listenCalls = 0;
  var stopCalls = 0;
  var cancelCalls = 0;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> listen({
    required String? localeId,
    required ImpulseTranscriptChanged onText,
  }) async {
    lastLocaleId = localeId;
    listenCalls += 1;
    if (transcript.trim().isNotEmpty) onText(transcript);
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }

  @override
  Future<void> cancel() async {
    cancelCalls += 1;
  }

  @override
  Future<void> dispose() async {}
}
