import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // --- PENGATURAN STATUS BAR (ATAS) ---
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.light, // Icon status bar putih (karena konten gelap)
        // --- PENGATURAN NAVIGASI BAR (BAWAH) ---
        systemNavigationBarColor:
            Colors.white, // Background navigasi menjadi PUTIH
        systemNavigationBarIconBrightness: Brightness
            .dark, // Icon navigasi menjadi HITAM (agar terlihat di bg putih)
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
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
          return Stack(
            children: [
              PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: controller.videoList.length,
                itemBuilder: (context, index) =>
                    ReelsItem(item: controller.videoList[index]),
              ),
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
                          fontSize: 16,
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

// ... Class ReelsItem dan kode bawahnya tetap sama ...
class ReelsItem extends StatefulWidget {
  final ContentModel item;
  const ReelsItem({super.key, required this.item});
  @override
  State<ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<ReelsItem> {
  bool isDescriptionExpanded = false;
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  Widget _buildImage(String imageUrl) {
    const BoxFit fixedFit = BoxFit.contain;
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
        String base64String = imageUrl.replaceAll(RegExp(r'\s+'), '');
        if (base64String.contains(','))
          base64String = base64String.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: fixedFit,
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
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Stack(
            children: [
              SizedBox.expand(child: _buildImage(widget.item.imageUrl)),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          bottom: 30 + MediaQuery.of(context).padding.bottom,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.title,
                style: GoogleFonts.philosopher(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  shadows: [const Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              const SizedBox(height: 12),
              if (widget.item.description.isNotEmpty) ...[
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
                GestureDetector(
                  onTap: () => setState(
                    () => isDescriptionExpanded = !isDescriptionExpanded,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      isDescriptionExpanded ? "Sembunyikan" : "Selengkapnya",
                      style: GoogleFonts.mulish(
                        color: const Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
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
                      color: const Color(0xFFD4AF37).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Tonton Video",
                          style: GoogleFonts.mulish(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
