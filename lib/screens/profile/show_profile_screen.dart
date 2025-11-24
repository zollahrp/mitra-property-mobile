import 'package:flutter/material.dart';
import 'package:mitra_property/screens/profile/edit_profile_screen.dart';

class ShowProfileScreen extends StatelessWidget {
  const ShowProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      body: SafeArea(
        child: Column(
          children: [
            // -------------------------------------
            // TOP HEADER
            // -------------------------------------
            Stack(
              children: [
                // Blue gradient header
                Container(
                  height: 210,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A6CF7), Color(0xFF3554D1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),

                // Back button + Avatar
                Positioned.fill(
                  child: Column(
                    children: [
                      // Back Icon
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 12),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Avatar floating
                      Material(
                        elevation: 10,
                        shape: const CircleBorder(),
                        child: const CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 48,
                            backgroundImage: AssetImage(
                              "assets/images/avatar.png",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // -------------------------------------
            // NAME + EDIT
            // -------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Jenny Perdana",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.edit, size: 18),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // -------------------------------------
            // TITLE
            // -------------------------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Personal Information",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2A53),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // -------------------------------------
            // INFO LIST (CARD STYLE)
            // -------------------------------------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  InfoCard(title: "Full Name", value: "Jenny Perdana"),
                  InfoCard(title: "Email", value: "Jenny123@gmail.com"),
                  InfoCard(title: "Phone Number", value: "081385997264"),
                  InfoCard(title: "Role", value: "User"),
                  InfoCard(title: "Date of Birth", value: "21 Januari 2025"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// REUSABLE CARD ITEM (lebih profesional pakai card, bukan garis bawah)
// ===========================================================
class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A6CF7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
