import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:solopilot/models/extracted_fields.dart';
import 'package:solopilot/models/invoice.dart';
import 'package:solopilot/screens/invoices_list_screen.dart';
import 'package:solopilot/screens/review_screen.dart';
import 'package:solopilot/services/app_services.dart';
import 'package:solopilot/widgets/status_chip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('StatusChip shows a green paid state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusChip(status: 'paid')),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(StatusChip),
        matching: find.byType(Container),
      ).first,
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.green.shade100);
    expect(find.text('PAID'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('ReviewScreen shows validation for empty client or amount', (tester) async {
    await tester.pumpWidget(
      Provider<AppServices>.value(
        value: AppServices(useFakes: true),
        child: MaterialApp(
          home: ReviewScreen(
            initialFields: ExtractedFields(rawText: 'Sample receipt text'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Create Invoice'));
    await tester.pump();

    expect(find.text('Please enter a valid client name and amount.'), findsOneWidget);
  });

  testWidgets('InvoicesListScreen applies the overdue filter', (tester) async {
    final services = AppServices(useFakes: true);
    await services.init();
    await services.db.insertInvoice(
      Invoice(
        clientName: 'Alpha Studio',
        amount: 3000,
        issued: DateTime.now().subtract(const Duration(days: 12)),
        due: DateTime.now().subtract(const Duration(days: 2)),
        status: 'pending',
      ),
    );
    await services.db.insertInvoice(
      Invoice(
        clientName: 'Beta Studio',
        amount: 1500,
        issued: DateTime.now().subtract(const Duration(days: 1)),
        due: DateTime.now().add(const Duration(days: 5)),
        status: 'pending',
      ),
    );

    await tester.pumpWidget(
      Provider<AppServices>.value(
        value: services,
        child: const MaterialApp(
          home: InvoicesListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Alpha Studio'), findsOneWidget);

    await tester.tap(find.text('Overdue'));
    await tester.pumpAndSettle();

    expect(find.text('Alpha Studio'), findsOneWidget);
    expect(find.text('Beta Studio'), findsNothing);
  });
}
