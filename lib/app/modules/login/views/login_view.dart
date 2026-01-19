import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/login_controller.dart';
import '../../register/views/register_view.dart';
import '../../register/bindings/register_binding.dart';
import '../../lupapassword/views/lupapassword_view.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  // --- Konstanta Warna ---
  static const Color darkColor = Color(0xFF4E342E);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color surfaceColor = Colors.white;
  static const Color inputFillColor = Color(0xFFF9F9F9);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // --- PENGATURAN STATUS BAR (ATAS) ---
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Ikon baterai/jam jadi hitam
        // --- PENGATURAN NAVIGASI BAR (BAWAH) ---
        // Membuat latar belakang navigasi menjadi PUTIH
        systemNavigationBarColor: Colors.white,
        // Membuat ikon (Back/Home) menjadi GELAP agar terlihat di atas warna putih
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: surfaceColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Logo atau Icon Kecil (Opsional)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Ionicons.leaf, color: darkColor, size: 32),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sugeng Rawuh',
                  style: GoogleFonts.philosopher(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan masuk untuk melanjutkan perjalanan budayamu.',
                  style: GoogleFonts.mulish(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                _buildInputField(
                  label: 'Email Address',
                  controller: controller.emailController,
                  hint: 'Masukkan email',
                  icon: Ionicons.mail_outline,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                _buildPasswordField(),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Get.to(() => const LupapasswordView()),
                    child: Text(
                      'Lupa Kata Sandi?',
                      style: GoogleFonts.mulish(
                        color: darkColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // TOMBOL LOGIN EMAIL
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          (controller.isLoading.value ||
                              controller.isGoogleLoading.value)
                          ? null
                          : () => controller.login(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkColor,
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
                              'Masuk',
                              style: GoogleFonts.mulish(
                                color: accentColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Atau masuk dengan",
                        style: GoogleFonts.mulish(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 30),

                // TOMBOL LOGIN GOOGLE
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Obx(
                    () => OutlinedButton(
                      onPressed:
                          (controller.isLoading.value ||
                              controller.isGoogleLoading.value)
                          ? null
                          : () => controller.loginWithGoogle(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: controller.isGoogleLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.red,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Ionicons.logo_google,
                                  color: Colors.red,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Google",
                                  style: GoogleFonts.mulish(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum punya akun? ",
                      style: GoogleFonts.mulish(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(
                        () => const RegisterView(),
                        binding: RegisterBinding(),
                      ),
                      child: Text(
                        'Daftar Sekarang',
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
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Kata Sandi",
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
          child: Obx(
            () => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.isObscure.value,
              style: GoogleFonts.mulish(color: Colors.black87),
              cursorColor: darkColor,
              decoration: InputDecoration(
                hintText: 'Masukkan password',
                hintStyle: GoogleFonts.mulish(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Ionicons.lock_closed_outline,
                  color: Colors.grey[500],
                  size: 22,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isObscure.value
                        ? Ionicons.eye_off_outline
                        : Ionicons.eye_outline,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => controller.toggleObscure(),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18.0,
                  horizontal: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
