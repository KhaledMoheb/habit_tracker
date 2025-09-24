// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/local_auth_service.dart';
import 'home_screen.dart';

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
    if (_nameController.text.trim().isEmpty) {
      _showToast('Name is required');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showToast('Email is required');
      return;
    }

    final emailError = _validateEmail(_emailController.text);
    if (emailError != null) {
      _showToast(emailError);
      return;
    }

    if (_passwordController.text.isEmpty || _confirmController.text.isEmpty) {
      _showToast('Password and Confirm Password are required');
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
      _showToast('Account created successfully', isError: false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
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

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButton<String>(
        value: _selectedCountry,
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
        isExpanded: true,
        underline: const SizedBox(),
        items: _countries.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedCountry = newValue!;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          'Register',
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(_nameController, 'Full Name', Icons.person),
                const SizedBox(height: 10),
                _buildInputField(_emailController, 'Email', Icons.email),
                const SizedBox(height: 10),
                _buildInputField(
                  _passwordController,
                  'Password',
                  Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  _confirmController,
                  'Confirm Password',
                  Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                Text(
                  'Age: ${_age.round()}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Slider(
                  value: _age,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  activeColor: Colors.blue.shade600,
                  inactiveColor: Colors.blue.shade300,
                  onChanged: (double value) => setState(() => _age = value),
                ),
                const SizedBox(height: 10),
                _buildCountryDropdown(),
                const SizedBox(height: 20),
                const Text(
                  'Select Your Habits',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _habits.keys.map((habit) {
                    final isSelected = _habits[habit]!;
                    return GestureDetector(
                      onTap: () => _toggleHabit(habit),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade600
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade700),
                        ),
                        child: Text(
                          habit,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 15,
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
