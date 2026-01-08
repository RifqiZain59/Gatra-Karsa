import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Pastikan path ini sesuai dengan struktur project Anda
import '../../verification/views/verification_view.dart';

class RegisterController extends GetxController {
  // Input Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variables
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // --- REGISTER EMAIL & PASSWORD ---
  Future<void> register() async {
    // 1. Validasi Input
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Semua kolom harus diisi',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    try {
      isLoading.value = true;
      print("--- MULAI PROSES REGISTER ---"); // DEBUG LOG

      // 2. Buat Akun di Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      print(
        "User berhasil dibuat dengan UID: ${userCredential.user?.uid}",
      ); // DEBUG LOG

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        // 3. Simpan Data ke Firestore
        print("Menyimpan data ke Firestore..."); // DEBUG LOG
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'role': 'user', // Role default
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': false, // Penanda awal
        });

        // 4. Kirim Email Verifikasi
        print("Mencoba mengirim email verifikasi..."); // DEBUG LOG
        try {
          await userCredential.user!.sendEmailVerification();
          print(
            "SUKSES: Email verifikasi telah dikirim ke server Firebase.",
          ); // DEBUG LOG
        } catch (emailError) {
          print("ERROR KIRIM EMAIL: $emailError"); // DEBUG LOG
          // Kita tidak return di sini, biarkan user masuk ke halaman verifikasi
          // agar mereka bisa mencoba tombol "Kirim Ulang" di sana.
        }

        isLoading.value = false;

        Get.snackbar(
          'Registrasi Berhasil',
          'Silakan cek email Anda untuk verifikasi.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // 5. Arahkan ke Halaman Verifikasi
        Get.offAll(() => const VerificationView());
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = 'Terjadi kesalahan.';

      print("FIREBASE AUTH ERROR: ${e.code} - ${e.message}"); // DEBUG LOG

      if (e.code == 'weak-password') {
        message = 'Password terlalu lemah (min. 6 karakter).';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email ini sudah terdaftar.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      }

      Get.snackbar(
        'Gagal',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      print("GENERAL ERROR: $e"); // DEBUG LOG
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
