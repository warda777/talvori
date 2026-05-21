import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

abstract class ImpulseVoiceMessageService {
  Future<ImpulseVoiceMessageResult> startRecording({String? localeId});
  Stream<double> amplitudeLevels({
    Duration interval = const Duration(milliseconds: 180),
  });
  Future<ImpulseVoiceMessageResult> stopRecording();
  Future<ImpulseVoiceMessageResult> cancelRecording();
  Future<ImpulseVoiceMessageResult> pauseRecording();
  Future<ImpulseVoiceMessageResult> resumeRecording();
  Future<ImpulseVoicePlaybackResult> play(String path);
  Future<void> stopPlayback();
  Future<void> dispose();
}

enum ImpulseVoiceMessageStatus {
  started,
  completed,
  cancelled,
  paused,
  resumed,
  denied,
  unavailable,
  tooShort,
  alreadyRecording,
  failed,
}

enum ImpulseVoiceRecordingState {
  idle,
  recording,
  locked,
  paused,
  cancelled,
  completed,
  denied,
  unavailable,
  error,
}

class ImpulseVoiceMessageResult {
  const ImpulseVoiceMessageResult._({
    required this.status,
    this.audioPath,
    this.durationMs,
    this.waveformSeed,
    this.transcript,
    this.language,
    this.errorMessage,
  });

  const ImpulseVoiceMessageResult.started()
    : this._(status: ImpulseVoiceMessageStatus.started);

  const ImpulseVoiceMessageResult.completed({
    required String audioPath,
    required int durationMs,
    int? waveformSeed,
    String? transcript,
    String? language,
  }) : this._(
         status: ImpulseVoiceMessageStatus.completed,
         audioPath: audioPath,
         durationMs: durationMs,
         waveformSeed: waveformSeed,
         transcript: transcript,
         language: language,
       );

  const ImpulseVoiceMessageResult.cancelled()
    : this._(status: ImpulseVoiceMessageStatus.cancelled);

  const ImpulseVoiceMessageResult.paused()
    : this._(status: ImpulseVoiceMessageStatus.paused);

  const ImpulseVoiceMessageResult.resumed()
    : this._(status: ImpulseVoiceMessageStatus.resumed);

  const ImpulseVoiceMessageResult.denied()
    : this._(status: ImpulseVoiceMessageStatus.denied);

  const ImpulseVoiceMessageResult.unavailable()
    : this._(status: ImpulseVoiceMessageStatus.unavailable);

  const ImpulseVoiceMessageResult.tooShort()
    : this._(status: ImpulseVoiceMessageStatus.tooShort);

  const ImpulseVoiceMessageResult.alreadyRecording()
    : this._(status: ImpulseVoiceMessageStatus.alreadyRecording);

  const ImpulseVoiceMessageResult.failed([String? errorMessage])
    : this._(
        status: ImpulseVoiceMessageStatus.failed,
        errorMessage: errorMessage,
      );

  final ImpulseVoiceMessageStatus status;
  final String? audioPath;
  final int? durationMs;
  final int? waveformSeed;
  final String? transcript;
  final String? language;
  final String? errorMessage;
}

class ImpulseVoicePlaybackResult {
  const ImpulseVoicePlaybackResult._({
    required this.success,
    this.errorMessage,
  });

  const ImpulseVoicePlaybackResult.success() : this._(success: true);

  const ImpulseVoicePlaybackResult.failed([String? errorMessage])
    : this._(success: false, errorMessage: errorMessage);

  final bool success;
  final String? errorMessage;
}

abstract class ImpulseAudioRecorder {
  Future<bool> hasPermission({bool request = true});
  Future<bool> isEncoderSupported(AudioEncoder encoder);
  Stream<Amplitude> onAmplitudeChanged(Duration interval);
  Future<void> start(RecordConfig config, {required String path});
  Future<String?> stop();
  Future<void> cancel();
  Future<void> pause();
  Future<void> resume();
  Future<void> dispose();
}

abstract class ImpulseSpeechTranscriber {
  Future<bool> initialize();
  Future<void> listen({
    required String? localeId,
    required ImpulseTranscriptChanged onText,
  });
  Future<void> stop();
  Future<void> cancel();
  Future<void> dispose();
}

typedef ImpulseTranscriptChanged = void Function(String value);

class SpeechToTextImpulseTranscriber implements ImpulseSpeechTranscriber {
  SpeechToTextImpulseTranscriber({SpeechToText? speech})
    : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  var _initialized = false;

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    return _initialized;
  }

  @override
  Future<void> listen({
    required String? localeId,
    required ImpulseTranscriptChanged onText,
  }) async {
    if (!_initialized) return;
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        final words = result.recognizedWords.trim();
        if (words.isNotEmpty) onText(words);
      },
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
        autoPunctuation: true,
      ),
    );
  }

  @override
  Future<void> stop() async {
    if (_initialized) await _speech.stop();
  }

  @override
  Future<void> cancel() async {
    if (_initialized) await _speech.cancel();
  }

  @override
  Future<void> dispose() async {
    await cancel();
  }
}

class RecordImpulseAudioRecorder implements ImpulseAudioRecorder {
  RecordImpulseAudioRecorder({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  @override
  Future<bool> hasPermission({bool request = true}) {
    return _recorder.hasPermission(request: request);
  }

  @override
  Future<bool> isEncoderSupported(AudioEncoder encoder) {
    return _recorder.isEncoderSupported(encoder);
  }

  @override
  Future<void> start(RecordConfig config, {required String path}) {
    return _recorder.start(config, path: path);
  }

  @override
  Stream<Amplitude> onAmplitudeChanged(Duration interval) {
    return _recorder.onAmplitudeChanged(interval);
  }

  @override
  Future<String?> stop() => _recorder.stop();

  @override
  Future<void> cancel() => _recorder.cancel();

  @override
  Future<void> pause() => _recorder.pause();

  @override
  Future<void> resume() => _recorder.resume();

  @override
  Future<void> dispose() => _recorder.dispose();
}

class LocalImpulseVoiceMessageService implements ImpulseVoiceMessageService {
  LocalImpulseVoiceMessageService({
    ImpulseAudioRecorder? recorder,
    ImpulseSpeechTranscriber? transcriber,
    AudioPlayer? player,
    DateTime Function()? clock,
    Future<Directory> Function()? directoryProvider,
    this.minimumDuration = const Duration(seconds: 1),
  }) : _recorder = recorder ?? RecordImpulseAudioRecorder(),
       _transcriber = transcriber ?? SpeechToTextImpulseTranscriber(),
       _player = player,
       _clock = clock ?? DateTime.now,
       _directoryProvider =
           directoryProvider ?? getApplicationDocumentsDirectory;

  final ImpulseAudioRecorder _recorder;
  final ImpulseSpeechTranscriber _transcriber;
  AudioPlayer? _player;
  final DateTime Function() _clock;
  final Future<Directory> Function() _directoryProvider;
  final Duration minimumDuration;

  ImpulseVoiceRecordingState _state = ImpulseVoiceRecordingState.idle;
  DateTime? _startedAt;
  Duration _pausedElapsed = Duration.zero;
  DateTime? _pauseStartedAt;
  String? _currentPath;
  String? _currentLocaleId;
  String _latestTranscript = '';

  ImpulseVoiceRecordingState get state => _state;

  @override
  Stream<double> amplitudeLevels({
    Duration interval = const Duration(milliseconds: 180),
  }) {
    return _recorder
        .onAmplitudeChanged(interval)
        .map((amplitude) {
          final current = amplitude.current;
          if (current <= -55) return 0.0;
          if (current >= -12) return 1.0;
          return ((current + 55) / 43).clamp(0.0, 1.0);
        })
        .handleError((Object _) => 0.0);
  }

  @override
  Future<ImpulseVoiceMessageResult> startRecording({String? localeId}) async {
    if (_state == ImpulseVoiceRecordingState.recording ||
        _state == ImpulseVoiceRecordingState.paused) {
      return const ImpulseVoiceMessageResult.alreadyRecording();
    }

    try {
      final permitted = await _recorder.hasPermission();
      if (!permitted) {
        _state = ImpulseVoiceRecordingState.denied;
        return const ImpulseVoiceMessageResult.denied();
      }

      final encoder = await _selectEncoder();
      if (encoder == null) {
        _state = ImpulseVoiceRecordingState.unavailable;
        return const ImpulseVoiceMessageResult.unavailable();
      }

      final directory = await _voiceDirectory();
      final path =
          '${directory.path}/impulse-voice-${_clock().microsecondsSinceEpoch}.${_extensionFor(encoder)}';
      await _recorder.start(
        RecordConfig(
          encoder: encoder,
          bitRate: 96000,
          sampleRate: 44100,
          numChannels: 1,
          noiseSuppress: true,
          echoCancel: true,
        ),
        path: path,
      );
      _currentPath = path;
      _currentLocaleId = localeId;
      _latestTranscript = '';
      _startedAt = _clock();
      _pausedElapsed = Duration.zero;
      _pauseStartedAt = null;
      _state = ImpulseVoiceRecordingState.recording;
      await _startTranscription(localeId);
      return const ImpulseVoiceMessageResult.started();
    } on Object catch (error) {
      _state = ImpulseVoiceRecordingState.error;
      return ImpulseVoiceMessageResult.failed('$error');
    }
  }

  @override
  Future<ImpulseVoiceMessageResult> stopRecording() async {
    try {
      if (_state == ImpulseVoiceRecordingState.idle || _currentPath == null) {
        return const ImpulseVoiceMessageResult.failed('not_recording');
      }
      _resumePauseTimerIfNeeded();
      final path = await _recorder.stop() ?? _currentPath;
      await _transcriber.stop();
      final duration = _recordingDuration();
      final transcript = _latestTranscript.trim();
      final language = _currentLocaleId;
      _resetSession(ImpulseVoiceRecordingState.completed);
      if (path == null) {
        return const ImpulseVoiceMessageResult.failed('missing_path');
      }
      if (duration < minimumDuration) {
        await _deleteFileIfExists(path);
        return const ImpulseVoiceMessageResult.tooShort();
      }
      return ImpulseVoiceMessageResult.completed(
        audioPath: path,
        durationMs: duration.inMilliseconds,
        waveformSeed: path.hashCode.abs(),
        transcript: transcript.isEmpty ? null : transcript,
        language: language,
      );
    } on Object catch (error) {
      _state = ImpulseVoiceRecordingState.error;
      return ImpulseVoiceMessageResult.failed('$error');
    }
  }

  @override
  Future<ImpulseVoiceMessageResult> cancelRecording() async {
    final path = _currentPath;
    try {
      if (_state != ImpulseVoiceRecordingState.idle) {
        await _recorder.cancel();
      }
      await _transcriber.cancel();
      if (path != null) await _deleteFileIfExists(path);
      _resetSession(ImpulseVoiceRecordingState.cancelled);
      return const ImpulseVoiceMessageResult.cancelled();
    } on Object catch (error) {
      if (path != null) await _deleteFileIfExists(path);
      _state = ImpulseVoiceRecordingState.error;
      return ImpulseVoiceMessageResult.failed('$error');
    }
  }

  @override
  Future<ImpulseVoiceMessageResult> pauseRecording() async {
    try {
      if (_state != ImpulseVoiceRecordingState.recording) {
        return const ImpulseVoiceMessageResult.failed('not_recording');
      }
      await _recorder.pause();
      await _transcriber.stop();
      _pauseStartedAt = _clock();
      _state = ImpulseVoiceRecordingState.paused;
      return const ImpulseVoiceMessageResult.paused();
    } on Object catch (error) {
      _state = ImpulseVoiceRecordingState.error;
      return ImpulseVoiceMessageResult.failed('$error');
    }
  }

  @override
  Future<ImpulseVoiceMessageResult> resumeRecording() async {
    try {
      if (_state != ImpulseVoiceRecordingState.paused) {
        return const ImpulseVoiceMessageResult.failed('not_paused');
      }
      _resumePauseTimerIfNeeded();
      await _recorder.resume();
      await _startTranscription(_currentLocaleId);
      _state = ImpulseVoiceRecordingState.recording;
      return const ImpulseVoiceMessageResult.resumed();
    } on Object catch (error) {
      _state = ImpulseVoiceRecordingState.error;
      return ImpulseVoiceMessageResult.failed('$error');
    }
  }

  @override
  Future<ImpulseVoicePlaybackResult> play(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        return const ImpulseVoicePlaybackResult.failed('missing_file');
      }
      final player = _player ??= AudioPlayer();
      await player.stop();
      await player.play(DeviceFileSource(path));
      return const ImpulseVoicePlaybackResult.success();
    } on Object catch (error) {
      return ImpulseVoicePlaybackResult.failed('$error');
    }
  }

  @override
  Future<void> stopPlayback() async {
    await _player?.stop();
  }

  @override
  Future<void> dispose() async {
    await cancelRecording();
    await _player?.dispose();
    await _transcriber.dispose();
    await _recorder.dispose();
  }

  Future<void> _startTranscription(String? localeId) async {
    try {
      final available = await _transcriber.initialize();
      if (!available) return;
      await _transcriber.listen(
        localeId: localeId,
        onText: (value) {
          final normalized = value.trim();
          if (normalized.isNotEmpty) _latestTranscript = normalized;
        },
      );
    } on Object {
      // Audio recording must stay usable even when local speech recognition
      // is unavailable or denied.
    }
  }

  Future<AudioEncoder?> _selectEncoder() async {
    for (final encoder in const [AudioEncoder.aacLc, AudioEncoder.wav]) {
      if (await _recorder.isEncoderSupported(encoder)) return encoder;
    }
    return null;
  }

  String _extensionFor(AudioEncoder encoder) {
    return switch (encoder) {
      AudioEncoder.wav => 'wav',
      _ => 'm4a',
    };
  }

  Future<Directory> _voiceDirectory() async {
    final root = await _directoryProvider();
    final directory = Directory('${root.path}/impulse_voice_messages');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Duration _recordingDuration() {
    final started = _startedAt;
    if (started == null) return Duration.zero;
    final currentPause = _pauseStartedAt == null
        ? Duration.zero
        : _clock().difference(_pauseStartedAt!);
    final raw = _clock().difference(started) - _pausedElapsed - currentPause;
    return raw.isNegative ? Duration.zero : raw;
  }

  void _resumePauseTimerIfNeeded() {
    final pauseStarted = _pauseStartedAt;
    if (pauseStarted == null) return;
    _pausedElapsed += _clock().difference(pauseStarted);
    _pauseStartedAt = null;
  }

  void _resetSession(ImpulseVoiceRecordingState nextState) {
    _state = nextState;
    _startedAt = null;
    _pausedElapsed = Duration.zero;
    _pauseStartedAt = null;
    _currentPath = null;
    _currentLocaleId = null;
    _latestTranscript = '';
  }

  Future<void> _deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
