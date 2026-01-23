import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/ulasan_controller.dart';

// --- TEMA WARNA PREMIUM ---
class WayangColors {
  static const Color primaryDark = Color(0xFF3E2723); // Coklat Tua
  static const Color primaryLight = Color(0xFF5D4037);
  static const Color goldAccent = Color(0xFFD4AF37); // Emas
  static const Color background = Color(0xFFFDFCF8); // Putih Tulang
  static const Color surface = Colors.white;
  static const Color textSecondary = Color(0xFF795548);
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
      // PERUBAHAN TIPE STREAM: List<DocumentSnapshot>
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: controller.myReviewsStream,
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: WayangColors.primaryDark),
            );
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // Data (Snapshot sekarang langsung List, bukan .docs lagi)
          List<DocumentSnapshot> docs = snapshot.data ?? [];
          int totalReviews = docs.length;

          return Stack(
            children: [
              // --- BACKGROUND DECORATION ---
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: WayangColors.goldAccent.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: WayangColors.primaryDark.withOpacity(0.05),
                  ),
                ),
              ),

              // --- MAIN CONTENT ---
              SafeArea(
                child: Column(
                  children: [
                    // 1. HEADER
                    _buildHeader(),

                    // 2. KOTAK TOTAL (SUMMARY CARD)
                    _buildTotalSummaryCard(totalReviews),

                    // 3. LIST DATA
                    Expanded(
                      child: docs.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                10,
                                20,
                                20,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                // Ambil dokumen langsung
                                var doc = docs[index];
                                var data = doc.data() as Map<String, dynamic>;

                                // Kirim doc utuh untuk keperluan delete reference
                                return _buildReviewCard(context, data, doc);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Ionicons.arrow_back,
                color: WayangColors.primaryDark,
                size: 20,
              ),
            ),
          ),
          Text(
            "Riwayat Ulasan",
            style: GoogleFonts.philosopher(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: WayangColors.primaryDark,
            ),
          ),
          const SizedBox(width: 40), // Spacer penyeimbang
        ],
      ),
    );
  }

  // --- KOTAK TOTAL (SUMMARY) ---
  Widget _buildTotalSummaryCard(int total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [WayangColors.primaryDark, WayangColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: WayangColors.primaryDark.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Kontribusi",
                style: GoogleFonts.mulish(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "$total",
                    style: GoogleFonts.philosopher(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: WayangColors.goldAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Ulasan",
                    style: GoogleFonts.mulish(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Ionicons.chatbubbles_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  // --- KARTU ULASAN ---
  Widget _buildReviewCard(
    BuildContext context,
    Map<String, dynamic> data,
    DocumentSnapshot doc, // Parameter diubah menerima DocumentSnapshot
  ) {
    // Format Data
    String title = data['targetName'] ?? 'Tanpa Judul';
    String category = data['category'] ?? 'Umum';
    String imageUrl = data['image'] ?? data['image_url'] ?? '';
    String comment = data['comment'] ?? '';
    int rating = data['rating'] ?? 0;

    // Format Tanggal
    String dateStr = "-";
    if (data['created_at'] != null && data['created_at'] is Timestamp) {
      DateTime dt = (data['created_at'] as Timestamp).toDate();
      dateStr = "${dt.day}/${dt.month}/${dt.year}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: WayangColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: WayangColors.primaryDark.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR ---
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildImageLoader(imageUrl),
              ),
            ),

            const SizedBox(width: 16),

            // --- INFO ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: WayangColors.goldAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: GoogleFonts.mulish(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: WayangColors.goldAccent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Judul
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.philosopher(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: WayangColors.primaryDark,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Bintang Rating & Tanggal
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating
                                ? Ionicons.star
                                : Ionicons.star_outline,
                            size: 12,
                            color: WayangColors.goldAccent,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: GoogleFonts.mulish(
                          fontSize: 10,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Isi Komentar
                  Text(
                    comment.isNotEmpty ? "\"$comment\"" : "Tidak ada komentar",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.mulish(
                      fontSize: 12,
                      color: WayangColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // --- TOMBOL HAPUS ---
            // Mengirim DocumentSnapshot utuh agar controller bisa ambil reference-nya
            IconButton(
              onPressed: () => controller.deleteReview(doc),
              icon: Icon(
                Ionicons.trash_outline,
                size: 20,
                color: Colors.red.withOpacity(0.6),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Gambar
  Widget _buildImageLoader(String path) {
    if (path.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Ionicons.image_outline, color: Colors.grey),
      );
    }
    try {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, color: Colors.grey),
        );
      } else if (path.startsWith('assets/')) {
        return Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, color: Colors.grey),
        );
      } else {
        String cleanBase64 = path.replaceAll(RegExp(r'\s+'), '');
        if (cleanBase64.contains(','))
          cleanBase64 = cleanBase64.split(',').last;
        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image, color: Colors.grey),
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
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: WayangColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: WayangColors.primaryDark.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Ionicons.chatbubbles_outline,
              size: 60,
              color: WayangColors.primaryLight.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Belum Ada Ulasan",
            style: GoogleFonts.philosopher(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: WayangColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Mulai berikan ulasan pada\nmuseum atau event wayang yang kamu kunjungi.",
            textAlign: TextAlign.center,
            style: GoogleFonts.mulish(
              color: WayangColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
