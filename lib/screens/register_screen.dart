import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:habitt_app/consts/country_list.dart';
import '../services/local_auth_service.dart';
import 'habit_tracker_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  double _age = 25;
  List<String> _countries = [];
  bool _loadingCountries = true;
  String _selectedCountry = "";
  bool _loading = false;

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

  final Map<String, String> _habitColors = {
    'Wake Up Early': 'Orange',
    'Workout': 'Red',
    'Drink Water': 'Blue',
    'Meditate': 'Purple',
    'Read a Book': 'Green',
    'Practice Gratitude': 'Amber',
    'Sleep 8 Hours': 'Teal',
    'Eat Healthy': 'Pink',
    'Journal': 'Cyan',
    'Walk 10,000 Steps': 'Indigo',
  };

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      List<String> countries = await fetchCountries();
      setState(() {
        _countries = countries;
        _selectedCountry = _countries.first;
        _loadingCountries = false;
      });
    } catch (e) {
      _showToast('Error fetching countries');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty) {
      _showToast('Name is required');
      return;
    }
    if (_usernameController.text.trim().isEmpty) {
      _showToast('Username is required');
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

    final selectedHabits = _habits.entries
        .where((entry) => entry.value == true)
        .map(
          (entry) => {
            'name': entry.key,
            'color': _habitColors[entry.key] ?? 'Amber',
          },
        )
        .toList();

    setState(() => _loading = true);

    await LocalAuthService.register(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      age: _age.round(),
      country: _selectedCountry,
      selectedHabits: selectedHabits,
      completedHabits: [],
    );

    setState(() => _loading = false);

    _showToast('Account created successfully', isError: false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HabitTrackerScreen()),
    );
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
                _buildInputField(
                  _usernameController,
                  'Username',
                  Icons.alternate_email,
                ),
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
                _loadingCountries
                    ? const CircularProgressIndicator()
                    : _buildCountryDropdown(),
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
                      onTap: () => setState(() {
                        _habits[habit] = !isSelected;
                      }),
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
}
