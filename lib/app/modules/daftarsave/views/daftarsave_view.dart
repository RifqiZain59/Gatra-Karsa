import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../controllers/daftarsave_controller.dart';

// --- TEMA WARNA (Konsisten) ---
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
    // TIPS: Data Dummy untuk preview tampilan Save
    final List<Map<String, String>> items = [
      {
        'title': 'Wayang Kulit Arjuna',
        'category': 'Tokoh Pandawa',
        'image': 'https://via.placeholder.com/150',
      },
      {
        'title': 'Museum Wayang Kekayon',
        'category': 'Destinasi Budaya',
        'image': 'https://via.placeholder.com/150',
      },
      {
        'title': 'Pagelaran Semalam Suntuk',
        'category': 'Event Seni',
        'image': 'https://via.placeholder.com/150',
      },
    ];

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
          'Koleksi Tersimpan', // Diubah judulnya
          style: TextStyle(
            color: WayangColors.primaryDark,
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildSavedCard(
                  title: item['title']!,
                  category: item['category']!,
                  imageUrl: item['image']!,
                  onRemove: () {
                    // TODO: Panggil fungsi hapus bookmark di controller
                    // controller.removeBookmark(id);
                    Get.snackbar(
                      "Dihapus",
                      "${item['title']} dihapus dari penyimpanan",
                      backgroundColor: WayangColors.primaryDark,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(20),
                      borderRadius: 10,
                    );
                  },
                );
              },
            ),
    );
  }

  // --- WIDGET: EMPTY STATE (KOSONG) ---
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
            // Ikon Bookmark Outline (Arsip kosong)
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

  // --- WIDGET: KARTU ITEM (PREMIUM LOOK) ---
  Widget _buildSavedCard({
    required String title,
    required String category,
    required String imageUrl,
    required VoidCallback onRemove,
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
          onTap: () {
            // TODO: Arahkan ke detail halaman
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // --- 1. GAMBAR THUMBNAIL ---
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: WayangColors.background,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: WayangColors.goldAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Ionicons.image_outline,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // --- 2. TEXT DETAIL ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori
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
                      // Judul Utama
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

                // --- 3. TOMBOL BOOKMARK (ICON SAVE) ---
                IconButton(
                  onPressed: onRemove,
                  splashRadius: 24,
                  // Menggunakan Ikon Bookmark Solid berwarna Emas
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
}
