import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailmuseumController extends GetxController {
  // --- 1. FITUR FAVORIT (BOOKMARK) ---
  var isSaved = false.obs;

  void toggleSave() {
    isSaved.value = !isSaved.value;

    if (isSaved.value) {
      Get.snackbar(
        "Disimpan",
        "Museum masuk ke daftar kunjungan Anda",
        backgroundColor: Colors.white,
        colorText: const Color(0xFF3E2723), // Coklat Tua
        icon: const Icon(Icons.bookmark, color: Color(0xFFC5A059)), // Emas
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 10,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        "Dihapus",
        "Museum dihapus dari daftar kunjungan",
        backgroundColor: Colors.white,
        colorText: Colors.grey[800],
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 10,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // --- 2. FITUR RATING & ULASAN (BARU) ---
  var userRating = 0.obs; // Menyimpan jumlah bintang (1-5)
  final TextEditingController reviewController = TextEditingController();

  // Fungsi mengubah bintang saat diklik
  void setRating(int rating) {
    userRating.value = rating;
  }

  // Fungsi kirim ulasan
  void submitReview() {
    // Validasi: Cek apakah user sudah pilih bintang
    if (userRating.value == 0) {
      Get.snackbar(
        "Peringatan",
        "Harap berikan rating bintang terlebih dahulu.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    // Simulasi Pengiriman Data Sukses
    Get.snackbar(
      "Terima Kasih",
      "Ulasan Anda berhasil dikirim!",
      backgroundColor: Colors.white,
      colorText: const Color(0xFF3E2723),
      icon: const Icon(Icons.check_circle, color: Colors.green),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
    );

    // Reset Form setelah kirim
    userRating.value = 0;
    reviewController.clear();

    // Menutup keyboard jika terbuka
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // --- 3. FITUR LAINNYA ---
  void openMap() {
    Get.snackbar(
      "Peta",
      "Membuka Google Maps...",
      backgroundColor: Colors.white,
      colorText: Colors.black,
      icon: const Icon(Icons.map, color: Colors.blue),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
    );
  }

  // --- 4. MEMORY MANAGEMENT ---
  @override
  void onClose() {
    // Wajib dispose controller text agar tidak memory leak
    reviewController.dispose();
    super.onClose();
  }
}
