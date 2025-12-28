import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log.dart';
import '../models/log_category.dart';
import '../providers/log_provider.dart';
import '../services/log_templates.dart';
import '../widgets/category_editor_dialog.dart';

class LogEditorScreen extends StatefulWidget {
  final Log? log;

  const LogEditorScreen({super.key, this.log});

  @override
  State<LogEditorScreen> createState() => _LogEditorScreenState();
}

class _LogEditorScreenState extends State<LogEditorScreen> {
  late TextEditingController _nameController;
  String _selectedEmoji = '';
  final List<LogCategory> _categories = [];
  String? _selectedTemplateId;

  // Curated emojis for meaningful tracking
  static const List<String> _availableEmojis = [
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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.log?.name ?? '');
    _selectedEmoji = widget.log?.emoji ?? '😀';
    if (widget.log != null) {
      _categories.addAll(widget.log!.categories);
    } else {
      // Add default categories
      _categories.addAll([
        LogCategory(label: 'Category 1', color: 0xFF4CAF50),
        LogCategory(label: 'Category 2', color: 0xFF2196F3),
      ]);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.log == null ? 'Create Log' : 'Edit Log'),
        actions: [
          if (widget.log != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteLog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template selector (only for new logs)
            if (widget.log == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select a template'),
                    value: _selectedTemplateId,
                    items: LogTemplates.templates.map((template) {
                      return DropdownMenuItem<String>(
                        value: template.id,
                        child: Row(
                          children: [
                            Text(template.emoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    template.name,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    template.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        final template = LogTemplates.templates.firstWhere(
                          (t) => t.id == value,
                        );
                        setState(() {
                          _selectedTemplateId = value;
                        });
                        _loadTemplate(template);
                      }
                    },
                  ),
                ),
              ),
            if (widget.log == null) const SizedBox(height: 16),
            // Name and Emoji field in a row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji picker button
                InkWell(
                  onTap: _showEmojiPicker,
                  child: Container(
                    width: 60,
                    height: 58,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _selectedEmoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name field
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Log Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Categories section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCategory,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return _buildCategoryItem(index, category);
            }),
            const SizedBox(height: 32),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF98D8C8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Log',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(int index, LogCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(category.color),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        title: Text(category.label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editCategory(index, category),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _categories.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addCategory() {
    _editCategory(
      null,
      LogCategory(label: 'New Category', color: 0xFF9C27B0),
    );
  }

  void _editCategory(int? index, LogCategory category) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => CategoryEditorDialog(
        category: category,
        isNew: index == null,
        showDelete: false,
      ),
    );

    if (result is LogCategory) {
      setState(() {
        if (index == null) {
          _categories.add(result);
        } else {
          _categories[index] = result;
        }
      });
    }
  }

  void _showEmojiPicker() {
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
                    final isSelected = emoji == _selectedEmoji;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedEmoji = emoji;
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
  }

  void _saveLog() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a log name')),
      );
      return;
    }

    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one category')),
      );
      return;
    }

    final log = widget.log?.copyWith(
          name: _nameController.text,
          emoji: _selectedEmoji,
          categories: _categories,
        ) ??
        Log(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          emoji: _selectedEmoji,
          categories: _categories,
        );

    final provider = context.read<LogProvider>();
    if (widget.log == null) {
      provider.addLog(log);
    } else {
      provider.updateLog(log);
    }

    Navigator.pop(context);
  }

  void _loadTemplate(LogTemplate template) {
    setState(() {
      _nameController.text = template.name;
      _selectedEmoji = template.emoji;
      _categories.clear();
      _categories.addAll(
        template.categories
            .map((cat) => LogCategory(label: cat.label, color: cat.color))
            .toList(),
      );
    });
  }

  void _deleteLog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Log'),
        content: const Text('Are you sure you want to delete this log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<LogProvider>().deleteLog(widget.log!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close editor
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

extension on Log {
  Log copyWith({
    String? name,
    String? emoji,
    List<LogCategory>? categories,
  }) {
    return Log(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      categories: categories ?? this.categories,
      entries: entries,
      createdAt: createdAt,
    );
  }
}
