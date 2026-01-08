import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini

class VerificationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Instance Firestore

  var isLoading = false.obs;
  var statusMessage = "Mengecek status verifikasi...".obs;
  var isEmailVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkStatusOnLoad();
  }

  // --- LOGIKA UTAMA: UPDATE FIRESTORE JIKA VERIFIED ---
  Future<void> _updateFirestoreStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Update field 'isVerified' di collection 'users' menjadi true
        await _firestore.collection('users').doc(user.uid).update({
          'isVerified': true,
        });
        print("Database Firestore berhasil diupdate menjadi Verified!");
      } catch (e) {
        print("Gagal update firestore: $e");
      }
    }
  }

  Future<void> checkStatusOnLoad() async {
    User? user = _auth.currentUser;
    await user?.reload();
    user = _auth.currentUser;

    if (user != null && user.emailVerified) {
      // 1. Update status Lokal
      isEmailVerified.value = true;
      statusMessage.value = "Verifikasi Berhasil!\nDialihkan dalam 3 detik...";

      // 2. UPDATE DATABASE FIRESTORE (PENTING!)
      await _updateFirestoreStatus();

      await Future.delayed(const Duration(seconds: 3));
      Get.offAllNamed('/home');
    } else {
      isEmailVerified.value = false;
      statusMessage.value =
          "Silakan klik link di email Anda,\nlalu tekan tombol di bawah.";
    }
  }

  Future<void> checkVerificationManual() async {
    try {
      isLoading.value = true;
      User? user = _auth.currentUser;

      await user?.reload();
      user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        isEmailVerified.value = true;
        statusMessage.value = "Verifikasi Berhasil!";

        // UPDATE DATABASE FIRESTORE (PENTING!)
        await _updateFirestoreStatus();

        Get.snackbar(
          'Sukses',
          'Status akun diperbarui. Masuk ke beranda...',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Belum Verifikasi',
          'Email belum terkonfirmasi di sistem Firebase.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ... (Sisa fungsi resend dan cancel tetap sama) ...
  Future<void> resendVerificationEmail() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Get.snackbar('Terkirim', 'Link baru dikirim ke ${user.email}');
      } else {
        Get.snackbar('Info', 'Akun sudah terverifikasi.');
      }
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelVerification() async {
    await _auth.signOut();
    Get.offAllNamed('/login');
  }
}
