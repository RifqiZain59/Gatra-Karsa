import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DaftarlikeController extends GetxController {
  // Fungsi untuk mendapatkan Stream data koleksi favorit
  Stream<QuerySnapshot<Map<String, dynamic>>> streamFavorites() {
    final user = FirebaseAuth.instance.currentUser;

    // Pastikan user sudah login sebelum mengambil data
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('saved_at', descending: true)
          .snapshots();
    } else {
      // Jika belum login, kembalikan stream kosong agar tidak error
      return const Stream.empty();
    }
  }
}
