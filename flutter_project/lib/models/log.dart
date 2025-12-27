import 'package:hive/hive.dart';
import 'log_category.dart';
import 'day_entry.dart';

part 'log.g.dart';

@HiveType(typeId: 2)
class Log {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String emoji;

  @HiveField(3)
  List<LogCategory> categories;

  @HiveField(4)
  List<DayEntry> entries;

  @HiveField(5)
  final DateTime createdAt;

  Log({
    required this.id,
    required this.name,
    required this.emoji,
    required this.categories,
    List<DayEntry>? entries,
    DateTime? createdAt,
  })  : entries = entries ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Get entry for a specific date
  DayEntry? getEntryForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    try {
      return entries.firstWhere(
        (entry) {
          final entryDate = DateTime(
            entry.date.year,
            entry.date.month,
            entry.date.day,
          );
          return entryDate == normalizedDate;
        },
      );
    } catch (e) {
      return null;
    }
  }

  // Add or update entry for a date
  void setEntry(DayEntry entry) {
    final normalizedDate = DateTime(
      entry.date.year,
      entry.date.month,
      entry.date.day,
    );

    // Remove existing entry for this date if it exists
    entries.removeWhere((e) {
      final entryDate = DateTime(e.date.year, e.date.month, e.date.day);
      return entryDate == normalizedDate;
    });

    // Add new entry
    entries.add(DayEntry(
      date: normalizedDate,
      categoryIndex: entry.categoryIndex,
      note: entry.note,
    ));
  }

  // Remove entry for a date
  void removeEntry(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    entries.removeWhere((e) {
      final entryDate = DateTime(e.date.year, e.date.month, e.date.day);
      return entryDate == normalizedDate;
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'categories': categories.map((c) => c.toJson()).toList(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      categories: (json['categories'] as List)
          .map((c) => LogCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
      entries: (json['entries'] as List)
          .map((e) => DayEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
