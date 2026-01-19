import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/daftarsave_controller.dart';

// --- TEMA WARNA ---
class WayangColors {
  static const Color primaryDark = Color(0xFF4E342E);
  static const Color primaryLight = Color(0xFF8D6E63);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color background = Color(0xFFFAFAF5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF3E2723);
  static const Color textSecondary = Color(0xFF795548);
}

class DaftarsaveView extends GetView<DaftarsaveController> {
  const DaftarsaveView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller jika belum ada
    if (!Get.isRegistered<DaftarsaveController>()) {
      Get.put(DaftarsaveController());
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
          'Koleksi Tersimpan',
          style: TextStyle(
            color: WayangColors.primaryDark,
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      // MENGGUNAKAN STREAMBUILDER UNTUK DATA REALTIME
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.bookmarksStream,
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: WayangColors.primaryDark),
            );
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // 4. Data Ada -> Tampilkan List
          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;

              // Ambil Data dengan Default Value
              String title = data['title'] ?? 'Tanpa Judul';
              String category = data['category'] ?? 'Umum';
              String imageUrl = data['image_url'] ?? '';

              return _buildSavedCard(
                title: title,
                category: category,
                imageUrl: imageUrl,
                onRemove: () => controller.removeBookmark(doc.id),
                onTap: () => controller.navigateToDetail(data),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: WayangColors.primaryDark.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Ionicons.bookmark_outline,
              size: 80,
              color: WayangColors.primaryDark.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Belum Ada Arsip",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
              color: WayangColors.primaryDark.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Simpan konten menarik agar\nmudah dibaca kembali nanti.",
            textAlign: TextAlign.center,
            style: TextStyle(color: WayangColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCard({
    required String title,
    required String category,
    required String imageUrl,
    required VoidCallback onRemove,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: WayangColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: WayangColors.primaryDark.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // --- GAMBAR ---
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: WayangColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: WayangColors.goldAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: _buildImage(imageUrl),
                  ),
                ),

                const SizedBox(width: 16),

                // --- INFO ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: WayangColors.goldAccent,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: WayangColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- TOMBOL HAPUS ---
                IconButton(
                  onPressed: onRemove,
                  splashRadius: 24,
                  icon: const Icon(
                    Ionicons.bookmark,
                    color: WayangColors.goldAccent,
                    size: 24,
                  ),
                  tooltip: "Hapus Simpanan",
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
    if (path.isEmpty)
      return const Icon(Ionicons.image_outline, color: Colors.grey);

    try {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.error),
        );
      } else if (path.startsWith('assets/')) {
        return Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.error),
        );
      } else {
        String cleanBase64 = path.replaceAll(RegExp(r'\s+'), '');
        if (cleanBase64.contains(','))
          cleanBase64 = cleanBase64.split(',').last;
        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.error),
        );
      }
    } catch (e) {
      return const Icon(Ionicons.image_outline, color: Colors.grey);
    }
  }
}
