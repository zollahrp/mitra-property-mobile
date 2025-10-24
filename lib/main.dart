import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const MitraPropertyApp());
}

class MitraPropertyApp extends StatelessWidget {
  const MitraPropertyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mitra Property',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: AppRoutes.routes,
    );
  }
}
