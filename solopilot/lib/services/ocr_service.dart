/// Reads text from a photograph using OCR (Optical Character Recognition).
/// Uses Google ML Kit for offline text recognition on the phone.
abstract class OcrService {
  /// Takes the file path of an image and returns the recognized text.
  /// Returns empty string if nothing could be read (never throws).
  Future<String> readTextFromImage(String imagePath);
}
