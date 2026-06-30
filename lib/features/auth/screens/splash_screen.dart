import 'package:flutter/material.dart';
import 'package:roofscout/features/home/screens/menu_handler.dart';
import 'package:roofscout/features/home/screens/selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
    checkFirstVisit();

  }
  void checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    bool firstVisit = prefs.getBool('firstVisit') ?? true;
    String? token = prefs.getString('token');
    prefs.getString('user_role');

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuHandler()),
        );
    } else if (firstVisit) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SelectionScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenuHandler()),
      );
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: ScaleTransition(
              scale: _animation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Image.asset(
                      'assets/images/roof_scout.png',
                      width: 200,
                      height: 200,
                    ),


                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.blue, Colors.purple, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),


                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Secure & Fast",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
