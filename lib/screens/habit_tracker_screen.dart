import 'package:flutter/material.dart';
import 'package:habitt_app/screens/personal_info_screen.dart';
import 'package:habitt_app/screens/reports_screen.dart';
import 'package:habitt_app/services/habit_service.dart';
import '../services/local_auth_service.dart';

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({Key? key}) : super(key: key);

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  String name = "User";
  bool _isLoading = true;
  List<Map<String, dynamic>> incompleteHabits = [];
  List<Map<String, dynamic>> doneHabits = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = await LocalAuthService.getLoggedInUser();
    final selected = await HabitService.getSelectedHabits();
    final completed = await HabitService.getCompletedHabits();

    if (user != null) {
      setState(() {
        name = user['name'] ?? "User";
        incompleteHabits = selected;
        doneHabits = completed;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _markHabitDone(String habit) async {
    final selected = await HabitService.getSelectedHabits();
    final completed = await HabitService.getCompletedHabits();

    final index = selected.indexWhere((h) => h["name"] == habit);
    if (index != -1) {
      final moved = selected.removeAt(index);
      completed.add(moved);

      // Save updates
      await HabitService.saveSelectedHabits(selected);
      await HabitService.saveCompletedHabits(completed);

      // Update today's completion (example: use DateTime weekday → 1–7, shift to 0–6)
      final today = DateTime.now().weekday - 1;
      await HabitService.completeHabitForDay(habit, today);

      await _initialize();
    }
  }

  Future<void> _deleteHabit(String habit) async {
    await HabitService.deleteHabit(habit);
    await _initialize();
  }

  Color _getColorFromName(String colorName) {
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

  Widget _buildSectionTitle(String text, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ...items,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTodoItem(Map<String, dynamic> habit, {bool done = false}) {
    final String name = habit["name"] ?? "";
    final String colorName = habit["color"] ?? "Purple";

    return Dismissible(
      key: Key(name),
      background: done
          ? Container()
          : Container(
              color: Colors.green,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.check, color: Colors.white),
            ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: done
          ? DismissDirection.endToStart
          : DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd && !done) {
          _markHabitDone(name);
        } else if (direction == DismissDirection.endToStart) {
          _deleteHabit(name);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _getColorFromName(colorName),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          name.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configure'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/configure');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Personal Info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sign Out'),
              onTap: () async {
                await LocalAuthService.logout();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Welcome, $name!',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSectionTitle(
                        'To Do 📝',
                        incompleteHabits.isEmpty
                            ? [
                                const Text(
                                  "Use the + button to create some habits!",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ]
                            : incompleteHabits
                                  .map(
                                    (habit) =>
                                        _buildTodoItem(habit, done: false),
                                  )
                                  .toList(),
                      ),
                      _buildSectionTitle(
                        'Done ✅ 🎉',
                        doneHabits.isEmpty
                            ? [
                                const Text(
                                  "Swipe left on an activity to delete it.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ]
                            : doneHabits
                                  .map(
                                    (habit) =>
                                        _buildTodoItem(habit, done: true),
                                  )
                                  .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/configure'),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
