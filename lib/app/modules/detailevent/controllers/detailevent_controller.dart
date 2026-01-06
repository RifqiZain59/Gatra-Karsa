import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetaileventController extends GetxController {
  // --- 1. FITUR BOOKMARK / SIMPAN ---
  var isSaved = false.obs;

  void toggleSave() {
    isSaved.value = !isSaved.value;
    if (isSaved.value) {
      Get.snackbar(
        "Disimpan",
        "Acara ditambahkan ke jadwal saya",
        backgroundColor: Colors.white,
        colorText: const Color(0xFF3E2723),
        icon: const Icon(Icons.bookmark, color: Color(0xFFC5A059)),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
      );
    } else {
      Get.snackbar(
        "Dihapus",
        "Acara dihapus dari jadwal",
        backgroundColor: Colors.white,
        colorText: Colors.grey[800],
        icon: const Icon(Icons.delete_outline, color: Colors.grey),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
      );
    }
  }

  // --- 2. FITUR BUKA PETA ---
  void openMap() {
    // Simulasi membuka peta
    Get.snackbar(
      "Membuka Peta",
      "Mengarahkan ke lokasi acara...",
      backgroundColor: Colors.white,
      colorText: const Color(0xFF3E2723),
      icon: const Icon(Icons.map, color: Colors.blue),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
    );
  }

  // --- 3. FITUR RATING & ULASAN ---
  var userRating = 0.obs; // Menyimpan status bintang (0-5)
  final TextEditingController reviewController = TextEditingController();

  // Fungsi mengubah bintang saat diklik
  void setRating(int rating) {
    userRating.value = rating;
  }

  // Fungsi kirim ulasan
  void submitReview() {
    // Validasi input
    if (userRating.value == 0) {
      Get.snackbar(
        "Peringatan",
        "Harap berikan rating bintang terlebih dahulu.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    // Simulasi Sukses
    Get.snackbar(
      "Terima Kasih",
      "Ulasan acara berhasil dikirim!",
      backgroundColor: Colors.white,
      colorText: const Color(0xFF3E2723),
      icon: const Icon(Icons.check_circle, color: Colors.green),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
    );

    // Reset Form setelah kirim
    userRating.value = 0;
    reviewController.clear();

    // Tutup keyboard
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // --- 4. MEMBERSIHKAN MEMORI ---
  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
