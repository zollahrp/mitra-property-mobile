import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

final TextEditingController namaC = TextEditingController();
final TextEditingController alamatC = TextEditingController();
final TextEditingController emailC = TextEditingController();
final TextEditingController usernameC = TextEditingController();
final TextEditingController passC = TextEditingController();
final TextEditingController confirmPassC = TextEditingController();

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
              // AppBar custom
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
                        'Register',
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

              // Card container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Color(0xFFFFE066),
                          backgroundImage: AssetImage(
                            'assets/images/avatar.png',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFF4A6CF7),
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Create an Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Full Name
                    _inputField(
                      hint: "Full Name",
                      icon: Icons.person_outline,
                      controller: namaC,
                    ),

                    const SizedBox(height: 14),

                    // Alamat
                    _inputField(
                      hint: "Alamat",
                      icon: Icons.home_outlined,
                      controller: alamatC,
                    ),

                    const SizedBox(height: 14),

                    // Email
                    _inputField(
                      hint: "Email",
                      icon: Icons.email_outlined,
                      controller: emailC,
                    ),

                    const SizedBox(height: 14),

                    // Username
                    _inputField(
                      hint: "Username",
                      icon: Icons.person,
                      controller: usernameC,
                    ),

                    const SizedBox(height: 14),

                    // Password
                    _inputField(
                      hint: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      controller: passC,
                    ),

                    const SizedBox(height: 14),

                    // Confirm Password
                    _inputField(
                      hint: "Confirm Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      controller: confirmPassC,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'By creating an account, you agree to our\nTerms of Service and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sign Up button (OVAL biar sama dengan Sign In)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (passC.text != confirmPassC.text) {
                            print("Password tidak sama");
                            return;
                          }
                          registerUser();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A6CF7),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Register',
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> registerUser() async {
    try {
      final dio = Dio();

      final data = {
        "nama": namaC.text,
        "alamat": alamatC.text,
        "email": emailC.text,
        "username": usernameC.text,
        "password": passC.text,
      };

      final response = await dio.post(
        "http://api.mitrapropertysentul.com/auth/register",
        data: data,
      );

      print("STATUS: ${response.statusCode}");
      print("DATA: ${response.data}");

      // TODO: tampilkan dialog sukses
    } catch (e) {
      print("ERROR: $e");
      // TODO: tampilkan dialog error
    }
  }

  // MATCHED INPUT FIELD (seperti Sign In)
  Widget _inputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    bool obscure = isPassword;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300, width: 1.3),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.grey.shade500),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}
