import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/habit_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _enabled = false;
  Set<String> _selectedHabits = {};
  Set<String> _selectedTimes = {};

  Map<String, String> _habits = {};
  bool _isLoadingHabits = true;

  final List<String> times = ["Morning", "Afternoon", "Evening"];
  String _webPermission = "unknown";

  static const _prefsEnabledKey = "notifications_enabled";
  static const _prefsHabitsKey = "notifications_habits";
  static const _prefsTimesKey = "notifications_times";

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadHabits();
    _checkPermission();
  }

  Future<void> _loadHabits() async {
    final selectedHabits = await HabitService.getSelectedHabits();
    final mapped = {
      for (var h in selectedHabits)
        h["name"] as String: h["color"] as String? ?? "Blue",
    };
    setState(() {
      _habits = mapped;
      _isLoadingHabits = false;
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = prefs.getBool(_prefsEnabledKey) ?? false;
      _selectedHabits = (prefs.getStringList(_prefsHabitsKey) ?? []).toSet();
      _selectedTimes = (prefs.getStringList(_prefsTimesKey) ?? []).toSet();
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsEnabledKey, _enabled);
    await prefs.setStringList(_prefsHabitsKey, _selectedHabits.toList());
    await prefs.setStringList(_prefsTimesKey, _selectedTimes.toList());
  }

  void _toggleEnabled(bool val) async {
    setState(() => _enabled = val);
    await _savePrefs();
    if (!val) NotificationService.cancelAllNotifications();
  }

  void _toggleHabit(String habit, bool selected) async {
    setState(() {
      if (selected) {
        _selectedHabits.add(habit);
      } else {
        _selectedHabits.remove(habit);
      }
    });
    await _savePrefs();
  }

  void _toggleTime(String time, bool selected) async {
    setState(() {
      if (selected) {
        _selectedTimes.add(time);
      } else {
        _selectedTimes.remove(time);
      }
    });
    await _savePrefs();
  }

  Future<void> _checkPermission() async {
    final status = await NotificationService.checkWebPermission();
    setState(() {
      _webPermission = status;
    });
  }

  Widget _permissionIndicator() {
    Color color;
    IconData icon;
    switch (_webPermission) {
      case "granted":
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case "denied":
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text("Permission: $_webPermission"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text("Notifications"),
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enable Notifications Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Enable Notifications",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Switch(value: _enabled, onChanged: _toggleEnabled),
              ],
            ),
            const Divider(height: 30),

            // Habits
            const Text(
              "Select Habits for Notification",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _isLoadingHabits
                ? const Center(child: CircularProgressIndicator())
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _habits.entries.map((entry) {
                      final habit = entry.key;
                      final colorName = entry.value;
                      final habitColor = HabitService.getColorFromName(
                        colorName,
                      );
                      final selected = _selectedHabits.contains(habit);

                      return ChoiceChip(
                        label: Text(
                          habit,
                          style: TextStyle(
                            color: selected ? Colors.white : habitColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: selected,
                        selectedColor: habitColor,
                        backgroundColor: Colors.white,
                        shape: StadiumBorder(
                          side: BorderSide(color: habitColor, width: 2),
                        ),
                        onSelected: (val) => _toggleHabit(habit, val),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 20),

            // Times
            const Text(
              "Select Times for Notification",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: times.map((time) {
                final selected = _selectedTimes.contains(time);
                return ChoiceChip(
                  label: Text(
                    time,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.blue.shade700,
                    ),
                  ),
                  selected: selected,
                  selectedColor: Colors.blue.shade600,
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(color: Colors.blue.shade700, width: 2),
                  ),
                  onSelected: (val) => _toggleTime(time, val),
                );
              }).toList(),
            ),
            const Spacer(),

            // Permission indicator
            _permissionIndicator(),
            const SizedBox(height: 20),

            // Enable Web Notifications Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  await NotificationService.requestWebPermission();
                  await _checkPermission();
                },
                child: const Text(
                  "Enable Web Notifications",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Test Notification Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _enabled
                    ? () async {
                        await NotificationService.showTestNotification();
                        await _checkPermission();
                      }
                    : null,
                child: const Text(
                  "Send Test Notification",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
