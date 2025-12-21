import 'package:flutter/material.dart';
import 'package:mitra_property/screens/auth/sign_in_screen.dart';
import 'package:mitra_property/screens/profile/faq_screen.dart';
import 'package:mitra_property/screens/profile/show_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String nama = "";
  String email = "";
  String userId = "";
  String token = "";
  String? photoUrl;
  bool isLoadingPhoto = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    initProfile();
    loadUserPhoto();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoadingPhoto = true;
    });

    await loadUserData();
    await loadUserPhoto();

    await Future.delayed(const Duration(milliseconds: 400));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> initProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final storedUserId = prefs.getString("id");
    final storedToken = prefs.getString("token");

    if (storedUserId == null || storedToken == null) return;

    setState(() {
      nama = prefs.getString("nama") ?? "User";
      email = prefs.getString("email") ?? "user@example.com";
      userId = storedUserId;
      token = storedToken;

      photoUrl =
          "https://api.mitrapropertysentul.com/users/photo/$storedUserId?ts=${DateTime.now().millisecondsSinceEpoch}";
      isLoadingPhoto = false;
    });
  }

  Future<void> loadUserPhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("id");
      final token = prefs.getString("token");

      if (userId == null || token == null) return;

      final response = await http.get(
        Uri.parse("https://api.mitrapropertysentul.com/users/photo/$userId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          photoUrl = data["photo"];
          isLoadingPhoto = false;
        });
      } else {
        isLoadingPhoto = false;
      }
    } catch (e) {
      isLoadingPhoto = false;
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nama = prefs.getString("nama") ?? "User";
      email = prefs.getString("email") ?? "user@example.com";
      userId = prefs.getString("id") ?? "";
      token = prefs.getString("token") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 80),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6276E8),
                        Color(0xFF788BF3),
                        Color.fromARGB(255, 139, 159, 233),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              nama,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              email,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: -45,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: isLoadingPhoto
                            ? const CircularProgressIndicator()
                            : Image.network(
                                "${photoUrl!}?ts=${DateTime.now().millisecondsSinceEpoch}",
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                headers: {"Authorization": "Bearer $token"},
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "assets/images/avatar.png",
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            // =========================
            // MENU LIST
            // =========================
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(), // 👈 DI SINI
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildMenuItem(
                      icon: Icons.person,
                      iconColor: Colors.grey.shade600,
                      title: "My Profile",
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ShowProfileScreen(),
                          ),
                        );

                        if (result == true) {
                          await loadUserData();
                          await loadUserPhoto();
                        }
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.language,
                      iconColor: Colors.redAccent,
                      title: "Website",
                      onTap: () async {
                        final url = Uri.parse('http://mitrapropertysentul.com');

                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode
                                .externalApplication, // biar buka browser
                          );
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.star,
                      iconColor: Colors.orange,
                      title: "Rate Us",
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      iconColor: Colors.teal,
                      title: "Faq",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FAQScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // =========================
            // LOGOUT BUTTON
            // =========================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoggingOut
                      ? null
                      : () async {
                          setState(() {
                            _isLoggingOut = true;
                          });

                          await Future.delayed(const Duration(seconds: 2));

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();

                          if (!mounted) return;

                          _showSnack("Berhasil logout");

                          await Future.delayed(
                            const Duration(milliseconds: 800),
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignInScreen(),
                            ),
                            (route) => false,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6CF7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isLoggingOut
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // REUSABLE MENU ITEM
  // ====================================================
  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade200,
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
