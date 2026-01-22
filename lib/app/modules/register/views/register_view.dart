import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  // --- Palet Warna Premium (Sesuai HomeView) ---
  static const Color primaryColor = Color(0xFF3E2723); // Coklat Tua
  static const Color accentColor = Color(0xFFD4AF37); // Emas
  static const Color bgColor = Color(0xFFFDFCF8); // Putih Tulang
  static const Color inputColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RegisterController>()) Get.put(RegisterController());

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
            // Lingkaran aksen di pojok kanan atas
            Positioned(
              top: -80,
              right: -40,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [accentColor.withOpacity(0.1), Colors.transparent],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
            ),

            // --- CONTENT ---
            SafeArea(
              child: Column(
                children: [
                  // CUSTOM APP BAR
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 24,
                      top: 16,
                    ),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Ionicons.arrow_back,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            'Buat Akun Baru',
                            style: GoogleFonts.philosopher(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Mulai lestarikan budaya dengan bergabung\nbersama Gatra Karsa.',
                            style: GoogleFonts.mulish(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40.0),

                          _buildInputField(
                            label: 'Nama Lengkap',
                            controller: controller.nameController,
                            hint: 'Rifqi Zain',
                            icon: Ionicons.person_outline,
                          ),
                          const SizedBox(height: 20.0),

                          _buildInputField(
                            label: 'Alamat Email',
                            controller: controller.emailController,
                            hint: 'contoh@email.com',
                            icon: Ionicons.mail_outline,
                            inputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20.0),

                          _buildInputField(
                            label: 'Kata Sandi',
                            controller: controller.passwordController,
                            hint: 'Buat kata sandi kuat',
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
                                  backgroundColor: primaryColor,
                                  foregroundColor: accentColor,
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
                                        'Buat Akun',
                                        style: GoogleFonts.mulish(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
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
                                style: GoogleFonts.mulish(
                                  color: Colors.grey[600],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Text(
                                  'Masuk',
                                  style: GoogleFonts.mulish(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
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
            obscureText: isPassword,
            keyboardType: inputType,
            style: GoogleFonts.mulish(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
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
}
