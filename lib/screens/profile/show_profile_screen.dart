import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mitra_property/screens/profile/edit_profile_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ShowProfileScreen extends StatefulWidget {
  const ShowProfileScreen({super.key});

  @override
  State<ShowProfileScreen> createState() => _ShowProfileScreenState();
}

class _ShowProfileScreenState extends State<ShowProfileScreen> {
  String nama = "";
  String email = "";
  String username = "";
  String alamat = "";
  String? photoUrl;
  String token = "";
  bool isLoadingPhoto = true;

  @override
  void initState() {
    super.initState();
    loadProfileData();
    loadUserPhoto();
  }

  Future<void> loadUserPhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("id");
      final storedToken = prefs.getString("token");

      if (userId == null || storedToken == null) return;

      final response = await http.get(
        Uri.parse("https://api.mitrapropertysentul.com/users/photo/$userId"),
        headers: {
          "Authorization": "Bearer $storedToken",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          photoUrl = data["photo"];
          token = storedToken;
          isLoadingPhoto = false;
        });
      } else {
        isLoadingPhoto = false;
      }
    } catch (e) {
      isLoadingPhoto = false;
    }
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nama = prefs.getString("nama") ?? "-";
      email = prefs.getString("email") ?? "-";
      username = prefs.getString("username") ?? "-";
      alamat = prefs.getString("alamat") ?? "-";
    });
  }

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
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 210,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6276E8),
                        Color(0xFF788BF3),
                        Color(0xFFA8BBFF),
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
                      const SizedBox(height: 25),

                      // Avatar Floating
                      Positioned(
                        bottom: -50,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Material(
                            elevation: 10,
                            shape: const CircleBorder(),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: isLoadingPhoto
                                    ? const CircularProgressIndicator()
                                    : Image.network(
                                        photoUrl ?? "",
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Image.asset(
                                                "assets/images/avatar.png",
                                                width: 96,
                                                height: 96,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                      ),
                              ),
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
                Flexible(
                  child: Text(
                    nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),

                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );

                    if (result == true) {
                      await loadProfileData(); // refresh data
                      await loadUserPhoto();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profil berhasil diperbarui"),
                        ),
                      );
                    }
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
            // INFO LIST (Dinamis)
            // -------------------------------------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  InfoCard(title: "Nama", value: nama),
                  InfoCard(title: "Email", value: email),
                  InfoCard(title: "Username", value: username),
                  InfoCard(title: "Alamat", value: alamat),
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
// REUSABLE CARD ITEM
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          SizedBox(
            width: 90, // biar rapi & konsisten
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // VALUE (DINAMIS + WRAP)
          Expanded(
            child: Text(
              value,
              maxLines: 3, // email & alamat bisa multiline
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A6CF7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
