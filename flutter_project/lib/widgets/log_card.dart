import 'package:flutter/material.dart';
import '../models/log.dart';

class LogCard extends StatelessWidget {
  final Log log;
  final int year;

  const LogCard({
    super.key,
    required this.log,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  log.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    log.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildMiniGrid(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildColorLegend(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniGrid() {
    // Create a mini version of the year grid
    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    return Column(
      children: [
        // Month headers (optional in mini view)
        Row(
          children: months.map((m) {
            return Expanded(
              child: Text(
                m,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 8, color: Colors.grey),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        // Day grid
        Expanded(
          child: Column(
            children: List.generate(31, (dayIndex) {
              return Expanded(
                child: Row(
                  children: List.generate(12, (monthIndex) {
                    final day = dayIndex + 1;
                    if (day > daysInMonth[monthIndex]) {
                      // Empty cell for days that don't exist in this month
                      return const Expanded(child: SizedBox());
                    }

                    final date = DateTime(year, monthIndex + 1, day);
                    final entry = log.getEntryForDate(date);
                    final color = entry != null && entry.categoryIndex < log.categories.length
                        ? Color(log.categories[entry.categoryIndex].color)
                        : Colors.grey.shade200;

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(0.5),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildColorLegend() {
    // Show all categories in a vertical row
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: log.categories.map((category) {
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Color(category.color),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }).toList(),
    );
  }
}
