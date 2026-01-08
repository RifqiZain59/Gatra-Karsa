import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:url_launcher/url_launcher.dart'; // Import Wajib

class DetailmuseumController extends GetxController {
  late ContentModel museum;

  // --- 1. INIT DATA ---
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ContentModel) {
      museum = Get.arguments as ContentModel;
    } else {
      museum = ContentModel(
        id: '0',
        title: 'Data Tidak Ditemukan',
        subtitle: '',
        category: 'Unknown',
        description: 'Terjadi kesalahan saat memuat data.',
        imageUrl: '',
        location: '-',
        mapsUrl: '', // Pastikan model Anda mendukung field ini
      );
    }
  }

  // --- 2. BOOKMARK ---
  var isSaved = false.obs;

  void toggleSave() {
    isSaved.value = !isSaved.value;
    Get.snackbar(
      isSaved.value ? "Disimpan" : "Dihapus",
      isSaved.value ? "Ditambahkan ke favorit" : "Dihapus dari favorit",
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

  // --- 4. MAPS (LOGIKA BARU) ---
  Future<void> openMap() async {
    // Cek apakah URL maps ada dan tidak kosong
    if (museum.mapsUrl != null && museum.mapsUrl!.isNotEmpty) {
      final Uri url = Uri.parse(museum.mapsUrl!);

      try {
        // Mode externalApplication akan memaksa membuka Google Maps / Browser
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw 'Could not launch $url';
        }
      } catch (e) {
        Get.snackbar(
          "Gagal",
          "Tidak dapat membuka aplikasi peta.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
        );
      }
    } else {
      Get.snackbar(
        "Info",
        "Link peta tidak tersedia untuk lokasi ini.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
