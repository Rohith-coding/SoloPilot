import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

/// B4 — Local push notifications for overdue invoices.
///
/// Uses a high-importance Android channel so notifications show as a banner.
/// Requests permission on Android 13+ (POST_NOTIFICATIONS).
/// Tapping the notification calls the [onTap] callback from init().
class LocalNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  void Function()? _onTap;

  @override
  Future<void> init(void Function() onTap) async {
    _onTap = onTap;

    try {
      // Android-specific initialization settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: androidSettings);

      await _plugin.initialize(
        settings,
        // This fires when the user taps the notification
        onDidReceiveNotificationResponse: (response) {
          _onTap?.call();
        },
      );

      // Create a high-importance notification channel (required on Android 8+)
      const channel = AndroidNotificationChannel(
        'overdue_invoices', // channel id
        'Overdue Invoices', // channel name
        description: 'Reminders about overdue invoices',
        importance: Importance.high,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Request notification permission (required on Android 13+)
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      // Notifications failing should never crash the app
      print('Notification init error: $e');
    }
  }

  @override
  Future<void> showOverdueSummary(int count) async {
    if (count <= 0) return; // nothing to notify

    try {
      const androidDetails = AndroidNotificationDetails(
        'overdue_invoices', // must match the channel ID above
        'Overdue Invoices',
        channelDescription: 'Reminders about overdue invoices',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);

      await _plugin.show(
        0, // notification id (0 = replaces the previous overdue notification)
        'Overdue Invoices',
        '$count invoice${count == 1 ? '' : 's'} overdue — tap to review',
        details,
      );
    } catch (e) {
      print('Notification show error: $e');
    }
  }
}
