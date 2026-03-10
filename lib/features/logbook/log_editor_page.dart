import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_073/features/logbook/models/log_model.dart';
import 'package:logbook_app_073/features/logbook/widgets/log_constants.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final String role;
  final String userId;

  const LogEditorPage({
    super.key,
    this.log,
    required this.role,
    required this.userId,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(
      text: widget.log?.description ?? '',
    );
    _selectedCategory = widget.log?.category ?? 'Pribadi';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'title': _titleController.text,
        'description': _descController.text,
        'category': _selectedCategory,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.log != null;
    final primaryColor = Theme.of(context).primaryColor;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.edit_note), text: 'Edit'),
              Tab(icon: Icon(Icons.preview_rounded), text: 'Preview'),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.check_rounded), onPressed: _save),
          ],
        ),
        body: TabBarView(
          children: [
            // TAB 1: EDIT FORM
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Catatan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul',
                        hintText: 'Masukkan judul catatan...',
                        prefixIcon: const Icon(Icons.title_rounded),
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Judul tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi (Mendukung Markdown)',
                        hintText: 'Gunakan # untuk judul, * untuk miring, dll.',
                        prefixIcon: const Icon(Icons.description_rounded),
                        alignLabelWithHint: true,
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Deskripsi tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: kCategoryIcons.keys.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        final color = kCategoryColors[cat] ?? Colors.grey;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                            }
                          },
                          selectedColor: color.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? color : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          avatar: Icon(
                            kCategoryIcons[cat],
                            size: 16,
                            color: isSelected ? color : Colors.grey,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            // TAB 2: PREVIEW
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _descController,
              builder: (context, value, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: MarkdownBody(
                    data: value.text.isEmpty
                        ? '*Belum ada deskripsi untuk dipratinjau.*'
                        : value.text,
                    selectable: true,
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: Text(isEdit ? 'Update Catatan' : 'Simpan Catatan'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
