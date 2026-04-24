import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Parse().initialize(
    'YOUR_APP_ID',
    'https://parseapi.back4app.com',
    clientKey: 'YOUR_CLIENT_KEY',
    autoSendSessionId: true,
    debug: true,
  );

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1565C0),
          secondary: Color(0xFF1565C0),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}