import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // WAJIB: Import package ini

import '../controllers/artikel_controller.dart';

class ArtikelView extends GetView<ArtikelController> {
  const ArtikelView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    Get.put(ArtikelController());

    // --- TEMA WARNA ---
    final Color primaryColor = const Color(0xFF5D4037); // Coklat Tua
    final Color accentColor = const Color(0xFF8D6E63); // Coklat Muda
    final Color backgroundColor = const Color(0xFFF5F5F5); // Abu Muda

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Jelajah Artikel',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: Obx(() {
        // 1. Loading State
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }

        // 2. Empty State
        if (controller.artikelList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.library_books_outlined,
                  size: 80,
                  color: Colors.brown[200],
                ),
                const SizedBox(height: 16),
                Text(
                  "Belum ada artikel.",
                  style: TextStyle(color: Colors.brown[400]),
                ),
              ],
            ),
          );
        }

        // 3. Data Loaded
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: primaryColor,
          child: Column(
            children: [
              // Header Statistik
              _buildHeaderStat(
                controller.artikelList.length,
                primaryColor,
                accentColor,
              ),

              // List Artikel
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: controller.artikelList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final artikel = controller.artikelList[index];
                    return _buildModernCard(artikel, context, primaryColor);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // =========================================================
  // WIDGET: HEADER STATISTIK
  // =========================================================
  Widget _buildHeaderStat(int count, Color colorTk, Color colorMd) {
    return Container(
      width: double.infinity,
      height: 140,
      margin: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorTk, colorMd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorTk.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.auto_stories,
              size: 150,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.history_edu,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Koleksi Pustaka",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$count Artikel",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // WIDGET: KARTU ARTIKEL (LINK LOGIC DI KOTAK PUTIH)
  // =========================================================
  Widget _buildModernCard(
    dynamic artikel,
    BuildContext context,
    Color primaryColor,
  ) {
    // Ambil Link dari Model
    final String linkDatabase = artikel.link ?? "";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Gambar (Klik -> Detail Internal)
          InkWell(
            onTap: () => Get.toNamed('/detail-artikel', arguments: artikel),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 8,
                    child: _buildImage(artikel.imageUrl),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      artikel.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Konten Teks & Link Box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul & Deskripsi (Klik -> Detail Internal)
                InkWell(
                  onTap: () =>
                      Get.toNamed('/detail-artikel', arguments: artikel),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artikel.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artikel.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // -----------------------------------------------------
                // 3. KOTAK PUTIH SEBAGAI TOMBOL LINK
                // (Tanpa widget Button di dalamnya, Kotaknya yang diklik)
                // -----------------------------------------------------
                if (linkDatabase.isNotEmpty)
                  Material(
                    color: Colors.white, // Warna Putih
                    // Bentuk Border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: primaryColor, width: 1.5),
                    ),
                    // InkWell untuk efek klik pada Material
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // LOGIKA KLIK LANGSUNG DISINI
                        _launchURL(linkDatabase);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.link, color: primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              "Kunjungi Sumber", // Label Link
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: primaryColor.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HELPER: LAUNCH URL
  // =========================================================
  Future<void> _launchURL(String urlString) async {
    try {
      final Uri uri = Uri.parse(urlString);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          "Gagal",
          "Tidak dapat membuka link: $urlString",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Format link tidak valid",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // =========================================================
  // HELPER: IMAGE
  // =========================================================
  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) return _placeholder();
    try {
      if (imageUrl.startsWith('data:')) {
        return Image.memory(
          base64Decode(imageUrl.split(',').last),
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _placeholder(),
        );
      } else {
        return Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _placeholder(),
        );
      }
    } catch (e) {
      return _placeholder();
    }
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 40),
      ),
    );
  }
}
