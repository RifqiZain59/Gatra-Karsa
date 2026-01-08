import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class KebijakanprivasiController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String uid = user.uid;
        String? email = user.email; // Ambil email sebelum dihapus

        // 1. Loading
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
          ),
          barrierDismissible: false,
        );

        // 2. BLACKLIST EMAIL (Agar tidak bisa daftar/login lagi)
        if (email != null) {
          await _firestore.collection('deleted_accounts').doc(email).set({
            'email': email,
            'deletedAt': FieldValue.serverTimestamp(),
            'old_uid': uid,
          });
        }

        // 3. Hapus data di Firestore
        await _firestore.collection('users').doc(uid).delete();

        // 4. Hapus dari Auth
        await user.delete();

        Get.back(); // Tutup loading
        Get.offAllNamed('/login');

        Get.snackbar(
          "AKUN TERHAPUS",
          "Email ini tidak dapat digunakan kembali di sistem kami.",
          backgroundColor: const Color(0xFF4E342E),
          colorText: Colors.white,
          borderRadius: 15,
        );
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      if (e.code == 'requires-recent-login') {
        _showReauthMessage();
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Gagal menghapus: $e");
    }
  }

  // --- Pop up Re-Login tetap sama seperti sebelumnya (Melengkung Bagus) ---
  void _showReauthMessage() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.security_rounded,
                color: Color(0xFFD4AF37),
                size: 50,
              ),
              const SizedBox(height: 20),
              const Text(
                "Verifikasi Ulang",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Silakan masuk kembali untuk menghapus akun secara permanen.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _auth.signOut();
                    Get.offAllNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E342E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "MASUK ULANG",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
