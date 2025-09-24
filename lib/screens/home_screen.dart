import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';
import '../services/habit_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          ? Container() // Empty container to avoid null error
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
          ? DismissDirection
                .endToStart // Only allow swipe left for done items
          : DismissDirection.horizontal, // Allow both for incomplete habits
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
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: Text(
          'Welcome, $name!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await LocalAuthService.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
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
                                  "Swipe right on an activity to mark as done.",
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
