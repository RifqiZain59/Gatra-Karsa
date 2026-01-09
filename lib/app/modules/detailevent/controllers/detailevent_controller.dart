import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DetaileventController extends GetxController {
  final ApiService _apiService = ApiService();
  late ContentModel event;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ContentModel) {
      event = Get.arguments;
    } else {
      event = ContentModel(
        id: '0',
        title: 'Error',
        subtitle: '-',
        category: '-',
        description: 'Error',
        imageUrl: '',
      );
    }
  }

  // Stream Ulasan
  Stream<QuerySnapshot> get ulasanStream => _apiService.streamUlasan(event.id);

  // --- FITUR MAPS ---
  Future<void> openMap() async {
    final String? url = event.mapsUrl;
    if (url != null && url.isNotEmpty) {
      try {
        if (!await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        )) {
          throw 'Could not launch $url';
        }
      } catch (e) {
        Get.snackbar(
          "Gagal",
          "Link peta tidak valid.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        "Info",
        "Lokasi peta tidak tersedia.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // --- FITUR BOOKMARK ---
  var isSaved = false.obs;
  void toggleSave() {
    isSaved.value = !isSaved.value;
    Get.snackbar(
      "Berhasil",
      isSaved.value ? "Acara disimpan" : "Dihapus dari simpanan",
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(20),
    );
  }

  // --- FITUR RATING ---
  var userRating = 0.obs;
  final TextEditingController reviewController = TextEditingController();

  void setRating(int rating) => userRating.value = rating;

  Future<void> submitReview() async {
    if (userRating.value == 0) {
      Get.snackbar(
        "Peringatan",
        "Beri bintang dulu ya!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        "Akses Ditolak",
        "Login dulu untuk mengulas.",
        backgroundColor: Colors.orange,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _apiService.submitUlasan(
        contentId: event.id,
        targetName: event.title,
        category: event.category,
        subtitle: event.subtitle,
        // imageUrl: event.imageUrl, <--- DIHAPUS
        rating: userRating.value,
        comment: reviewController.text,
        userId: user.uid,
        userName: user.displayName ?? "Pengguna",
      );

      Get.back();
      Get.snackbar(
        "Sukses",
        "Ulasan terkirim!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reset Form
      userRating.value = 0;
      reviewController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (e) {
      Get.back();
      Get.snackbar("Gagal", "Error: $e", backgroundColor: Colors.red);
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
