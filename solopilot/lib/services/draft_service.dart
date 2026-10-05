import '../models/invoice.dart';

/// Generates polite payment reminder text for overdue invoices.
/// Uses templates (or Gemma AI when available) — works fully offline.
abstract class DraftService {
  /// Returns a human-friendly reminder message for the given invoice.
  /// The tone varies based on how overdue the invoice is.
  Future<String> draftReminder(Invoice i);
}
