// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/local_auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  double _age = 25;
  String _selectedCountry = 'United States';
  bool _loading = false;

  final List<String> _countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'India',
    'Germany',
    'France',
    'Japan',
    'China',
    'Brazil',
    'South Africa',
  ];

  final Map<String, bool> _habits = {
    'Wake Up Early': false,
    'Workout': false,
    'Drink Water': false,
    'Meditate': false,
    'Read a Book': false,
    'Practice Gratitude': false,
    'Sleep 8 Hours': false,
    'Eat Healthy': false,
    'Journal': false,
    'Walk 10,000 Steps': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter email';
    final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return re.hasMatch(v) ? null : 'Enter a valid email';
  }

  void _toggleHabit(String habit) {
    setState(() {
      _habits[habit] = !_habits[habit]!;
    });
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      _showToast('Please fill all fields');
      return;
    }

    final emailError = _validateEmail(_emailController.text);
    if (emailError != null) {
      _showToast(emailError);
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      _showToast('Passwords do not match');
      return;
    }

    setState(() => _loading = true);
    final success = await LocalAuthService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    setState(() => _loading = false);

    if (success) {
      _showToast('Account created. Please login.', isError: false);
      Navigator.pop(context);
    } else {
      _showToast('An account with that email already exists');
    }
  }

  void _showToast(String msg, {bool isError = true}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(controller: _nameController, hint: 'Full Name'),
            const SizedBox(height: 15),
            _buildTextField(controller: _emailController, hint: 'Email'),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _passwordController,
              hint: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _confirmController,
              hint: 'Confirm Password',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Text(
              'Age ${_age.toInt()}',
              style: const TextStyle(color: Colors.white),
            ),
            Slider(
              value: _age,
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: Colors.grey[200],
              inactiveColor: Colors.grey[400],
              onChanged: (value) => setState(() => _age = value),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  value: _selectedCountry,
                  items: _countries
                      .map(
                        (country) => DropdownMenuItem(
                          value: country,
                          child: Text(
                            country,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCountry = value!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select your habits',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _habits.keys.map((habit) {
                final isSelected = _habits[habit]!;
                return ElevatedButton(
                  onPressed: () => _toggleHabit(habit),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    elevation: 0,
                    backgroundColor: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.8),
                    foregroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    habit,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.blue[700],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 150,
                height: 45,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[500],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
