import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log.dart';
import '../models/day_entry.dart';
import '../providers/log_provider.dart';
import '../widgets/day_entry_dialog.dart';

enum ZoomLevel { month, year }

class AllLogsGridScreen extends StatefulWidget {
  const AllLogsGridScreen({super.key});

  @override
  State<AllLogsGridScreen> createState() => _AllLogsGridScreenState();
}

class _AllLogsGridScreenState extends State<AllLogsGridScreen> {
  ZoomLevel _zoomLevel = ZoomLevel.month;
  int _selectedMonth = DateTime.now().month;
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    // Initialize page controller to current month (0-11 index)
    _pageController = PageController(initialPage: _selectedMonth - 1);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logProvider = context.watch<LogProvider>();
    final logs = logProvider.logs;
    final year = logProvider.selectedYear;

    if (logs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('All Logs Grid'),
        ),
        body: const Center(
          child: Text('No logs available'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(_zoomLevel == ZoomLevel.month ? '${_getMonthName(_selectedMonth)} $year' : '$year'),
        actions: [
          // Zoom toggle button
          IconButton(
            icon: Icon(_zoomLevel == ZoomLevel.year ? Icons.zoom_in : Icons.zoom_out),
            tooltip: _zoomLevel == ZoomLevel.year ? 'View Month' : 'View Year',
            onPressed: () {
              setState(() {
                _zoomLevel = _zoomLevel == ZoomLevel.year ? ZoomLevel.month : ZoomLevel.year;
                if (_zoomLevel == ZoomLevel.month) {
                  // Recreate page controller for month view
                  _pageController.dispose();
                  _pageController = PageController(initialPage: _selectedMonth - 1);
                } else {
                  // Recreate page controller for year view  
                  _pageController.dispose();
                  _pageController = PageController(initialPage: 0);
                }
              });
            },
          ),
        ],
      ),
      body: _buildGrid(logs, year),
    );
  }

  Widget _buildGrid(List<Log> logs, int year) {
    if (_zoomLevel == ZoomLevel.month) {
      // Month view with swipeable pages using vertical PageView
      return Column(
        children: [
          // Month navigation indicator
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _selectedMonth > 1
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
                Text(
                  _getMonthName(_selectedMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _selectedMonth < 12
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
          // Grid content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedMonth = index + 1;
                });
              },
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                return _buildMonthGrid(logs, year, month);
              },
            ),
          ),
        ],
      );
    } else {
      // Year view - single page
      return _buildYearGrid(logs, year);
    }
  }
  
  Widget _buildYearGrid(List<Log> logs, int year) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with log emojis
              _buildHeaderRow(logs),
              const SizedBox(height: 8),
              // Day rows for entire year
              ..._buildYearDayRows(logs, year),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMonthGrid(List<Log> logs, int year, int month) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with log emojis
              _buildHeaderRow(logs),
              const SizedBox(height: 8),
              // Day rows for selected month
              ..._buildMonthDayRows(logs, year, month),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(List<Log> logs) {
    return Row(
      children: [
        // Day column header
        Container(
          width: 40,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Day',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
        const SizedBox(width: 2),
        // Log emoji headers
        ...logs.map((log) {
          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Container(
              width: 24,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                log.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        }),
      ],
    );
  }

  List<Widget> _buildYearDayRows(List<Log> logs, int year) {
    final rows = <Widget>[];
    final daysInYear = _isLeapYear(year) ? 366 : 365;
    
    for (int dayOfYear = 1; dayOfYear <= daysInYear; dayOfYear++) {
      final date = _getDateFromDayOfYear(year, dayOfYear);
      rows.add(_buildDayRow(date, logs, true));
    }
    
    return rows;
  }
  
  List<Widget> _buildMonthDayRows(List<Log> logs, int year, int month) {
    final rows = <Widget>[];
    final daysInMonth = _getDaysInMonth(year, month);
    
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      rows.add(_buildDayRow(date, logs, false));
    }
    
    return rows;
  }

  Widget _buildDayRow(DateTime date, List<Log> logs, bool showMonthInLabel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          // Day label
          Container(
            width: 40,
            height: 18,
            alignment: Alignment.center,
            child: Text(
              showMonthInLabel
                  ? '${date.day}/${date.month}'
                  : '${date.day}',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 2),
          // Log entries for this day
          ...logs.map((log) {
            final entry = log.getEntryForDate(date);
            final color = entry != null && entry.categoryIndex < log.categories.length
                ? Color(log.categories[entry.categoryIndex].color)
                : Colors.grey.shade300;
            
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: GestureDetector(
                onTap: () => _showDayDetails(date, log, entry),
                child: Container(
                  width: 24,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showDayDetails(DateTime date, Log log, dynamic entry) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DayEntryDialog(
        date: date,
        log: log,
        existingEntry: entry,
      ),
    );

    if (result != null) {
      final categoryIndex = result['categoryIndex'] as int?;
      final note = result['note'] as String?;

      if (categoryIndex != null) {
        final newEntry = DayEntry(
          date: date,
          categoryIndex: categoryIndex,
          note: note,
        );

        setState(() {
          log.setEntry(newEntry);
        });

        // Update in provider
        if (mounted) {
          context.read<LogProvider>().updateLog(log);
        }
      } else if (result['delete'] == true) {
        setState(() {
          log.removeEntry(date);
        });
        if (mounted) {
          context.read<LogProvider>().updateLog(log);
        }
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getWeekdayShort(int weekday) {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return weekdays[weekday - 1];
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  int _getDaysInMonth(int year, int month) {
    final isLeapYear = _isLeapYear(year);
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return month == 2 && isLeapYear ? 29 : daysInMonth[month - 1];
  }

  DateTime _getDateFromDayOfYear(int year, int dayOfYear) {
    int month = 1;
    int day = dayOfYear;
    
    final daysInMonths = _getDaysInMonthsList(year);
    
    for (int m = 0; m < 12; m++) {
      if (day <= daysInMonths[m]) {
        month = m + 1;
        break;
      }
      day -= daysInMonths[m];
    }
    
    return DateTime(year, month, day);
  }

  List<int> _getDaysInMonthsList(int year) {
    final isLeapYear = _isLeapYear(year);
    return [31, isLeapYear ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  }
}
