import 'package:hive/hive.dart';

part 'day_entry.g.dart';

@HiveType(typeId: 1)
class DayEntry {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int categoryIndex; // Index into the log's categories list

  @HiveField(2)
  final String? note;

  DayEntry({
    required this.date,
    required this.categoryIndex,
    this.note,
  });

  // Create a copy with updated fields
  DayEntry copyWith({
    DateTime? date,
    int? categoryIndex,
    String? note,
  }) {
    return DayEntry(
      date: date ?? this.date,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'categoryIndex': categoryIndex,
      'note': note,
    };
  }

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    return DayEntry(
      date: DateTime.parse(json['date'] as String),
      categoryIndex: json['categoryIndex'] as int,
      note: json['note'] as String?,
    );
  }
}
