import 'package:flutter/material.dart';
import 'package:logbook_app_073/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_073/features/logbook/log_controller.dart';
import 'package:logbook_app_073/features/logbook/models/log_model.dart';
import 'package:logbook_app_073/features/logbook/widgets/log_card.dart';
import 'package:logbook_app_073/features/logbook/widgets/log_empty_state.dart';
import 'package:logbook_app_073/features/logbook/widgets/log_category_dialog.dart';
import 'package:logbook_app_073/services/access_control_service.dart';

// ────────────────────────────────────────────────────────────
// LogView
// ────────────────────────────────────────────────────────────
class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'Pribadi'; // untuk dialog add/edit
  late Future<List<LogModel>> _logFuture;

  @override
  void initState() {
    super.initState();
    _logFuture = _controller.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Dialog Selamat Datang ──────────────────────────────────
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selamat Datang'),
          content: Text(
            'Halo ${widget.username}, selamat menggunakan Logbook!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mulai'),
            ),
          ],
        );
      },
    );
  }

  // ── Dialog Tambah Catatan ─────────────────────────────────
  void _showAddLogDialog() {
    _titleController.clear();
    _descController.clear();
    _selectedCategory = 'Pribadi';

    showDialog(
      context: context,
      builder: (context) => LogCategoryDialog(
        titleLabel: 'Tambah Catatan',
        titleController: _titleController,
        descController: _descController,
        initialCategory: _selectedCategory,
        onCancel: () => Navigator.pop(context),
        onSubmit: (category) {
          if (_titleController.text.isNotEmpty &&
              _descController.text.isNotEmpty) {
            setState(() {
              _logFuture = _controller.addLog(
                _titleController.text,
                _descController.text,
                category: category,
              );
            });
            _titleController.clear();
            _descController.clear();
            Navigator.pop(context);
          }
        },
        submitLabel: 'Simpan',
      ),
    );
  }

  // ── Dialog Edit Catatan ────────────────────────────────────
  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _descController.text = log.description;
    _selectedCategory = log.category;

    showDialog(
      context: context,
      builder: (context) => LogCategoryDialog(
        titleLabel: 'Edit Catatan',
        titleController: _titleController,
        descController: _descController,
        initialCategory: _selectedCategory,
        onCancel: () {
          _titleController.clear();
          _descController.clear();
          Navigator.pop(context);
        },
        onSubmit: (category) {
          if (_titleController.text.isNotEmpty &&
              _descController.text.isNotEmpty) {
            setState(() {
              _logFuture = _controller.updateLog(
                index,
                _titleController.text,
                _descController.text,
                category: category,
              );
            });
            _titleController.clear();
            _descController.clear();
            Navigator.pop(context);
          }
        },
        submitLabel: 'Update',
      ),
    );
  }

  // ── Refresh Handler ──────────────────────────────────────
  Future<void> _handleRefresh() async {
    setState(() {
      _logFuture = _controller.loadFromCloud();
    });
    // Menunggu masa depan selesai agar RefreshIndicator tetap berputar sebentar
    await _logFuture;
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Text(
                  widget.username.isNotEmpty
                      ? widget.username[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'My Logbook',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: ValueListenableBuilder<List<LogModel>>(
                valueListenable: _controller.logsNotifier,
                builder: (context, logs, _) => Text('${logs.length}'),
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const OnboardingView(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari catatan...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (ctx, val, child) => val.text.isNotEmpty
                      ? IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.clear_rounded,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<LogModel>>(
              future: _logFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            snapshot.error.toString().contains('internet')
                                ? Icons.wifi_off_rounded
                                : Icons.error_outline_rounded,
                            size: 80,
                            color: Colors.redAccent.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            snapshot.error.toString().contains('Exception: ')
                                ? snapshot.error.toString().replaceAll(
                                    'Exception: ',
                                    '',
                                  )
                                : 'Terjadi kesalahan saat memuat data.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _handleRefresh,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const LogEmptyState(isSearching: false);
                }

                final logs = snapshot.data!;
                final filteredLogs = logs.where((log) {
                  return log.title.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredLogs.isEmpty && _searchQuery.isNotEmpty) {
                  return const LogEmptyState(isSearching: true);
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: Theme.of(context).primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];

                      return Dismissible(
                        key: ValueKey(
                          log.id?? log.title + log.date,
                        ),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Hapus',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text('Hapus Catatan?'),
                                  content: Text(
                                    'Catatan "${log.title}" akan dihapus secara permanen.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        },
                        onDismissed: (direction) {
                          final originalIndex = logs.indexOf(log);
                          setState(() {
                            _logFuture = _controller.removeLog(originalIndex);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Catatan "${log.title}" dihapus.'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            ),
                          );
                        },
                        child: AnimatedLogCard(
                          log: log,
                          index: index,
                          onTap: () {
                            final originalIndex = logs.indexOf(log);
                            _showEditLogDialog(originalIndex, log);
                          },
                          onDelete: () async {
                            final confirm =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: const Text('Hapus Catatan?'),
                                    content: Text(
                                      'Catatan "${log.title}" akan dihapus secara permanen.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;

                            if (confirm) {
                              final originalIndex = logs.indexOf(log);
                              setState(() {
                                _logFuture = _controller.removeLog(
                                  originalIndex,
                                );
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLogDialog,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 8,
        icon: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 2 * 3.14159,
              child: const Icon(Icons.add_rounded),
            );
          },
        ),
        label: const Text(
          'Catatan Baru',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
