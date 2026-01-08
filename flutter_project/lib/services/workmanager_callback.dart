import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/log.dart';
import '../models/log_category.dart';
import '../models/day_entry.dart';

/// This function runs in a separate isolate and checks if user has logged today
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('Background task started: $task');
      
      // Initialize Hive for background task
      await Hive.initFlutter();
      
      // IMPORTANT: Register adapters in background isolate
      Hive.registerAdapter(LogCategoryAdapter());
      Hive.registerAdapter(DayEntryAdapter());
      Hive.registerAdapter(LogAdapter());
      
      // Open box if not already open
      Box<Log> logsBox;
      if (Hive.isBoxOpen('logs')) {
        logsBox = Hive.box<Log>('logs');
      } else {
        logsBox = await Hive.openBox<Log>('logs');
      }
      
      // Check each log and send notifications for incomplete ones
      await _checkAndNotifyForEachLog();
      
      // Reschedule for tomorrow at the same time
      await _rescheduleNextReminder();
      
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}

/// Check each log and send notification for logs without today's entry
Future<void> _checkAndNotifyForEachLog() async {
  try {
    final box = Hive.box('logs');
    final logs = box.values.toList();
    
    if (logs.isEmpty) {
      print('No logs found');
      return;
    }
    
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    int notificationId = 100; // Start from 100 to avoid conflicts
    
    // Check each log
    for (var log in logs) {
      if (log == null) continue;
      
      final logName = (log as dynamic).name as String;
      final logEmoji = (log as dynamic).emoji as String;
      final entries = (log as dynamic).entries as List;
      
      // Check if this log has an entry for today
      bool hasEntryToday = false;
      for (var entry in entries) {
        final entryDate = (entry as dynamic).date as DateTime;
        final normalizedDate = DateTime(
          entryDate.year,
          entryDate.month,
          entryDate.day,
        );
        
        if (normalizedDate.isAtSameMomentAs(todayDate)) {
          hasEntryToday = true;
          break;
        }
      }
      
      // If no entry for today, send notification for this log
      if (!hasEntryToday) {
        print('Log "$logName" not completed today, sending notification');
        await _showReminderNotification(
          notificationId: notificationId++,
          logName: logName,
          logEmoji: logEmoji,
        );
      } else {
        print('Log "$logName" already completed today');
      }
    }
  } catch (e) {
    print('Error checking logs: $e');
  }
}

/// Show a reminder notification for a specific log
Future<void> _showReminderNotification({
  required int notificationId,
  required String logName,
  required String logEmoji,
}) async {
  const channelId = 'daily_reminder';
  const channelName = 'Daily Reminders';
  const channelDescription = 'Notifications to remind you to log your day';

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications for background task
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(
    android: androidSettings,
  );
  await notifications.initialize(initializationSettings);

  // Create notification channel
  const androidChannel = AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.high,
    enableVibration: true,
  );

  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  // Show notification with log-specific message
  final androidDetails = AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  final notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await notifications.show(
    notificationId,
    '$logEmoji $logName',
    'Don\'t forget to track your $logName for today!',
    notificationDetails,
  );
}

/// Reschedule the next reminder for tomorrow at the same time
Future<void> _rescheduleNextReminder() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('notification_enabled') ?? false;
    
    if (!isEnabled) {
      print('Notifications disabled, not rescheduling');
      return;
    }
    
    final hour = prefs.getInt('notification_time_hour') ?? 20;
    final minute = prefs.getInt('notification_time_minute') ?? 0;
    
    print('Rescheduling next reminder for $hour:$minute tomorrow');
    
    // Calculate time until tomorrow at the same hour:minute
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, hour, minute);
    final delay = tomorrow.difference(now);
    
    // Register next day's task
    await Workmanager().registerOneOffTask(
      'dailyLogReminder',
      'dailyLogReminder',
      initialDelay: delay,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
    
    print('Next reminder scheduled successfully');
  } catch (e) {
    print('Error rescheduling reminder: $e');
  }
}
