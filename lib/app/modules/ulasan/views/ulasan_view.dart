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
  static const Color textSecondary = Color(0xFF795548);
  static const Color cardBg = Color(0xFFFFFFFF);
}

class UlasanView extends GetView<UlasanController> {
  const UlasanView({super.key});

  @override
  Widget build(BuildContext context) {
    // DUMMY DATA
    final List<Map<String, dynamic>> myReviews = [
      {
        "targetName": "Festival Wayang Jogja 2024",
        "category": "Event",
        "image": "https://via.placeholder.com/150",
        "date": "10 Jan 2024",
        "rating": 5,
        "comment":
            "Acaranya meriah sekali! Dalangnya sangat profesional dan tata panggungnya megah.",
      },
      {
        "targetName": "Museum Wayang Kekayon",
        "category": "Destinasi",
        "image": "https://via.placeholder.com/150",
        "date": "25 Des 2023",
        "rating": 4,
        "comment":
            "Koleksinya lengkap, tapi sayang pencahayaan di beberapa sudut agak kurang terang.",
      },
      {
        "targetName": "Gatot Kaca",
        "category": "Tokoh",
        "image": "https://via.placeholder.com/150",
        "date": "12 Nov 2023",
        "rating": 5,
        "comment": "Tokoh favorit saya sepanjang masa. Otot kawat tulang besi!",
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
          'Riwayat Ulasan',
          style: TextStyle(
            color: WayangColors.primaryDark,
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: myReviews.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: myReviews.length,
              itemBuilder: (context, index) {
                return _buildHistoryCard(context, myReviews[index]);
              },
            ),
    );
  }

  // --- WIDGET: EMPTY STATE ---
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
              Ionicons.document_text_outline,
              size: 80,
              color: WayangColors.primaryDark.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Belum Ada Ulasan",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
              color: WayangColors.primaryDark.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Ulasan yang Anda kirim akan\nmuncul di halaman ini.",
            textAlign: TextAlign.center,
            style: TextStyle(color: WayangColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: KARTU RIWAYAT (PREMIUM) ---
  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> data) {
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
          // Dekorasi Kutipan di Background (Watermark)
          Positioned(
            bottom: -10,
            right: 20,
            child: Icon(
              Ionicons.chatbox_outline,
              size: 100,
              color: WayangColors.goldAccent.withOpacity(0.05),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER: Gambar & Info Utama
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar Thumbnail
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(data['image']),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Info Teks
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Chip Kategori & Tanggal
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: WayangColors.goldAccent.withOpacity(
                                    0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  data['category'].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: WayangColors.primaryDark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Tanggal Review
                              Text(
                                data['date'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Spacer agar tidak nabrak tombol hapus
                              const SizedBox(width: 30),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Judul Item
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Text(
                              data['targetName'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Serif',
                                color: WayangColors.textPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Bintang Rating
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < data['rating']
                                    ? Ionicons.star
                                    : Ionicons.star_outline,
                                size: 16,
                                color: WayangColors.goldAccent,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ISI KOMENTAR
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WayangColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: WayangColors.primaryDark.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.format_quote_rounded,
                        size: 30,
                        color: WayangColors.primaryLight,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['comment'],
                        style: const TextStyle(
                          color: WayangColors.textPrimary,
                          fontSize: 14,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TOMBOL HAPUS (Pojok Kanan Atas - Subtle)
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              // Panggil Fungsi Pop-up Keren di sini
              onPressed: () => _showDeleteDialog(context),
              icon: Icon(
                Ionicons.trash_outline,
                size: 20,
                color: Colors.red.withOpacity(0.6),
              ),
              splashRadius: 20,
              tooltip: "Hapus Ulasan",
            ),
          ),
        ],
      ),
    );
  }

  // --- POP-UP DIALOG KEREN (PREMIUM) ---
  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Ikon Peringatan Besar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Ionicons.trash_outline,
                  size: 32,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),

              // 2. Judul
              const Text(
                "Hapus Ulasan?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: WayangColors.primaryDark,
                ),
              ),
              const SizedBox(height: 10),

              // 3. Deskripsi
              Text(
                "Ulasan ini akan dihapus permanen dan tidak dapat dikembalikan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // 4. Tombol Aksi
              Row(
                children: [
                  // Tombol Batal
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Tombol Hapus
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Tutup Dialog
                        // Logika hapus data di sini
                        Get.snackbar(
                          "Berhasil",
                          "Ulasan berhasil dihapus",
                          backgroundColor: WayangColors.primaryDark,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(20),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Hapus",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
