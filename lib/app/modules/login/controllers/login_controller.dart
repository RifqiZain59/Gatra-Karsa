import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isGoogleLoading = false.obs;
  var isObscure = true.obs;

  void toggleObscure() => isObscure.value = !isObscure.value;

  // --- 1. LOGIN EMAIL & PASSWORD ---
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackbar(
        "Peringatan",
        "Email dan password wajib diisi",
        Colors.orange,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Cek Blacklist (Opsional)
      bool isBlacklisted = await _checkIfEmailDeleted(
        emailController.text.trim(),
      );
      if (isBlacklisted) {
        isLoading.value = false;
        _showAccessDeniedDialog();
        return;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Cek apakah email sudah diverifikasi (Opsional, tergantung flow Anda)
        // if (!userCredential.user!.emailVerified) { ... }

        await recordUserDevice(userCredential.user!.uid);
        Get.offAllNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar(
        "Gagal Masuk",
        e.message ?? "Kesalahan autentikasi",
        Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- 2. LOGIN GOOGLE (PERBAIKAN UTAMA DISINI) ---
  Future<void> loginWithGoogle() async {
    try {
      isGoogleLoading.value = true;

      // 1. Trigger Google Sign In Flow
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isGoogleLoading.value = false;
        return; // User membatalkan login
      }

      // Cek Blacklist
      bool isBlacklisted = await _checkIfEmailDeleted(googleUser.email);
      if (isBlacklisted) {
        isGoogleLoading.value = false;
        await _googleSignIn.disconnect();
        _showAccessDeniedDialog();
        return;
      }

      // 2. Dapatkan Credential dari Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Sign In ke Firebase Auth
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        // 4. CEK & SIMPAN KE FIRESTORE (LOGIKA REGISTER OTOMATIS)
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Jika dokumen belum ada, berarti ini user baru. Simpan datanya.
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? googleUser.displayName ?? "User Google",
            'email': user.email ?? googleUser.email,
            'photoUrl': user.photoURL ?? googleUser.photoUrl,
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
            'isVerified': true, // User Google dianggap sudah terverifikasi
            'authProvider': 'google',
          });
          print("User Google baru berhasil didaftarkan ke Firestore");
        } else {
          // Opsional: Update data jika user mengganti nama/foto di Google
          await _firestore.collection('users').doc(user.uid).update({
            'last_login': FieldValue.serverTimestamp(),
            // 'photoUrl': user.photoURL, // Uncomment jika ingin auto-update foto
          });
        }

        await recordUserDevice(user.uid);
        Get.offAllNamed('/home');
      }
    } catch (e) {
      print("Google Login Error: $e");
      _showSnackbar(
        "Google Error",
        "Gagal login dengan Google: $e",
        Colors.red,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // --- 3. REKAM DEVICE ---
  Future<void> recordUserDevice(String uid) async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String model = "Unknown Device";
      String platform = Platform.isAndroid ? "Android" : "iOS";

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        model = "${androidInfo.brand} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        model = iosInfo.name;
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('login_history')
          .add({
            'device_info': model,
            'platform': platform,
            'last_login': FieldValue.serverTimestamp(),
            'status': 'Active',
          });
    } catch (e) {
      debugPrint("Gagal rekam device: $e");
    }
  }

  Future<bool> _checkIfEmailDeleted(String email) async {
    try {
      var check = await _firestore
          .collection('deleted_accounts')
          .doc(email)
          .get();
      return check.exists;
    } catch (e) {
      return false;
    }
  }

  void _showAccessDeniedDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Ionicons.ban_outline, color: Colors.red[700], size: 50),
              const SizedBox(height: 20),
              const Text(
                "Akses Ditolak",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Akun ini telah dihapus permanen.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E342E),
                  ),
                  child: const Text(
                    "MENGERTI",
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

  void _showSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
    );
  }
}
