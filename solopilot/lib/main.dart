import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_services.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/invoices_list_screen.dart';

/// Global navigator key so we can navigate from notification callbacks
/// (which don't have a BuildContext).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ┌─────────────────────────────────────────────────────────┐
  // │  Set useFakes: true  → develop UI without real services │
  // │  Set useFakes: false → run on a real Android phone      │
  // └─────────────────────────────────────────────────────────┘
  final services = AppServices.instance;
  services.useFakes = true;
  await services.init();

  // F4 — Notification tap: open the overdue invoices list
  await services.notification.init(() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const InvoicesListScreen(initialFilter: 'Overdue'),
      ),
    );
  });

  // Seed demo data so there's something to show in the hackathon pitch
  await services.sampleData.seedIfEmpty();

  runApp(
    Provider<AppServices>.value(
      value: services,
      child: const SoloPilotApp(),
    ),
  );
}

/// Root widget.
class SoloPilotApp extends StatelessWidget {
  const SoloPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoloPilot',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // needed for notification navigation
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
