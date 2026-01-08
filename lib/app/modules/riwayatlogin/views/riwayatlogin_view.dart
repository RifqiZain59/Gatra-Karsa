import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/riwayatlogin_controller.dart';

class WayangColors {
  static const Color primaryDark = Color(0xFF4E342E);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color background = Color(0xFFFAFAF5);
  static const Color surface = Colors.white;
}

class RiwayatloginView extends GetView<RiwayatloginController> {
  const RiwayatloginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Memastikan controller ter-inject
    if (!Get.isRegistered<RiwayatloginController>()) {
      Get.put(RiwayatloginController());
    }

    return Scaffold(
      backgroundColor: WayangColors.background,
      appBar: AppBar(
        backgroundColor: WayangColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Ionicons.arrow_back,
            color: WayangColors.primaryDark,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Aktivitas Login',
          style: TextStyle(
            color: WayangColors.primaryDark,
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: WayangColors.primaryDark),
          );
        }

        if (controller.loginHistory.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchHistory(),
          color: WayangColors.goldAccent,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: controller.loginHistory.length,
            itemBuilder: (context, index) {
              final data = controller.loginHistory[index];
              // index 0 dianggap sebagai sesi terbaru
              return _buildPremiumHistoryCard(data, index == 0);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.shield_checkmark_outline,
            size: 80,
            color: WayangColors.primaryDark.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum Ada Riwayat",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: WayangColors.primaryDark,
              fontFamily: 'Serif',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHistoryCard(Map<String, dynamic> data, bool isLatest) {
    // Sinkronisasi field dengan Controller
    String deviceName = _formatDeviceName(data['device'] ?? "Unknown Device");
    String platform = data['platform'] ?? "Android";

    // Penanganan Timestamp Firestore
    dynamic rawTimestamp = data['timestamp'];
    String dateStr = "-";
    String timeStr = "-";

    if (rawTimestamp != null && rawTimestamp is Timestamp) {
      DateTime date = rawTimestamp.toDate();
      dateStr = DateFormat('EEE, d MMM yyyy', 'id_ID').format(date);
      timeStr = DateFormat('HH:mm').format(date);
    }

    bool isIos = platform.toLowerCase() == 'ios';
    IconData iconDevice = isIos ? Ionicons.logo_apple : Ionicons.logo_android;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: WayangColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isLatest
            ? Border.all(
                color: WayangColors.goldAccent.withOpacity(0.5),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Ikon Platform
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isIos ? Colors.grey[100] : Colors.green[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                iconDevice,
                color: isIos ? Colors.black87 : Colors.green[700],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Detail Device
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLatest)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: WayangColors.goldAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "AKTIF SEKARANG",
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    deviceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: WayangColors.primaryDark,
                      fontFamily: 'Serif',
                    ),
                  ),
                  Text(
                    "Terakhir masuk dari Indonesia",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            // Waktu
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: WayangColors.primaryDark,
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDeviceName(String rawName) {
    if (rawName.isEmpty || rawName == "Unknown Device")
      return "Perangkat Tidak Dikenal";
    return rawName
        .split(' ')
        .map((word) {
          if (word.isEmpty) return "";
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
