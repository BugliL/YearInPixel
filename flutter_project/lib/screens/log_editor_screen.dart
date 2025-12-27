import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log.dart';
import '../models/log_category.dart';
import '../providers/log_provider.dart';

class LogEditorScreen extends StatefulWidget {
  final Log? log;

  const LogEditorScreen({super.key, this.log});

  @override
  State<LogEditorScreen> createState() => _LogEditorScreenState();
}

class _LogEditorScreenState extends State<LogEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emojiController;
  final List<LogCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.log?.name ?? '');
    _emojiController = TextEditingController(text: widget.log?.emoji ?? '');
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
    _emojiController.dispose();
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
            // Name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Log Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Emoji field
            TextField(
              controller: _emojiController,
              decoration: InputDecoration(
                labelText: 'Emoji',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLength: 2,
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
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Color:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  0xFFF44336, // Red
                  0xFFFF9800, // Orange
                  0xFFFFEB3B, // Yellow
                  0xFF4CAF50, // Green
                  0xFF2196F3, // Blue
                  0xFF9C27B0, // Purple
                  0xFFE91E63, // Pink
                  0xFF795548, // Brown
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
                        border: selectedColor.value == colorValue
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newCategory = LogCategory(
                  label: nameController.text,
                  color: selectedColor.value,
                );

                setState(() {
                  if (index == null) {
                    _categories.add(newCategory);
                  } else {
                    _categories[index] = newCategory;
                  }
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
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
          emoji: _emojiController.text,
          categories: _categories,
        ) ??
        Log(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          emoji: _emojiController.text,
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
