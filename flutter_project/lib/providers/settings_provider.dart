import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = false;
  int _notificationHour = 20; // Default: 8 PM
  int _notificationMinute = 0; // Default: 0 minutes
  
  final NotificationService _notificationService = NotificationService();

  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationHour => _notificationHour;
  int get notificationMinute => _notificationMinute;

  SettingsProvider() {
    _loadSettings();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    _notificationsEnabled = await _notificationService.isNotificationEnabled();
    _notificationHour = await _notificationService.getNotificationTime();
    _notificationMinute = await _notificationService.getNotificationMinute();
    notifyListeners();
  }

  /// Enable or disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();

    if (enabled) {
      await _notificationService.scheduleDailyReminder(
        hour: _notificationHour,
        minute: _notificationMinute,
      );
    } else {
      await _notificationService.cancelDailyReminder();
    }
  }

  /// Set the notification time (hour and minute)
  Future<void> setNotificationTime(int hour, int minute) async {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return;
    
    _notificationHour = hour;
    _notificationMinute = minute;
    notifyListeners();

    // Reschedule if notifications are enabled
    if (_notificationsEnabled) {
      await _notificationService.scheduleDailyReminder(
        hour: hour,
        minute: minute,
      );
    }
  }

  /// Format the notification time for display (24-hour format)
  String get formattedNotificationTime {
    final hour = _notificationHour.toString().padLeft(2, '0');
    final minute = _notificationMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
