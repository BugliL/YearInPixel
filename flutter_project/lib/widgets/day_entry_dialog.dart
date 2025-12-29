import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log.dart';
import '../models/day_entry.dart';

class DayEntryDialog extends StatefulWidget {
  final DateTime date;
  final Log log;
  final DayEntry? existingEntry;

  const DayEntryDialog({
    super.key,
    required this.date,
    required this.log,
    this.existingEntry,
  });

  @override
  State<DayEntryDialog> createState() => _DayEntryDialogState();
}

class _DayEntryDialogState extends State<DayEntryDialog> {
  late TextEditingController _noteController;
  int? _selectedCategoryIndex;

  @override
  void initState() {
    super.initState();
    // Validate categoryIndex to prevent crash if category was deleted
    final existingIndex = widget.existingEntry?.categoryIndex;
    _selectedCategoryIndex = (existingIndex != null && existingIndex < widget.log.categories.length)
        ? existingIndex
        : null;
    _noteController = TextEditingController(text: widget.existingEntry?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd\nEEE').format(widget.date);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Log info header (emoji and title)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.log.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.log.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Date header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    final previousDate = widget.date.subtract(const Duration(days: 1));
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      showDialog(
                        context: context,
                        builder: (_) => DayEntryDialog(
                          date: previousDate,
                          log: widget.log,
                          existingEntry: widget.log.getEntryForDate(previousDate),
                        ),
                      );
                    });
                  },
                ),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    final nextDate = widget.date.add(const Duration(days: 1));
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      showDialog(
                        context: context,
                        builder: (_) => DayEntryDialog(
                          date: nextDate,
                          log: widget.log,
                          existingEntry: widget.log.getEntryForDate(nextDate),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Color/category selection
            if (_selectedCategoryIndex != null && _selectedCategoryIndex! < widget.log.categories.length)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(widget.log.categories[_selectedCategoryIndex!].color),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            const SizedBox(height: 24),
            // Category buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: widget.log.categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final isSelected = _selectedCategoryIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(category.color),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: Text(
                      category.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Note input
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Add a note...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                if (widget.existingEntry != null)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, {'delete': true});
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _selectedCategoryIndex != null
                      ? () {
                          Navigator.pop(context, {
                            'categoryIndex': _selectedCategoryIndex,
                            'note': _noteController.text.isEmpty
                                ? null
                                : _noteController.text,
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF98D8C8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
