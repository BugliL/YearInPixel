import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log.dart';
import '../models/day_entry.dart';
import '../models/log_category.dart';
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
              '${_log.emoji} ${_log.name}',
              style: const TextStyle(fontSize: 18),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: _editLogNameAndEmoji,
              tooltip: 'Edit name and emoji',
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Log', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
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
            Row(
              children: [
                // Space for day numbers
                const SizedBox(width: 24),
                const SizedBox(width: 4),
                // Month headers aligned with grid
                ...months.map((month) {
                  return Container(
                    width: 20, // 18px cell + 2px horizontal padding (1px on each side)
                    alignment: Alignment.center,
                    child: Text(
                      month,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ],
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
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: SizedBox(width: 18, height: 18),
              );
            }

            final date = DateTime(year, monthIndex + 1, day);
            final entry = _log.getEntryForDate(date);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: GestureDetector(
                onTap: () => _handleDayTap(date, entry),
                onLongPress: () {
                  if (entry?.note != null) {
                    _showNoteDialog(date, entry!);
                  }
                },
                child: Container(
                  width: 18,
                  height: 18,
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
      width: 80,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ..._log.categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => _editCategory(index, category),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
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
              ),
            );
          }),
          IconButton(
            onPressed: _addCategory,
            icon: const Icon(Icons.add_box_sharp),
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

  void _addCategory() {
    _editCategory(
      null,
      LogCategory(label: 'New Category', color: 0xFF9C27B0),
    );
  }

  void _handleCategoryDeletion(int categoryIndex) async {
    // Check if this category is being used by any entries
    final entriesUsingCategory = _log.entries
        .where((entry) => entry.categoryIndex == categoryIndex)
        .toList();

    if (entriesUsingCategory.isEmpty) {
      // Safe to delete - no entries use this category
      setState(() {
        _log.categories.removeAt(categoryIndex);
        // Update indices for entries with higher categoryIndex
        for (var entry in _log.entries) {
          if (entry.categoryIndex > categoryIndex) {
            final updatedEntry = entry.copyWith(
              categoryIndex: entry.categoryIndex - 1,
            );
            final entryIndex = _log.entries.indexOf(entry);
            _log.entries[entryIndex] = updatedEntry;
          }
        }
      });
      context.read<LogProvider>().updateLog(_log);
      return;
    }

    // Category is in use - show dialog with options
    if (!mounted) return;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Category in Use'),
        content: Text(
          'This category is used by ${entriesUsingCategory.length} ${entriesUsingCategory.length == 1 ? "entry" : "entries"}. What would you like to do?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancel'),
          ),
          if (_log.categories.length > 1)
            TextButton(
              onPressed: () => Navigator.pop(context, 'reassign'),
              child: const Text('Reassign to Another'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete_all'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All Entries'),
          ),
        ],
      ),
    );
    if (!mounted) return;    if (result == 'delete_all') {
      setState(() {
        // Remove all entries using this category
        _log.entries.removeWhere((entry) => entry.categoryIndex == categoryIndex);
        // Remove the category
        _log.categories.removeAt(categoryIndex);
        // Update indices for remaining entries
        for (var entry in _log.entries) {
          if (entry.categoryIndex > categoryIndex) {
            final updatedEntry = entry.copyWith(
              categoryIndex: entry.categoryIndex - 1,
            );
            final entryIndex = _log.entries.indexOf(entry);
            _log.entries[entryIndex] = updatedEntry;
          }
        }
      });
      context.read<LogProvider>().updateLog(_log);
    } else if (result == 'reassign') {
      _showReassignDialog(categoryIndex, entriesUsingCategory);
    }
  }

  void _showReassignDialog(int oldCategoryIndex, List<DayEntry> entries) async {
    int? newCategoryIndex;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reassign to Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose a category to reassign ${entries.length} ${entries.length == 1 ? "entry" : "entries"}:'),
            const SizedBox(height: 16),
            ..._log.categories.asMap().entries.where((e) => e.key != oldCategoryIndex).map((entry) {
              return ListTile(
                leading: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(entry.value.color),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                title: Text(entry.value.label),
                onTap: () {
                  newCategoryIndex = entry.key;
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newCategoryIndex != null) {
      setState(() {
        // Reassign all entries to new category
        for (var entry in entries) {
          final updatedEntry = entry.copyWith(categoryIndex: newCategoryIndex);
          final entryIndex = _log.entries.indexOf(entry);
          _log.entries[entryIndex] = updatedEntry;
        }
        // Remove the old category
        _log.categories.removeAt(oldCategoryIndex);
        // Update indices for entries with indices greater than the deleted one
        for (int i = 0; i < _log.entries.length; i++) {
          final entry = _log.entries[i];
          if (entry.categoryIndex > oldCategoryIndex) {
            _log.entries[i] = entry.copyWith(
              categoryIndex: entry.categoryIndex - 1,
            );
          } else if (entry.categoryIndex == newCategoryIndex && newCategoryIndex! > oldCategoryIndex) {
            // Adjust the new category index since we're deleting a category before it
            _log.entries[i] = entry.copyWith(
              categoryIndex: entry.categoryIndex - 1,
            );
          }
        }
      });
      context.read<LogProvider>().updateLog(_log);
    }
  }

  void _editCategory(int? index, LogCategory category) {
    final nameController = TextEditingController(text: category.label);
    Color selectedColor = Color(category.color);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index == null ? 'Add Category' : 'Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Color:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  0xFF4CAF50, // Green (5 stars)
                  0xFF8BC34A, // Light Green (4 stars)
                  0xFFFFEB3B, // Yellow (3 stars)
                  0xFFFF9800, // Orange (2 stars)
                  0xFFF44336, // Red (1 star)
                  0xFF2196F3, // Blue
                  0xFF9C27B0, // Purple
                  0xFFE91E63, // Pink
                  0xFF795548, // Brown
                  0xFF607D8B, // Blue Grey
                ].map((colorValue) {
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        selectedColor = Color(colorValue);
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        shape: BoxShape.circle,
                        border: selectedColor.toARGB32() == colorValue
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            if (index != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleCategoryDeletion(index);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newCategory = LogCategory(
                  label: nameController.text.isEmpty 
                      ? category.label 
                      : nameController.text,
                  color: selectedColor.toARGB32(),
                );

                setState(() {
                  if (index == null) {
                    _log.categories.add(newCategory);
                  } else {
                    _log.categories[index] = newCategory;
                  }
                });

                context.read<LogProvider>().updateLog(_log);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // Available emojis for the log
  static const List<String> _availableEmojis = [
    // Emotions & Moods
    '😊', '😢', '😡', '😰', '😴', '🤔', '😍', '😐', '🥳', '😞', '🤗', '😎',
    // Activities & Work
    '💼', '💻', '📚', '✍️', '🎨', '🎵', '🎮', '📺', '🎓', '📊', '💡',
    // Exercise & Sports
    '🏃', '🚴', '🧘', '💪', '🏊', '⚽', '🏀', '🎾', '⛳',
    // Health & Wellness
    '❤️', '🤒', '💊', '🩺', '🧠', '💚', '🩹', '😷',
    // Food & Drink
    '🍎', '🥗', '🍕', '☕', '🍰', '🍔', '🥤', '🍝', '🍜', '🥘',
    // Weather
    '☀️', '⛅', '🌧️', '⛈️', '🌈', '❄️', '🌤️',
    // Social & People
    '👥', '💬', '📱', '👪', '💑', '🎉', '🎈', '🎁',
    // Nature & Outdoors
    '🌳', '🌸', '🌺', '🌿', '🐕', '🐱', '🦋', '🌄',
    // Travel & Places
    '✈️', '🚗', '🏠', '🏖️', '🗺️', '🚂', '🏨', '⛺',
    // Achievement & Goals
    '⭐', '🏆', '🎯', '✅', '💯', '🔥', '🌟',
    // Money & Shopping
    '💰', '💸', '💳', '🛍️',
    // Time & Schedule
    '⏰', '🌅', '🌙', '⏱️', '📅',
    // Misc Useful
    '📷', '💤', '🔔', '📧', '🎬', '🎭', '📖', '🎪',
  ];

  void _editLogNameAndEmoji() {
    final nameController = TextEditingController(text: _log.name);
    String selectedEmoji = _log.emoji;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Log'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji picker button
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Select an Emoji',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: GridView.builder(
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 6,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                        itemCount: _availableEmojis.length,
                                        itemBuilder: (context, index) {
                                          final emoji = _availableEmojis[index];
                                          final isSelected = emoji == selectedEmoji;
                                          return InkWell(
                                            onTap: () {
                                              setDialogState(() {
                                                selectedEmoji = emoji;
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFF98D8C8).withOpacity(0.3)
                                                    : Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(8),
                                                border: isSelected
                                                    ? Border.all(
                                                        color: const Color(0xFF98D8C8),
                                                        width: 2,
                                                      )
                                                    : null,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  emoji,
                                                  style: const TextStyle(fontSize: 28),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 60,
                          height: 58,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              selectedEmoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name field
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Log Name',
                            border: OutlineInputBorder(),
                          ),
                          autofocus: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a log name')),
                    );
                    return;
                  }

                  setState(() {
                    _log = Log(
                      id: _log.id,
                      name: nameController.text,
                      emoji: selectedEmoji,
                      categories: _log.categories,
                      entries: _log.entries,
                      createdAt: _log.createdAt,
                    );
                  });

                  context.read<LogProvider>().updateLog(_log);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Log'),
          content: Text(
            'Are you sure you want to delete "${_log.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await context.read<LogProvider>().deleteLog(_log.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
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
