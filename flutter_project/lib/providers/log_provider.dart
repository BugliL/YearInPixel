import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/log.dart';
import '../models/log_category.dart';
import '../models/day_entry.dart';

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
