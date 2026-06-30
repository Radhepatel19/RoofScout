import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/screens/favorite_page.dart';
import 'package:roofscout/features/home/screens/home_page.dart';
import 'package:roofscout/features/home/screens/notification_page.dart';
import 'package:roofscout/features/profile/screens/profile_page.dart';

class MenuHandler extends StatefulWidget {
  const MenuHandler({super.key});

  @override
  State<MenuHandler> createState() => _MenuHandlerState();
}

class _MenuHandlerState extends State<MenuHandler> {
  int _selectedIndex = 0;
  double _bottomNavHeight = 80;

  late final List<Widget> _pages;

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.notifications_rounded,
    Icons.favorite_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = [
    "Home",
    "Alerts",
    "Saved",
    "Profile",
  ];

  final List<Color> _iconColors = [
    Color(0xFF0066FF),
    Color(0xFFFF6B00),
    Color(0xFFF44336),
    Color(0xFF9C27B0),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      NotificationPage(onNavigateToTab: _onItemTapped),
      const FavoritePage(),
      ProfilePage(onNavigateToTab: _onItemTapped), // 🔑 callback
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Bottom nav animation
      _bottomNavHeight = 70;
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() => _bottomNavHeight = 80);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _bottomNavHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_icons.length, (index) {
          final isSelected = _selectedIndex == index;
          final iconColor =
          isSelected ? _iconColors[index] : Colors.grey[400]!;

          return GestureDetector(
            onTap: () => _onItemTapped(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icons[index], color: iconColor),
                const SizedBox(height: 4),
                if (isSelected)
                  Text(
                    _labels[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
