import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import '../controllers/video_controller.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  // Pastikan Controller di-put atau di-find
  final VideoController controller = Get.put(VideoController());

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // --- SETTING NAVIGASI BAR & STATUS BAR ---
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white, // Background Bawah Putih
        systemNavigationBarIconBrightness: Brightness.dark, // Icon Bawah Hitam
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (controller.videoList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_off, color: Colors.grey, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    "Belum ada video",
                    style: GoogleFonts.mulish(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return Stack(
            children: [
              // PageView untuk Scroll Vertikal (seperti TikTok/Reels)
              PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: controller.videoList.length,
                itemBuilder: (context, index) =>
                    ReelsItem(item: controller.videoList[index]),
              ),

              // Header Judul "Jelajahi" (Overlay Tetap)
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Jelajahi',
                        style: GoogleFonts.philosopher(
                          color: Colors.white,
                          fontSize: 16, // Ukuran font header kecil
                          fontWeight: FontWeight.bold,
                          shadows: [
                            const Shadow(blurRadius: 10, color: Colors.black),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 30,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: const [
                            BoxShadow(blurRadius: 5, color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class ReelsItem extends StatefulWidget {
  final ContentModel item;
  const ReelsItem({super.key, required this.item});

  @override
  State<ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<ReelsItem> {
  bool isDescriptionExpanded = false;

  // --- PERBAIKAN FUNGSI LAUNCH URL ---
  Future<void> _launchUrl(String url) async {
    // 1. Bersihkan spasi kosong
    String cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return;

    // 2. Cek apakah ada http/https, jika tidak ada, tambahkan https://
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    try {
      final Uri uri = Uri.parse(cleanUrl);

      // 3. Coba buka dengan mode external (Aplikasi YouTube / Browser)
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // Jika gagal, coba mode in-app browser
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          Get.snackbar("Gagal", "Tidak dapat memutar video ini.");
        }
      }
    } catch (e) {
      // Menampilkan error detail di console untuk debugging
      print("Error launch url: $e");
      Get.snackbar("Error", "Link video rusak atau tidak valid.");
    }
  }

  // Helper Build Image (Support Base64 & Network)
  Widget _buildImage(String imageUrl) {
    const BoxFit fixedFit = BoxFit.contain; // Gambar utuh (tidak crop)

    if (imageUrl.isEmpty) return Container(color: Colors.grey[900]);

    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: fixedFit,
          errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
        );
      } else if (imageUrl.startsWith('assets/')) {
        return Image.asset(imageUrl, fit: fixedFit);
      } else {
        // Bersihkan Base64 string
        String base64String = imageUrl.trim().replaceAll(RegExp(r'\s+'), '');
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }
        // Tambahkan padding jika kurang (wajib untuk Dart Base64 decoder)
        int mod4 = base64String.length % 4;
        if (mod4 > 0) {
          base64String += '=' * (4 - mod4);
        }

        return Image.memory(
          base64Decode(base64String),
          fit: fixedFit,
          gaplessPlayback: true,
          errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
        );
      }
    } catch (e) {
      return Container(color: Colors.grey[900]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Background Image Layer
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          alignment: Alignment.center,
          child: _buildImage(widget.item.imageUrl),
        ),

        // 2. Gradient Overlay Layer (Agar teks terbaca)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // 3. LAYER TOMBOL PLAY (Check video_link)
        if (widget.item.video_link != null &&
            widget.item.video_link!.isNotEmpty)
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: () => _launchUrl(
                  widget.item.video_link!,
                ), // Launch URL yang sudah diperbaiki
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                ),
              ),
            ),
          ),

        // 4. Content Text Layer (Judul & Deskripsi)
        Positioned(
          left: 20,
          bottom: 30 + MediaQuery.of(context).padding.bottom,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Video
              Text(
                widget.item.title,
                style: GoogleFonts.philosopher(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // Ukuran font judul kecil
                  shadows: [const Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              const SizedBox(height: 8),

              // Deskripsi Expandable
              if (widget.item.description.isNotEmpty) ...[
                GestureDetector(
                  onTap: () => setState(() {
                    isDescriptionExpanded = !isDescriptionExpanded;
                  }),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        alignment: Alignment.topCenter,
                        child: Text(
                          widget.item.description,
                          maxLines: isDescriptionExpanded ? null : 2,
                          overflow: isDescriptionExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: GoogleFonts.mulish(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                            shadows: [
                              const Shadow(blurRadius: 4, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                      if (widget.item.description.length > 50)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            isDescriptionExpanded
                                ? "Sembunyikan"
                                : "Selengkapnya",
                            style: GoogleFonts.mulish(
                              color: const Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
