import '../notification_service.dart';

/// Simulates notifications for UI development.
class FakeNotificationService implements NotificationService {
  @override
  Future<void> init(void Function() onTap) async {
    // Nothing to set up in fake mode
  }

  @override
  Future<void> showOverdueSummary(int count) async {
    print('FakeNotificationService: $count invoices overdue');
  }
}
