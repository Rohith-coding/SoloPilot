import '../ocr_service.dart';

/// Returns realistic sample OCR text for UI development.
class FakeOcrService implements OcrService {
  @override
  Future<String> readTextFromImage(String imagePath) async {
    // Simulate a brief processing delay (feels real in the UI)
    await Future.delayed(const Duration(milliseconds: 800));

    // Return text that looks like a real Indian receipt/invoice
    return '''
Invoice #1042
To: Ravi Sharma
Date: 15/09/2026

Web Development Services
Total Amount: ₹5,000

Payment due by: 30/09/2026
UPI: ravi@upi
''';
  }
}
