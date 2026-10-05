import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../services/app_services.dart';
import '../widgets/invoice_card.dart';
import '../widgets/empty_state.dart';
import 'invoice_screen.dart';

/// 5. Invoices List Screen. Filterable list of all invoices.
class InvoicesListScreen extends StatefulWidget {
  final String initialFilter;
  
  const InvoicesListScreen({super.key, this.initialFilter = 'All'});

  @override
  State<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends State<InvoicesListScreen> {
  late String _selectedFilter;
  List<Invoice> _allInvoices = [];
  bool _isLoading = true;

  final List<String> _filters = ['All', 'Pending', 'Overdue', 'Paid'];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _load();
  }

  Future<void> _load() async {
    final services = Provider.of<AppServices>(context, listen: false);
    final invoices = await services.db.getInvoices();
    if (mounted) {
      setState(() {
        _allInvoices = invoices;
        _isLoading = false;
      });
    }
  }

  List<Invoice> get _filtered {
    if (_selectedFilter == 'All') return _allInvoices;
    return _allInvoices.where((i) => i.effectiveStatus.toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoices')),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          
          // List
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _filtered.isEmpty
                        ? EmptyState(
                            message: 'No ${_selectedFilter.toLowerCase()} invoices found.',
                            icon: Icons.receipt_long_outlined,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final inv = _filtered[index];
                              return InvoiceCard(
                                invoice: inv,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => InvoiceScreen(invoiceId: inv.id!)),
                                  ).then((_) => _load());
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
