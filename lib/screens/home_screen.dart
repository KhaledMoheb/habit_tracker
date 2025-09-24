import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = "User";
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadUserName();
      _isLoading = false;
    }
  }

  Future<void> _loadUserName() async {
    final users = await LocalAuthService.getUsers();
    if (users.isNotEmpty) {
      setState(() {
        name = users[0]['name'] ?? "User";
      });
    }
  }

  Widget _buildSectionTitle(String text, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textAlign: TextAlign.center, 
        ),
        const SizedBox(height: 10),
        ...items,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTodoItem(String text, Color bgColor) {
    return Container(
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
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                'To Do ✅ 📝',
                [
                  _buildTodoItem('Wake Up Early', Colors.deepPurple),
                  _buildTodoItem('Meditate', Colors.teal),
                  _buildTodoItem('Read a Book', Colors.indigo),
                ],
              ),
              _buildSectionTitle(
                'Done ✅ 🎉',
                [
                  _buildTodoItem('Walk 10,000 Steps', Colors.pinkAccent),
                  _buildTodoItem('Drink Water', Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
