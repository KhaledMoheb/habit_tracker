import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';
import 'habit_tracker_screen.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({Key? key}) : super(key: key);

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _habitController = TextEditingController();

  final Map<String, Color> _colorOptions = {
    'Red': Colors.red[400]!,
    'Pink': Colors.pink[400]!,
    'Green': Colors.green[600]!,
    'Blue': Colors.blue[800]!,
    'Amber': Colors.amber[400]!,
    'Orange': Colors.deepOrange[400]!,
    'Light Green': Colors.lightGreen[400]!,
  };

  String _selectedColorKey = 'Amber';
  List<Map<String, dynamic>> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final user = await LocalAuthService.getLoggedInUser();
    if (user != null) {
      setState(() {
        _habits = List<Map<String, dynamic>>.from(user['habits'] ?? []);
      });
    }
  }

  Future<void> _addHabit() async {
    final habitName = _habitController.text.trim();
    if (habitName.isEmpty) return;

    final user = await LocalAuthService.getLoggedInUser();
    if (user == null) return;

    final habits = List<Map<String, dynamic>>.from(user['habits'] ?? []);
    habits.add({'name': habitName, 'color': _selectedColorKey, 'done': false});

    user['habits'] = habits;
    await LocalAuthService.updateLoggedInUser(user);

    _habitController.clear();
    _selectedColorKey = 'Amber';

    await _loadHabits();
  }

  Future<void> _removeHabit(String habitName) async {
    final user = await LocalAuthService.getLoggedInUser();
    if (user == null) return;

    final habits = List<Map<String, dynamic>>.from(user['habits'] ?? []);
    habits.removeWhere((h) => h['name'] == habitName);

    user['habits'] = habits;
    await LocalAuthService.updateLoggedInUser(user);

    await _loadHabits();
  }

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Habits'),
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HabitTrackerScreen()),
            );
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Habit name input
            TextField(
              controller: _habitController,
              decoration: InputDecoration(
                hintText: 'Habit Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Color selector label
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Color:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 6),

            // Color dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _colorOptions[_selectedColorKey],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedColorKey,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  isExpanded: true,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedColorKey = val;
                      });
                    }
                  },
                  selectedItemBuilder: (context) {
                    return _colorOptions.keys.map((colorName) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          colorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  items: _colorOptions.keys.map((colorName) {
                    return DropdownMenuItem<String>(
                      value: colorName,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _colorOptions[colorName],
                        ),
                        child: Text(
                          colorName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Add Habit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addHabit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Add Habit',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Habits list
            Expanded(
              child: _habits.isEmpty
                  ? const Center(
                      child: Text(
                        "No habits yet. Add one above.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _habits.length,
                      itemBuilder: (context, index) {
                        final habit = _habits[index];
                        final color =
                            _colorOptions[habit["color"]] ?? Colors.grey;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  habit["name"] ?? "",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _removeHabit(habit["name"] ?? ""),
                                tooltip: 'Delete Habit',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
