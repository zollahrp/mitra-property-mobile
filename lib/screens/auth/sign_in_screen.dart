import 'package:flutter/material.dart';
import 'package:mitra_property/routes/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final TextEditingController loginEmailC = TextEditingController();
final TextEditingController loginPassC = TextEditingController();

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

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

              Image.asset(
                'assets/images/signin_illustration.png',
                width: 240,
              ),

              const SizedBox(height: 28),

              const Text(
                'Hai, Selamat datang kembali!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 28),

              _inputField(
                hint: "Email / Username",
                icon: Icons.email_outlined,
                controller: loginEmailC,
              ),

              PasswordField(controller: loginPassC),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.forgotPassword);
                  },
                  child: const Text(
                    "Lupa Password?",
                    style: TextStyle(
                      color: Color(0xFF4A6CF7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // 🔥 LOGIN BUTTON + LOADING
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6CF7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  //                        LOGIN USER
  // ===========================================================

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = Dio();

      final response = await dio.post(
        "https://api.mitrapropertysentul.com/auth/login",
        data: {
          "username": loginEmailC.text,
          "password": loginPassC.text,
        },
      );

      if (response.statusCode == 200) {
        final user = response.data["data"];
        final token = user["token"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);

        final decoded = JwtDecoder.decode(token);
        await prefs.setString("id", decoded["id"]);

        await prefs.setString("nama", user["nama"] ?? "");
        await prefs.setString("email", user["email"] ?? "");
        await prefs.setString("username", user["username"] ?? "");
        await prefs.setString("alamat", user["alamat"] ?? "");
        await prefs.setString("role", response.data["role"] ?? "");

        _showSnack("Login berhasil, tunggu sebentar...");

        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      } else {
        _showSnack("Login gagal, cek kembali akun Anda");
      }
    } catch (e) {
      _showSnack("Login gagal, cek kembali username/password");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// ===========================================================
//                   INPUT FIELD
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
//                   PASSWORD FIELD
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
    );
  }
}
