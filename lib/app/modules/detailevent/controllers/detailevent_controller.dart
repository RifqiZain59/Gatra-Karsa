import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart'; // Pastikan import ContentModel benar
import 'package:url_launcher/url_launcher.dart'; // Jangan lupa tambahkan package ini di pubspec.yaml

class DetaileventController extends GetxController {
  // --- DATA DARI HALAMAN SEBELUMNYA ---
  late ContentModel event;

  @override
  void onInit() {
    super.onInit();
    // 1. Tangkap data yang dikirim dari halaman list
    if (Get.arguments is ContentModel) {
      event = Get.arguments;
    } else {
      // Fallback jika data error
      event = ContentModel(
        id: '0',
        title: 'Error',
        subtitle: '-',
        category: '-',
        description: 'Gagal memuat data.',
        imageUrl: '',
      );
    }
  }

  // --- 1. FITUR BUKA PETA (FOKUS PERBAIKAN) ---
  Future<void> openMap() async {
    // AMBIL DATA DARI 'maps_url' milik object 'event'
    final String? url = event.mapsUrl;

    print("Mencoba membuka maps: $url"); // Debugging di console

    // Validasi: Pastikan URL ada isinya
    if (url != null && url.isNotEmpty) {
      final Uri uri = Uri.parse(url);

      try {
        // Buka di aplikasi eksternal (Google Maps / Browser)
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw 'Could not launch $uri';
        }
      } catch (e) {
        Get.snackbar(
          "Gagal Membuka Peta",
          "Link peta rusak atau tidak valid.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const Icon(Icons.broken_image, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
        );
      }
    } else {
      // Jika maps_url kosong (null) di database
      Get.snackbar(
        "Info",
        "Lokasi peta belum tersedia untuk acara ini.",
        backgroundColor: Colors.orange[800],
        colorText: Colors.white,
        icon: const Icon(Icons.map_outlined, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
    }
  }

  // --- 2. FITUR BOOKMARK ---
  var isSaved = false.obs;
  void toggleSave() {
    isSaved.value = !isSaved.value;
    String message = isSaved.value
        ? "Acara disimpan"
        : "Acara dihapus dari simpanan";
    Get.snackbar(
      "Berhasil",
      message,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 1),
    );
  }

  // --- 3. FITUR RATING ---
  var userRating = 0.obs;
  final TextEditingController reviewController = TextEditingController();

  void setRating(int rating) => userRating.value = rating;

  void submitReview() {
    if (userRating.value == 0) {
      Get.snackbar(
        "Peringatan",
        "Beri bintang dulu ya!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    Get.snackbar(
      "Terima Kasih",
      "Ulasan Anda telah dikirim.",
      backgroundColor: Colors.green,
      colorText: Colors.white,
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
