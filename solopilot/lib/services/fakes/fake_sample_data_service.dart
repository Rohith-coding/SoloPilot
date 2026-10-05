import '../../models/client.dart';
import '../../models/invoice.dart';
import '../../models/draft.dart';
import '../db_service.dart';
import '../sample_data_service.dart';

/// Seeds the fake database with demo data for UI development.
class FakeSampleDataService implements SampleDataService {
  final DbService _db;

  FakeSampleDataService(this._db);

  @override
  Future<void> seedIfEmpty() async {
    final existing = await _db.getInvoices();
    if (existing.isNotEmpty) return; // already has data
    await _seed();
  }

  @override
  Future<void> reset() async {
    await _db.deleteAll();
    await _seed();
  }

  /// Create 2 clients, 4 invoices, and 1 reminder draft.
  Future<void> _seed() async {
    final now = DateTime.now();

    // ── 2 clients ──
    await _db.upsertClient(
        Client(name: 'Ravi Sharma', contact: 'ravi@email.com'));
    await _db.upsertClient(
        Client(name: 'Priya Patel', contact: 'priya@email.com'));

    // ── 4 invoices ──

    // Invoice 1: ~12 days overdue, ₹5,000 (the star of the demo)
    final overdueId = await _db.insertInvoice(Invoice(
      clientName: 'Ravi Sharma',
      amount: 5000,
      issued: now.subtract(const Duration(days: 20)),
      due: now.subtract(const Duration(days: 12)),
      status: 'pending',
    ));

    // Invoice 2: Pending, due in 10 days
    await _db.insertInvoice(Invoice(
      clientName: 'Priya Patel',
      amount: 12000,
      issued: now.subtract(const Duration(days: 5)),
      due: now.add(const Duration(days: 10)),
      status: 'pending',
    ));

    // Invoice 3: Due very soon (2 days)
    await _db.insertInvoice(Invoice(
      clientName: 'Ravi Sharma',
      amount: 3500,
      issued: now.subtract(const Duration(days: 3)),
      due: now.add(const Duration(days: 2)),
      status: 'pending',
    ));

    // Invoice 4: Already paid
    await _db.insertInvoice(Invoice(
      clientName: 'Priya Patel',
      amount: 8000,
      issued: now.subtract(const Duration(days: 30)),
      due: now.subtract(const Duration(days: 15)),
      status: 'paid',
    ));

    // ── 1 reminder draft for the overdue invoice ──
    await _db.insertDraft(Draft(
      type: 'reminder',
      text: 'Hi Ravi Sharma,\n\n'
          'Hope you\'re doing well! Just a quick reminder that the payment '
          'of ₹5,000 was due 12 days ago. I\'m sure it just slipped '
          'through — no worries at all!\n\n'
          'Could you let me know when I can expect the transfer?\n\n'
          'Thanks so much!\nWarm regards',
      status: 'draft',
      invoiceId: overdueId,
    ));
  }
}
