import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import 'pdf_service.dart';

/// B8 — Generates a clean one-page PDF invoice and opens the share/print sheet.
///
/// Layout: Header → Client info → Dates → Amount box → Footer.
/// Works completely offline — no internet needed.
class PdfPrintService implements PdfService {
  // Format amounts as ₹5,000 (Indian style)
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  // Format dates as dd/MM/yyyy (Indian style)
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Future<void> shareInvoicePdf(Invoice i) async {
    try {
      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header ──
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1565C0'),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Invoice #${i.id ?? '-'}',
                style: const pw.TextStyle(
                    fontSize: 12, color: PdfColors.grey700),
              ),
              pw.Divider(
                  thickness: 2, color: PdfColor.fromHex('#1565C0')),
              pw.SizedBox(height: 20),

              // ── Client info ──
              _labelValue('Bill To', i.clientName),
              pw.SizedBox(height: 16),

              // ── Dates row ──
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _labelValue('Issued', _dateFormat.format(i.issued)),
                  _labelValue('Due', _dateFormat.format(i.due)),
                  _labelValue(
                      'Status', i.effectiveStatus.toUpperCase()),
                ],
              ),
              pw.SizedBox(height: 30),

              // ── Amount box ──
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#E3F2FD'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Total Amount',
                      style: const pw.TextStyle(
                          fontSize: 14, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      _currencyFormat.format(i.amount),
                      style: pw.TextStyle(
                        fontSize: 36,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1565C0'),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Spacer pushes footer to bottom ──
              pw.Spacer(),

              // ── Footer ──
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              pw.Text(
                'Generated on-device by SoloPilot',
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey500),
              ),
              pw.Text(
                'Generated on ${_dateFormat.format(DateTime.now())}',
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey500),
              ),
            ],
          ),
        ),
      );

      // Open the system share/print sheet
      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'invoice_${i.id ?? 'new'}.pdf',
      );
    } catch (e) {
      // Don't crash the app — the UI should show an error message instead
      print('PDF generation error: $e');
    }
  }

  /// Helper: creates a label + value pair for the PDF layout.
  pw.Widget _labelValue(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(
                fontSize: 10, color: PdfColors.grey600)),
        pw.SizedBox(height: 2),
        pw.Text(value,
            style:
                pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }
}
