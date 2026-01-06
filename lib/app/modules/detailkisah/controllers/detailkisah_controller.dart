import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailkisahController extends GetxController {
  // --- LOGIKA SIMPAN (YANG SUDAH ADA) ---
  var isSaved = false.obs;

  void toggleSave() {
    isSaved.value = !isSaved.value;
    if (isSaved.value) {
      Get.snackbar(
        "Disimpan",
        "Kisah masuk ke koleksi",
        backgroundColor: Colors.white,
      );
    } else {
      Get.snackbar(
        "Dihapus",
        "Kisah dihapus dari koleksi",
        backgroundColor: Colors.white,
      );
    }
  }

  // --- TAMBAHAN BARU: LOGIKA RATING ---
  var userRating = 0.obs; // Menyimpan jumlah bintang (0-5)
  final TextEditingController reviewController = TextEditingController();

  // Fungsi set bintang saat diklik
  void setRating(int rating) {
    userRating.value = rating;
  }

  // Fungsi kirim ulasan
  void submitReview() {
    if (userRating.value == 0) {
      Get.snackbar(
        "Peringatan",
        "Mohon berikan rating bintang terlebih dahulu.",
        backgroundColor: Colors.white,
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    // Simulasi kirim data
    Get.snackbar(
      "Terima Kasih",
      "Ulasan Anda berhasil dikirim!",
      backgroundColor: Colors.white,
      colorText: const Color(0xFF3E2723),
      icon: const Icon(Icons.check_circle, color: Colors.green),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
    );

    // Reset Form
    userRating.value = 0;
    reviewController.clear();
    FocusManager.instance.primaryFocus?.unfocus(); // Tutup keyboard
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
