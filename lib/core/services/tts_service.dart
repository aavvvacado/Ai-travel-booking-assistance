import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

abstract class TtsService {
  // Singleton Factory: enables calling TtsService() anywhere to return the singleton instance
  factory TtsService() => FlutterTtsServiceImpl();

  Future<void> init();
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> setMuted(bool isMuted);
  bool get isMuted;
  bool get isSpeaking;
  void setCompletionHandler(Function() onComplete);
}

class FlutterTtsServiceImpl implements TtsService {
  // 1. Singleton Setup: Prevents UI rebuilds from destroying the audio instance
  FlutterTtsServiceImpl._internal() {
    init();
  }
  static final FlutterTtsServiceImpl _instance = FlutterTtsServiceImpl._internal();
  factory FlutterTtsServiceImpl() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _muted = false;
  bool _speaking = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // Natural conversational rate
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambientSolo,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
        );
      }

      // 2. Wait for speech to finish before allowing other audio events
      await _flutterTts.awaitSpeakCompletion(true);

      _flutterTts.setStartHandler(() {
        _speaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _speaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        _speaking = false;
      });

      _isInitialized = true;
    } catch (_) {}
  }

  @override
  void setCompletionHandler(Function() onComplete) {
    _flutterTts.setCompletionHandler(() {
      _speaking = false;
      onComplete();
    });
  }

  @override
  bool get isMuted => _muted;

  @override
  bool get isSpeaking => _speaking;

  @override
  Future<void> setMuted(bool isMuted) async {
    _muted = isMuted;
    if (_muted && _speaking) {
      await stop();
    }
  }

  @override
  Future<void> speak(String text) async {
    if (!_isInitialized) await init();
    if (_muted || text.trim().isEmpty) return;

    // Clean voice text of markdown symbols before speaking
    final cleanText = text
        .replaceAll(RegExp(r'\*\*|\*|#|`'), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();

    // 3. Stop any current speech before starting new to prevent overlap crashes
    await stop();
    _speaking = true;

    try {
      await _flutterTts.speak(cleanText);
    } catch (e) {
      _speaking = false;
    }
  }

  @override
  Future<void> stop() async {
    _speaking = false;
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
