import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/extracted_fields.dart';
import '../models/invoice.dart';
import '../models/client.dart';
import '../services/app_services.dart';
import '../widgets/primary_action_button.dart';

/// 3. Review Screen.
/// Shows what the AI extracted as editable fields. The user confirms or
/// corrects them before creating an invoice. "You're always in control."
class ReviewScreen extends StatefulWidget {
  final ExtractedFields initialFields;

  const ReviewScreen({super.key, required this.initialFields});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late TextEditingController _clientController;
  late TextEditingController _amountController;
  late DateTime _issuedDate;
  late DateTime _dueDate;
  bool _isSaving = false;

  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _clientController =
        TextEditingController(text: widget.initialFields.clientName ?? '');
    _amountController = TextEditingController(
      text: widget.initialFields.amount?.toStringAsFixed(0) ?? '',
    );
    _issuedDate = DateTime.now();
    _dueDate = widget.initialFields.date ??
        _issuedDate.add(const Duration(days: 14));
  }

  Future<void> _createInvoice() async {
    final client = _clientController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    // Validate: need a client name and positive amount
    if (client.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please enter a valid client name and amount.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final services = Provider.of<AppServices>(context, listen: false);

    try {
      // Save the client for future reference
      await services.db.upsertClient(Client(name: client));

      // Create the invoice
      final inv = Invoice(
        clientName: client,
        amount: amount,
        issued: _issuedDate,
        due: _dueDate,
      );

      final id = await services.db.insertInvoice(inv);

      if (!mounted) return;

      // Go back to Home (which will refresh and show the new invoice)
      Navigator.popUntil(context, (route) => route.isFirst);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate({required bool isIssued}) async {
    final initial = isIssued ? _issuedDate : _dueDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        if (isIssued) {
          _issuedDate = date;
        } else {
          _dueDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Reassuring message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.edit, size: 18, color: Colors.indigo),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'re always in control. Edit any field below.',
                    style: TextStyle(color: Colors.indigo),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Client name
          TextField(
            controller: _clientController,
            decoration: const InputDecoration(
              labelText: 'Client Name',
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Amount
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (₹)',
              prefixIcon: Icon(Icons.currency_rupee),
            ),
          ),
          const SizedBox(height: 16),

          // Issued date
          ListTile(
            title: const Text('Issued Date'),
            subtitle: Text(_dateFormat.format(_issuedDate)),
            trailing: const Icon(Icons.calendar_today),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            onTap: () => _pickDate(isIssued: true),
          ),
          const SizedBox(height: 12),

          // Due date
          ListTile(
            title: const Text('Due Date'),
            subtitle: Text(_dateFormat.format(_dueDate)),
            trailing: const Icon(Icons.calendar_today),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            onTap: () => _pickDate(isIssued: false),
          ),
          const SizedBox(height: 24),

          // Raw text accordion
          if (widget.initialFields.rawText.isNotEmpty)
            ExpansionTile(
              title: const Text('View Raw Scanned Text',
                  style: TextStyle(fontSize: 14)),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: Text(
                    widget.initialFields.rawText,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 32),

          // Create invoice button
          PrimaryActionButton(
            label: 'Create Invoice',
            icon: Icons.check,
            onPressed: _createInvoice,
            isLoading: _isSaving,
          ),
        ],
      ),
    );
  }
}
