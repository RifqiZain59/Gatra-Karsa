import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// Pastikan path import ini sesuai dengan struktur project Anda
import 'package:gatrakarsa/app/data/service/api_service.dart';

class DetailmuseumController extends GetxController {
  // Menerima data yang dikirim dari halaman sebelumnya
  final ContentModel museum = Get.arguments;

  // Instance Service
  final ApiService _apiService = ApiService();

  // State Variables
  var isSaved = false.obs; // Status Bookmark
  var userRating = 5.obs; // Bintang yang dipilih user
  final TextEditingController reviewController =
      TextEditingController(); // Input teks ulasan

  // Stream untuk Realtime Review
  late Stream<QuerySnapshot> ulasanStream;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi stream ulasan berdasarkan ID museum
    ulasanStream = _apiService.streamUlasan(museum.id);
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }

  // =======================================================================
  // 1. FUNGSI BUKA MAPS (WEBSITE MODE)
  // =======================================================================
  Future<void> openMap() async {
    final String url = museum.mapsUrl ?? "";

    if (url.isEmpty) {
      Get.snackbar(
        "Info",
        "Link lokasi belum tersedia untuk museum ini.",
        backgroundColor: Colors.black.withOpacity(0.7),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    try {
      final Uri uri = Uri.parse(url);

      // Menggunakan externalApplication agar terbuka di Browser (Chrome/Safari)
      // bukan memaksa masuk ke aplikasi Maps Native.
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar("Gagal", "Tidak dapat membuka link website.");
      }
    } catch (e) {
      Get.snackbar("Error", "Format link tidak valid.");
    }
  }

  // =======================================================================
  // 2. FUNGSI SUBMIT REVIEW
  // =======================================================================
  Future<void> submitReview() async {
    if (reviewController.text.trim().isEmpty) {
      Get.snackbar("Error", "Ulasan tidak boleh kosong");
      return;
    }

    try {
      // --- TODO: Ganti dengan Data User Asli dari Auth Controller ---
      String dummyUserId = "user_123";
      String dummyUserName = "Pengunjung";
      // -------------------------------------------------------------

      await _apiService.submitUlasan(
        contentId: museum.id,
        targetName: museum.title,
        category: 'Museum',
        rating: userRating.value,
        comment: reviewController.text,
        userId: dummyUserId, // Ganti dengan user.uid asli
        userName: dummyUserName, // Ganti dengan user.displayName asli
      );

      // Reset Form setelah sukses
      reviewController.clear();
      userRating.value = 5;

      Get.snackbar(
        "Sukses",
        "Terima kasih atas ulasan Anda!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan: $e");
    }
  }

  // =======================================================================
  // 3. FUNGSI BOOKMARK (TOGGLE)
  // =======================================================================
  void toggleSave() {
    isSaved.value = !isSaved.value;
    // Disini Anda bisa menambahkan logika simpan ke Database (Favorites collection)
    if (isSaved.value) {
      Get.snackbar(
        "Disimpan",
        "${museum.title} ditambahkan ke koleksi.",
        duration: const Duration(seconds: 1),
      );
    }
  }

  // Helper untuk mengubah rating bintang
  void setRating(int rating) {
    userRating.value = rating;
  }
}
