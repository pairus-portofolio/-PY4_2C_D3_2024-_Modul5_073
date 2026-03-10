class LoginController {
  final Map<String, String> users = {
    'admin': '123',
    'budi': '456',
    'siti': 'abc',
    'ketua': 'ketua123',
    'anggota1': 'anggota123',
    'anggota2': 'anggota123',
  };

  bool login(String username, String password) {
    if (users.containsKey(username) && users[username] == password) {
      return true;
    }
    return false;
  }
}
