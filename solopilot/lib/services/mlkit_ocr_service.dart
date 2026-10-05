import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ocr_service.dart';

/// B2a — Reads text from photos using Google ML Kit.
///
/// Runs completely offline on-device. Uses the Latin script recognizer
/// which works well for English text and Indian receipts.
class MlKitOcrService implements OcrService {
  @override
  Future<String> readTextFromImage(String imagePath) async {
    try {
      // Load the image from the file path
      final inputImage = InputImage.fromFilePath(imagePath);

      // Create a text recognizer for Latin script (English, etc.)
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

      try {
        // Run OCR — this happens entirely on the phone, no internet needed
        final result = await recognizer.processImage(inputImage);
        return result.text;
      } finally {
        // Always close the recognizer to free memory
        await recognizer.close();
      }
    } catch (e) {
      // Never crash the app — return empty string so the user can type manually
      print('OCR error: $e');
      return '';
    }
  }
}
