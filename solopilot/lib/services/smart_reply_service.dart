/// Suggests 1–3 quick replies to a client message.
/// Uses ML Kit Smart Reply with canned fallbacks when ML Kit returns nothing.
abstract class SmartReplyService {
  /// Returns 1–3 suggested reply strings for the given client message.
  Future<List<String>> suggest(String clientMessage);

  /// Checks / downloads the ML Kit smart reply model.
  /// Returns true if the model is ready for offline use.
  Future<bool> ensureModelsReady();
}
