import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HabitService {
  static const String _keyHabits = "habits";

  // static final List<Map<String, dynamic>> _defaultHabits = [
  //   {"name": "Workout", "color": "Red", "done": false},
  //   {"name": "Meditate", "color": "Pink", "done": false},
  //   {"name": "Read a Book", "color": "Green", "done": false},
  //   {"name": "Drink Water", "color": "Blue", "done": false},
  //   {"name": "Practice Gratitude", "color": "Amber", "done": false},
  //   {"name": "Wake Up Early", "color": "Orange", "done": false},
  //   {"name": "Journal", "color": "Light Green", "done": false},
  // ];

  static final List<Map<String, dynamic>> _defaultHabits = [];

  static Future<List<Map<String, dynamic>>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyHabits);

    if (jsonString == null || jsonString.isEmpty) {
      // Save defaults if nothing exists
      await _saveHabits(_defaultHabits);
      return List<Map<String, dynamic>>.from(_defaultHabits);
    }

    final List decoded = json.decode(jsonString);
    return List<Map<String, dynamic>>.from(decoded);
  }

  static Future<void> _saveHabits(List<Map<String, dynamic>> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(habits);
    await prefs.setString(_keyHabits, jsonString);
  }

  static Future<void> addHabit(
    String habit, {
    String color = "Purple",
    bool done = false,
  }) async {
    final habits = await getHabits();
    habits.add({"name": habit, "color": color, "done": done});
    await _saveHabits(habits);
  }

  static Future<void> updateHabit(String habit, bool done) async {
    final habits = await getHabits();
    final index = habits.indexWhere((h) => h["name"] == habit);
    if (index != -1) {
      habits[index]["done"] = done;
      await _saveHabits(habits);
    }
  }

  static Future<void> deleteHabit(String habit) async {
    final habits = await getHabits();
    habits.removeWhere((h) => h["name"] == habit);
    await _saveHabits(habits);
  }

  static Future<void> clearHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHabits);
  }
}
