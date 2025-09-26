// lib/main.dart
import 'package:flutter/material.dart';
import 'package:habitt_app/screens/add_habit_screen.dart';
import 'package:habitt_app/screens/notifications_screen.dart';
import 'package:habitt_app/services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/habit_tracker_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
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
        '/home': (ctx) => const HabitTrackerScreen(),
        '/configure': (ctx) => AddHabitScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}
