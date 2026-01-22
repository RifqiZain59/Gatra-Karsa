import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/daftarlike_controller.dart';
import '../../detail_wayang/views/detail_wayang_view.dart';

// 1. IMPORT PENTING: Gunakan Model dari API Service agar datanya terbaca di halaman Detail
import 'package:gatrakarsa/app/data/service/api_service.dart';

class DaftarlikeView extends GetView<DaftarlikeController> {
  const DaftarlikeView({super.key});

  // --- PALET WARNA (Sesuai HomeView) ---
  static const Color primaryColor = Color(0xFF3E2723); // Coklat Tua
  static const Color secondaryColor = Color(0xFF5D4037); // Coklat Medium
  static const Color accentColor = Color(0xFFD4AF37); // Emas
  static const Color bgColor = Color(0xFFFDFCF8); // Putih Tulang
  static const Color surfaceColor = Colors.white;

  // Helper Decode Image (Base64)
  Uint8List? _decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      if (base64String.contains(',')) {
        return base64Decode(base64String.split(',').last);
      }
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan controller ter-inject
    if (!Get.isRegistered<DaftarlikeController>()) {
      Get.put(DaftarlikeController());
    }

    final User? user = FirebaseAuth.instance.currentUser;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: bgColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Ionicons.arrow_back, color: primaryColor),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Koleksi Disukai',
            style: GoogleFonts.philosopher(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        body: user == null
            ? Center(
                child: Text(
                  "Silakan login untuk melihat koleksi.",
                  style: GoogleFonts.mulish(color: Colors.grey),
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                // Mengambil stream dari Controller (atau langsung firestore jika controller belum siap)
                stream: controller.streamFavorites(),
                builder: (context, snapshot) {
                  // 1. Loading State
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }

                  // 2. Empty State
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.05),
                            ),
                            child: Icon(
                              Ionicons.heart_dislike_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Belum ada koleksi yang disukai",
                            style: GoogleFonts.mulish(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Jelajahi wayang dan simpan favoritmu!",
                            style: GoogleFonts.mulish(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // 3. Data Loaded
                  var docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;

                      // 2. MAPPING DATA KE CONTENTMODEL (Dari API Service)
                      ContentModel item = ContentModel(
                        id: data['id'] ?? '',
                        title: data['title'] ?? '',
                        subtitle: data['subtitle'] ?? '',
                        category: data['category'] ?? 'Umum',
                        description: data['description'] ?? '',
                        imageUrl: data['image_url'] ?? '',
                      );

                      Uint8List? imageBytes = _decodeImage(item.imageUrl);

                      return GestureDetector(
                        onTap: () {
                          // Kirim data ke DetailWayangView
                          Get.to(
                            () => const DetailWayangView(),
                            arguments: item,
                          );
                        },
                        child: Container(
                          height: 110,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.06),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // --- GAMBAR DI KIRI ---
                              Hero(
                                tag: 'thumb_${item.id}',
                                child: Container(
                                  width: 100,
                                  height: 110,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    ),
                                    child: imageBytes != null
                                        ? Image.memory(
                                            imageBytes,
                                            fit: BoxFit.cover,
                                          )
                                        : (item.imageUrl.startsWith('http')
                                              ? Image.network(
                                                  item.imageUrl,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  'assets/wayang purwa.png',
                                                  fit: BoxFit.cover,
                                                )),
                                  ),
                                ),
                              ),

                              // --- INFO DI TENGAH ---
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: accentColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          item.category.toUpperCase(),
                                          style: GoogleFonts.mulish(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: secondaryColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.philosopher(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.mulish(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // --- ICON PANAH DI KANAN ---
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Ionicons.chevron_forward,
                                    size: 18,
                                    color: secondaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
