import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Perlu import ini untuk Colors
import 'package:get/get.dart';
import 'package:async/async.dart'; // Pastikan package 'async' ada di pubspec.yaml

class UlasanController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream Gabungan: Mengembalikan List<DocumentSnapshot>
  Stream<List<DocumentSnapshot>> get myReviewsStream {
    String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return Stream.value([]);

    // 1. Stream dari Museum
    var streamMuseum = _firestore
        .collection('museum_user')
        .where('user_id', isEqualTo: uid)
        .snapshots();

    // 2. Stream dari Event
    var streamEvent = _firestore
        .collection('event_user')
        .where('user_id', isEqualTo: uid)
        .snapshots();

    // 3. Gabungkan kedua Stream menggunakan StreamZip
    return StreamZip([streamMuseum, streamEvent]).map((
      List<QuerySnapshot> snapshots,
    ) {
      List<DocumentSnapshot> allDocs = [];

      // Masukkan semua dokumen museum
      allDocs.addAll(snapshots[0].docs);
      // Masukkan semua dokumen event
      allDocs.addAll(snapshots[1].docs);

      // 4. Sorting (Urutkan berdasarkan tanggal created_at descending/terbaru)
      allDocs.sort((a, b) {
        // Ambil created_at, handle jika null
        Timestamp t1 =
            (a.data() as Map<String, dynamic>)['created_at'] ?? Timestamp.now();
        Timestamp t2 =
            (b.data() as Map<String, dynamic>)['created_at'] ?? Timestamp.now();
        return t2.compareTo(t1); // t2 banding t1 agar descending
      });

      return allDocs;
    });
  }

  // Hapus Review
  void deleteReview(DocumentSnapshot doc) {
    Get.defaultDialog(
      title: "Hapus Ulasan?",
      middleText: "Ulasan ini akan dihapus permanen.",
      textConfirm: "Hapus",
      textCancel: "Batal",
      // PERBAIKAN DI SINI: Menggunakan warna langsung
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF3E2723), // Warna Coklat Tua (PrimaryDark)
      cancelTextColor: const Color(0xFF3E2723),
      onConfirm: () async {
        try {
          // Hapus langsung dari referensi dokumen
          await doc.reference.delete();
          Get.back(); // Tutup dialog
          Get.snackbar(
            "Sukses",
            "Ulasan berhasil dihapus",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.back();
          Get.snackbar(
            "Error",
            "Gagal menghapus: $e",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }
}
