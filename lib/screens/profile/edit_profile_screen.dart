import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  bool isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? photoUrl;
  bool isLoadingPhoto = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadUserPhoto();
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

  Future<void> _loadUserPhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("id");
      final token = prefs.getString("token");

      if (userId == null || token == null) return;

      final dio = Dio();

      final response = await dio.get(
        "https://api.mitrapropertysentul.com/users/photo/$userId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          photoUrl = response.data["photo"];
          isLoadingPhoto = false;
        });
      } else {
        isLoadingPhoto = false;
      }
    } catch (_) {
      isLoadingPhoto = false;
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
    });

    await _uploadProfilePhoto();
  }

  Future<void> _uploadProfilePhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final userId = prefs.getString("id");

      if (token == null || userId == null) {
        throw "Token atau User ID tidak ada";
      }

      final dio = Dio();

      final formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.path.split('/').last,
        ),
      });

      final response = await dio.post(
        "https://api.mitrapropertysentul.com/users/photo/$userId",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200) {
        _showSnack(
          "Foto berhasil diupload, klik Simpan Perubahan untuk menyimpan",
        );
      }
    } catch (e) {
      _showSnack("Gagal upload foto");
    }
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
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

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

      if (response.statusCode == 200) {
        await prefs.setString("nama", namaC.text);
        await prefs.setString("email", emailC.text);
        await prefs.setString("username", usernameC.text);
        await prefs.setString("alamat", alamatC.text);

        if (!mounted) return;

        _showSnack("Profil berhasil diperbarui");

        await Future.delayed(const Duration(milliseconds: 800));

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack("Gagal update profil");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor: Colors.white,
                                child: isLoadingPhoto
                                    ? const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      )
                                    : CircleAvatar(
                                        radius: 48,
                                        backgroundImage: _selectedImage != null
                                            ? FileImage(_selectedImage!)
                                            : photoUrl != null
                                            ? NetworkImage(photoUrl!)
                                            : const AssetImage(
                                                    "assets/images/avatar.png",
                                                  )
                                                  as ImageProvider,
                                      ),
                              ),
                            ),

                            // 👇 IKON KAMERA ADA DI SINI & BISA DIKLIK
                            GestureDetector(
                              onTap: _pickAndUploadPhoto,
                              child: Container(
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
              // SAVE & CANCEL BUTTONS
              // ===========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Tombol Batal (kecil)
                    SizedBox(
                      height: 55,
                      width: 120, // lebarnya kecil tetap
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF4A6CF7),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A6CF7),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Tombol Simpan (ambil sisa space)
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A6CF7),
                            disabledBackgroundColor: const Color(0xFF4A6CF7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
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
                  ],
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
