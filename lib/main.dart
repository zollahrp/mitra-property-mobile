import 'package:flutter/material.dart';
import 'package:mitra_property/routes/app_routes.dart'; // pastiin path-nya ini bener

void main() {
  runApp(const MitraPropertyApp());
}

class MitraPropertyApp extends StatelessWidget {
  const MitraPropertyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mitra Property',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),

      // pastiin rute awalnya salah satu dari yang ada di app_routes.dart
      initialRoute: AppRoutes.splash, // bisa diganti loginChoice juga
      routes: AppRoutes.routes,

      // tambahin fallback biar gak error kalo route gak ketemu
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('404 — Route not found'),
          ),
        ),
      ),
    );
  }
}
