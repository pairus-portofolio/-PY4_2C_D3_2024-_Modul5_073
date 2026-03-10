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
      final logs = await _mongoService.getAllLogs();

      // Update Hive with fresh data from Cloud
      await _logBox.clear();
      await _logBox.addAll(logs);

      // Sort for UI consistency
      logs.sort((a, b) => b.date.compareTo(a.date));
      logsNotifier.value = logs;
      return logs;
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
  }) async {
    final newLog = LogModel(
      id: ObjectId().oid,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      authorId: "user1",
      teamId: "team1",
      category: category,
    );

    // 1. Update UI & Hive Instantly
    logsNotifier.value = [newLog, ...logsNotifier.value];
    await _logBox.add(newLog);

    // 2. Sync to Cloud
    try {
      await _mongoService.insertLog(newLog);
    } catch (e) {
      debugPrint("Background Cloud Sync failed (Add): $e");
    }

    return logsNotifier.value;
  }

  // ✏ UPDATE LOG
  Future<List<LogModel>> updateLog(
    int index,
    String title,
    String desc, {
    String category = 'Pribadi',
  }) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      authorId: oldLog.authorId,
      teamId: oldLog.teamId,
      category: category,
    );

    // 1. Update UI & Hive Instantly
    currentLogs[index] = updatedLog;
    logsNotifier.value = currentLogs;

    final boxKey = _logBox.keys.firstWhere(
      (k) => _logBox.get(k)?.id == oldLog.id,
      orElse: () => null,
    );
    if (boxKey != null) {
      await _logBox.put(boxKey, updatedLog);
    }

    // 2. Sync to Cloud
    try {
      if (oldLog.id != null) {
        await _mongoService.deleteLog(oldLog.id!);
      }
      await _mongoService.insertLog(updatedLog);
    } catch (e) {
      debugPrint("Background Cloud Sync failed (Update): $e");
    }

    return logsNotifier.value;
  }

  // 🗑 DELETE LOG
  Future<List<LogModel>> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final log = currentLogs[index];

    // 1. Update UI & Hive Instantly
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;

    final boxKey = _logBox.keys.firstWhere(
      (k) => _logBox.get(k)?.id == log.id,
      orElse: () => null,
    );
    if (boxKey != null) {
      await _logBox.delete(boxKey);
    }

    // 2. Sync to Cloud
    try {
      if (log.id != null) {
        await _mongoService.deleteLog(log.id!);
      }
    } catch (e) {
      debugPrint("Background Cloud Sync failed (Delete): $e");
    }

    return logsNotifier.value;
  }
}
