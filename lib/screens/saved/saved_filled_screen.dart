import 'package:flutter/material.dart';

class SavedFilledScreen extends StatelessWidget {
  const SavedFilledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Saved Properties"),
      ),
      body: const Center(
        child: Text(
          "Saved Page",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
