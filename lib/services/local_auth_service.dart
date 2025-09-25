import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const _nameKey = 'name';
  static const _usernameKey = 'username';
  static const _passwordKey = 'password';
  static const _ageKey = 'age';
  static const _countryKey = 'country';
  static const _selectedHabitsKey = 'selectedHabitsMap';
  static const _completedHabitsKey = 'completedHabitsMap';

  /// Register (replace existing user data)
  static Future<void> register({
    required String name,
    required String username,
    required String password,
    required int age,
    required String country,
    List<Map<String, dynamic>>? selectedHabits,
    List<Map<String, dynamic>>? completedHabits,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_passwordKey, password);
    await prefs.setInt(_ageKey, age);
    await prefs.setString(_countryKey, country);
    await prefs.setString(
      _selectedHabitsKey,
      json.encode(selectedHabits ?? []),
    );
    await prefs.setString(
      _completedHabitsKey,
      json.encode(completedHabits ?? []),
    );
  }

  /// Login with username
  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString(_usernameKey);
    final storedPassword = prefs.getString(_passwordKey);

    // If no user exists → seed default user
    if (storedUsername == null || storedPassword == null) {
      await register(
        name: 'Test User',
        username: 'testuser',
        password: 'password123',
        age: 25,
        country: 'Australia',
        selectedHabits: [],
        completedHabits: [],
      );
      return await getLoggedInUser();
    }

    if (username == storedUsername && password == storedPassword) {
      return await getLoggedInUser();
    }

    return null;
  }

  /// Get current user profile
  static Future<Map<String, dynamic>> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_nameKey),
      'username': prefs.getString(_usernameKey),
      'password': prefs.getString(_passwordKey),
      'age': prefs.getInt(_ageKey),
      'country': prefs.getString(_countryKey),
      'selectedHabits': json.decode(
        prefs.getString(_selectedHabitsKey) ?? '[]',
      ),
      'completedHabits': json.decode(
        prefs.getString(_completedHabitsKey) ?? '[]',
      ),
    };
  }

  // /// Update selected habits
  // static Future<void> updateSelectedHabits(
  //   List<Map<String, dynamic>> habits,
  // ) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(_selectedHabitsKey, json.encode(habits));
  // }

  // /// Update completed habits
  // static Future<void> updateCompletedHabits(
  //   List<Map<String, dynamic>> habits,
  // ) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(_completedHabitsKey, json.encode(habits));
  // }

  // Logout
  static Future<void> logout() async {
    await clear();
  }

  /// Clear all user data
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> updateLoggedInUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, user['name']);
    await prefs.setString(_usernameKey, user['username']);
    await prefs.setString(_passwordKey, user['password']);
    await prefs.setInt(_ageKey, user['age']);
    await prefs.setString(_countryKey, user['country']);
    await prefs.setString(
      _selectedHabitsKey,
      json.encode(user['selectedHabits'] ?? []),
    );
    await prefs.setString(
      _completedHabitsKey,
      json.encode(user['completedHabits'] ?? []),
    );
  }
}
