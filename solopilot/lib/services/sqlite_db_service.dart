import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/client.dart';
import '../models/invoice.dart';
import '../models/draft.dart';
import 'db_service.dart';

/// B1 — SQLite database service.
///
/// All data stays on the phone in a single file (solopilot.db).
/// Three tables: clients, invoices, drafts.
/// The database survives app restarts — your data is safe.
class SqliteDbService implements DbService {
  Database? _db;

  /// Opens (or creates) the database. Call once at app startup.
  Future<void> open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'solopilot.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create all three tables when the database is first created
        await db.execute('''
          CREATE TABLE clients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            contact TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE invoices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_name TEXT NOT NULL,
            amount REAL NOT NULL,
            issued INTEGER NOT NULL,
            due INTEGER NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending'
          )
        ''');
        await db.execute('''
          CREATE TABLE drafts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            text TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'draft',
            invoice_id INTEGER
          )
        ''');
      },
    );
  }

  /// Shortcut to get the database (throws if not opened yet).
  Database get _database {
    if (_db == null) {
      throw StateError('Database not opened. Call open() first.');
    }
    return _db!;
  }

  // ── Invoices ──

  @override
  Future<int> insertInvoice(Invoice i) async {
    return await _database.insert('invoices', i.toMap());
  }

  @override
  Future<List<Invoice>> getInvoices() async {
    // Newest first by issued date
    final rows = await _database.query('invoices', orderBy: 'issued DESC');
    return rows.map((r) => Invoice.fromMap(r)).toList();
  }

  @override
  Future<Invoice?> getInvoice(int id) async {
    final rows = await _database.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Invoice.fromMap(rows.first);
  }

  @override
  Future<void> markPaid(int id) async {
    await _database.update(
      'invoices',
      {'status': 'paid'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Invoice>> getOverdue() async {
    // Fetch all pending invoices, then filter for overdue in Dart
    // (because 'overdue' is a computed state, not stored in the DB)
    final rows = await _database.query(
      'invoices',
      where: 'status = ?',
      whereArgs: ['pending'],
    );
    return rows
        .map((r) => Invoice.fromMap(r))
        .where((i) => i.effectiveStatus == 'overdue')
        .toList();
  }

  // ── Drafts ──

  @override
  Future<int> insertDraft(Draft d) async {
    return await _database.insert('drafts', d.toMap());
  }

  @override
  Future<void> updateDraft(Draft d) async {
    await _database.update(
      'drafts',
      d.toMap(),
      where: 'id = ?',
      whereArgs: [d.id],
    );
  }

  @override
  Future<List<Draft>> getDrafts({String? status}) async {
    if (status != null) {
      final rows = await _database.query(
        'drafts',
        where: 'status = ?',
        whereArgs: [status],
      );
      return rows.map((r) => Draft.fromMap(r)).toList();
    }
    final rows = await _database.query('drafts');
    return rows.map((r) => Draft.fromMap(r)).toList();
  }

  @override
  Future<Draft?> getDraftForInvoice(int invoiceId, String type) async {
    final rows = await _database.query(
      'drafts',
      where: 'invoice_id = ? AND type = ?',
      whereArgs: [invoiceId, type],
    );
    if (rows.isEmpty) return null;
    return Draft.fromMap(rows.first);
  }

  // ── Clients ──

  @override
  Future<void> upsertClient(Client c) async {
    // Check if a client with the same name already exists
    final existing = await _database.query(
      'clients',
      where: 'name = ?',
      whereArgs: [c.name],
    );
    if (existing.isNotEmpty) {
      // Update existing client
      await _database.update(
        'clients',
        c.toMap(),
        where: 'name = ?',
        whereArgs: [c.name],
      );
    } else {
      // Insert new client
      await _database.insert('clients', c.toMap());
    }
  }

  // ── Maintenance ──

  @override
  Future<void> deleteAll() async {
    await _database.delete('drafts');
    await _database.delete('invoices');
    await _database.delete('clients');
  }

  /// Close the database (call when the app is disposed).
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
