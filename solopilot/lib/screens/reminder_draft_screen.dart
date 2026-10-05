import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../models/draft.dart';
import '../services/app_services.dart';
import '../widgets/primary_action_button.dart';

/// 6. Reminder Draft Screen. Displays generated text, allows edit, approve, and send.
class ReminderDraftScreen extends StatefulWidget {
  final Invoice invoice;

  const ReminderDraftScreen({super.key, required this.invoice});

  @override
  State<ReminderDraftScreen> createState() => _ReminderDraftScreenState();
}

class _ReminderDraftScreenState extends State<ReminderDraftScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  Draft? _draft;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final services = Provider.of<AppServices>(context, listen: false);
    
    // Check if we already have an approved/drafted reminder in DB
    var existing = await services.db.getDraftForInvoice(widget.invoice.id!, 'reminder');
    
    if (existing == null) {
      // Generate a new one
      final text = await services.draft.draftReminder(widget.invoice);
      existing = Draft(
        type: 'reminder',
        text: text,
        invoiceId: widget.invoice.id,
      );
      // We don't save to DB until approved.
    }

    if (mounted) {
      setState(() {
        _draft = existing;
        _textController.text = existing!.text;
        _isLoading = false;
      });
    }
  }

  Future<void> _approve() async {
    if (_draft == null) return;
    
    final services = Provider.of<AppServices>(context, listen: false);
    _draft!.text = _textController.text;
    _draft!.status = 'approved';
    
    if (_draft!.id == null) {
      await services.db.insertDraft(_draft!);
    } else {
      await services.db.updateDraft(_draft!);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft approved.')));
      setState(() {});
    }
  }

  Future<void> _send() async {
    if (_draft == null) return;

    final services = Provider.of<AppServices>(context, listen: false);
    _draft!.text = _textController.text;
    _draft!.status = 'sent';

    if (_draft!.id == null) {
      await services.db.insertDraft(_draft!);
    } else {
      await services.db.updateDraft(_draft!);
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Reminder Sent'),
          content: const Text('Reminder sent — simulated, nothing left your phone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminder Draft')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Generated Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: 'Reminder text here...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _draft?.status == 'approved'
                            ? PrimaryActionButton(
                                label: 'Send (Simulated)',
                                icon: Icons.send,
                                onPressed: _send,
                              )
                            : PrimaryActionButton(
                                label: 'Approve',
                                icon: Icons.thumb_up,
                                onPressed: _approve,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
