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
  }

  Future<void> loadLogs() async {
    _logs = _logBox.values.toList();
    _logs.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    notifyListeners();
  }

  Future<void> addLog(Log log) async {
    log.sortOrder = _logs.length;
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

  Future<void> reorderLogs(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final log = _logs.removeAt(oldIndex);
    _logs.insert(newIndex, log);
    
    // Update sortOrder for all logs
    for (int i = 0; i < _logs.length; i++) {
      _logs[i].sortOrder = i;
      await _logBox.put(_logs[i].id, _logs[i]);
    }
    
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
}
