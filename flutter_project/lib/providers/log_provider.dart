import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/log.dart';
import '../models/log_category.dart';
import '../models/day_entry.dart';
import '../models/import_result.dart';
import '../services/import_export_service.dart';

class LogProvider extends ChangeNotifier {
  late Box<Log> _logBox;
  List<Log> _logs = [];
  int _selectedYear = DateTime.now().year;

  LogProvider() {
    _init();
  }

  List<Log> get logs => _logs;
  int get selectedYear => _selectedYear;

  Future<void> _init() async {
    _logBox = Hive.box<Log>('logs');
    await loadLogs();
    
    // If no logs exist, create sample logs
    if (_logs.isEmpty) {
      await _createSampleLogs();
    }
  }

  Future<void> loadLogs() async {
    _logs = _logBox.values.toList();
    notifyListeners();
  }

  Future<void> addLog(Log log) async {
    await _logBox.put(log.id, log);
    await loadLogs();
  }

  Future<void> updateLog(Log log) async {
    await _logBox.put(log.id, log);
    await loadLogs();
  }

  Future<void> deleteLog(String logId) async {
    await _logBox.delete(logId);
    await loadLogs();
  }

  void setSelectedYear(int year) {
    _selectedYear = year;
    notifyListeners();
  }

  // Export all logs to a file
  Future<bool> exportAllLogs() async {
    try {
      return await ImportExportService.exportLogs(_logs);
    } catch (e) {
      print('Error in exportAllLogs: $e');
      return false;
    }
  }

  // Import logs from a file
  Future<ImportResult> importLogsFromFile({bool replaceExisting = false}) async {
    try {
      final importedLogs = await ImportExportService.importLogs();
      
      if (importedLogs == null) {
        return ImportResult(
          success: false,
          message: 'Import cancelled',
          logsImported: 0,
        );
      }

      if (importedLogs.isEmpty) {
        return ImportResult(
          success: false,
          message: 'No logs found in import file',
          logsImported: 0,
        );
      }

      int imported = 0;
      int skipped = 0;
      int updated = 0;

      for (final log in importedLogs) {
        // Check if log with same ID already exists
        final existingLog = _logBox.get(log.id);
        
        if (existingLog != null) {
          if (replaceExisting) {
            // Merge entries from imported log with existing log
            final mergedLog = _mergeLogEntries(existingLog, log);
            await _logBox.put(log.id, mergedLog);
            updated++;
          } else {
            skipped++;
          }
        } else {
          await _logBox.put(log.id, log);
          imported++;
        }
      }

      await loadLogs();

      final message = _buildImportMessage(imported, updated, skipped);
      
      return ImportResult(
        success: true,
        message: message,
        logsImported: imported + updated,
        logsSkipped: skipped,
      );
    } catch (e) {
      print('Error in importLogsFromFile: $e');
      return ImportResult(
        success: false,
        message: 'Error importing logs: ${e.toString()}',
        logsImported: 0,
      );
    }
  }

  // Merge entries from two logs
  Log _mergeLogEntries(Log existing, Log imported) {
    // Create a map of existing entries by date
    final existingEntriesMap = <String, DayEntry>{};
    for (final entry in existing.entries) {
      final key = _dateKey(entry.date);
      existingEntriesMap[key] = entry;
    }

    // Add/update with imported entries
    for (final entry in imported.entries) {
      final key = _dateKey(entry.date);
      existingEntriesMap[key] = entry;
    }

    // Update the existing log with merged entries
    existing.entries.clear();
    existing.entries.addAll(existingEntriesMap.values);

    // Update categories if different
    if (imported.categories.length != existing.categories.length ||
        !_categoriesMatch(existing.categories, imported.categories)) {
      existing.categories = imported.categories;
    }

    // Update name and emoji if they've changed
    existing.name = imported.name;
    existing.emoji = imported.emoji;

    return existing;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _categoriesMatch(List<LogCategory> cat1, List<LogCategory> cat2) {
    if (cat1.length != cat2.length) return false;
    for (int i = 0; i < cat1.length; i++) {
      if (cat1[i].label != cat2[i].label || cat1[i].color != cat2[i].color) {
        return false;
      }
    }
    return true;
  }

  String _buildImportMessage(int imported, int updated, int skipped) {
    final parts = <String>[];
    if (imported > 0) {
      parts.add('$imported new log${imported == 1 ? '' : 's'}');
    }
    if (updated > 0) {
      parts.add('$updated updated');
    }
    if (skipped > 0) {
      parts.add('$skipped skipped');
    }
    
    if (parts.isEmpty) {
      return 'No changes made';
    }
    
    return 'Imported: ${parts.join(', ')}';
  }

  Future<void> _createSampleLogs() async {
    // Rate my day log (5 stars)
    final rateDayLog = Log(
      id: 'rate_my_day',
      name: 'rate my day',
      emoji: '⭐',
      categories: [
        LogCategory(label: '5 stars', color: 0xFF4CAF50), // Green
        LogCategory(label: '4 stars', color: 0xFF8BC34A), // Light green
        LogCategory(label: '3 stars', color: 0xFFFFEB3B), // Yellow
        LogCategory(label: '2 stars', color: 0xFFFF9800), // Orange
        LogCategory(label: '1 star', color: 0xFFF44336), // Red
      ],
    );

    // Health log
    final healthLog = Log(
      id: 'health_log',
      name: 'health log',
      emoji: '🏥',
      categories: [
        LogCategory(label: 'well', color: 0xFF4CAF50), // Green
        LogCategory(label: 'cold', color: 0xFFFFB6C1), // Light pink
        LogCategory(label: 'fever', color: 0xFFDDA0DD), // Plum
        LogCategory(label: 'headache', color: 0xFFFFEB3B), // Yellow
        LogCategory(label: 'stomach pain', color: 0xFFFF9800), // Orange
        LogCategory(label: 'body pain', color: 0xFFFFB347), // Light orange
        LogCategory(label: 'hungover', color: 0xFFF06292), // Pink
      ],
    );

    // Anxiety log
    final anxietyLog = Log(
      id: 'anxiety_log',
      name: 'anxiety log',
      emoji: '😰',
      categories: [
        LogCategory(label: 'none', color: 0xFF4CAF50), // Green
        LogCategory(label: 'low', color: 0xFF81D4FA), // Light blue
        LogCategory(label: 'medium', color: 0xFFFFEB3B), // Yellow
        LogCategory(label: 'high', color: 0xFFFF9800), // Orange
        LogCategory(label: 'severe', color: 0xFFD32F2F), // Dark red
      ],
    );

    // Period tracker
    final periodLog = Log(
      id: 'period_tracker',
      name: 'period tracker',
      emoji: '🩸',
      categories: [
        LogCategory(label: 'period', color: 0xFFF48FB1), // Pink
      ],
    );

    // Training log
    final trainingLog = Log(
      id: 'training_log',
      name: 'training log',
      emoji: '💪',
      categories: [
        LogCategory(label: '10 km+', color: 0xFFF48FB1), // Hot pink
        LogCategory(label: '6-9 km', color: 0xFFE91E63), // Pink
        LogCategory(label: '3-5 km', color: 0xFF81C784), // Light green
        LogCategory(label: '1-2 km', color: 0xFF64B5F6), // Light blue
        LogCategory(label: 'intervals', color: 0xFFFFB74D), // Orange
        LogCategory(label: 'nothing', color: 0xFFB39DDB), // Light purple
      ],
    );

    // Reading log
    final readingLog = Log(
      id: 'reading_log',
      name: 'reading log',
      emoji: '📚',
      categories: [
        LogCategory(label: 'read today', color: 0xFFB39DDB), // Purple
        LogCategory(label: 'finished book', color: 0xFFF48FB1), // Pink
      ],
    );

    await addLog(rateDayLog);
    await addLog(healthLog);
    await addLog(anxietyLog);
    await addLog(periodLog);
    await addLog(trainingLog);
    await addLog(readingLog);
  }
}
