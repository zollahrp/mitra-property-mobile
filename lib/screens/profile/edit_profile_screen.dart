import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final usernameC = TextEditingController();
  final alamatC = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      namaC.text = prefs.getString("nama") ?? "";
      emailC.text = prefs.getString("email") ?? "";
      usernameC.text = prefs.getString("username") ?? "";
      alamatC.text = prefs.getString("alamat") ?? "";
    });
  }

  Future<void> updateProfile() async {
    try {
      final dio = Dio();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final userId = prefs.getString("id");

      if (userId == null || userId.isEmpty) {
        throw "User ID tidak ditemukan";
      }

      final data = {
        "nama": namaC.text,
        "email": emailC.text,
        "username": usernameC.text,
        "alamat": alamatC.text,
      };

      // ========================
      //   ENDPOINT YANG BENAR
      // ========================
      final response = await dio.put(
        "https://api.mitrapropertysentul.com/users/$userId",
        data: data,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      print("UPDATE STATUS: ${response.statusCode}");
      print("UPDATE DATA: ${response.data}");

      if (response.statusCode == 200) {
        await prefs.setString("nama", namaC.text);
        await prefs.setString("email", emailC.text);
        await prefs.setString("username", usernameC.text);
        await prefs.setString("alamat", alamatC.text);

        Navigator.pop(context, true); // kirim sinyal berhasil

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui")),
        );
      }
    } catch (e) {
      print("UPDATE ERROR: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal update profil")));
    }
  }

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
                        colors: [
                          Color(0xFF6276E8), // kiri
                          Color(0xFF788BF3), // tengah
                          Color(0xFFAEC8FF), // kanan lebih muda
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
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
                                    "assets/images/avatar.png",
                                  ),
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
                        ),
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
              _inputCard("Nama", namaC),
              _inputCard("Email", emailC),
              _inputCard("Username", usernameC),
              _inputCard("Alamat", alamatC),

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
                      updateProfile();
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
