import 'package:flutter/material.dart';
import 'package:logbook_app_073/features/logbook/widgets/log_constants.dart';

class LogCategoryDialog extends StatefulWidget {
  final String titleLabel;
  final TextEditingController titleController;
  final TextEditingController descController;
  final String initialCategory;
  final VoidCallback onCancel;
  final void Function(String category) onSubmit;
  final String submitLabel;

  const LogCategoryDialog({
    super.key,
    required this.titleLabel,
    required this.titleController,
    required this.descController,
    required this.initialCategory,
    required this.onCancel,
    required this.onSubmit,
    required this.submitLabel,
  });

  @override
  State<LogCategoryDialog> createState() => _LogCategoryDialogState();
}

class _LogCategoryDialogState extends State<LogCategoryDialog> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final color = kCategoryColors[_selectedCategory] ?? Colors.green;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(widget.titleLabel),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.titleController,
              decoration: InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: widget.descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kategori',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                prefixIcon: Icon(
                  kCategoryIcons[_selectedCategory],
                  color: color,
                ),
              ),
              items: kCategories.map((cat) {
                final catColor = kCategoryColors[cat]!;
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(kCategoryIcons[cat], color: catColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        cat,
                        style: TextStyle(
                          color: catColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => widget.onSubmit(_selectedCategory),
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
