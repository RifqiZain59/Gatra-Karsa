import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Pastikan path ini benar sesuai struktur folder Anda
import 'package:gatrakarsa/app/data/service/api_service.dart';

class DetailkisahController extends GetxController {
  final ApiService _apiService = ApiService();
  late ContentModel story;

  @override
  void onInit() {
    super.onInit();
    // Validasi data arguments
    if (Get.arguments is ContentModel) {
      story = Get.arguments as ContentModel;
    } else {
      story = ContentModel(
        id: '0',
        title: 'Error',
        subtitle: '-',
        category: '-',
        description: 'Error',
        imageUrl: '',
      );
    }
  }

  // Stream untuk memantau ulasan secara realtime
  Stream<QuerySnapshot> get ulasanStream => _apiService.streamUlasan(story.id);

  // --- LOGIC SAVE / BOOKMARK ---
  var isSaved = false.obs;
  void toggleSave() {
    isSaved.value = !isSaved.value;
    Get.snackbar(
      isSaved.value ? "Disimpan" : "Dihapus",
      "",
      backgroundColor: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(20),
    );
  }

  // --- LOGIC ULASAN / RATING ---
  var userRating = 0.obs;
  final TextEditingController reviewController = TextEditingController();

  void setRating(int rating) => userRating.value = rating;

  Future<void> submitReview() async {
    // 1. Validasi Rating
    if (userRating.value == 0) {
      Get.snackbar(
        "Peringatan",
        "Beri bintang dulu ya!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // 2. Cek Login User
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        "Akses Ditolak",
        "Login dulu untuk mengulas.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Tampilkan Loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // 3. Submit ke Firebase (PERBAIKAN DI SINI)
      // Parameter 'imageUrl' sudah dihapus agar sesuai dengan ApiService
      await _apiService.submitUlasan(
        contentId: story.id,
        targetName: story.title,
        category: story.category,
        subtitle: story.subtitle,
        rating: userRating.value,
        comment: reviewController.text,
        userId: user.uid,
        userName: user.displayName ?? "Pengguna",
      );

      // Tutup Loading
      Get.back();

      // Notifikasi Sukses
      Get.snackbar(
        "Sukses",
        "Ulasan terkirim!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reset Form
      userRating.value = 0;
      reviewController.clear();
      FocusManager.instance.primaryFocus?.unfocus(); // Tutup keyboard
    } catch (e) {
      // Pastikan loading tertutup jika error terjadi
      if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar(
        "Gagal",
        "Error: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
