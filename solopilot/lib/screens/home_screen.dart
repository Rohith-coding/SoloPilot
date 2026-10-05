import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../models/extracted_fields.dart';
import '../services/app_services.dart';
import '../widgets/summary_card.dart';
import '../widgets/invoice_card.dart';
import '../widgets/offline_badge.dart';
import '../widgets/empty_state.dart';
import 'scan_screen.dart';
import 'invoices_list_screen.dart';
import 'invoice_screen.dart';
import 'review_screen.dart';

/// 1. Home Screen ("Today").
/// Shows greeting, overdue banner, summaries, quick actions, and recent invoices.
/// Long-press the app title to reset sample data (for demo-proofing).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _drafts = [];
  List<Invoice> _overdue = [];
  List<Invoice> _allInvoices = [];
  bool _isLoading = true;
  bool _notificationFired = false; // only fire once per session

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final services = Provider.of<AppServices>(context, listen: false);
    final results = await Future.wait([
      services.db.getDrafts(status: 'draft'),
      services.db.getOverdue(),
      services.db.getInvoices(),
    ]);

    if (!mounted) return;

    setState(() {
      _drafts = results[0] as List;
      _overdue = results[1] as List<Invoice>;
      _allInvoices = results[2] as List<Invoice>;
      _isLoading = false;
    });

    // F4 — Fire overdue notification once per app session
    if (!_notificationFired && _overdue.isNotEmpty) {
      _notificationFired = true;
      services.notification.showOverdueSummary(_overdue.length);
    }
  }

  /// Navigate and refresh when returning
  Future<void> _navigateAndRefresh(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    _load();
  }

  /// F6 — Long-press the title to reset sample data (hidden demo trick)
  Future<void> _resetSampleData() async {
    final services = Provider.of<AppServices>(context, listen: false);
    await services.sampleData.reset();
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample data reset.')),
      );
    }
  }

  /// Contextual greeting based on time of day
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _resetSampleData,
          child: const Text(
            'SoloPilot',
            semanticsLabel: 'SoloPilot app title',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: OfflineBadge(),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Greeting
                  Text(
                    _greeting,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // F4 — In-app overdue banner
                  if (_overdue.isNotEmpty)
                    GestureDetector(
                      onTap: () => _navigateAndRefresh(
                        const InvoicesListScreen(initialFilter: 'Overdue'),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_overdue.length} invoice${_overdue.length == 1 ? '' : 's'} overdue — review',
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: Colors.red.shade400),
                          ],
                        ),
                      ),
                    ),

                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Drafts to approve',
                          value: _drafts.length.toString(),
                          icon: Icons.edit_document,
                          color: Colors.blue.shade700,
                          onTap: () => _navigateAndRefresh(
                            const InvoicesListScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: 'Invoices overdue',
                          value: _overdue.length.toString(),
                          icon: Icons.warning_amber_rounded,
                          color: Colors.red.shade700,
                          onTap: () => _navigateAndRefresh(
                            const InvoicesListScreen(
                                initialFilter: 'Overdue'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Big action buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () =>
                              _navigateAndRefresh(const ScanScreen()),
                          icon: const Icon(Icons.document_scanner),
                          label: const Text('Scan'),
                          style: FilledButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _navigateAndRefresh(
                            ReviewScreen(
                              initialFields:
                                  ExtractedFields(rawText: ''),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('New Invoice'),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Recent invoices
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Invoices',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => _navigateAndRefresh(
                          const InvoicesListScreen(),
                        ),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  if (_allInvoices.isEmpty)
                    const EmptyState(
                      message:
                          'No invoices yet.\nScan a receipt to start!',
                      icon: Icons.receipt_long,
                    )
                  else
                    ..._allInvoices.take(3).map(
                          (inv) => InvoiceCard(
                            invoice: inv,
                            onTap: () => _navigateAndRefresh(
                              InvoiceScreen(invoiceId: inv.id!),
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
