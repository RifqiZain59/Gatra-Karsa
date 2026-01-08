import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailkisahController extends GetxController {
  // --- LOGIKA SIMPAN ---
  var isSaved = false.obs;

  void toggleSave() {
    isSaved.value = !isSaved.value;
    if (isSaved.value) {
      Get.snackbar(
        "Disimpan",
        "Kisah masuk ke koleksi",
        backgroundColor: Colors.white,
        colorText: Colors.black87,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
      );
    } else {
      Get.snackbar(
        "Dihapus",
        "Kisah dihapus dari koleksi",
        backgroundColor: Colors.white,
        colorText: Colors.black87,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
      );
    }
  }

  // --- LOGIKA RATING ---
  var userRating = 0.obs;
  final TextEditingController reviewController = TextEditingController();

  void setRating(int rating) {
    userRating.value = rating;
  }

  void submitReview() {
    if (userRating.value == 0) {
      Get.snackbar(
        "Peringatan",
        "Mohon berikan rating bintang terlebih dahulu.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    Get.snackbar(
      "Terima Kasih",
      "Ulasan Anda berhasil dikirim!",
      backgroundColor: Colors.white,
      colorText: const Color(0xFF3E2723),
      icon: const Icon(Icons.check_circle, color: Colors.green),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
    );

    userRating.value = 0;
    reviewController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
