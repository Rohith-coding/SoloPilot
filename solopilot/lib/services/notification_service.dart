/// Local push notifications for overdue invoice reminders.
/// No internet needed — all notifications are scheduled on-device.
abstract class NotificationService {
  /// Set up the notification channel and request permissions.
  /// [onTap] is called when the user taps a notification.
  Future<void> init(void Function() onTap);

  /// Show a notification like "2 invoices overdue — tap to review".
  Future<void> showOverdueSummary(int count);
}
