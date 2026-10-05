/// Wraps speech-to-text for voice dictation.
/// The recognised text feeds into the same extract() pipeline,
/// so "Invoice Ravi five thousand rupees due Friday" gets parsed
/// into amount + client + date.
abstract class VoiceService {
  /// Initialize the speech recognizer. Returns true if available.
  Future<bool> init();

  /// Start listening. Calls [onText] with partial/final transcriptions.
  Future<void> start(void Function(String text) onText);

  /// Stop listening.
  Future<void> stop();
}
