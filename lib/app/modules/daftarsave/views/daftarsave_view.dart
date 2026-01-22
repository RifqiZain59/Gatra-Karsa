import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/daftarsave_controller.dart';

// --- TEMA WARNA PREMIUM ---
class WayangColors {
  static const Color primaryDark = Color(0xFF3E2723); // Coklat Tua
  static const Color primaryLight = Color(0xFF5D4037);
  static const Color goldAccent = Color(0xFFD4AF37); // Emas
  static const Color background = Color(0xFFFDFCF8); // Putih Tulang
  static const Color surface = Colors.white;
  static const Color textSecondary = Color(0xFF795548);
}

class DaftarsaveView extends GetView<DaftarsaveController> {
  const DaftarsaveView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DaftarsaveController>()) {
      Get.put(DaftarsaveController());
    }

    return Scaffold(
      backgroundColor: WayangColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.bookmarksStream,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: WayangColors.primaryDark),
            );
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          // Data
          var docs = snapshot.hasData ? snapshot.data!.docs : [];
          int totalSaved = docs.length;

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
                    // 1. HEADER NAVIGASI
                    _buildAppBar(),

                    // 2. KOTAK TOTAL (SUMMARY CARD)
                    _buildTotalSummaryCard(totalSaved),

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
                                var doc = docs[index];
                                var data = doc.data() as Map<String, dynamic>;

                                return _buildSavedCard(
                                  title: data['title'] ?? 'Tanpa Judul',
                                  category: data['category'] ?? 'Umum',
                                  subtitle: data['subtitle'] ?? '',
                                  imageUrl: data['image_url'] ?? '',
                                  onRemove: () =>
                                      controller.removeBookmark(doc.id),
                                  onTap: () =>
                                      controller.navigateToDetail(data),
                                );
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

  // --- 1. HEADER SEDERHANA ---
  Widget _buildAppBar() {
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
            "Arsip Pribadi",
            style: GoogleFonts.philosopher(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: WayangColors.primaryDark,
            ),
          ),
          const SizedBox(width: 40), // Penyeimbang
        ],
      ),
    );
  }

  // --- 2. KOTAK TOTAL (BARU) ---
  Widget _buildTotalSummaryCard(int total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Gradient Coklat Mewah
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
                "Total Disimpan",
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
                      color: WayangColors.goldAccent, // Angka warna Emas
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Item",
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
          // Icon Besar Transparan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Ionicons.bookmark, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  // --- WIDGET EMPTY STATE ---
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
              Ionicons.folder_open_outline,
              size: 60,
              color: WayangColors.primaryLight.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Belum Ada Arsip",
            style: GoogleFonts.philosopher(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: WayangColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Simpan konten menarik agar\nmudah dibaca kembali nanti.",
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

  // --- WIDGET CARD (LIST ITEM) ---
  Widget _buildSavedCard({
    required String title,
    required String category,
    required String subtitle,
    required String imageUrl,
    required VoidCallback onRemove,
    required VoidCallback onTap,
  }) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // --- GAMBAR ---
                Hero(
                  tag: 'saved_$title',
                  child: Container(
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
                      child: _buildImage(imageUrl),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // --- INFO ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(
                        subtitle.isNotEmpty ? subtitle : "Klik untuk detail",
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

                // --- TOMBOL HAPUS ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Ionicons.trash_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    tooltip: "Hapus dari koleksi",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Gambar
  Widget _buildImage(String path) {
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
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      } else if (path.startsWith('assets/')) {
        return Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      } else {
        String cleanBase64 = path.replaceAll(RegExp(r'\s+'), '');
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',').last;
        }
        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      }
    } catch (e) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.error_outline, color: Colors.grey),
      );
    }
  }
}
