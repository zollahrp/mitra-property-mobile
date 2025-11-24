import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController(text: "Jenny Perdana");
  final emailController = TextEditingController(text: "Jenny123@gmail.com");
  final phoneController = TextEditingController(text: "081385997264");
  final roleController = TextEditingController(text: "User");
  final dobController = TextEditingController(text: "21 Januari 2025");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),

      // ===========================
      // CUSTOM HEADER SAMA KAYAK SHOW PROFILE
      // ===========================
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
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

                  Positioned.fill(
                    child: Column(
                      children: [
                        // Back button
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

                        // ===========================
                        // AVATAR + EDIT ICON (CAMERA)
                        // ===========================
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Material(
                              elevation: 10,
                              shape: const CircleBorder(),
                              child: const CircleAvatar(
                                radius: 52,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundImage: AssetImage(
                                      "assets/images/avatar.png"),
                                ),
                              ),
                            ),

                            // Small edit button
                            Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 18,
                                color: Color(0xFF4A6CF7),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ===========================
              // TITLE
              // ===========================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ===========================
              // EDITABLE CARD INPUT
              // ===========================
              _inputCard("Full Name", nameController),
              _inputCard("Email", emailController),
              _inputCard("Phone Number", phoneController),
              _inputCard("Role", roleController),
              _inputCard("Date of Birth", dobController),

              const SizedBox(height: 30),

              // ===========================
              // SAVE BUTTON
              // ===========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Save ke DB
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6CF7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Simpan Perubahan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // CUSTOM CARD INPUT BIAR MATCH DENGAN SHOW PROFILE
  // ======================================================
  Widget _inputCard(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
