import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../controllers/gantikatasandi_controller.dart';

// --- TEMA WARNA (Konsisten) ---
const Color primaryDark = Color(0xFF4E342E);
const Color goldAccent = Color(0xFFD4AF37);
const Color background = Color(0xFFFAFAF5);

class GantikatasandiView extends GetView<GantikatasandiController> {
  const GantikatasandiView({super.key});

  @override
  Widget build(BuildContext context) {
    // Injeksi controller jika belum ada
    if (!Get.isRegistered<GantikatasandiController>()) {
      Get.put(GantikatasandiController());
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
          'Ganti Kata Sandi',
          style: TextStyle(
            color: primaryDark,
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Amankan Akun Anda",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryDark,
                fontFamily: 'Serif',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Buat kata sandi baru yang kuat dan belum pernah digunakan sebelumnya.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // --- INPUT SANDI LAMA ---
            Obx(
              () => _buildPasswordField(
                controller: controller.oldPassC,
                label: "Kata Sandi Lama",
                isHidden: controller.isOldHidden.value,
                onToggle: () => controller.isOldHidden.toggle(),
                icon: Ionicons.key_outline,
              ),
            ),

            const SizedBox(height: 20),

            // --- INPUT SANDI BARU ---
            Obx(
              () => _buildPasswordField(
                controller: controller.newPassC,
                label: "Kata Sandi Baru",
                isHidden: controller.isNewHidden.value,
                onToggle: () => controller.isNewHidden.toggle(),
                icon: Ionicons.lock_closed_outline,
              ),
            ),

            const SizedBox(height: 20),

            // --- INPUT KONFIRMASI SANDI ---
            Obx(
              () => _buildPasswordField(
                controller: controller.confirmPassC,
                label: "Konfirmasi Sandi Baru",
                isHidden: controller.isConfirmHidden.value,
                onToggle: () => controller.isConfirmHidden.toggle(),
                icon: Ionicons.checkmark_circle_outline,
                isLast: true,
              ),
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
                      : () => controller.changePassword(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    foregroundColor: goldAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: primaryDark.withOpacity(0.4),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: goldAccent)
                      : const Text(
                          "Perbarui Kata Sandi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  // --- WIDGET HELPER INPUT FIELD ---
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isHidden,
    required VoidCallback onToggle,
    required IconData icon,
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryDark,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isHidden,
            textInputAction: isLast
                ? TextInputAction.done
                : TextInputAction.next,
            style: const TextStyle(color: primaryDark),
            decoration: InputDecoration(
              hintText: "Masukkan $label",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(icon, color: primaryDark.withOpacity(0.6)),
              suffixIcon: IconButton(
                icon: Icon(
                  isHidden ? Ionicons.eye_off_outline : Ionicons.eye_outline,
                  color: Colors.grey,
                ),
                onPressed: onToggle,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryDark, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
