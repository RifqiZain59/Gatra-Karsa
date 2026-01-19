import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/lupapassword_controller.dart';

class LupapasswordView extends GetView<LupapasswordController> {
  const LupapasswordView({super.key});

  final Color darkColor = const Color(0xFF4E342E);

  @override
  Widget build(BuildContext context) {
    // FIX: Mendaftarkan controller jika belum ada
    if (!Get.isRegistered<LupapasswordController>()) {
      Get.put(LupapasswordController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // --- PERBAIKAN DI SINI: Pasang style langsung di AppBar ---
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Android: Icon Hitam
          statusBarBrightness: Brightness.light, // iOS: Icon Hitam
        ),
        // ---------------------------------------------------------
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: darkColor, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Lupa Kata Sandi?',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: darkColor,
                fontFamily: 'Serif',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Masukkan email Anda untuk menerima tautan pengaturan ulang kata sandi.',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            Text(
              "Email Address",
              style: TextStyle(fontWeight: FontWeight.w600, color: darkColor),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Masukkan email Anda",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(
                  Ionicons.mail_outline,
                  color: Colors.grey[500],
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.sendResetPasswordEmail(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Kirim Tautan Reset",
                          style: TextStyle(
                            color: Color(0xFFD9C19D),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
