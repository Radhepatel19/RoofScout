import 'package:flutter/material.dart';
import 'package:roofscout/features/auth/screens/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionPage extends StatefulWidget {
  const NotificationPermissionPage({super.key});

  @override
  State<NotificationPermissionPage> createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState extends State<NotificationPermissionPage> {
  @override
  void initState() {
    super.initState();
    _checkPermissionAndNavigate();
  }
  Future<void> pickImagesLikeSplash() async {
    await Future.delayed(const Duration(milliseconds: 300)); // ensure context ready

    // 📌 Check both possible permissions depending on Android version
    PermissionStatus photoStatus = await Permission.photos.status;
    PermissionStatus storageStatus = await Permission.storage.status;

    // 📌 Ask if denied
    if (photoStatus.isDenied) {
      photoStatus = await Permission.photos.request();
    }
    if (storageStatus.isDenied) {
      storageStatus = await Permission.storage.request();
    }

    // ⏳ Safety delay (avoid freezing)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
// 🔹 Handle all cases gracefully
    if (photoStatus.isGranted || photoStatus.isDenied || photoStatus.isPermanentlyDenied) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Splashscreen()),
      );
    } else {
      // Fallback — still go to splash to avoid infinite spinner
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Splashscreen()),
      );
    }

  }
  Future<void> _checkPermissionAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 300)); // ensure context ready

    PermissionStatus status = await Permission.notification.status;

    // 🔹 If not yet requested, ask once
    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    // 🔹 Timeout fallback (in case request hangs)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // 🔹 Handle all cases gracefully
    if (status.isGranted || status.isDenied || status.isPermanentlyDenied) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Splashscreen()),
      );
    } else {
      // Fallback — still go to splash to avoid infinite spinner
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Splashscreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
