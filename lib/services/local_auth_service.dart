// lib/services/local_auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const _usersKey = 'users';

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = json.decode(raw) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // returns true on success, false if email already exists
  static Future<bool> register(String name, String email, String password) async {
    final users = await getUsers();
    if (users.any((u) => u['email'] == email)) return false;
    users.add({'name': name, 'email': email, 'password': password});
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_usersKey, json.encode(users));
  }

  // returns user map on success, null on failure
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final users = await getUsers();
    try {
      final user = users.firstWhere((u) => u['email'] == email && u['password'] == password);
      return user;
    } catch (_) {
      return null;
    }
  }

  // helper for debugging
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
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
}
}
