import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UlasanController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- STREAM: AMBIL DATA LANGSUNG DARI USERS ---
  // Tidak perlu index manual, tidak perlu logic aneh-aneh.
  Stream<QuerySnapshot> get myReviewsStream {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reviews')
          .orderBy('created_at', descending: true)
          .snapshots();
    } else {
      return const Stream.empty();
    }
  }

  // --- FUNGSI: HAPUS ULASAN ---
  Future<void> deleteReview(String docId) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // Hapus dari riwayat user
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reviews')
          .doc(docId)
          .delete();

      if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar(
        "Dihapus",
        "Ulasan berhasil dihapus",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus: $e");
    }
  }
}
