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
    // Debug logs
    final hasPermission = await _speech.hasPermission;
    final locale = await _speech.systemLocale();
    print("STT permission: $hasPermission");
    print("System locale: ${locale?.localeId}");

    // Attempt initialization
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("STT status: $status");
        onStatus(status);
      },
      onError: (error) {
        print("STT error: ${error.errorType} — ${error.errorMsg}");
        onError(error.errorMsg);
      },
    );

    print("Speech recognition available: $available");

    // Retry if needed
    if (!available) {
      print("STT unavailable, retrying...");
      await Future.delayed(Duration(seconds: 1));
      available = await _speech.initialize(
        onStatus: (status) {
          print("STT status: $status");
          onStatus(status);
        },
        onError: (error) {
          print("STT error (retry): ${error.errorType} — ${error.errorMsg}");
          onError(error.errorMsg);
        },
      );
      if (!available) return false;
    }

    // Avoid duplicate listens
    if (_speech.isListening) {
      print("Already listening — skipping new listen call.");
      return true;
    }

    // Add slight delay to reduce platform race conditions
    await Future.delayed(const Duration(milliseconds: 500));

    isListening = true;

    _speech.listen(
      onResult: (result) {
        lastWords = result.recognizedWords;
        print("STT result: $lastWords");
        onResult(lastWords);
      },
      cancelOnError: true,
      listenMode: ListenMode.confirmation, // or .dictation or .search
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

  /// Whether STT is available
  Future<bool> isAvailable() async {
    return await _speech.initialize();
  }
}
