import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../errors/result.dart';
import '../errors/failures.dart';

abstract class SttService {
  Future<bool> initialize({Function(String status)? onStatus});
  Future<Result<bool>> startListening({
    required Function(String recognizedText) onResult,
    required Function() onSoundLevelChange,
    required Function() onError,
    Function(String status)? onStatus,
  });
  Future<void> stopListening();
  bool get isListening;
  bool get isAvailable;
}

class SpeechToTextServiceImpl implements SttService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isInitialized = false;

  @override
  bool get isListening => _speechToText.isListening;

  @override
  bool get isAvailable => _isInitialized && _speechToText.isAvailable;

  @override
  Future<bool> initialize({Function(String status)? onStatus}) async {
    try {
      final status = await Permission.microphone.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        _isInitialized = false;
        return false;
      }

      _isInitialized = await _speechToText.initialize(
        onError: (val) {
          // Suppress speech timeout prints as timeouts are normal idle events
          if (val.errorMsg != 'error_speech_timeout') {
            print('STT Error: ${val.errorMsg}');
          }
        },
        onStatus: (val) {
          if (onStatus != null) {
            onStatus(val);
          }
        },
      );
      return _isInitialized;
    } catch (e) {
      _isInitialized = false;
      return false;
    }
  }

  @override
  Future<Result<bool>> startListening({
    required Function(String recognizedText) onResult,
    required Function() onSoundLevelChange,
    required Function() onError,
    Function(String status)? onStatus,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize(onStatus: onStatus);
      if (!initialized) {
        return const FailureResult(VoiceFailure('Speech recognition is not available on this device or permission was denied.'));
      }
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 60),
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
        ),
      );
      return const Success(true);
    } catch (e) {
      return FailureResult(VoiceFailure('Failed to start listening: $e'));
    }
  }

  @override
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }
}
