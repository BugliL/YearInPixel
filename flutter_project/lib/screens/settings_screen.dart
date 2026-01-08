import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8D4E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              context,
              title: 'Notifications',
              children: [
                _buildNotificationToggle(context),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Data Management',
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.upload_file,
                  iconColor: const Color(0xFF98D8C8),
                  title: 'Backup Logs',
                  subtitle: 'Save all your logs to a file',
                  onTap: () => _handleExport(context),
                ),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  context,
                  icon: Icons.download,
                  iconColor: const Color(0xFFFFB6C1),
                  title: 'Import Logs',
                  subtitle: 'Load logs from a file',
                  onTap: () => _handleImport(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'About',
              children: [
                _buildInfoTile(
                  context,
                  title: 'Version',
                  value: '1.0.0',
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  context,
                  title: 'App Name',
                  value: 'Year in Pixels',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    final provider = Provider.of<LogProvider>(context, listen: false);
    
    if (provider.logs.isEmpty) {
      _showMessage(
        context,
        'No logs to export',
        'Add some logs first before exporting.',
        isError: true,
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF98D8C8)),
        ),
      ),
    );

    final success = await provider.exportAllLogs();
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
      
      if (success) {
        _showMessage(
          context,
          'Export Successful',
          'Your logs have been saved to the selected folder.',
        );
      } else {
        _showMessage(
          context,
          'Export Cancelled',
          'Export was cancelled or no location was selected.',
          isError: false,
        );
      }
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    final provider = Provider.of<LogProvider>(context, listen: false);

    // Show import options dialog
    final replaceExisting = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Import Logs'),
        content: const Text(
          'How should we handle existing logs with the same ID?\n\n'
          '• Merge: Update existing logs with imported data\n'
          '• Keep: Skip logs that already exist',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Existing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Merge'),
          ),
        ],
      ),
    );

    if (replaceExisting == null) return; // User cancelled

    // Show loading
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF98D8C8)),
          ),
        ),
      );
    }

    final result = await provider.importLogsFromFile(
      replaceExisting: replaceExisting,
    );

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog

      if (result.success) {
        _showMessage(
          context,
          'Import Successful',
          result.message,
        );
      } else {
        _showMessage(
          context,
          'Import Failed',
          result.message,
          isError: true,
        );
      }
    }
  }

  void _showMessage(
    BuildContext context,
    String title,
    String message, {
    bool isError = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.red : const Color(0xFF98D8C8),
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB6C1).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Color(0xFFFFB6C1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Reminder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Get notified for each log you haven\'t completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                value: settings.notificationsEnabled,
                activeColor: const Color(0xFF98D8C8),
                onChanged: (value) {
                  settings.setNotificationsEnabled(value);
                  
                  if (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✓ Daily reminder set for ${settings.formattedNotificationTime}',
                        ),
                        backgroundColor: const Color(0xFF98D8C8),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Daily reminder disabled'),
                        backgroundColor: Colors.black54,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              if (settings.notificationsEnabled) ...[
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF98D8C8).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Color(0xFF98D8C8),
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Reminder Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    settings.formattedNotificationTime,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black26,
                  ),
                  onTap: () => _showTimePicker(context, settings),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB6C1).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bug_report,
                      color: Color(0xFFFFB6C1),
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Test Notification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    'Send a test notification in 5 seconds',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  onTap: () => _testNotification(context),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _testNotification(BuildContext context) async {
    final notificationService = NotificationService();
    await notificationService.testNotificationNow();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Test notification scheduled in 5 seconds. Close the app to test!'),
          backgroundColor: Color(0xFF98D8C8),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showTimePicker(BuildContext context, SettingsProvider settings) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB388EB), // Purple
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              dialBackgroundColor: const Color(0xFFB388EB).withOpacity(0.15),
              hourMinuteTextColor: const Color(0xFFB388EB),
              dayPeriodTextColor: const Color(0xFFB388EB),
              dialHandColor: const Color(0xFFB388EB),
              hourMinuteColor: const Color(0xFFB388EB).withOpacity(0.1),
              dayPeriodBorderSide: const BorderSide(color: Color(0xFFB388EB)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && context.mounted) {
      await settings.setNotificationTime(pickedTime.hour, pickedTime.minute);
      
      final timeString = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Reminder time updated to $timeString'),
            backgroundColor: const Color(0xFF98D8C8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

