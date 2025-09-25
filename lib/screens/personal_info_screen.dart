import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:habitt_app/consts/country_list.dart';
import 'package:habitt_app/services/local_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();

  double _age = 25;
  String _country = 'United States';
  bool _loadingCountries = true;
  List<String> _countries = [];

  @override
  void initState() {
    super.initState();
    _loadCountries().then((_) {
      _loadUserData();
    });
  }

  Future<void> _loadCountries() async {
    try {
      List<String> countries = await fetchCountries();
      setState(() {
        _countries = countries;
        _loadingCountries = false;
      });
    } catch (e) {
      _showToast('Error fetching countries');
    }
  }

  Future<void> _loadUserData() async {
    final user = await LocalAuthService.getLoggedInUser();
    setState(() {
      _nameController.text = user['name'];
      _usernameController.text = user['username'] ?? '';
      _age = user['age'] ?? 25;
      _country = user['country'] ?? 'United States';
    });
  }

  Future<void> _saveUserData() async {
    final user = await LocalAuthService.getLoggedInUser();

    user['name'] = _nameController.text.trim();
    user['username'] = _usernameController.text.trim();
    user['age'] = _age.round();
    user['country'] = _country;

    await LocalAuthService.updateLoggedInUser(user);

    Fluttertoast.showToast(
      msg: "Profile updated successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    Navigator.pop(context, _nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Personal Info'),
        leading: const BackButton(color: Colors.black),
      ),
      body: Container(
        color: Colors.blue.shade50.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 16),
              Text(
                'Age: ${_age.round()}',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 18),
              ),
              Slider(
                value: _age,
                min: 21,
                max: 100,
                divisions: 79,
                activeColor: Colors.blue.shade600,
                inactiveColor: Colors.blue.shade300,
                onChanged: (value) {
                  setState(() {
                    _age = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              _loadingCountries
                  ? const CircularProgressIndicator()
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.shade700),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButton<String>(
                        value: _country,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blue.shade700,
                        ),
                        items: _countries.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _country = newValue!;
                          });
                        },
                      ),
                    ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 16,
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade700),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
