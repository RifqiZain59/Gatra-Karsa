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

  // --- Palet Warna Premium (Sesuai HomeView) ---
  static const Color primaryColor = Color(0xFF3E2723); // Coklat Tua
  static const Color secondaryColor = Color(0xFF5D4037); // Coklat Medium
  static const Color accentColor = Color(0xFFD4AF37); // Emas
  static const Color bgColor = Color(0xFFFDFCF8); // Putih Tulang
  static const Color inputColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: bgColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            // --- BACKGROUND DECORATION ---
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.05),
                ),
              ),
            ),

            // --- CONTENT ---
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LOGO & HEADER
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Ionicons.leaf,
                            color: primaryColor,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Sugeng Rawuh',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.philosopher(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masuk untuk melanjutkan perjalanan\nbudaya nusantara.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.mulish(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // INPUT FIELDS
                      _buildInputField(
                        label: 'Email',
                        controller: controller.emailController,
                        hint: 'contoh@email.com',
                        icon: Ionicons.mail_outline,
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      _buildPasswordField(),

                      // FORGOT PASSWORD
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Get.to(() => const LupapasswordView()),
                          child: Text(
                            'Lupa Kata Sandi?',
                            style: GoogleFonts.mulish(
                              color: secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // TOMBOL LOGIN
                      SizedBox(
                        height: 56,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed:
                                (controller.isLoading.value ||
                                    controller.isGoogleLoading.value)
                                ? null
                                : () => controller.login(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              elevation: 8,
                              shadowColor: primaryColor.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
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
                              "atau",
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

                      // GOOGLE LOGIN
                      SizedBox(
                        height: 56,
                        child: Obx(
                          () => OutlinedButton(
                            onPressed:
                                (controller.isLoading.value ||
                                    controller.isGoogleLoading.value)
                                ? null
                                : () => controller.loginWithGoogle(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: controller.isGoogleLoading.value
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: primaryColor,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icon/google.png',
                                        height: 24,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Ionicons.logo_google,
                                            color: Colors.red,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Masuk dengan Google",
                                        style: GoogleFonts.mulish(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
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
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
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
          ],
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
              color: primaryColor,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: inputColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3E2723).withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: inputType,
            style: GoogleFonts.mulish(color: primaryColor, fontWeight: FontWeight.w600),
            cursorColor: primaryColor,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.mulish(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
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
              color: primaryColor,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: inputColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3E2723).withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Obx(
            () => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.isObscure.value,
              style: GoogleFonts.mulish(color: primaryColor, fontWeight: FontWeight.w600),
              cursorColor: primaryColor,
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: GoogleFonts.mulish(
                  color: Colors.grey[400],
                  fontSize: 14,
                  letterSpacing: 2,
                ),
                prefixIcon: Icon(
                  Ionicons.lock_closed_outline,
                  color: Colors.grey[400],
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isObscure.value
                        ? Ionicons.eye_off_outline
                        : Ionicons.eye_outline,
                    color: Colors.grey[400],
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