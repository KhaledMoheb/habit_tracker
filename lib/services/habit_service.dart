import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class HabitService {
  static const String _selectedHabitsKey = "selectedHabitsMap";
  static const String _completedHabitsKey = "completedHabitsMap";
  static const String _weeklyDataKey = "weeklyData";

  /// -------------------------
  /// Selected & Completed Habits
  /// -------------------------

  static Future<List<Map<String, dynamic>>> getSelectedHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_selectedHabitsKey);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = json.decode(raw);
    return List<Map<String, dynamic>>.from(decoded);
  }

  static Future<List<Map<String, dynamic>>> getCompletedHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_completedHabitsKey);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = json.decode(raw);
    return List<Map<String, dynamic>>.from(decoded);
  }

  static Future<void> saveSelectedHabits(
    List<Map<String, dynamic>> habits,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedHabitsKey, json.encode(habits));
  }

  static Future<void> saveCompletedHabits(
    List<Map<String, dynamic>> habits,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_completedHabitsKey, json.encode(habits));
  }

  /// -------------------------
  /// Habit Operations
  /// -------------------------

  static Future<void> addHabit(String habit, {String color = "Purple"}) async {
    final habits = await getSelectedHabits();
    habits.add({"name": habit, "color": color});
    await saveSelectedHabits(habits);

    // Ensure every habit has weeklyData initialized
    final data = await getWeeklyData();
    for (var h in habits) {
      final name = h["name"] as String;
      if (!data.containsKey(name)) {
        data[name] = List.filled(7, 0); // Mon–Sun = 0
      }
    }
    await _saveWeeklyData(data);
  }

  static Future<void> completeHabitForDay(
    String habit,
    int dayIndex, // 0 = Mon … 6 = Sun
  ) async {
    final data = await getWeeklyData();
    if (!data.containsKey(habit)) {
      data[habit] = List.filled(7, 0);
    }
    data[habit]![dayIndex] = 1;
    await _saveWeeklyData(data);
  }

  static Future<void> resetHabitForDay(String habit, int dayIndex) async {
    final data = await getWeeklyData();
    if (!data.containsKey(habit)) return;
    data[habit]![dayIndex] = 0;
    await _saveWeeklyData(data);
  }

  static Future<void> deleteHabit(String habit) async {
    final selected = await getSelectedHabits();
    final completed = await getCompletedHabits();

    selected.removeWhere((h) => h["name"] == habit);
    completed.removeWhere((h) => h["name"] == habit);

    await saveSelectedHabits(selected);
    await saveCompletedHabits(completed);

    // Also remove from weeklyData
    final data = await getWeeklyData();
    data.remove(habit);
    await _saveWeeklyData(data);
  }

  static Future<void> clearAllHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedHabitsKey);
    await prefs.remove(_completedHabitsKey);
    await prefs.remove(_weeklyDataKey);
  }

  /// -------------------------
  /// Weekly Data
  /// -------------------------

  static Future<Map<String, List<int>>> getWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_weeklyDataKey);
    Map<String, List<int>> data = {};

    if (raw != null && raw.isNotEmpty) {
      final Map<String, dynamic> decoded = json.decode(raw);
      data = decoded.map((key, value) => MapEntry(key, List<int>.from(value)));
    }

    // Ensure all current habits exist in weeklyData
    final habits = await getSelectedHabits();
    for (var h in habits) {
      final name = h["name"] as String;
      data.putIfAbsent(name, () => List.filled(7, 0));
    }

    await _saveWeeklyData(data);
    return data;
  }

  static Future<void> _saveWeeklyData(Map<String, List<int>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weeklyDataKey, json.encode(data));
  }

  static Color getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case "green":
        return Colors.green;
      case "blue":
        return Colors.blue;
      case "red":
        return Colors.red;
      case "orange":
        return Colors.orange;
      case "yellow":
        return Colors.yellow;
      case "purple":
        return Colors.purple;
      case "amber":
        return Colors.amber;
      case "teal":
        return Colors.teal;
      case "pink":
        return Colors.pink;
      case "cyan":
        return Colors.cyan;
      case "indigo":
        return Colors.indigo;
      default:
        return Colors.deepPurple;
    }
  }
}
