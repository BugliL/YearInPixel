import 'package:flutter/material.dart';

class EmojiPickerDialog extends StatelessWidget {
  final String? currentEmoji;
  
  const EmojiPickerDialog({
    super.key,
    this.currentEmoji,
  });

  // Curated emojis for meaningful tracking
  static const List<String> availableEmojis = [
    // Emotions & Moods
    '😊', '😢', '😡', '😰', '😴', '🤔', '😍', '😐', '🥳', '😞', '🤗', '😎',
    // Activities & Work
    '💼', '💻', '📚', '✍️', '🎨', '🎵', '🎮', '📺', '🎓', '📊', '💡',
    // Exercise & Sports
    '🏃', '🚴', '🧘', '💪', '🏊', '⚽', '🏀', '🎾', '⛳',
    // Health & Wellness
    '❤️', '🤒', '💊', '🩺', '🧠', '💚', '🩹', '😷', '🛁', '🪥',
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
    '📷', '💤', '🛌', '🔔', '📧', '🎬', '🎭', '📖', '🎪',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                itemCount: availableEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = availableEmojis[index];
                  final isSelected = emoji == currentEmoji;
                  return InkWell(
                    onTap: () => Navigator.pop(context, emoji),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF98D8C8).withValues(alpha: 0.3)
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
    );
  }
}
