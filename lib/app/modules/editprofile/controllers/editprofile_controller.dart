import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ionicons/ionicons.dart'; // Pastikan import icon

class EditprofileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController nameC;
  late TextEditingController emailC;

  var isLoading = false.obs;
  var selectedImage = Rx<File?>(null);
  var base64ImageString = "".obs;

  // Warna Tema (Hardcode disini agar controller mandiri)
  final Color primaryDark = const Color(0xFF4E342E);
  final Color goldAccent = const Color(0xFFD4AF37);

  @override
  void onInit() {
    super.onInit();
    nameC = TextEditingController();
    emailC = TextEditingController();
    loadUserData();
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    super.onClose();
  }

  // --- 1. LOAD DATA ---
  void loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      nameC.text = user.displayName ?? "";
      emailC.text = user.email ?? "";

      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          nameC.text = data['name'] ?? user.displayName ?? "";
          emailC.text = data['email'] ?? user.email ?? "";
          if (data['photoBase64'] != null) {
            base64ImageString.value = data['photoBase64'];
          }
        }
      } catch (e) {
        print("Gagal load firestore: $e");
      }
    }
  }

  // --- 2. PICK IMAGE ---
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 70,
    );

    if (image != null) {
      File file = File(image.path);
      selectedImage.value = file;
      List<int> imageBytes = await file.readAsBytes();
      base64ImageString.value = base64Encode(imageBytes);
    }
  }

  // --- 3. SIMPAN PROFIL ---
  Future<void> saveProfile() async {
    if (nameC.text.isEmpty || emailC.text.isEmpty) {
      Get.snackbar(
        "Perhatian",
        "Nama dan Email wajib diisi",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      User? user = _auth.currentUser;

      if (user != null) {
        String uid = user.uid;
        bool isEmailChanged = user.email != emailC.text;

        // A. Update Nama
        if (user.displayName != nameC.text) {
          await user.updateDisplayName(nameC.text);
        }

        // B. Update Database
        Map<String, dynamic> dataToUpdate = {
          'name': nameC.text,
          'email': emailC.text,
        };
        if (base64ImageString.value.isNotEmpty) {
          dataToUpdate['photoBase64'] = base64ImageString.value;
        }
        await _firestore.collection('users').doc(uid).update(dataToUpdate);

        // C. CEK EMAIL BERUBAH
        if (isEmailChanged) {
          // Kirim Link Verifikasi
          await user.verifyBeforeUpdateEmail(emailC.text);
          isLoading.value = false;

          // TAMPILKAN DIALOG PREMIUM (VERIFIKASI EMAIL)
          _showPremiumDialog(
            icon: Ionicons.mail_unread_outline,
            iconColor: Colors.blueAccent,
            title: "Cek Email Anda",
            description:
                "Demi keamanan, kami telah mengirimkan tautan verifikasi ke email baru:\n\n${emailC.text}\n\nSilakan klik tautan tersebut, lalu masuk kembali.",
            buttonText: "Siap, Login Ulang",
            onPressed: () async {
              await _auth.signOut();
              Get.offAllNamed('/login');
            },
          );
        } else {
          isLoading.value = false;
          Get.back();
          Get.snackbar(
            "Berhasil",
            "Data profil telah diperbarui",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      // --- TAMPILKAN DIALOG PREMIUM (JIKA BUTUH LOGIN ULANG) ---
      if (e.code == 'requires-recent-login') {
        _showPremiumDialog(
          icon: Ionicons.shield_checkmark_outline,
          iconColor: Colors.orange,
          title: "Verifikasi Keamanan",
          description:
              "Perubahan email adalah tindakan sensitif. Sistem mendeteksi Anda sudah login cukup lama.\n\nDemi keamanan akun, mohon login ulang untuk melanjutkan.",
          buttonText: "Login Ulang Sekarang",
          onPressed: () async {
            await _auth.signOut();
            Get.offAllNamed('/login');
          },
        );
      } else {
        Get.snackbar(
          "Gagal",
          e.message ?? "Terjadi kesalahan",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Gagal menyimpan: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // --- WIDGET DIALOG PREMIUM (Custom Design) ---
  void _showPremiumDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Icon Circle dengan Background Halus
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: iconColor),
              ),
              const SizedBox(height: 24),

              // 2. Judul
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E342E), // Primary Dark Theme
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 12),

              // 3. Deskripsi
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 4. Tombol Aksi Full Width
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E342E), // Primary Theme
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 5. Tombol Batal (Opsional/Kecil)
              GestureDetector(
                onTap: () => Get.back(),
                child: Text(
                  "Batal",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // User wajib klik tombol
    );
  }
}
