import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/editprofile_controller.dart';

// Warna Tema
const Color primaryDark = Color(0xFF4E342E);
const Color goldAccent = Color(0xFFD4AF37);
const Color background = Color(0xFFFAFAF5);

class EditprofileView extends GetView<EditprofileController> {
  const EditprofileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller di-put
    if (!Get.isRegistered<EditprofileController>()) {
      Get.put(EditprofileController());
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: primaryDark),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: primaryDark,
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- BAGIAN FOTO PROFIL ---
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Obx(() {
                    ImageProvider imageProvider;
                    if (controller.selectedImage.value != null) {
                      imageProvider = FileImage(
                        controller.selectedImage.value!,
                      );
                    } else if (controller.base64ImageString.value.isNotEmpty) {
                      try {
                        imageProvider = MemoryImage(
                          base64Decode(controller.base64ImageString.value),
                        );
                      } catch (e) {
                        imageProvider = const NetworkImage(
                          'https://i.pravatar.cc/150?img=32',
                        );
                      }
                    } else {
                      imageProvider = const NetworkImage(
                        'https://i.pravatar.cc/150?img=32',
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: goldAccent, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: imageProvider,
                      ),
                    );
                  }),
                  // Tombol Kamera
                  GestureDetector(
                    onTap: () => controller.pickImage(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryDark,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Ionicons.camera,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Ketuk ikon kamera untuk mengubah foto",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 30),

            // --- FORM NAMA ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nama Lengkap",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.nameC,
                  decoration: _inputDecoration(
                    "Masukkan nama lengkap",
                    Ionicons.person_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- FORM EMAIL ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Alamat Email",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    "Masukkan email baru",
                    Ionicons.mail_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.saveProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Simpan Perubahan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Serif',
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

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: primaryDark.withOpacity(0.5)),
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryDark, width: 1.5),
      ),
    );
  }
}
