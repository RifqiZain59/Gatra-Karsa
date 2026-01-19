import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  // --- Konstanta Warna ---
  static const Color darkColor = Color(0xFF4E342E);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color surfaceColor = Colors.white;
  static const Color inputFillColor = Color(0xFFF9F9F9);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RegisterController>()) Get.put(RegisterController());

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        // --- PERBAIKAN SYSTEM UI DI SINI ---
        systemOverlayStyle: const SystemUiOverlayStyle(
          // Status Bar (Atas)
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Ikon Hitam
          statusBarBrightness: Brightness.light, // iOS: Background Terang
          // Navigation Bar (Bawah)
          systemNavigationBarColor: Colors.white, // Background Putih
          systemNavigationBarIconBrightness: Brightness.dark, // Ikon Hitam
        ),
        // -----------------------------------
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Ionicons.chevron_back,
                color: darkColor,
                size: 20,
              ),
            ),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Buat Akun Baru',
                style: GoogleFonts.philosopher(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Daftar untuk mulai menjelajah dunia wayang!',
                style: GoogleFonts.mulish(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40.0),

              _buildInputField(
                label: 'Nama Lengkap',
                controller: controller.nameController,
                hint: 'Masukkan nama lengkap',
                icon: Ionicons.person_outline,
              ),
              const SizedBox(height: 20.0),

              _buildInputField(
                label: 'Alamat Email',
                controller: controller.emailController,
                hint: 'Masukkan email',
                icon: Ionicons.mail_outline,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20.0),

              _buildInputField(
                label: 'Kata Sandi',
                controller: controller.passwordController,
                hint: 'Buat kata sandi',
                icon: Ionicons.lock_closed_outline,
                isPassword: true,
              ),
              const SizedBox(height: 40.0),

              SizedBox(
                width: double.infinity,
                height: 56.0,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.register(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkColor,
                      foregroundColor: accentColor,
                      elevation: 5,
                      shadowColor: darkColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: accentColor,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Daftar',
                            style: GoogleFonts.mulish(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah punya akun? ",
                    style: GoogleFonts.mulish(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      'Masuk',
                      style: GoogleFonts.mulish(
                        color: darkColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.mulish(
              fontWeight: FontWeight.bold,
              color: darkColor,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: inputType,
            style: GoogleFonts.mulish(color: Colors.black87),
            cursorColor: darkColor,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.mulish(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18.0,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
