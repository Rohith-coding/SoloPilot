import '../../models/invoice.dart';
import '../draft_service.dart';

/// Returns a believable reminder template for UI development.
class FakeDraftService implements DraftService {
  @override
  Future<String> draftReminder(Invoice i) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return 'Hi ${i.clientName},\n\n'
        'Hope you\'re doing well! Just a friendly reminder that '
        'invoice #${i.id ?? 1} for ₹${i.amount.toStringAsFixed(0)} '
        'was due on ${i.due.day}/${i.due.month}/${i.due.year}. '
        'Would appreciate it if you could process the payment '
        'at your earliest convenience.\n\n'
        'Thanks!\nSoloPilot User';
  }
}
