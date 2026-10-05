import '../models/client.dart';
import '../models/invoice.dart';
import '../models/draft.dart';

/// Local SQLite database for storing clients, invoices, and drafts.
/// All data stays on the device — no cloud sync, no accounts.
abstract class DbService {
  // ── Invoices ──

  /// Insert a new invoice. Returns the auto-generated ID.
  Future<int> insertInvoice(Invoice i);

  /// Get all invoices, newest first (by issued date).
  Future<List<Invoice>> getInvoices();

  /// Get a single invoice by ID, or null if not found.
  Future<Invoice?> getInvoice(int id);

  /// Mark an invoice as paid.
  Future<void> markPaid(int id);

  /// Get all overdue invoices (pending + past due date).
  Future<List<Invoice>> getOverdue();

  // ── Drafts ──

  /// Insert a new draft. Returns the auto-generated ID.
  Future<int> insertDraft(Draft d);

  /// Update an existing draft (e.g. change status from 'draft' to 'approved').
  Future<void> updateDraft(Draft d);

  /// Get drafts, optionally filtered by status (e.g. 'draft' for the Home count).
  Future<List<Draft>> getDrafts({String? status});

  /// Get the draft linked to a specific invoice and type (e.g. 'reminder').
  Future<Draft?> getDraftForInvoice(int invoiceId, String type);

  // ── Clients ──

  /// Insert or update a client (matched by name).
  Future<void> upsertClient(Client c);

  // ── Maintenance ──

  /// Wipe all data from all tables (used by SampleDataService.reset()).
  Future<void> deleteAll();
}
