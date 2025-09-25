import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HabitService {
  static const String _selectedHabitsKey = "selectedHabitsMap";
  static const String _completedHabitsKey = "completedHabitsMap";

  /// Get all selected (incomplete) habits
  static Future<List<Map<String, dynamic>>> getSelectedHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_selectedHabitsKey);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = json.decode(raw);
    return List<Map<String, dynamic>>.from(decoded);
  }

  /// Get all completed habits
  static Future<List<Map<String, dynamic>>> getCompletedHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_completedHabitsKey);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = json.decode(raw);
    return List<Map<String, dynamic>>.from(decoded);
  }

  /// Save selected habits
  static Future<void> _saveSelectedHabits(
    List<Map<String, dynamic>> habits,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedHabitsKey, json.encode(habits));
  }

  /// Save completed habits
  static Future<void> _saveCompletedHabits(
    List<Map<String, dynamic>> habits,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_completedHabitsKey, json.encode(habits));
  }

  /// Add new habit (to selected list)
  static Future<void> addHabit(String habit, {String color = "Purple"}) async {
    final habits = await getSelectedHabits();
    habits.add({"name": habit, "color": color});
    await _saveSelectedHabits(habits);
  }

  /// Mark habit as done: move from selected → completed
  static Future<void> completeHabit(String habit) async {
    final selected = await getSelectedHabits();
    final completed = await getCompletedHabits();

    final index = selected.indexWhere((h) => h["name"] == habit);
    if (index != -1) {
      final habitData = selected.removeAt(index);
      completed.add(habitData);
      await _saveSelectedHabits(selected);
      await _saveCompletedHabits(completed);
    }
  }

  /// Delete habit from either list
  static Future<void> deleteHabit(String habit) async {
    final selected = await getSelectedHabits();
    final completed = await getCompletedHabits();

    selected.removeWhere((h) => h["name"] == habit);
    completed.removeWhere((h) => h["name"] == habit);

    await _saveSelectedHabits(selected);
    await _saveCompletedHabits(completed);
  }

  /// Clear all habits
  static Future<void> clearAllHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedHabitsKey);
    await prefs.remove(_completedHabitsKey);
  }
}
