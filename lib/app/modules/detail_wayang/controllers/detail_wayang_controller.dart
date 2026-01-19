import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';

class DetailWayangController extends GetxController {
  // Model Data
  late ContentModel wayang;

  // Variabel Reaktif untuk UI (Icon Love Berubah)
  var isFavorite = false.obs;

  // Instance Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();

    // 1. Ambil Data dari Halaman Sebelumnya
    if (Get.arguments is ContentModel) {
      wayang = Get.arguments as ContentModel;
    } else {
      wayang = ContentModel(
        id: '0',
        title: 'Unknown',
        subtitle: '',
        category: '',
        description: 'Data tidak ditemukan',
        imageUrl: '',
      );
    }

    // 2. Cek apakah user sudah pernah like sebelumnya
    checkFavoriteStatus();
  }

  // --- CEK STATUS DI DATABASE ---
  void checkFavoriteStatus() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(wayang.id)
          .get();

      if (doc.exists) {
        isFavorite.value = true;
      } else {
        isFavorite.value = false;
      }
    } catch (e) {
      print("ERROR Check Favorite: $e");
    }
  }

  // --- FUNGSI TOMBOL LOVE (SIMPAN/HAPUS) ---
  void toggleFavorite() async {
    User? user = _auth.currentUser;

    // 1. Cek Login
    if (user == null) {
      Get.snackbar(
        "Akses Dibatasi",
        "Silakan login terlebih dahulu untuk menyimpan.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 2. Cek Validitas Data
    if (wayang.id == '0' || wayang.id.isEmpty) {
      Get.snackbar("Error", "Data tidak valid, tidak bisa disimpan.");
      return;
    }

    DocumentReference docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(wayang.id);

    try {
      if (isFavorite.value) {
        // --- HAPUS DARI DATABASE ---
        await docRef.delete();
        isFavorite.value = false;

        Get.snackbar(
          "Dihapus",
          "Dihapus dari koleksi favorit",
          backgroundColor: Colors.grey,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
        );
      } else {
        // --- SIMPAN KE DATABASE ---
        await docRef.set({
          'id': wayang.id,
          'title': wayang.title,
          'subtitle': wayang.subtitle,
          'category': wayang.category,
          'image_url': wayang.imageUrl,
          'description': wayang.description,
          'saved_at': FieldValue.serverTimestamp(),
        });

        isFavorite.value = true;

        Get.snackbar(
          "Disukai",
          "Berhasil masuk ke daftar favorit!",
          backgroundColor: const Color(0xFF3E2723), // Warna Primary Apps
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
        );
      }
    } catch (e) {
      print("ERROR SAVE TO FIREBASE: $e");
      Get.snackbar(
        "Gagal",
        "Terjadi kesalahan koneksi database",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
