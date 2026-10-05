import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import '../models/extracted_fields.dart';
import 'extract_service.dart';

/// B2b — Extracts amount, date, and client name from text.
///
/// Strategy:
///   1. Try ML Kit Entity Extraction for money + dateTime entities
///   2. Regex fallback for ₹/Rs./INR amounts and dd/MM/yyyy dates
///   3. Heuristics for client name (ML Kit can't find names)
///
/// Never throws — returns ExtractedFields with nulls for missing data.
class MlKitExtractService implements ExtractService {
  EntityExtractor? _extractor;

  @override
  Future<bool> ensureModelsReady() async {
    try {
      _extractor = EntityExtractor(
        options: EntityExtractorOptions(EntityExtractorLanguage.english),
      );
      // This triggers the model download if not already on the device
      await _extractor!.extractEntities('test ₹100 01/01/2026');
      return true;
    } catch (e) {
      print('Entity extraction model download failed: $e');
      return false;
    }
  }

  @override
  Future<ExtractedFields> extract(String text) async {
    double? amount;
    DateTime? date;
    String? clientName;

    // ── Step 1: Try ML Kit Entity Extraction ──
    try {
      _extractor ??= EntityExtractor(
        options: EntityExtractorOptions(EntityExtractorLanguage.english),
      );
      final annotations = await _extractor!.extractEntities(text);

      for (final annotation in annotations) {
        for (final entity in annotation.entities) {
          // Take the first money entity as the amount
          if (amount == null && entity.type == EntityType.money) {
            final raw = annotation.text.replaceAll(RegExp(r'[^\d.]'), '');
            amount = double.tryParse(raw);
          }
          // Take the first dateTime entity as the date
          if (date == null && entity.type == EntityType.dateTime) {
            final dt = entity.rawValue;
            if (dt is DateTimeEntity) {
              date = DateTime.fromMillisecondsSinceEpoch(dt.timestamp);
            }
          }
        }
      }
    } catch (e) {
      print('ML Kit extraction error (will try regex fallback): $e');
    }

    // ── Step 2: Regex fallback for anything ML Kit missed ──
    amount ??= _extractAmountRegex(text);
    date ??= _extractDateRegex(text);

    // ── Step 3: Client name heuristics ──
    clientName = _extractClientName(text);

    return ExtractedFields(
      amount: amount,
      date: date,
      clientName: clientName,
      rawText: text,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // REGEX FALLBACK: Amount
  // Matches: ₹5,000  Rs 5000.50  INR 12,500  Rs. 3,500.00
  // Prefers amounts near keywords like "total", "due", "amount"
  // ─────────────────────────────────────────────────────────────
  double? _extractAmountRegex(String text) {
    final pattern = RegExp(
      r'(?:₹|Rs\.?|INR)\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );

    final matches = pattern.allMatches(text);
    if (matches.isEmpty) return null;

    double? bestAmount;
    bool bestNearKeyword = false;

    for (final match in matches) {
      final raw = match.group(1)!.replaceAll(',', '');
      final value = double.tryParse(raw);
      if (value == null) continue;

      // Check if this amount is near a keyword like "total" or "due"
      final start = (match.start - 30).clamp(0, text.length);
      final end = (match.end + 30).clamp(0, text.length);
      final context = text.substring(start, end).toLowerCase();
      final nearKeyword = context.contains('total') ||
          context.contains('amount') ||
          context.contains('due') ||
          context.contains('grand') ||
          context.contains('payable');

      // Prefer amount near keyword; otherwise pick the largest
      if (bestAmount == null ||
          (nearKeyword && !bestNearKeyword) ||
          (nearKeyword == bestNearKeyword && value > bestAmount)) {
        bestAmount = value;
        bestNearKeyword = nearKeyword;
      }
    }

    return bestAmount;
  }

  // ─────────────────────────────────────────────────────────────
  // REGEX FALLBACK: Date
  // Matches: dd/MM/yyyy, dd-MM-yyyy, "12 Oct 2026"
  // Indian style: day first, then month
  // ─────────────────────────────────────────────────────────────
  DateTime? _extractDateRegex(String text) {
    // Pattern 1: dd/MM/yyyy or dd-MM-yyyy
    final slashPattern = RegExp(r'(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})');
    final slashMatch = slashPattern.firstMatch(text);
    if (slashMatch != null) {
      final day = int.tryParse(slashMatch.group(1)!);
      final month = int.tryParse(slashMatch.group(2)!);
      final year = int.tryParse(slashMatch.group(3)!);
      if (day != null &&
          month != null &&
          year != null &&
          day >= 1 &&
          day <= 31 &&
          month >= 1 &&
          month <= 12) {
        return DateTime(year, month, day);
      }
    }

    // Pattern 2: "12 Oct 2026" or "12 October 2026"
    final months = {
      'jan': 1, 'january': 1, 'feb': 2, 'february': 2,
      'mar': 3, 'march': 3, 'apr': 4, 'april': 4,
      'may': 5, 'jun': 6, 'june': 6,
      'jul': 7, 'july': 7, 'aug': 8, 'august': 8,
      'sep': 9, 'september': 9, 'oct': 10, 'october': 10,
      'nov': 11, 'november': 11, 'dec': 12, 'december': 12,
    };
    final namedPattern = RegExp(
      r'(\d{1,2})\s+(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+(\d{4})',
      caseSensitive: false,
    );
    final namedMatch = namedPattern.firstMatch(text);
    if (namedMatch != null) {
      final day = int.tryParse(namedMatch.group(1)!);
      final monthStr = namedMatch.group(2)!.toLowerCase();
      final year = int.tryParse(namedMatch.group(3)!);
      final month = months[monthStr];
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // CLIENT NAME HEURISTICS
  // ML Kit can't find names, so we look for patterns like:
  //   "To: Ravi Sharma", "Bill to: Name", "Dear Name",
  //   "Invoice Ravi…", or just the first capitalised line
  // ─────────────────────────────────────────────────────────────
  String? _extractClientName(String text) {
    final lines =
        text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);

    // Pattern: "To: Ravi Sharma" or "Bill to: Priya Patel" etc.
    final toPattern = RegExp(
      r'(?:to|bill\s*to|dear|attn|attention|client|customer)\s*[:\-]?\s*([A-Z][a-zA-Z]+(?:\s+[A-Z][a-zA-Z]+)+)',
      caseSensitive: false,
    );
    final toMatch = toPattern.firstMatch(text);
    if (toMatch != null) return toMatch.group(1)!.trim();

    // Pattern: "Invoice Ravi Sharma" at the start of a line
    final invoicePattern = RegExp(
      r'^Invoice\s+([A-Z][a-zA-Z]+(?:\s+[A-Z][a-zA-Z]+)+)',
      caseSensitive: false,
      multiLine: true,
    );
    final invoiceMatch = invoicePattern.firstMatch(text);
    if (invoiceMatch != null) return invoiceMatch.group(1)!.trim();

    // Fallback: first line that looks like a name
    // (2+ capitalised words, no numbers, not too long)
    for (final line in lines) {
      if (line.length > 40) continue; // too long to be a name
      if (RegExp(r'\d').hasMatch(line)) continue; // has numbers
      if (RegExp(r'^[A-Z][a-z]+(\s+[A-Z][a-z]+)+$').hasMatch(line)) {
        return line;
      }
    }

    return null; // couldn't find a name — user types it in the review screen
  }

  /// Clean up the extractor when done.
  Future<void> dispose() async {
    await _extractor?.close();
    _extractor = null;
  }
}
