import 'package:intl/intl.dart';
import '../models/invoice.dart';
import 'draft_service.dart';

/// B3 — Payment reminder templates.
///
/// Three tones that escalate based on how overdue the invoice is:
///   ≤7 days  → Gentle (friendly nudge)
///   8–30 days → Firm (professional follow-up)
///   30+ days  → Final (last reminder, still polite)
///
/// All text is generated offline — no AI needed.
/// Amounts are formatted in Indian rupees (₹) with the `intl` package.
class TemplateDraftService implements DraftService {
  // Format amounts as ₹5,000 (Indian style, no decimals)
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  // Format dates as dd/MM/yyyy (Indian style)
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Future<String> draftReminder(Invoice i) async {
    final amount = _currencyFormat.format(i.amount);
    final dueDate = _dateFormat.format(i.due);
    final days = i.daysOverdue;

    // Pick the right tone based on how overdue
    if (days <= 7) {
      return _gentle(i.clientName, amount, dueDate, days);
    } else if (days <= 30) {
      return _firm(i.clientName, amount, dueDate, days);
    } else {
      return _final(i.clientName, amount, dueDate, days);
    }
  }

  /// Friendly nudge for recently overdue invoices (≤7 days).
  String _gentle(String client, String amount, String due, int days) {
    return 'Hi $client,\n\n'
        'Hope you\'re doing well! Just a quick reminder that the payment '
        'of $amount was due on $due ($days day${days == 1 ? '' : 's'} ago). '
        'I\'m sure it just slipped through — no worries at all!\n\n'
        'Could you let me know when I can expect the transfer?\n\n'
        'Thanks so much!\n'
        'Warm regards';
  }

  /// Professional but firm follow-up (8–30 days overdue).
  String _firm(String client, String amount, String due, int days) {
    return 'Dear $client,\n\n'
        'I\'m writing to follow up on the outstanding payment of $amount, '
        'which was due on $due — now $days days ago. I\'d appreciate it if '
        'you could process this at your earliest convenience.\n\n'
        'If the payment has already been sent, please disregard this message '
        'and accept my thanks.\n\n'
        'Looking forward to hearing from you.\n'
        'Best regards';
  }

  /// Final reminder for significantly overdue invoices (30+ days).
  String _final(String client, String amount, String due, int days) {
    return 'Dear $client,\n\n'
        'This is a final reminder regarding the overdue payment of $amount, '
        'originally due on $due ($days days ago). Despite previous reminders, '
        'I have not yet received this payment.\n\n'
        'I would truly appreciate your prompt attention to this matter. '
        'Please let me know if there are any issues I can help resolve.\n\n'
        'Thank you for your understanding.\n'
        'Regards';
  }
}
