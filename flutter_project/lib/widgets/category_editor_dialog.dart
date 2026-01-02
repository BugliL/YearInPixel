import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/log_category.dart';

class CategoryEditorDialog extends StatefulWidget {
  final LogCategory category;
  final bool isNew;
  final bool showDelete;

  const CategoryEditorDialog({
    super.key,
    required this.category,
    this.isNew = false,
    this.showDelete = false,
  });

  @override
  State<CategoryEditorDialog> createState() => _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends State<CategoryEditorDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;

  static const List<int> _presetColors = [
    0xFF4CAF50, // Green
    0xFF8BC34A, // Light Green
    0xFFFFEB3B, // Yellow
    0xFFFF9800, // Orange
    0xFFF44336, // Red
    0xFF2196F3, // Blue
    0xFF9C27B0, // Purple
    0xFFE91E63, // Pink
    0xFF795548, // Brown
    0xFF607D8B, // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.label);
    _selectedColor = Color(widget.category.color);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _isPresetColor(Color color) {
    return _presetColors.contains(color.toARGB32());
  }

  Future<void> _showColorPicker() async {
    Color pickerColor = _selectedColor;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              colorPickerWidth: 300,
              pickerAreaHeightPercent: 0.7,
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithHue,
              labelTypes: const [],
              pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedColor = pickerColor;
                });
                Navigator.pop(context);
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isNew ? 'Add Category' : 'Edit Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
            ),
          ),
          const SizedBox(height: 24),
          const Text('Select Color:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._presetColors.map((colorValue) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = Color(colorValue);
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(colorValue),
                      shape: BoxShape.circle,
                      border: _selectedColor.toARGB32() == colorValue
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                  ),
                );
              }),
              // Custom color picker button
              GestureDetector(
                onTap: _showColorPicker,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isPresetColor(_selectedColor)
                        ? Colors.white
                        : _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isPresetColor(_selectedColor)
                          ? Colors.grey
                          : Colors.black,
                      width: _isPresetColor(_selectedColor) ? 2 : 3,
                    ),
                  ),
                  child: _isPresetColor(_selectedColor)
                      ? const Icon(Icons.add, color: Colors.grey, size: 24)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (widget.showDelete)
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a category name')),
              );
              return;
            }
            
            final newCategory = LogCategory(
              label: _nameController.text,
              color: _selectedColor.toARGB32(),
            );
            Navigator.pop(context, newCategory);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
