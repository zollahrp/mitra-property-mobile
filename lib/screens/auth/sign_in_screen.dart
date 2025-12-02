import 'package:flutter/material.dart';
import 'package:mitra_property/routes/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final TextEditingController loginEmailC = TextEditingController();
final TextEditingController loginPassC = TextEditingController();

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back + Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF4A6CF7),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 20),

              // Illustration
              Image.asset(
                'assets/images/signin_illustration.png',
                width: 240,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 28),

              const Text(
                'Hai, Selamat datang kembali!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 28),

              // Email
              _inputField(
                hint: "Email / Username",
                icon: Icons.email_outlined,
                controller: loginEmailC,
              ),

              // Password with toggle eye
              PasswordField(controller: loginPassC),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.forgotPassword);
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFF4A6CF7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 2),

              // Sign In Button (OVAL)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    loginUser(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6CF7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Future<void> loginUser(BuildContext context) async {
    try {
      final dio = Dio();

      final data = {"username": loginEmailC.text, "password": loginPassC.text};

      final response = await dio.post(
        "https://api.mitrapropertysentul.com/auth/login",
        data: data,
      );

      print("STATUS: ${response.statusCode}");
      print("DATA: ${response.data}");

      if (response.statusCode == 200) {
        final user = response.data["data"];
        final token = user["token"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);

        Map<String, dynamic> decoded = JwtDecoder.decode(token);
        String userId = decoded["id"];

        await prefs.setString("id", userId);

        await prefs.setString("nama", user["nama"] ?? "");
        await prefs.setString("email", user["email"] ?? "");
        await prefs.setString("username", user["username"] ?? "");
        await prefs.setString("alamat", user["alamat"] ?? "");

        Navigator.pushNamed(context, AppRoutes.home);
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login gagal, cek kembali username/password"),
        ),
      );
    }
  }
}

// ===========================================================
//                   INPUT FIELD DEFAULT
// ===========================================================

Widget _inputField({
  required String hint,
  required IconData icon,
  required TextEditingController controller,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 1.3),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.grey.shade500),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    ),
  );
}

// ===========================================================
//                   PASSWORD FIELD (TOGGLE)
// ===========================================================

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300, width: 1.3),
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: isHidden,
          decoration: InputDecoration(
            hintText: "Password",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade500),
            suffixIcon: IconButton(
              icon: Icon(
                isHidden ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade500,
              ),
              onPressed: () {
                setState(() {
                  isHidden = !isHidden;
                });
              },
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
