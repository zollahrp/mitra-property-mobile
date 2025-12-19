import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:mitra_property/screens/home/home_screen.dart';
import 'package:mitra_property/screens/saved/saved_filled_screen.dart';
import 'package:mitra_property/screens/profile/profile_screen.dart';

class BottomNavbar extends StatefulWidget {
  final int initialIndex;

  const BottomNavbar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  late int _selectedIndex;
  DateTime? _lastPressed;

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _screens = [
    const HomeScreen(),
    const SavedFilledScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastPressed == null ||
            now.difference(_lastPressed!) > const Duration(seconds: 2)) {
          _lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tekan sekali lagi untuk keluar"),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: PhysicalModel(
          color: Colors.transparent,
          elevation: 12,
          shadowColor: Colors.black.withOpacity(0.25),
          child: CurvedNavigationBar(
            key: _bottomNavigationKey,
            backgroundColor: Colors.transparent,
            color: Colors.white,
            buttonBackgroundColor: Colors.white,
            height: 60,
            index: _selectedIndex,
            items: const <Widget>[
              Icon(Icons.home_filled, size: 30, color: Color(0xFF0E91E9)),
              Icon(Icons.bookmark_rounded, size: 30, color: Color(0xFF0E91E9)),
              Icon(Icons.person_rounded, size: 30, color: Color(0xFF0E91E9)),
            ],
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            animationDuration: const Duration(milliseconds: 300),
            animationCurve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }
}
