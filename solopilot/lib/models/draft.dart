/// A drafted message (reminder or reply) that the user reviews before "sending".
///
/// Lifecycle: 'draft' → user reviews → 'approved' → simulated send → 'sent'.
/// Sending is simulated (just flips status) — no real email/SMS goes out.
class Draft {
  int? id;
  String type;   // 'reminder' or 'reply'
  String text;
  String status; // 'draft', 'approved', or 'sent'
  int? invoiceId; // linked invoice (for reminders)

  Draft({
    this.id,
    required this.type,
    required this.text,
    this.status = 'draft',
    this.invoiceId,
  });

  /// Create from a database row.
  factory Draft.fromMap(Map<String, dynamic> map) {
    return Draft(
      id: map['id'] as int?,
      type: map['type'] as String,
      text: map['text'] as String,
      status: map['status'] as String,
      invoiceId: map['invoice_id'] as int?,
    );
  }

  /// Convert to a Map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'text': text,
      'status': status,
      'invoice_id': invoiceId,
    };
  }

  @override
  String toString() => 'Draft(id: $id, type: $type, status: $status)';
}
