import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay sebelum pindah ke LoginChoiceScreen
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, AppRoutes.loginChoice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // putih bersih
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 150, // atur sesuai kebutuhan
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
