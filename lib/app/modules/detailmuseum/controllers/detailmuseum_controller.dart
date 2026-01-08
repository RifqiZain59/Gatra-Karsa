import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';

class DetailmuseumController extends GetxController {
  late ContentModel museum;

  // --- 1. INIT DATA ---
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ContentModel) {
      museum = Get.arguments as ContentModel;
    } else {
      // Fallback Data
      museum = ContentModel(
        id: '0',
        title: 'Museum Tidak Ditemukan',
        subtitle: '',
        category: 'Museum',
        description: 'Data tidak tersedia.',
        imageUrl: '',
        location: '-',
      );
    }
  }

  // --- 2. BOOKMARK ---
  var isSaved = false.obs;

  void toggleSave() {
    isSaved.value = !isSaved.value;
    Get.snackbar(
      isSaved.value ? "Disimpan" : "Dihapus",
      isSaved.value
          ? "Museum ditambahkan ke favorit"
          : "Museum dihapus dari favorit",
      backgroundColor: Colors.white,
      colorText: const Color(0xFF3E2723),
      icon: Icon(
        isSaved.value ? Icons.bookmark : Icons.delete_outline,
        color: isSaved.value ? const Color(0xFFC5A059) : Colors.red,
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
    );
  }

  // --- 3. REVIEW ---
  var userRating = 0.obs;
  final TextEditingController reviewController = TextEditingController();

  void setRating(int rating) {
    userRating.value = rating;
  }

  void submitReview() {
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

  // --- 4. MAPS ---
  void openMap() {
    if (museum.mapsUrl != null && museum.mapsUrl!.isNotEmpty) {
      // TODO: Gunakan url_launcher untuk membuka real maps
      // launchUrl(Uri.parse(museum.mapsUrl!));
      Get.snackbar("Peta", "Membuka peta ke: ${museum.location}");
    } else {
      Get.snackbar("Info", "Lokasi peta tidak tersedia");
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
