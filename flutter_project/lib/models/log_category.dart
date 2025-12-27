import 'package:hive/hive.dart';

part 'log_category.g.dart';

@HiveType(typeId: 0)
class LogCategory {
  @HiveField(0)
  final String label;

  @HiveField(1)
  final int color; // Color value as int

  LogCategory({
    required this.label,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'color': color,
    };
  }

  factory LogCategory.fromJson(Map<String, dynamic> json) {
    return LogCategory(
      label: json['label'] as String,
      color: json['color'] as int,
    );
  }
}
