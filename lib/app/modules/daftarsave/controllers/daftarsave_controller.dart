import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:gatrakarsa/app/modules/detailevent/views/detailevent_view.dart';
import 'package:gatrakarsa/app/modules/detailmuseum/views/detailmuseum_view.dart';

class DaftarsaveController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk mendengarkan perubahan data bookmarks
  Stream<QuerySnapshot> get bookmarksStream {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .orderBy('saved_at', descending: true)
          .snapshots();
    } else {
      // Return stream kosong jika belum login
      return const Stream.empty();
    }
  }

  // Fungsi Hapus Bookmark
  Future<void> removeBookmark(String docId) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .doc(docId)
          .delete();

      Get.snackbar(
        "Dihapus",
        "Item dihapus dari koleksi tersimpan",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus: $e");
    }
  }

  // Fungsi Navigasi ke Detail
  void navigateToDetail(Map<String, dynamic> data) {
    // Konversi Map ke ContentModel
    ContentModel item = ContentModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
      location: data['location'], // Opsional
      price: data['price'], // Opsional
    );

    String category = item.category.toLowerCase();

    // Logika Routing Berdasarkan Kategori
    if (category.contains('kisah')) {
    } else if (category.contains('event')) {
      Get.to(() => const DetaileventView(), arguments: item);
    } else if (category.contains('museum')) {
      Get.to(() => const DetailmuseumView(), arguments: item);
    } else {
      Get.snackbar("Info", "Detail konten ini belum tersedia");
    }
  }
}
