import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gatrakarsa/app/modules/video/controllers/video_controller.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  final VideoController controller = Get.put(VideoController());

  @override
  Widget build(BuildContext context) {
    const SystemUiOverlayStyle currentStyle = SystemUiOverlayStyle.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: currentStyle.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          // Loading Indicator
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // State Kosong
          if (controller.videoList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, color: Colors.grey, size: 50),
                  SizedBox(height: 10),
                  Text("Belum ada video", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // Konten Utama
          return Stack(
            children: [
              // 1. PageView Vertical
              PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: controller.videoList.length,
                itemBuilder: (context, index) {
                  return ReelsItem(item: controller.videoList[index]);
                },
              ),

              // 2. Header "Jelajahi" (Tetap di atas)
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Jelajahi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                          shadows: [
                            Shadow(blurRadius: 10, color: Colors.black),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 30,
                        height: 2,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
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

// --- WIDGET ITEM (REELS) ---
class ReelsItem extends StatefulWidget {
  final ContentModel item;

  const ReelsItem({super.key, required this.item});

  @override
  State<ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<ReelsItem> {
  // State: Apakah deskripsi dibuka penuh atau disingkat
  bool isDescriptionExpanded = false;

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  // Helper Build Gambar
  Widget _buildImage(String imageUrl) {
    // Mode Fixed: Contain (Fit Screen / Gambar Utuh)
    const BoxFit fixedFit = BoxFit.contain;

    if (imageUrl.isEmpty) return Container(color: Colors.grey[900]);

    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: fixedFit,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: Colors.grey[900]),
        );
      } else if (imageUrl.startsWith('assets/')) {
        return Image.asset(imageUrl, fit: fixedFit);
      } else {
        String base64String = imageUrl;
        if (base64String.contains(','))
          base64String = base64String.split(',').last;
        base64String = base64String.replaceAll(RegExp(r'\s+'), '');
        Uint8List bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: fixedFit,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: Colors.grey[900]),
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
        // ---------------------------------------------
        // LAYER 1: GAMBAR BACKGROUND (Fit Screen / Utuh)
        // ---------------------------------------------
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black, // Background hitam untuk mengisi sisa ruang
          child: Stack(
            children: [
              // Gambar Utama (Tanpa Double Tap)
              SizedBox.expand(child: _buildImage(widget.item.imageUrl)),

              // Gradient Hitam di Bawah (Agar teks terbaca jelas)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height:
                    MediaQuery.of(context).size.height *
                    0.7, // 70% layar gradasi
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.95), // Lebih gelap di bawah
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ---------------------------------------------
        // LAYER 2: KONTEN INFO (TEXT & BUTTONS)
        // ---------------------------------------------
        Positioned(
          left: 20,
          bottom: 30, // Jarak dari bawah
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Konten (Ikon crop dihapus)
              Text(
                widget.item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  fontFamily: 'Serif',
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),

              const SizedBox(height: 12),

              // --- DESKRIPSI (BISA BUKA TUTUP) ---
              if (widget.item.description.isNotEmpty) ...[
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment.topCenter,
                  child: Text(
                    widget.item.description,
                    // Jika expanded: null (tampil semua), jika tidak: 2 baris
                    maxLines: isDescriptionExpanded ? null : 2,
                    overflow: isDescriptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                  ),
                ),

                // Tombol Selengkapnya / Sembunyikan
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isDescriptionExpanded = !isDescriptionExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      isDescriptionExpanded ? "Sembunyikan" : "Selengkapnya",
                      style: const TextStyle(
                        color: Color(0xFFD4AF37), // Warna Emas
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // --- TOMBOL TONTON VIDEO ---
              if (widget.item.videoUrl != null &&
                  widget.item.videoUrl!.isNotEmpty)
                GestureDetector(
                  onTap: () => _launchUrl(widget.item.videoUrl!),
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.95), // Emas
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Tonton Video",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Serif',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Spacer bawah agar tidak terlalu mepet layar
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
