import '../smart_reply_service.dart';

/// Returns sample quick replies for UI development.
class FakeSmartReplyService implements SmartReplyService {
  @override
  Future<List<String>> suggest(String clientMessage) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      'Thanks, I\'ll check on that.',
      'Sure, I\'ll send the updated invoice.',
      'Got it, will follow up soon.',
    ];
  }

  @override
  Future<bool> ensureModelsReady() async => true;
}
