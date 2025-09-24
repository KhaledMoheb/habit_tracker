import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HabitService {
  static const String _keyHabits = "habits";

  // Get all habits from local storage
  static Future<List<Map<String, dynamic>>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyHabits);
    if (jsonString == null || jsonString.isEmpty) return [];
    final List decoded = json.decode(jsonString);
    return List<Map<String, dynamic>>.from(decoded);
  }

  // Save all habits to local storage
  static Future<void> _saveHabits(List<Map<String, dynamic>> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(habits);
    await prefs.setString(_keyHabits, jsonString);
  }

  // Create habit
  static Future<void> addHabit(String habit, {bool done = false}) async {
    final habits = await getHabits();
    habits.add({"name": habit, "done": done});
    await _saveHabits(habits);
  }

  // Update habit status
  static Future<void> updateHabit(String habit, bool done) async {
    final habits = await getHabits();
    final index = habits.indexWhere((h) => h["name"] == habit);
    if (index != -1) {
      habits[index]["done"] = done;
      await _saveHabits(habits);
    }
  }

  // Delete habit
  static Future<void> deleteHabit(String habit) async {
    final habits = await getHabits();
    habits.removeWhere((h) => h["name"] == habit);
    await _saveHabits(habits);
  }

  // Clear all habits
  static Future<void> clearHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHabits);
  }
}
