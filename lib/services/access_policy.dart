import '../features/logbook/models/log_model.dart';

class AccessPolicy {
  // Hanya pembuat yang boleh edit (Sovereignty)
  static bool canEdit({required String userId, required String logAuthorId}) {
    return userId == logAuthorId;
  }

  // Hanya pembuat yang boleh delete (Sovereignty)
  static bool canDelete({required String userId, required String logAuthorId}) {
    return userId == logAuthorId;
  }

  // Siapa yang boleh melihat catatan ini (Visibility)
  static bool canView({required LogModel log, required String currentUserId}) {
    // Pemilik selalu bisa lihat
    if (log.authorId == currentUserId) return true;

    // Orang lain (anggota/ketua) bisa lihat jika publik
    return log.isPublic;
  }
}
