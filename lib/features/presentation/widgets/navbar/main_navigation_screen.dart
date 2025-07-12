import 'package:flutter/material.dart';
import 'package:petzy/features/presentation/screens/home_screen/home_screen.dart';
import 'package:petzy/features/presentation/screens/category_screen/category_screen.dart';
import 'package:petzy/features/presentation/screens/home_screen/widgets/custom_navbar.dart';

class MainNavigationScreen extends StatefulWidget {
  final dynamic user;

  const MainNavigationScreen({super.key, this.user});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    Center(child: Text("My Orders Coming Soon")),
    CategoryScreen(),
    Center(child: Text("Settings Coming Soon")),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
