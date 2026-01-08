import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GantikatasandiController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Text Controllers
  late TextEditingController oldPassC;
  late TextEditingController newPassC;
  late TextEditingController confirmPassC;

  // Observables untuk Toggle Visibility Password
  var isOldHidden = true.obs;
  var isNewHidden = true.obs;
  var isConfirmHidden = true.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    oldPassC = TextEditingController();
    newPassC = TextEditingController();
    confirmPassC = TextEditingController();
  }

  @override
  void onClose() {
    oldPassC.dispose();
    newPassC.dispose();
    confirmPassC.dispose();
    super.onClose();
  }

  // --- LOGIKA GANTI PASSWORD ---
  Future<void> changePassword() async {
    // 1. Validasi Input Dasar
    if (oldPassC.text.isEmpty ||
        newPassC.text.isEmpty ||
        confirmPassC.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Semua kolom harus diisi",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPassC.text != confirmPassC.text) {
      Get.snackbar(
        "Error",
        "Konfirmasi sandi baru tidak cocok",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPassC.text.length < 6) {
      Get.snackbar(
        "Error",
        "Sandi baru minimal 6 karakter",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      User? user = _auth.currentUser;

      if (user != null && user.email != null) {
        // 2. RE-AUTHENTICATE (Wajib untuk keamanan Firebase)
        // Kita harus membuktikan bahwa user mengetahui password lama
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassC.text,
        );

        await user.reauthenticateWithCredential(credential);

        // 3. UPDATE PASSWORD
        await user.updatePassword(newPassC.text);

        isLoading.value = false;
        Get.back(); // Kembali ke profile
        Get.snackbar(
          "Sukses",
          "Kata sandi berhasil diperbarui. Silakan login ulang nanti.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = "Terjadi kesalahan";

      if (e.code == 'wrong-password') {
        message = "Kata sandi lama salah.";
      } else if (e.code == 'weak-password') {
        message = "Kata sandi baru terlalu lemah.";
      } else if (e.code == 'requires-recent-login') {
        message = "Sesi habis. Silakan logout dan login ulang.";
      }

      Get.snackbar(
        "Gagal",
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
