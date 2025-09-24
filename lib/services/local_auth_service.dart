import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const _usersKey = 'users';
  static const _loggedInUserKey = 'loggedInUser';

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = json.decode(raw) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    final users = await getUsers();
    if (users.any((u) => u['email'] == email || u['name'] == name))
      return false;
    users.add({'name': name, 'email': email, 'password': password});
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_usersKey, json.encode(users));
  }

  static Future<Map<String, dynamic>?> login(
    String usernameOrEmail,
    String password,
  ) async {
    final users = await getUsers();
    try {
      final user = users.firstWhere(
        (u) =>
            (u['email'] == usernameOrEmail || u['name'] == usernameOrEmail) &&
            u['password'] == password,
      );
      await _setLoggedInUser(user);
      return user;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _setLoggedInUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedInUserKey, json.encode(user));
  }

  static Future<Map<String, dynamic>?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_loggedInUserKey);
    if (raw == null || raw.isEmpty) return null;
    return Map<String, dynamic>.from(json.decode(raw));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_loggedInUserKey);
  }

  static Future<void> seedTestUser() async {
    final users = await getUsers();
    if (!users.any((u) => u['email'] == 'user1@test.com')) {
      users.add({
        'name': 'Test User',
        'email': 'user1@test.com',
        'password': '123456',
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usersKey, json.encode(users));
    }
    if (!users.any((u) => u['email'] == 'testuser@test.com')) {
      users.add({
        'name': 'testuser',
        'email': 'testuser@test.com',
        'password': 'password123',
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usersKey, json.encode(users));
    }
  }
}
