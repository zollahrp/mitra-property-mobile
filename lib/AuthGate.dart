import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mitra_property/screens/auth/login_choice_screen.dart';
import 'package:mitra_property/screens/navbar/bottom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null || token.isEmpty) return false;
    return !JwtDecoder.isExpired(token);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ SUDAH LOGIN
        if (snapshot.data == true) {
          return const BottomNavbar();
        }

        // ✅ BELUM LOGIN → LOGIN CHOICE
        return const LoginChoiceScreen();
      },
    );
  }
}
