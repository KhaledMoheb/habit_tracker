import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';
import '../services/habit_service.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({Key? key}) : super(key: key);

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  String name = "User";
  bool _isLoading = true;
  List<String> incompleteHabits = [];
  List<String> doneHabits = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserName();
    await _loadHabits();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUserName() async {
    final user = await LocalAuthService.getLoggedInUser();
    if (user != null) {
      setState(() {
        name = user['name'] ?? "User";
      });
    }
  }

  Future<void> _loadHabits() async {
    final habits = await HabitService.getHabits();
    setState(() {
      incompleteHabits = habits
          .where((h) => !h["done"])
          .map((h) => h["name"].toString())
          .toList();

      doneHabits = habits
          .where((h) => h["done"])
          .map((h) => h["name"].toString())
          .toList();
    });
  }

  void _addHabitDialog() {
    final TextEditingController habitController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Habit"),
        content: TextField(
          controller: habitController,
          decoration: const InputDecoration(hintText: "Enter habit name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final habitName = habitController.text.trim();
              if (habitName.isNotEmpty) {
                await HabitService.addHabit(habitName);
                _loadHabits();
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _markHabitDone(String habit) async {
    await HabitService.updateHabit(habit, true);
    _loadHabits();
  }

  void _deleteHabit(String habit) async {
    await HabitService.deleteHabit(habit);
    _loadHabits();
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

  Widget _buildTodoItem(String text, Color bgColor, {bool done = false}) {
    return Dismissible(
      key: Key(text),
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
          _markHabitDone(text);
        } else if (direction == DismissDirection.endToStart) {
          _deleteHabit(text);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text.toUpperCase(),
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
                color: Colors.blue[700],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Menu',
                  style: const TextStyle(
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Personal Info'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart),
              title: const Text('Report'),
              onTap: () => Navigator.pop(context),
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
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Welcome, $name!',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
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
                                    (habit) => _buildTodoItem(
                                      habit,
                                      Colors.deepPurple,
                                      done: false,
                                    ),
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
                                    (habit) => _buildTodoItem(
                                      habit,
                                      Colors.green,
                                      done: true,
                                    ),
                                  )
                                  .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addHabitDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
