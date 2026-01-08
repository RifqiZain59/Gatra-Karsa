import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart'; // Import Model PENTING
import '../controllers/detailkisah_controller.dart';

class DetailkisahView extends GetView<DetailkisahController> {
  const DetailkisahView({super.key});

  // --- PALET WARNA TEMA WAYANG ---
  final Color _primaryBrown = const Color(0xFF3E2723);
  final Color _goldAccent = const Color(0xFFC5A059);
  final Color _paperBg = const Color(0xFFFDFBF7);
  final Color _textBody = const Color(0xFF4E342E);

  @override
  Widget build(BuildContext context) {
    // Injeksi Controller
    Get.put(DetailkisahController());

    // --- TERIMA DATA SEBAGAI CONTENTMODEL ---
    final ContentModel story = Get.arguments as ContentModel;

    // --- MAPPING DATA MODEL KE UI ---
    final String title = story.title;
    final String category = story.category;
    final String image = story.imageUrl;

    // Moral value (subtitle atau default)
    final String moral = story.subtitle.isNotEmpty
        ? story.subtitle
        : "Hikmah cerita ini mengajarkan tentang keberanian dan kebenaran.";

    // Isi Cerita
    final String content = story.description;

    // (BAGIAN TOKOH/CHARACTERS SUDAH DIHAPUS DARI SINI)

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _paperBg,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // A. Background Watermark
            Positioned(
              top: 100,
              left: -50,
              child: Opacity(
                opacity: 0.03,
                child: Icon(Ionicons.book, size: 300, color: _primaryBrown),
              ),
            ),

            // B. Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // --- HEADER ---
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  stretch: true,
                  backgroundColor: _primaryBrown,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Ionicons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(
                        right: 16,
                        top: 8,
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Obx(
                        () => IconButton(
                          icon: Icon(
                            controller.isSaved.value
                                ? Ionicons.bookmark
                                : Ionicons.bookmark_outline,
                            color: controller.isSaved.value
                                ? _goldAccent
                                : Colors.white,
                          ),
                          onPressed: () => controller.toggleSave(),
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Helper Image
                        _buildImage(image),

                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                _paperBg,
                                _paperBg.withOpacity(0.8),
                                Colors.transparent,
                                Colors.black38,
                              ],
                              stops: const [0.0, 0.1, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- CONTENT BODY ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Kategori & Judul
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryBrown,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: TextStyle(
                                color: _goldAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                fontFamily: 'Serif',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _primaryBrown,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 2. Moral Value
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _goldAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(color: _goldAccent, width: 4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Ionicons.sparkles,
                                    size: 16,
                                    color: _primaryBrown,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "INTISARI & HIKMAH",
                                    style: TextStyle(
                                      color: _primaryBrown,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      fontFamily: 'Serif',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "\"$moral\"",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 15,
                                  color: _textBody,
                                  height: 1.4,
                                  fontFamily: 'Serif',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 3. Isi Cerita
                        Text(
                          content,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.8,
                            color: _textBody,
                            fontFamily: 'Serif',
                          ),
                        ),

                        const SizedBox(height: 30),
                        const Divider(),
                        const SizedBox(height: 20),

                        // (BAGIAN LIST TOKOH SUDAH DIHAPUS DARI SINI)

                        // 4. Input Rating
                        _buildRatingSection(context),

                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryBrown.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bagaimana kesan Anda?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _primaryBrown,
              fontFamily: 'Serif',
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => controller.setRating(index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < controller.userRating.value
                            ? Ionicons.star
                            : Ionicons.star_outline,
                        color: const Color(0xFFD4AF37),
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller.reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Tulis pendapat Anda tentang kisah ini...",
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontFamily: 'Serif',
              ),
              filled: true,
              fillColor: _paperBg,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _goldAccent.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _primaryBrown),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.submitReview(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 2,
              ),
              child: const Text(
                "Kirim Ulasan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Serif',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HELPER UNTUK GAMBAR (Base64 Safe)
  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(color: _primaryBrown);
    }
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: _primaryBrown),
        );
      } else if (imageUrl.startsWith('assets/')) {
        return Image.asset(imageUrl, fit: BoxFit.cover);
      } else {
        // Base64 logic
        String cleanBase64 = imageUrl;
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',').last;
        }
        cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');
        int mod4 = cleanBase64.length % 4;
        if (mod4 > 0) {
          cleanBase64 += '=' * (4 - mod4);
        }
        Uint8List bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: _primaryBrown),
        );
      }
    } catch (e) {
      return Container(color: _primaryBrown);
    }
  }
}
