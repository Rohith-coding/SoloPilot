/// Seeds the database with demo data for the hackathon pitch.
/// This is the backup plan if the live camera demo fails.
abstract class SampleDataService {
  /// Insert sample clients, invoices, and drafts if the DB is empty.
  Future<void> seedIfEmpty();

  /// Wipe everything and re-seed with fresh demo data.
  Future<void> reset();
}
