import '../../models/extracted_fields.dart';
import '../extract_service.dart';

/// Returns pre-filled extracted fields for UI development.
class FakeExtractService implements ExtractService {
  @override
  Future<ExtractedFields> extract(String text) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ExtractedFields(
      amount: 5000.0,
      date: DateTime(2026, 9, 30),
      clientName: 'Ravi Sharma',
      rawText: text,
    );
  }

  @override
  Future<bool> ensureModelsReady() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true; // always "ready" in fake mode
  }
}
