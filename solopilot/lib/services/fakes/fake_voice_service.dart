import '../voice_service.dart';

/// Simulates voice input for UI development.
/// Delivers text in stages to mimic real speech recognition.
class FakeVoiceService implements VoiceService {
  @override
  Future<bool> init() async => true;

  @override
  Future<void> start(void Function(String text) onText) async {
    // Simulate voice recognition arriving in chunks
    await Future.delayed(const Duration(seconds: 1));
    onText('Invoice Ravi');
    await Future.delayed(const Duration(seconds: 1));
    onText('Invoice Ravi five thousand rupees');
    await Future.delayed(const Duration(seconds: 1));
    onText('Invoice Ravi five thousand rupees due Friday');
  }

  @override
  Future<void> stop() async {}
}
