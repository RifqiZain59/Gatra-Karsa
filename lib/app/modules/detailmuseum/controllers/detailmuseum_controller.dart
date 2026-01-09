import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';

class DetailmuseumController extends GetxController {
  final ApiService _apiService = ApiService();
  late ContentModel museum;

  // Controller untuk Input Ulasan
  final TextEditingController reviewController = TextEditingController();
  var userRating = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ContentModel) {
      museum = Get.arguments as ContentModel;
    } else {
      museum = ContentModel(
        id: '0',
        title: 'Error',
        subtitle: '-',
        category: '-',
        description: 'Error',
        imageUrl: '',
      );
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }

  // --- 1. GETTER STREAM ULASAN (YANG ERROR SEBELUMNYA) ---
  Stream<QuerySnapshot> get ulasanStream => _apiService.streamUlasan(museum.id);

  // --- 2. FITUR SAVE / BOOKMARK ---
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

  // --- 3. FITUR SUBMIT REVIEW ---
  void setRating(int rating) => userRating.value = rating;

  Future<void> submitReview() async {
    // Validasi Rating
    if (userRating.value == 0) {
      Get.snackbar(
        "Peringatan",
        "Beri bintang dulu ya!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Cek Login User
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

      // Kirim ke Firebase (Tanpa ImageUrl sesuai perbaikan API)
      await _apiService.submitUlasan(
        contentId: museum.id,
        targetName: museum.title,
        category: museum.category,
        subtitle: museum.subtitle,
        rating: userRating.value,
        comment: reviewController.text,
        userId: user.uid,
        userName: user.displayName ?? "Pengguna",
      );

      // Tutup Loading & Reset
      Get.back();
      Get.snackbar(
        "Sukses",
        "Ulasan terkirim!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      userRating.value = 0;
      reviewController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        "Gagal",
        "Error: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // --- 4. FITUR BUKA PETA ---
  void openMap() {
    if (museum.mapsUrl != null && museum.mapsUrl!.isNotEmpty) {
      // Logika buka URL peta bisa ditambahkan di sini (misal pakai url_launcher)
      Get.snackbar(
        "Info",
        "Membuka peta...",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Maaf",
        "Link peta belum tersedia.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
}
