import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class LupapasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  var isLoading = false.obs;

  Future<void> sendResetPasswordEmail() async {
    if (emailController.text.isEmpty ||
        !GetUtils.isEmail(emailController.text)) {
      Get.snackbar(
        "Input Tidak Valid",
        "Silakan masukkan alamat email yang benar.",
        backgroundColor: Colors.red[800],
        colorText: Colors.white,
        borderRadius: 15,
        margin: const EdgeInsets.all(15),
      );
      return;
    }

    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());

      // PANGGIL POP-UP CUSTOM YANG SUDAH DIBAGUSIN
      _showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Gagal",
        e.message ?? "Terjadi kesalahan",
        backgroundColor: Colors.red[800],
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- POP-UP CUSTOM PREMIUM ---
  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28), // Melengkung Mewah
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animasi Ikon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Ionicons.paper_plane_outline,
                  color: Color(0xFFD4AF37),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Teks Judul
              const Text(
                "Email Terkirim!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Color(0xFF4E342E),
                ),
              ),
              const SizedBox(height: 12),

              // Teks Deskripsi
              Text(
                "Kami telah mengirimkan instruksi pemulihan kata sandi ke:\n${emailController.text}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Aksi
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Tutup Dialog
                    Get.back(); // Kembali ke Login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E342E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "KEMBALI KE LOGIN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
