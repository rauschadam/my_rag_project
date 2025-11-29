import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Manages the Speech-to-Text functionality.
class SpeechManager {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  bool get isListening => _speechToText.isListening;
  bool get isEnabled => _speechEnabled;
  bool get isAvailable => _speechToText.isAvailable;

  /// Initialize the speech-to-text service
  Future<bool> init({required Function(String) onError}) async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (e) => onError(e.errorMsg),
      );
    } catch (e) {
      _speechEnabled = false;
      onError(e.toString());
    }
    return _speechEnabled;
  }

  /// Starts listening to the user's speech
  Future<void> startListening({
    required Function(String) onResult,
    required VoidCallback onListeningStateChanged,
    String localeId = "hu_HU",
  }) async {
    if (!_speechEnabled) {
      // Try to re-initialize if not enabled
      try {
        _speechEnabled = await _speechToText.initialize();
      } catch (e) {
        debugPrint("Re-init error: $e");
      }
    }

    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords);
        },
        onSoundLevelChange: (level) {
           // Optional: Handle sound level changes if needed for UI visualization
        },
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        pauseFor: const Duration(seconds: 3),
        localeId: localeId,
      );
      // Notify UI that listening started
      onListeningStateChanged();
    }
  }

  /// Manually stop listening
  Future<void> stopListening({required VoidCallback onListeningStateChanged}) async {
    await _speechToText.stop();
    onListeningStateChanged();
  }
}
