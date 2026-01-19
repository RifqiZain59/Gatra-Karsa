import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';

class DetailkisahController extends GetxController {
  late ContentModel story;
  var isSaved = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController reviewController = TextEditingController();
  var userRating = 5.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ContentModel) {
      story = Get.arguments as ContentModel;
    } else {
      story = ContentModel(
        id: '0',
        title: 'Unknown',
        subtitle: '',
        category: 'Kisah',
        description: '',
        imageUrl: '',
      );
    }
    checkSaveStatus();
  }

  // --- CEK STATUS (Di dalam Users -> Bookmarks) ---
  void checkSaveStatus() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users') // Masuk ke users
          .doc(user.uid) // Pilih user yang login
          .collection('bookmarks') // Masuk ke sub-collection bookmarks
          .doc(story.id)
          .get();

      isSaved.value = doc.exists;
    } catch (e) {
      print("Error checking save: $e");
    }
  }

  // --- SAVE DATA (Ke Users -> Bookmarks) ---
  void toggleSave() async {
    User? user = _auth.currentUser;
    if (user == null) {
      Get.snackbar("Akses Dibatasi", "Silakan login untuk menyimpan.");
      return;
    }

    DocumentReference docRef = _firestore
        .collection('users') // 1. Collection Users
        .doc(user.uid) // 2. Dokumen User ID
        .collection('bookmarks') // 3. Sub-Collection Bookmarks
        .doc(story.id); // 4. Dokumen ID Konten

    try {
      if (isSaved.value) {
        await docRef.delete();
        isSaved.value = false;
        Get.snackbar(
          "Dihapus",
          "Dihapus dari koleksi pribadi",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        await docRef.set({
          'id': story.id,
          'title': story.title,
          'subtitle': story.subtitle,
          'category': 'Kisah',
          'image_url': story.imageUrl,
          'description': story.description,
          'saved_at': FieldValue.serverTimestamp(),
        });
        isSaved.value = true;
        Get.snackbar(
          "Disimpan",
          "Masuk ke koleksi pribadi",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan: $e");
    }
  }

  // --- SUBMIT REVIEW (Ke Users -> Reviews) ---
  void submitReview() async {
    User? user = _auth.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Login diperlukan.");
      return;
    }
    if (reviewController.text.trim().isEmpty) return;

    try {
      // Ambil data profil user untuk disimpan di ulasan
      var userDoc = await _firestore.collection('users').doc(user.uid).get();
      String userName =
          (userDoc.data() as Map<String, dynamic>?)?['name'] ?? 'Pengguna';
      String userPhoto =
          (userDoc.data() as Map<String, dynamic>?)?['photoBase64'] ?? '';

      // Data Ulasan
      Map<String, dynamic> reviewData = {
        'user_id': user.uid,
        'user_name': userName,
        'user_photo': userPhoto,
        'rating': userRating.value,
        'comment': reviewController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
        // Data konten agar history user lengkap
        'content_id': story.id,
        'targetName': story.title,
        'category': 'Kisah',
        'image': story.imageUrl,
      };

      // 1. SIMPAN KE USERS (Riwayat Pribadi) -> INI YANG ANDA MINTA
      await _firestore
          .collection('users') // Collection Users
          .doc(user.uid) // User ID
          .collection('reviews') // Sub-Collection Reviews
          .add(reviewData);

      // 2. SIMPAN KE CONTENTS (Agar tampil di halaman detail untuk orang lain)
      await _firestore
          .collection('contents')
          .doc(story.id)
          .collection('reviews')
          .add(reviewData);

      reviewController.clear();
      userRating.value = 5;
      Get.snackbar(
        "Sukses",
        "Ulasan tersimpan di profil Anda!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Gagal", "Error: $e");
    }
  }

  // Stream untuk menampilkan ulasan orang lain di halaman detail
  Stream<QuerySnapshot> get ulasanStream {
    return _firestore
        .collection('contents')
        .doc(story.id)
        .collection('reviews')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  void setRating(int rating) => userRating.value = rating;

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
