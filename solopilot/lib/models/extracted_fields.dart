/// Fields extracted from OCR text (receipt photo, pasted text, or voice input).
///
/// Any field can be null if extraction couldn't find it — the UI shows
/// editable fields so the user fills in whatever's missing.
class ExtractedFields {
  double? amount;
  DateTime? date;
  String? clientName;
  String rawText; // the original text that was processed

  ExtractedFields({
    this.amount,
    this.date,
    this.clientName,
    required this.rawText,
  });

  @override
  String toString() =>
      'ExtractedFields(amount: $amount, date: $date, client: $clientName)';
}
