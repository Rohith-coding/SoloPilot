import '../../models/invoice.dart';
import '../pdf_service.dart';

/// Simulates PDF generation for UI development.
class FakePdfService implements PdfService {
  @override
  Future<void> shareInvoicePdf(Invoice i) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In fake mode, just pretend it worked
    print('FakePdfService: Would share PDF for invoice #${i.id}');
  }
}
