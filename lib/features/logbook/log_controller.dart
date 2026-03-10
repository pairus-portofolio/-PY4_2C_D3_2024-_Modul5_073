import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import '../../../services/mongo_service.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final MongoService _mongoService = MongoService();
  final Box<LogModel> _logBox = Hive.box<LogModel>('offline_logs');

  LogController();

  // 🔌 INIT DATABASE
  Future<List<LogModel>> init() async {
    // 1. Load from Hive FIRST for instant UI
    loadFromLocal();

    try {
      // 2. Connect to Mongo and refresh
      await _mongoService.connect();
      // 🚀 Sync data yang tertunda segera setelah login/terhubung
      await syncPendingLogs();
      return await loadFromCloud();
    } catch (e) {
      // If offline, just return local data
      debugPrint("Init Offline Mode: $e");
      return logsNotifier.value;
    }
  }

  // 📥 LOAD DATA FROM LOCAL (HIVE)
  void loadFromLocal() {
    final logs = _logBox.values.toList();
    // Sort by date descending (newest first)
    logs.sort((a, b) => b.date.compareTo(a.date));
    logsNotifier.value = logs;
  }

  // 📥 LOAD DATA FROM ATLAS
  Future<List<LogModel>> loadFromCloud() async {
    try {
      final cloudLogs = await _mongoService.getAllLogs();

      // 🛑 JANGAN PAKAI clear() sembarangan!
      // Kita ambil data lokal yang belum sempat tersinkron
      final pendingLogs = _logBox.values.where((l) => !l.isSynced).toList();

      // Bersihkan hanya data yang SUDAH tersinkron (agar data cloud yang baru masuk)
      final keysToDelete = _logBox.keys.where((key) {
        final log = _logBox.get(key);
        return log != null && log.isSynced;
      }).toList();

      for (var key in keysToDelete) {
        await _logBox.delete(key);
      }

      // Masukkan data cloud baru ke Hive
      for (var cloudLog in cloudLogs) {
        // Cek apakah data ini sudah ada di pending (lokal lebih baru)
        bool isPendingLocally = pendingLogs.any((l) => l.id == cloudLog.id);
        if (!isPendingLocally) {
          await _logBox.add(cloudLog);
        }
      }

      // Gabungkan untuk UI
      final allLogs = _logBox.values.toList();
      allLogs.sort((a, b) => b.date.compareTo(a.date));
      logsNotifier.value = allLogs;

      return allLogs;
    } catch (e) {
      debugPrint("Load from Cloud failed: $e");
      return logsNotifier.value;
    }
  }

  // ➕ ADD LOG
  Future<List<LogModel>> addLog(
    String title,
    String desc, {
    String category = 'Pribadi',
    required String authorId,
  }) async {
    final newLog = LogModel(
      id: ObjectId().oid,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      authorId: authorId,
      teamId: "team1",
      category: category,
      isSynced: false,
    );

    // 1. Simpan Lokal
    await _logBox.add(newLog);
    logsNotifier.value = [newLog, ...logsNotifier.value];

    // 2. Sync Atlas (Async)
    _syncToAtlas(newLog, isNew: true);

    return logsNotifier.value;
  }

  // 📝 UPDATE LOG
  Future<List<LogModel>> updateLog(
    int index,
    String title,
    String desc, {
    String category = 'Pribadi',
  }) async {
    final oldLog = logsNotifier.value[index];
    final updatedLog = oldLog.copyWith(
      title: title,
      description: desc,
      category: category,
      isSynced: false,
    );

    // 1. Update Lokal
    final boxKey = _logBox.keys.firstWhere(
      (k) => _logBox.get(k)?.id == oldLog.id,
      orElse: () => null,
    );
    if (boxKey != null) {
      await _logBox.put(boxKey, updatedLog);
    } else {
      await _logBox.putAt(index, updatedLog);
    }

    List<LogModel> currentLogs = List.from(logsNotifier.value);
    currentLogs[index] = updatedLog;
    logsNotifier.value = currentLogs;

    // 2. Sync Atlas (Async)
    _syncToAtlas(updatedLog, isNew: false);

    return logsNotifier.value;
  }

  // 🔄 Internal Sync
  Future<void> _syncToAtlas(LogModel log, {required bool isNew}) async {
    try {
      if (isNew) {
        await _mongoService.insertLog(log);
      } else {
        await _mongoService.updateLog(log.id!, log);
      }

      // Berhasil -> Update status isSynced
      final boxKey = _logBox.keys.firstWhere(
        (k) => _logBox.get(k)?.id == log.id,
        orElse: () => null,
      );
      if (boxKey != null) {
        final syncedLog = log.copyWith(isSynced: true);
        await _logBox.put(boxKey, syncedLog);

        // Update UI jika masih ada di list
        List<LogModel> currentLogs = List.from(logsNotifier.value);
        int uiIndex = currentLogs.indexWhere((l) => l.id == log.id);
        if (uiIndex != -1) {
          currentLogs[uiIndex] = syncedLog;
          logsNotifier.value = currentLogs;
        }
      }
    } catch (e) {
      debugPrint("Atlas Sync Error: $e");
    }
  }

  // ☁️ Sinkronisasi yang tertunda
  Future<void> syncPendingLogs() async {
    final pending = _logBox.values.where((l) => !l.isSynced).toList();
    for (var log in pending) {
      await _syncToAtlas(log, isNew: false);
    }
  }

  // 🗑 DELETE LOG
  Future<List<LogModel>> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final log = currentLogs[index];

    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;

    final boxKey = _logBox.keys.firstWhere(
      (k) => _logBox.get(k)?.id == log.id,
      orElse: () => null,
    );
    if (boxKey != null) {
      await _logBox.delete(boxKey);
    }

    try {
      if (log.id != null) {
        await _mongoService.deleteLog(log.id!);
      }
    } catch (e) {
      debugPrint("Delete Atlas Error: $e");
    }

    return logsNotifier.value;
  }
}
