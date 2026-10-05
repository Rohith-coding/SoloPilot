import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
import 'smart_reply_service.dart';

/// B6 — Smart Reply using ML Kit.
///
/// Suggests 1–3 quick replies to a client message.
/// ML Kit Smart Reply often returns empty results (that's normal),
/// so we always fall back to canned replies.
class MlKitSmartReplyService implements SmartReplyService {
  @override
  Future<List<String>> suggest(String clientMessage) async {
    try {
      final smartReply = SmartReply();

      try {
        // Add the client's message as a "remote" (incoming) message
        smartReply.addMessageToConversationFromRemoteUser(
          clientMessage,
          DateTime.now().millisecondsSinceEpoch,
          'client', // remote user ID
        );

        // Ask ML Kit for reply suggestions
        final response = await smartReply.suggestReplies();

        if (response.status == SmartReplySuggestionResultStatus.success &&
            response.suggestions.isNotEmpty) {
          return response.suggestions.map((s) => s.text).toList();
        }
      } finally {
        // Always clean up
        await smartReply.close();
      }
    } catch (e) {
      print('Smart Reply error (using fallback): $e');
    }

    // Fallback: ML Kit returned nothing or failed → use canned replies
    return _cannedReplies();
  }

  @override
  Future<bool> ensureModelsReady() async {
    // Smart Reply model is usually bundled with ML Kit
    // but we test it to make sure
    try {
      final smartReply = SmartReply();
      smartReply.addMessageToConversationFromRemoteUser(
        'test message',
        DateTime.now().millisecondsSinceEpoch,
        'test_user',
      );
      await smartReply.suggestReplies();
      await smartReply.close();
      return true;
    } catch (e) {
      print('Smart Reply model check failed: $e');
      return false;
    }
  }

  /// Canned replies for when ML Kit returns nothing.
  List<String> _cannedReplies() {
    return [
      'Thanks for letting me know! I\'ll look into it.',
      'Got it, I\'ll send the updated details shortly.',
      'Sure, I\'ll follow up on this right away.',
    ];
  }
}
