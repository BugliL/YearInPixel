import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log.dart';
import '../models/day_entry.dart';
import '../providers/log_provider.dart';
import '../widgets/day_entry_dialog.dart';

class LogDetailScreen extends StatefulWidget {
  final Log log;

  const LogDetailScreen({super.key, required this.log});

  @override
  State<LogDetailScreen> createState() => _LogDetailScreenState();
}

class _LogDetailScreenState extends State<LogDetailScreen> {
  late Log _log;

  @override
  void initState() {
    super.initState();
    _log = widget.log;
  }

  @override
  Widget build(BuildContext context) {
    final year = context.watch<LogProvider>().selectedYear;

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_log.name}${_log.emoji}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Main calendar grid
            Expanded(
              child: _buildCalendarGrid(year),
            ),
            // Color legend
            _buildColorLegend(),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    // Different background colors based on log type
    if (_log.name.contains('rate')) return const Color(0xFFB8D4B8);
    if (_log.name.contains('health')) return const Color(0xFFB8D4B8);
    if (_log.name.contains('anxiety')) return const Color(0xFFB0D4E8);
    if (_log.name.contains('period')) return const Color(0xFFF4C4C4);
    return const Color(0xFFE8D4E8);
  }

  Widget _buildCalendarGrid(int year) {
    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final daysInMonth = _getDaysInMonth(year);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month headers
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Row(
                children: months.map((month) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        month,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            // Day rows
            ...List.generate(31, (dayIndex) {
              final day = dayIndex + 1;
              return _buildDayRow(day, daysInMonth, year);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(int day, List<int> daysInMonth, int year) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          // Day number
          SizedBox(
            width: 24,
            child: Text(
              '$day',
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          // Day cells for each month
          ...List.generate(12, (monthIndex) {
            if (day > daysInMonth[monthIndex]) {
              return const Expanded(child: SizedBox(height: 12));
            }

            final date = DateTime(year, monthIndex + 1, day);
            final entry = _log.getEntryForDate(date);

            return Expanded(
              child: GestureDetector(
                onTap: () => _handleDayTap(date, entry),
                onLongPress: () {
                  if (entry?.note != null) {
                    _showNoteDialog(date, entry!);
                  }
                },
                child: Container(
                  height: 12,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: entry != null
                        ? Color(_log.categories[entry.categoryIndex].color)
                        : Colors.grey.shade300,
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

  Widget _buildColorLegend() {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._log.categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(category.color),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.label,
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),
          const Spacer(),
          // Add button
          IconButton(
            onPressed: () {
              // Add new category
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  void _handleDayTap(DateTime date, DayEntry? existingEntry) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => DayEntryDialog(
        date: date,
        log: _log,
        existingEntry: existingEntry,
      ),
    );

    if (result != null) {
      final categoryIndex = result['categoryIndex'] as int?;
      final note = result['note'] as String?;

      if (categoryIndex != null) {
        final entry = DayEntry(
          date: date,
          categoryIndex: categoryIndex,
          note: note,
        );

        setState(() {
          _log.setEntry(entry);
        });

        // Update in provider
        context.read<LogProvider>().updateLog(_log);
      } else if (result['delete'] == true) {
        setState(() {
          _log.removeEntry(date);
        });
        context.read<LogProvider>().updateLog(_log);
      }
    }
  }

  void _showNoteDialog(DateTime date, DayEntry entry) {
    _handleDayTap(date, entry);
  }

  List<int> _getDaysInMonth(int year) {
    final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    return [
      31, // Jan
      isLeapYear ? 29 : 28, // Feb
      31, // Mar
      30, // Apr
      31, // May
      30, // Jun
      31, // Jul
      31, // Aug
      30, // Sep
      31, // Oct
      30, // Nov
      31, // Dec
    ];
  }
}
