import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class DeteksiController extends GetxController {
  // Status izin kamera, diobservasi agar UI bisa otomatis di-refresh
  final Rx<PermissionStatus> cameraPermissionStatus =
      PermissionStatus.denied.obs;

  @override
  void onInit() {
    super.onInit();
    // Memanggil fungsi cek izin saat controller diinisialisasi
    checkCameraPermission();
  }

  // Fungsi untuk memeriksa dan meminta izin kamera
  Future<void> checkCameraPermission() async {
    // 1. Cek status izin saat ini
    var status = await Permission.camera.status;
    cameraPermissionStatus.value = status; // Update status

    // 2. Jika status DITOLAK atau DIBATASI, minta izin
    if (status.isDenied || status.isRestricted) {
      await requestCameraPermission();
    }
  }

  // Fungsi khusus untuk meminta izin kamera
  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    cameraPermissionStatus.value = status; // Update status

    if (status.isGranted) {
      Get.snackbar(
        "Berhasil",
        "Izin Kamera diberikan. Anda bisa memulai deteksi.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );
    } else if (status.isPermanentlyDenied) {
      // Jika ditolak permanen, arahkan ke pengaturan
      Get.defaultDialog(
        title: "Izin Kamera Dibutuhkan",
        middleText:
            "Aplikasi membutuhkan izin kamera untuk berfungsi. Mohon aktifkan di Pengaturan.",
        textConfirm: "Buka Pengaturan",
        textCancel: "Tutup",
        onConfirm: () {
          openAppSettings();
          Get.back();
        },
      );
    } else {
      Get.snackbar(
        "Gagal",
        "Izin Kamera ditolak.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fungsi contoh yang memerlukan kamera
  void startDeteksi() {
    if (cameraPermissionStatus.value.isGranted) {
      // Lanjutkan logika deteksi objek
      print("Memulai proses deteksi...");
      // ... (kode Anda untuk deteksi)
    } else {
      // Minta izin lagi atau informasikan pengguna
      requestCameraPermission();
    }
  }

  // Contoh fungsi dari template awal
  final count = 0.obs;
  void increment() => count.value++;

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
