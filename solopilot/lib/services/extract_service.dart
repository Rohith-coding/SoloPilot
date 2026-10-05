import '../models/extracted_fields.dart';

/// Extracts structured fields (amount, date, client name) from raw text.
/// Uses ML Kit Entity Extraction with regex fallback.
/// ML Kit doesn't find names — we use heuristics for that.
abstract class ExtractService {
  /// Parse raw text and pull out amount, date, and client name.
  /// Returns ExtractedFields with nulls for anything it can't find
  /// (the user fills in blanks in the review screen).
  Future<ExtractedFields> extract(String text);

  /// Downloads the ML Kit entity extraction model for offline use.
  /// Call once while online; offline extraction works after that.
  /// Returns true if the model is ready.
  Future<bool> ensureModelsReady();
}
