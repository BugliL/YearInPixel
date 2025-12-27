import '../models/log.dart';
import '../models/log_category.dart';

class LogTemplates {
  static List<LogTemplate> get templates => [
        LogTemplate(
          id: 'empty',
          name: 'Empty',
          emoji: '✨',
          description: 'Start from scratch with an empty log',
          categories: [],
        ),
        LogTemplate(
          id: 'rate_my_day',
          name: 'Rate My Day',
          emoji: '⭐',
          description: 'Track your daily mood with a 5-star rating system',
          categories: [
            LogCategory(label: '5 stars', color: 0xFF4CAF50), // Green
            LogCategory(label: '4 stars', color: 0xFF8BC34A), // Light green
            LogCategory(label: '3 stars', color: 0xFFFFEB3B), // Yellow
            LogCategory(label: '2 stars', color: 0xFFFF9800), // Orange
            LogCategory(label: '1 star', color: 0xFFF44336), // Red
          ],
        ),
        LogTemplate(
          id: 'health_log',
          name: 'Health Log',
          emoji: '🏥',
          description: 'Monitor your health conditions and symptoms',
          categories: [
            LogCategory(label: 'well', color: 0xFF4CAF50), // Green
            LogCategory(label: 'cold', color: 0xFFFFB6C1), // Light pink
            LogCategory(label: 'fever', color: 0xFFDDA0DD), // Plum
            LogCategory(label: 'headache', color: 0xFFFFEB3B), // Yellow
            LogCategory(label: 'stomach pain', color: 0xFFFF9800), // Orange
            LogCategory(label: 'body pain', color: 0xFFFFB347), // Light orange
            LogCategory(label: 'hungover', color: 0xFFF06292), // Pink
          ],
        ),
        LogTemplate(
          id: 'anxiety_log',
          name: 'Anxiety Log',
          emoji: '😰',
          description: 'Track your anxiety levels throughout the year',
          categories: [
            LogCategory(label: 'none', color: 0xFF4CAF50), // Green
            LogCategory(label: 'low', color: 0xFF81D4FA), // Light blue
            LogCategory(label: 'medium', color: 0xFFFFEB3B), // Yellow
            LogCategory(label: 'high', color: 0xFFFF9800), // Orange
            LogCategory(label: 'severe', color: 0xFFD32F2F), // Dark red
          ],
        ),
        LogTemplate(
          id: 'period_tracker',
          name: 'Period Tracker',
          emoji: '🩸',
          description: 'Track your menstrual cycle',
          categories: [
            LogCategory(label: 'period', color: 0xFFF48FB1), // Pink
          ],
        ),
        LogTemplate(
          id: 'training_log',
          name: 'Training Log',
          emoji: '💪',
          description: 'Log your daily workout and running activities',
          categories: [
            LogCategory(label: '10 km+', color: 0xFFF48FB1), // Hot pink
            LogCategory(label: '6-9 km', color: 0xFFE91E63), // Pink
            LogCategory(label: '3-5 km', color: 0xFF81C784), // Light green
            LogCategory(label: '1-2 km', color: 0xFF64B5F6), // Light blue
            LogCategory(label: 'intervals', color: 0xFFFFB74D), // Orange
            LogCategory(label: 'nothing', color: 0xFFB39DDB), // Light purple
          ],
        ),
        LogTemplate(
          id: 'reading_log',
          name: 'Reading Log',
          emoji: '📚',
          description: 'Keep track of your reading habits',
          categories: [
            LogCategory(label: 'read today', color: 0xFFB39DDB), // Purple
            LogCategory(label: 'finished book', color: 0xFFF48FB1), // Pink
          ],
        ),
      ];

  static Log createLogFromTemplate(LogTemplate template) {
    return Log(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: template.name,
      emoji: template.emoji,
      categories: template.categories
          .map((cat) => LogCategory(label: cat.label, color: cat.color))
          .toList(),
    );
  }
}

class LogTemplate {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<LogCategory> categories;

  LogTemplate({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.categories,
  });
}
