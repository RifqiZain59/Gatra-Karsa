import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart'; // Sesuaikan path ini
import 'package:url_launcher/url_launcher.dart';

class DetailmuseumController extends GetxController {
  late ContentModel museum;
  var isSaved = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController reviewController = TextEditingController();
  var userRating = 5.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ContentModel) {
      museum = Get.arguments as ContentModel;
    } else {
      museum = ContentModel(
        id: '0',
        title: 'Unknown',
        subtitle: '',
        category: 'Museum',
        description: '',
        imageUrl: '',
      );
    }
    checkSaveStatus();
  }

  // --- CEK STATUS BOOKMARK ---
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
      print("Error checking save status: $e");
    }
  }

  // --- TOGGLE SAVE (BOOKMARK) ---
  void toggleSave() async {
    User? user = _auth.currentUser;
    if (user == null) {
      Get.snackbar("Akses Dibatasi", "Silakan login.");
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
        Get.snackbar(
          "Dihapus",
          "Museum dihapus dari bookmark",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        await docRef.set({
          'id': museum.id,
          'title': museum.title,
          'subtitle': museum.subtitle,
          'category': 'Museum',
          'image_url': museum.imageUrl,
          'description': museum.description,
          'location': museum.location,
          'price': museum.price,
          'saved_at': FieldValue.serverTimestamp(),
        });
        isSaved.value = true;
        Get.snackbar(
          "Disimpan",
          "Museum disimpan",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  // --- OPEN MAP (Prioritas mapsUrl, Fallback ke Subtitle/Location) ---
  void openMap() async {
    // 1. Cek apakah ada link maps_url spesifik dari data API
    if (museum.mapsUrl != null && museum.mapsUrl!.isNotEmpty) {
      final Uri url = Uri.parse(museum.mapsUrl!);
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          return; // Keluar function jika sukses
        }
      } catch (e) {
        print("Gagal buka mapsUrl langsung: $e");
      }
    }

    // 2. Fallback: Cari manual berdasarkan Subtitle (biasanya alamat lengkap) atau Location
    String query = museum.subtitle.isNotEmpty
        ? museum.subtitle
        : (museum.location ?? "");

    if (query.isEmpty) {
      Get.snackbar("Info", "Lokasi tidak tersedia");
      return;
    }

    // Format URL pencarian Google Maps
    final Uri googleUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}",
    );

    try {
      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(googleUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal membuka peta: $e");
    }
  }

  // --- STREAM ULASAN (TANPA orderBy agar tidak butuh Index) ---
  Stream<QuerySnapshot> get ulasanStream {
    return _firestore
        .collection('museum_user')
        .where('content_id', isEqualTo: museum.id)
        // .orderBy(...) <-- DIHAPUS SENGAJA
        .snapshots();
  }

  void setRating(int rating) => userRating.value = rating;

  // --- KIRIM ULASAN ---
  void submitReview() async {
    User? user = _auth.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Login dulu.");
      return;
    }
    if (reviewController.text.trim().isEmpty) return;

    try {
      var userDoc = await _firestore.collection('users').doc(user.uid).get();
      String userName =
          (userDoc.data() as Map<String, dynamic>?)?['name'] ?? 'Pengguna';
      String userPhoto =
          (userDoc.data() as Map<String, dynamic>?)?['photoBase64'] ?? '';

      Map<String, dynamic> reviewData = {
        'content_id': museum.id,
        'targetName': museum.title,
        'category': 'Museum',
        'image': museum.imageUrl,
        'user_id': user.uid,
        'user_name': userName,
        'user_photo': userPhoto,
        'rating': userRating.value,
        'comment': reviewController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('museum_user').add(reviewData);

      reviewController.clear();
      userRating.value = 5;
      Get.snackbar(
        "Sukses",
        "Ulasan terkirim!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
