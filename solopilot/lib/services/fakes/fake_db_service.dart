import '../../models/client.dart';
import '../../models/invoice.dart';
import '../../models/draft.dart';
import '../db_service.dart';

/// In-memory fake database for UI development and testing.
/// Data is lost when the app restarts — that's fine for development.
class FakeDbService implements DbService {
  final List<Invoice> _invoices = [];
  final List<Draft> _drafts = [];
  final List<Client> _clients = [];
  int _nextInvoiceId = 1;
  int _nextDraftId = 1;
  int _nextClientId = 1;

  @override
  Future<int> insertInvoice(Invoice i) async {
    i.id = _nextInvoiceId++;
    _invoices.add(i);
    return i.id!;
  }

  @override
  Future<List<Invoice>> getInvoices() async {
    // Return a copy sorted newest first by issued date
    final sorted = List<Invoice>.from(_invoices);
    sorted.sort((a, b) => b.issued.compareTo(a.issued));
    return sorted;
  }

  @override
  Future<Invoice?> getInvoice(int id) async {
    try {
      return _invoices.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> markPaid(int id) async {
    final invoice = await getInvoice(id);
    if (invoice != null) invoice.status = 'paid';
  }

  @override
  Future<List<Invoice>> getOverdue() async {
    return _invoices.where((i) => i.effectiveStatus == 'overdue').toList();
  }

  @override
  Future<int> insertDraft(Draft d) async {
    d.id = _nextDraftId++;
    _drafts.add(d);
    return d.id!;
  }

  @override
  Future<void> updateDraft(Draft d) async {
    final index = _drafts.indexWhere((x) => x.id == d.id);
    if (index != -1) _drafts[index] = d;
  }

  @override
  Future<List<Draft>> getDrafts({String? status}) async {
    if (status == null) return List.from(_drafts);
    return _drafts.where((d) => d.status == status).toList();
  }

  @override
  Future<Draft?> getDraftForInvoice(int invoiceId, String type) async {
    try {
      return _drafts.firstWhere(
        (d) => d.invoiceId == invoiceId && d.type == type,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertClient(Client c) async {
    final index = _clients.indexWhere((x) => x.name == c.name);
    if (index != -1) {
      _clients[index] = c;
    } else {
      c.id = _nextClientId++;
      _clients.add(c);
    }
  }

  @override
  Future<void> deleteAll() async {
    _invoices.clear();
    _drafts.clear();
    _clients.clear();
    _nextInvoiceId = 1;
    _nextDraftId = 1;
    _nextClientId = 1;
  }
}
