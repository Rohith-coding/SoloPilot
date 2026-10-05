/// Represents an invoice for work done.
///
/// Status is stored as 'pending' or 'paid' in the database.
/// The 'overdue' state is computed dynamically (not stored) — if an invoice
/// is 'pending' and the due date has passed, it's overdue.
class Invoice {
  int? id;
  String clientName;
  double amount;
  DateTime issued;
  DateTime due;
  String status; // stored in DB: 'pending' or 'paid'

  Invoice({
    this.id,
    required this.clientName,
    required this.amount,
    required this.issued,
    required this.due,
    this.status = 'pending',
  });

  /// Returns the real status including 'overdue'.
  /// - 'paid'    → the user marked it as paid
  /// - 'overdue' → still pending AND past the due date
  /// - 'pending' → still pending but not yet due
  String get effectiveStatus {
    if (status == 'paid') return 'paid';
    if (DateTime.now().isAfter(due)) return 'overdue';
    return 'pending';
  }

  /// How many days past the due date. Returns 0 if not overdue.
  int get daysOverdue {
    if (effectiveStatus != 'overdue') return 0;
    return DateTime.now().difference(due).inDays;
  }

  /// Create from a database row.
  /// Dates are stored as millisecondsSinceEpoch (integers) in SQLite.
  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] as int?,
      clientName: map['client_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      issued: DateTime.fromMillisecondsSinceEpoch(map['issued'] as int),
      due: DateTime.fromMillisecondsSinceEpoch(map['due'] as int),
      status: map['status'] as String,
    );
  }

  /// Convert to a Map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'client_name': clientName,
      'amount': amount,
      'issued': issued.millisecondsSinceEpoch,
      'due': due.millisecondsSinceEpoch,
      'status': status,
    };
  }

  @override
  String toString() =>
      'Invoice(id: $id, client: $clientName, ₹$amount, $effectiveStatus)';
}
