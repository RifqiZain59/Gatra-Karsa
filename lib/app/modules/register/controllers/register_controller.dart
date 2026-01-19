import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Pastikan import ini mengarah ke file VerificationView Anda
import '../../verification/views/verification_view.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Semua kolom harus diisi',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 1. Create User di Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        // 2. Simpan Data ke Firestore
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': false,
          'authProvider':
              'email', // Berguna untuk membedakan dengan user Google
          'photoUrl': '', // Field kosong untuk konsistensi
        });

        // 3. Kirim Email Verifikasi
        try {
          await userCredential.user!.sendEmailVerification();
        } catch (e) {
          print("Gagal kirim email verifikasi: $e");
        }

        isLoading.value = false;

        Get.snackbar(
          'Registrasi Berhasil',
          'Silakan cek email Anda untuk verifikasi.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // 4. Arahkan ke Verification View
        Get.offAll(() => const VerificationView());
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = 'Terjadi kesalahan.';
      if (e.code == 'weak-password')
        message = 'Password terlalu lemah.';
      else if (e.code == 'email-already-in-use')
        message = 'Email ini sudah terdaftar.';
      else if (e.code == 'invalid-email')
        message = 'Format email tidak valid.';

      Get.snackbar(
        'Gagal',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
