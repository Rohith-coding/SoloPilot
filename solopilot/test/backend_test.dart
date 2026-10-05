import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import 'package:solopilot/models/client.dart';
import 'package:solopilot/models/invoice.dart';
import 'package:solopilot/models/draft.dart';
import 'package:solopilot/services/sqlite_db_service.dart';
import 'package:solopilot/services/mlkit_extract_service.dart';
import 'package:solopilot/services/template_draft_service.dart';

void main() {
  // Initialize FFI for SQLite tests on desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Invoice Model', () {
    test('effectiveStatus and daysOverdue', () {
      final now = DateTime.now();
      
      // Paid invoice
      final paid = Invoice(
        clientName: 'A', amount: 100,
        issued: now, due: now, status: 'paid',
      );
      expect(paid.effectiveStatus, 'paid');
      expect(paid.daysOverdue, 0);

      // Pending but not due yet
      final pending = Invoice(
        clientName: 'B', amount: 100,
        issued: now, due: now.add(const Duration(days: 5)), status: 'pending',
      );
      expect(pending.effectiveStatus, 'pending');
      expect(pending.daysOverdue, 0);

      // Overdue
      final overdue = Invoice(
        clientName: 'C', amount: 100,
        issued: now.subtract(const Duration(days: 10)),
        due: now.subtract(const Duration(days: 5)),
        status: 'pending',
      );
      expect(overdue.effectiveStatus, 'overdue');
      expect(overdue.daysOverdue, 5);
    });
  });

  group('ExtractService (Regex Fallbacks)', () {
    final service = MlKitExtractService();

    test('Extracts Indian amounts', () async {
      final res1 = await service.extract('Total is ₹5,000 for work');
      expect(res1.amount, 5000);

      final res2 = await service.extract('Rs 2500.50 due');
      expect(res2.amount, 2500.50);
    });

    test('Extracts Indian dates', () async {
      final res1 = await service.extract('Due on 15/10/2026');
      expect(res1.date, DateTime(2026, 10, 15));

      final res2 = await service.extract('Pay by 12 Oct 2026');
      expect(res2.date, DateTime(2026, 10, 12));
    });
  });

  group('DraftService Templates', () {
    final service = TemplateDraftService();

    test('Gentle tone (<= 7 days)', () async {
      final i = Invoice(
        clientName: 'Test', amount: 1000,
        issued: DateTime.now(), due: DateTime.now().subtract(const Duration(days: 2)),
      );
      final text = await service.draftReminder(i);
      expect(text.contains('slipped through'), true);
    });

    test('Firm tone (8-30 days)', () async {
      final i = Invoice(
        clientName: 'Test', amount: 1000,
        issued: DateTime.now(), due: DateTime.now().subtract(const Duration(days: 15)),
      );
      final text = await service.draftReminder(i);
      expect(text.contains('earliest convenience'), true);
    });
  });

  group('SqliteDbService', () {
    late SqliteDbService db;

    setUp(() async {
      db = SqliteDbService();
      // Using in-memory DB for tests
      await databaseFactory.openDatabase(inMemoryDatabasePath);
      await db.open(); // Will create tables in the default path, 
      // Note: for real isolated tests you might inject the db path.
    });

    // Simple placeholder to show testing structure
    test('DB init check', () {
      expect(db, isNotNull);
    });
  });
}
