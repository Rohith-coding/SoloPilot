import '../models/invoice.dart';

/// Generates and shares a clean one-page PDF invoice.
/// Works completely offline using the pdf + printing packages.
abstract class PdfService {
  /// Builds a PDF for the invoice and opens the system share/print sheet.
  Future<void> shareInvoicePdf(Invoice i);
}
