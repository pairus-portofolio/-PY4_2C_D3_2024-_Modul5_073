class AccessControlService {
  static bool canEdit({
    required String userId,
    required String role,
    required String logAuthorId,
  }) {
    // Ketua boleh edit semua
    if (role == "ketua") {
      return true;
    }

    // Owner boleh edit log sendiri
    if (userId == logAuthorId) {
      return true;
    }

    return false;
  }

  static bool canDelete({required String role}) {
    // hanya ketua yang boleh delete
    if (role == "ketua") {
      return true;
    }

    return false;
  }
}
