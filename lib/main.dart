import 'package:flutter/material.dart';
import 'package:roofscout/features/auth/screens/notification_permission_page.dart';

void main() async {

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomeReach',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotificationPermissionPage(), // ✅ Start with PermissionScreen
    );
  }
}


