import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DetaileventController extends GetxController {
  late ContentModel event;
  var isSaved = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController reviewController = TextEditingController();
  var userRating = 5.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ContentModel) {
      event = Get.arguments as ContentModel;
    } else {
      event = ContentModel(
        id: '0',
        title: 'Unknown',
        subtitle: '',
        category: 'Event',
        description: '',
        imageUrl: '',
      );
    }
    checkSaveStatus();
  }

  void checkSaveStatus() async {
    User? user = _auth.currentUser;
    if (user == null) return;
    try {
      var doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .doc(event.id)
          .get();
      isSaved.value = doc.exists;
    } catch (e) {
      print(e);
    }
  }

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
        .doc(event.id);

    try {
      if (isSaved.value) {
        await docRef.delete();
        isSaved.value = false;
        Get.snackbar(
          "Dihapus",
          "Event dihapus dari bookmark",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        await docRef.set({
          'id': event.id,
          'title': event.title,
          'subtitle': event.subtitle,
          'category': 'Event',
          'image_url': event.imageUrl,
          'description': event.description,
          'location': event.location,
          'price': event.price,
          'saved_at': FieldValue.serverTimestamp(),
        });
        isSaved.value = true;
        Get.snackbar(
          "Disimpan",
          "Event disimpan",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    }
  }

  // --- PERBAIKAN DI SINI (OPEN MAP) ---
  void openMap() async {
    if (event.location == null || event.location!.isEmpty) {
      Get.snackbar("Info", "Lokasi tidak tersedia");
      return;
    }

    // Format URL Google Maps Search yang benar
    final Uri googleUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(event.location!)}",
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

  Stream<QuerySnapshot> get ulasanStream {
    return _firestore
        .collection('contents')
        .doc(event.id)
        .collection('reviews')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  void setRating(int rating) => userRating.value = rating;

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
        'user_id': user.uid,
        'user_name': userName,
        'user_photo': userPhoto,
        'rating': userRating.value,
        'comment': reviewController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('contents')
          .doc(event.id)
          .collection('reviews')
          .add(reviewData);

      Map<String, dynamic> userHistoryData = {
        ...reviewData,
        'content_id': event.id,
        'targetName': event.title,
        'category': 'Event',
        'image': event.imageUrl,
      };
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reviews')
          .add(userHistoryData);

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
