import 'package:flutter/material.dart';

class SavedEmptyScreen extends StatelessWidget {
  const SavedEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GAMBAR NO DATA
              Image.asset(
                "assets/images/no_data.png",
                width: 230,
              ),

              const SizedBox(height: 20),

              const Text(
                "Belum ada properti yang disimpan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Simpan properti favoritmu untuk dilihat nanti.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
