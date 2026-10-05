import 'db_service.dart';
import 'ocr_service.dart';
import 'extract_service.dart';
import 'draft_service.dart';
import 'smart_reply_service.dart';
import 'voice_service.dart';
import 'pdf_service.dart';
import 'notification_service.dart';
import 'sample_data_service.dart';
// Fakes (for UI development before real services are built)
import 'fakes/fake_db_service.dart';
import 'fakes/fake_ocr_service.dart';
import 'fakes/fake_extract_service.dart';
import 'fakes/fake_draft_service.dart';
import 'fakes/fake_smart_reply_service.dart';
import 'fakes/fake_voice_service.dart';
import 'fakes/fake_pdf_service.dart';
import 'fakes/fake_notification_service.dart';
import 'fakes/fake_sample_data_service.dart';
// Real implementations
import 'sqlite_db_service.dart';
import 'mlkit_ocr_service.dart';
import 'mlkit_extract_service.dart';
import 'template_draft_service.dart';
import 'mlkit_smart_reply_service.dart';
import 'speech_voice_service.dart';
import 'pdf_print_service.dart';
import 'local_notification_service.dart';
import 'real_sample_data_service.dart';

/// Central service locator — every backend service in one place.
///
/// Set [useFakes] to true during UI development (fake data, no hardware).
/// Set it to false for the real app on a phone.
///
/// Usage in any widget:
///   final services = Provider.of<AppServices>(context, listen: false);
///   final invoices = await services.db.getInvoices();
class AppServices {
  static AppServices? _instance;

  /// Global singleton used by the app and screen code.
  static AppServices get instance => _instance ??= AppServices();

  /// Whether to use in-memory fake services (for UI development).
  bool useFakes;

  late final DbService db;
  late final OcrService ocr;
  late final ExtractService extract;
  late final DraftService draft;
  late final SmartReplyService smartReply;
  late final VoiceService voice;
  late final PdfService pdf;
  late final NotificationService notification;
  late final SampleDataService sampleData;

  AppServices({this.useFakes = false});

  /// Call this once at app startup before using any service.
  /// For fakes: wires up in-memory implementations instantly.
  /// For real: opens the database, initializes notification channels, etc.
  Future<void> init() async {
    if (useFakes) {
      _initFakes();
    } else {
      await _initReal();
    }
  }

  /// Wire up all in-memory fake services.
  void _initFakes() {
    final fakeDb = FakeDbService();
    db = fakeDb;
    ocr = FakeOcrService();
    extract = FakeExtractService();
    draft = FakeDraftService();
    smartReply = FakeSmartReplyService();
    voice = FakeVoiceService();
    pdf = FakePdfService();
    notification = FakeNotificationService();
    sampleData = FakeSampleDataService(fakeDb);
  }

  /// Wire up all real on-device services.
  Future<void> _initReal() async {
    // B1 — SQLite database (must be first, other services depend on it)
    final sqliteDb = SqliteDbService();
    await sqliteDb.open();
    db = sqliteDb;

    // B2 — OCR + extraction (the hero feature)
    ocr = MlKitOcrService();
    extract = MlKitExtractService();

    // B3 — Reminder templates
    draft = TemplateDraftService();

    // B4 — Local notifications
    notification = LocalNotificationService();

    // B5 — Sample data seeder
    sampleData = RealSampleDataService(db);

    // B6 — Smart reply suggestions
    smartReply = MlKitSmartReplyService();

    // B7 — Voice dictation
    voice = SpeechVoiceService();

    // B8 — PDF invoice export
    pdf = PdfPrintService();
  }
}
