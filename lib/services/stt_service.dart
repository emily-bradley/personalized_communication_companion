import 'package:speech_to_text/speech_to_text.dart';

class STTService {
  final SpeechToText _speech = SpeechToText();

  bool isListening = false;
  String lastWords = '';

  /// Initialize and start listening
  Future<bool> startListening({
    required Function(String) onResult,
    required Function(String) onStatus,
    required Function(String) onError,
  }) async {
    bool available = await _speech.initialize(
      onStatus: (val) => onStatus(val),
      onError: (val) => onError(val.errorMsg),
    );

    if (!available) return false;

    isListening = true;
    _speech.listen(
      onResult: (val) {
        lastWords = val.recognizedWords;
        onResult(lastWords);
      },
    );
    return true;
  }

  /// Stop listening
  void stopListening() {
    _speech.stop();
    isListening = false;
  }

  /// Cancel listening
  void cancelListening() {
    _speech.cancel();
    isListening = false;
  }

  /// Whether the device supports STT
  Future<bool> isAvailable() async {
    return await _speech.initialize();
  }
}
