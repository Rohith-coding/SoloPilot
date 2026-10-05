import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../services/app_services.dart';
import '../widgets/status_chip.dart';
import 'reminder_draft_screen.dart';

/// 4. Invoice Screen. Details for a single created invoice.
class InvoiceScreen extends StatefulWidget {
  final int invoiceId;

  const InvoiceScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  Invoice? _invoice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final services = Provider.of<AppServices>(context, listen: false);
    final inv = await services.db.getInvoice(widget.invoiceId);
    if (mounted) {
      setState(() {
        _invoice = inv;
        _isLoading = false;
      });
    }
  }

  Future<void> _markPaid() async {
    final services = Provider.of<AppServices>(context, listen: false);
    await services.db.markPaid(widget.invoiceId);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_invoice == null) return const Scaffold(body: Center(child: Text('Invoice not found.')));

    final inv = _invoice!;
    final dateFormat = DateFormat('dd MMM yyyy');
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: Text('Invoice #${inv.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(inv.clientName, style: Theme.of(context).textTheme.headlineSmall),
                      StatusChip(status: inv.effectiveStatus),
                    ],
                  ),
                  const Divider(height: 32),
                  _DetailRow('Amount', currency.format(inv.amount), isAmount: true),
                  const SizedBox(height: 16),
                  _DetailRow('Issued', dateFormat.format(inv.issued)),
                  const SizedBox(height: 8),
                  _DetailRow('Due', dateFormat.format(inv.due), 
                             isDanger: inv.effectiveStatus == 'overdue'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (inv.effectiveStatus == 'overdue')
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReminderDraftScreen(invoice: inv)),
                ).then((_) => _load());
              },
              icon: const Icon(Icons.mark_email_unread),
              label: const Text('Draft Reminder'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red.shade700,
              ),
            ),
          
          const SizedBox(height: 12),
          
          if (inv.effectiveStatus != 'paid')
            OutlinedButton.icon(
              onPressed: _markPaid,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark as Paid'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            
          const SizedBox(height: 12),
          
          TextButton.icon(
            onPressed: () {
               final services = Provider.of<AppServices>(context, listen: false);
               services.pdf.shareInvoicePdf(inv);
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAmount;
  final bool isDanger;

  const _DetailRow(this.label, this.value, {this.isAmount = false, this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: isAmount ? 24 : 16,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
            color: isDanger ? Colors.red.shade700 : (isAmount ? Theme.of(context).colorScheme.primary : null),
          ),
        ),
      ],
    );
  }
}
