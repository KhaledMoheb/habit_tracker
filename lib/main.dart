// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/add_habit_screen.dart';
import 'services/local_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalAuthService.seedTestUser();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habitt',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const LoginScreen(),
        '/register': (ctx) => const RegisterScreen(),
        '/home': (ctx) => const AddHabitScreen(),
      },
    );
  }
}
