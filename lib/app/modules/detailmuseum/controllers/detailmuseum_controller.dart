import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan Import Auth
import 'package:url_launcher/url_launcher.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';

class DetailmuseumController extends GetxController {
  // Menerima data yang dikirim dari halaman sebelumnya
  final ContentModel museum = Get.arguments;

  // Instance Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _apiService = ApiService();

  // State Variables
  var isSaved = false.obs; // Status Bookmark
  var userRating = 5.obs; // Bintang yang dipilih user
  final TextEditingController reviewController = TextEditingController();

  // Stream untuk Realtime Review
  late Stream<QuerySnapshot> ulasanStream;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi stream ulasan berdasarkan ID museum dari Firestore langsung
    // agar sinkron dengan fungsi submitReview yang baru
    ulasanStream = _firestore
        .collection('contents')
        .doc(museum.id)
        .collection('reviews')
        .orderBy('created_at', descending: true)
        .snapshots();

    checkSaveStatus();
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }

  // Cek apakah museum sudah dibookmark
  void checkSaveStatus() async {
    User? user = _auth.currentUser;
    if (user == null) return;
    try {
      var doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .doc(museum.id)
          .get();
      isSaved.value = doc.exists;
    } catch (e) {
      print("Error checking bookmark: $e");
    }
  }

  // =======================================================================
  // 1. FUNGSI BUKA MAPS
  // =======================================================================
  Future<void> openMap() async {
    final String url = museum.mapsUrl ?? "";

    if (url.isEmpty) {
      Get.snackbar(
        "Info",
        "Link lokasi belum tersedia.",
        backgroundColor: Colors.black.withOpacity(0.7),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar("Gagal", "Tidak dapat membuka peta.");
      }
    } catch (e) {
      Get.snackbar("Error", "Link tidak valid.");
    }
  }

  // =======================================================================
  // 2. FUNGSI SUBMIT REVIEW (FIXED)
  // =======================================================================
  Future<void> submitReview() async {
    // 1. Cek Login
    User? user = _auth.currentUser;
    if (user == null) {
      Get.snackbar("Akses Dibatasi", "Silakan login untuk memberikan ulasan.");
      return;
    }

    // 2. Cek Input Kosong
    if (reviewController.text.trim().isEmpty) {
      Get.snackbar("Error", "Ulasan tidak boleh kosong");
      return;
    }

    try {
      // 3. Ambil Data Detail User (Nama & Foto) dari Firestore
      var userDoc = await _firestore.collection('users').doc(user.uid).get();
      String userName =
          (userDoc.data() as Map<String, dynamic>?)?['name'] ?? 'Pengunjung';
      String userPhoto =
          (userDoc.data() as Map<String, dynamic>?)?['photoBase64'] ?? '';

      // 4. Siapkan Data Ulasan
      Map<String, dynamic> reviewData = {
        'user_id': user.uid,
        'user_name': userName,
        'user_photo': userPhoto,
        'rating': userRating.value,
        'comment': reviewController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      };

      // 5. Kirim ke Koleksi CONTENT (Supaya muncul di halaman detail museum)
      await _firestore
          .collection('contents')
          .doc(museum.id)
          .collection('reviews')
          .add(reviewData);

      // 6. Kirim ke Koleksi USER (Untuk riwayat ulasan di profil user) -> users/{uid}/reviews
      Map<String, dynamic> userHistoryData = {
        ...reviewData,
        'content_id': museum.id,
        'targetName': museum.title,
        'category': 'Museum',
        'image': museum.imageUrl,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reviews')
          .add(userHistoryData);

      // 7. Reset Form
      reviewController.clear();
      userRating.value = 5;

      Get.snackbar(
        "Sukses",
        "Ulasan berhasil dikirim!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan: $e");
    }
  }

  // =======================================================================
  // 3. FUNGSI BOOKMARK
  // =======================================================================
  void toggleSave() async {
    User? user = _auth.currentUser;
    if (user == null) {
      Get.snackbar("Akses Dibatasi", "Silakan login untuk menyimpan.");
      return;
    }

    var docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(museum.id);

    try {
      if (isSaved.value) {
        await docRef.delete();
        isSaved.value = false;
        Get.snackbar("Dihapus", "Museum dihapus dari koleksi.");
      } else {
        await docRef.set({
          'id': museum.id,
          'title': museum.title,
          'subtitle': museum.subtitle,
          'category': 'Museum',
          'image_url': museum.imageUrl,
          'description': museum.description,
          'price': museum.price,
          'saved_at': FieldValue.serverTimestamp(),
        });
        isSaved.value = true;
        Get.snackbar("Disimpan", "Museum berhasil disimpan.");
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  void setRating(int rating) {
    userRating.value = rating;
  }
}
