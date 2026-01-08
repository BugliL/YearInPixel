import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily Reminders';
  static const String _channelDescription =
      'Notifications to remind you to log your day';
  
  static const String taskName = 'dailyLogReminder';
  static const String prefKeyNotificationTime = 'notification_time_hour';
  static const String prefKeyNotificationMinute = 'notification_time_minute';
  static const String prefKeyNotificationEnabled = 'notification_enabled';

  /// Initialize the notification service
  Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - you can navigate to specific screen if needed
    print('Notification tapped: ${response.payload}');
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Schedule daily reminder using Workmanager
  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefKeyNotificationTime, hour);
    await prefs.setInt(prefKeyNotificationMinute, minute);
    await prefs.setBool(prefKeyNotificationEnabled, true);

    // Calculate the initial delay until the specified hour and minute
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If the time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final initialDelay = scheduledTime.difference(now);

    // Use one-off task instead of periodic (more reliable for daily reminders)
    // The task will reschedule itself after each run
    await Workmanager().registerOneOffTask(
      taskName,
      taskName,
      initialDelay: initialDelay,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Cancel the daily reminder
  Future<void> cancelDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKeyNotificationEnabled, false);
    await Workmanager().cancelByUniqueName(taskName);
  }

  /// Test notification immediately (for debugging)
  Future<void> testNotificationNow() async {
    await Workmanager().registerOneOffTask(
      'testNotification',
      taskName,
      initialDelay: const Duration(seconds: 5),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  /// Check if notifications are enabled
  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefKeyNotificationEnabled) ?? false;
  }

  /// Get the scheduled notification time (hour)
  Future<int> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(prefKeyNotificationTime) ?? 20; // Default: 8 PM
  }

  /// Get the scheduled notification time (minute)
  Future<int> getNotificationMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(prefKeyNotificationMinute) ?? 0; // Default: 0 minutes
  }
}
