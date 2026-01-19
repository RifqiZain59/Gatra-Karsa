import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/ulasan_controller.dart';

// --- TEMA WARNA ---
class WayangColors {
  static const Color primaryDark = Color(0xFF4E342E);
  static const Color primaryLight = Color(0xFF8D6E63);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color background = Color(0xFFFAFAF5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF3E2723);
  static const Color cardBg = Color(0xFFFFFFFF);
}

class UlasanView extends GetView<UlasanController> {
  const UlasanView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UlasanController>()) {
      Get.put(UlasanController());
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
          'Riwayat Ulasan',
          style: TextStyle(
            color: WayangColors.primaryDark,
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.myReviewsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: WayangColors.primaryDark),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;
              return _buildHistoryCard(context, data, doc.id);
            },
          );
        },
      ),
    );
  }

  // --- WIDGET KARTU ULASAN (LAYOUT DIPERBAIKI) ---
  Widget _buildHistoryCard(
    BuildContext context,
    Map<String, dynamic> data,
    String docId,
  ) {
    // Format Tanggal
    String dateStr = "-";
    if (data['created_at'] != null && data['created_at'] is Timestamp) {
      DateTime dt = (data['created_at'] as Timestamp).toDate();
      dateStr = "${dt.day}/${dt.month}/${dt.year}";
    }

    String title = data['targetName'] ?? 'Tanpa Judul';
    String category = data['category'] ?? 'Umum';
    String imageUrl = data['image'] ?? data['image_url'] ?? '';
    String comment = data['comment'] ?? '';
    int rating = data['rating'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: WayangColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: WayangColors.primaryDark.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              20,
            ), // Padding disesuaikan
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BAGIAN ATAS: Gambar + Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Gambar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImageLoader(imageUrl),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 2. Info Teks
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kategori Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: WayangColors.goldAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: WayangColors.primaryDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Judul (Dibatasi agar tidak nabrak icon hapus)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 24.0,
                            ), // Padding kanan extra untuk icon hapus
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Serif',
                                color: WayangColors.textPrimary,
                                height: 1.1,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Rating & Tanggal (Satu Baris di Bawah Judul)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Bintang
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < rating
                                        ? Ionicons.star
                                        : Ionicons.star_outline,
                                    size: 14,
                                    color: WayangColors.goldAccent,
                                  ),
                                ),
                              ),

                              // Tanggal (Dipindah ke sini agar aman)
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 3. Isi Komentar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WayangColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.format_quote_rounded,
                        size: 20,
                        color: WayangColors.primaryLight,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment,
                        style: const TextStyle(
                          color: WayangColors.textPrimary,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TOMBOL HAPUS (Absolut di Pojok Kanan Atas)
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              onPressed: () => controller.deleteReview(docId),
              icon: Icon(
                Ionicons.trash_outline,
                size: 20,
                color: Colors.red.withOpacity(0.5),
              ),
              splashRadius: 20,
              tooltip: "Hapus",
            ),
          ),
        ],
      ),
    );
  }

  // Helper Loader Gambar
  Widget _buildImageLoader(String path) {
    if (path.isEmpty)
      return const Icon(Ionicons.image_outline, color: Colors.grey);
    try {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
      } else if (path.startsWith('assets/')) {
        return Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
      } else {
        String cleanBase64 = path.replaceAll(RegExp(r'\s+'), '');
        if (cleanBase64.contains(','))
          cleanBase64 = cleanBase64.split(',').last;
        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.image),
        );
      }
    } catch (e) {
      return const Icon(Ionicons.image_outline, color: Colors.grey);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.chatbubble_ellipses_outline,
            size: 80,
            color: WayangColors.primaryDark.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          const Text(
            "Belum Ada Ulasan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
