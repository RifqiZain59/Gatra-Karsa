import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/date_symbol_data_local.dart';

class RiwayatloginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var loginHistory = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi bahasa Indonesia untuk format tanggal
    initializeDateFormatting('id_ID', null).then((_) {
      fetchHistory();
    });
  }

  // --- 1. AMBIL DATA DARI FIRESTORE (REAL-TIME) ---
  void fetchHistory() {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Mendengarkan perubahan data secara real-time
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('login_history')
            .orderBy(
              'last_login',
              descending: true,
            ) // Gunakan last_login sesuai LoginController
            .limit(20)
            .snapshots()
            .listen(
              (snapshot) {
                loginHistory.value = snapshot.docs.map((doc) {
                  Map<String, dynamic> data = doc.data();

                  // Kita petakan agar sesuai dengan variabel yang dipanggil di View
                  return {
                    'id': doc.id,
                    'device': data['device_info'] ?? 'Unknown Device',
                    'platform':
                        data['platform'] ??
                        (Platform.isAndroid ? 'Android' : 'iOS'),
                    'timestamp':
                        data['last_login'], // Ini akan menjadi objek Timestamp Firestore
                  };
                }).toList();

                isLoading.value = false;
              },
              onError: (error) {
                print("Error listener: $error");
                isLoading.value = false;
              },
            );
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      print("Gagal mengambil riwayat: $e");
      isLoading.value = false;
    }
  }

  // --- 2. FUNGSI UNTUK MENDAPATKAN NAMA DEVICE SAAT INI ---
  // Fungsi ini bisa digunakan oleh LoginController saat user login
  Future<Map<String, String>> getCurrentDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String model = "Unknown Device";
    String platform = Platform.isAndroid ? "Android" : "iOS";

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // Contoh: Samsung SM-G991B
        model = "${androidInfo.brand} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        model = iosInfo.name;
      }
    } catch (e) {
      print("Gagal deteksi device: $e");
    }

    return {"model": model, "platform": platform};
  }

  // --- 3. FITUR TAMBAHAN: HAPUS RIWAYAT (OPSIONAL) ---
  Future<void> clearHistory() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        var snapshots = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('login_history')
            .get();

        for (var doc in snapshots.docs) {
          await doc.reference.delete();
        }
        Get.snackbar("Sukses", "Riwayat login telah dibersihkan");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus riwayat");
    }
  }
}
