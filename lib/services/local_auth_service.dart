import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const _usersKey = 'users';
  static const _loggedInUserKey = 'loggedInUser';

  // Fetch all users
  static Future<List<Map<String, dynamic>>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = json.decode(raw);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Register user with full profile
  static Future<bool> register(
    String name,
    String email,
    String password, {
    int? age,
    String? country,
    List<Map<String, dynamic>>? habits,
  }) async {
    final users = await getUsers();
    if (users.any((u) => u['email'] == email || u['name'] == name)) {
      return false;
    }

    users.add({
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'country': country,
      'habits': habits ?? [],
    });

    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_usersKey, json.encode(users));
  }

  // Login
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

  // Save current logged-in user
  static Future<void> _setLoggedInUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedInUserKey, json.encode(user));
  }

  // Get logged-in user
  static Future<Map<String, dynamic>?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_loggedInUserKey);
    if (raw == null || raw.isEmpty) return null;
    return Map<String, dynamic>.from(json.decode(raw));
  }

  // Update logged-in user's profile and persist it
  static Future<void> updateLoggedInUser(
    Map<String, dynamic> updatedUser,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();

    final index = users.indexWhere((u) => u['email'] == updatedUser['email']);
    if (index != -1) {
      users[index] = updatedUser;
      await prefs.setString(_usersKey, json.encode(users));
    }
    await prefs.setString(_loggedInUserKey, json.encode(updatedUser));
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserKey);
  }

  // Clear all users
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_loggedInUserKey);
  }

  // Seed test users with habits
  static Future<void> seedTestUser() async {
    final users = await getUsers();
    if (!users.any((u) => u['email'] == 'user1@test.com')) {
      users.add({
        'name': 'Test User',
        'email': 'user1@test.com',
        'password': '123456',
        'age': 25,
        'country': 'United States',
        'habits': [
          {'name': 'Workout', 'color': 'Red', 'done': false},
          {'name': 'Drink Water', 'color': 'Blue', 'done': false},
        ],
      });
    }
    if (!users.any((u) => u['email'] == 'testuser@test.com')) {
      users.add({
        'name': 'testuser',
        'email': 'testuser@test.com',
        'password': 'password123',
        'age': 30,
        'country': 'India',
        'habits': [
          {'name': 'Meditate', 'color': 'Purple', 'done': false},
          {'name': 'Read a Book', 'color': 'Green', 'done': false},
        ],
      });
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, json.encode(users));
  }
}
