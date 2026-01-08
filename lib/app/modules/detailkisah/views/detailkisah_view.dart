import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../controllers/detailkisah_controller.dart';

class DetailkisahView extends GetView<DetailkisahController> {
  const DetailkisahView({super.key});

  // --- PALET WARNA TEMA WAYANG ---
  final Color _primaryBrown = const Color(0xFF3E2723); // Coklat Tua
  final Color _goldAccent = const Color(0xFFC5A059); // Emas
  final Color _paperBg = const Color(0xFFFDFBF7); // Krem Kertas
  final Color _textBody = const Color(0xFF4E342E); // Coklat Teks

  @override
  Widget build(BuildContext context) {
    // Injeksi Controller
    Get.put(DetailkisahController());

    // --- DATA HANDLING ---
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String title = args['title'] ?? 'Judul Tidak Tersedia';
    final String category = args['category'] ?? 'Cerita Wayang';
    final String image = args['image'] ?? '';
    final String moral = args['moral'] ?? 'Hikmah cerita belum tersedia.';
    final String content = args['content'] ?? 'Isi cerita belum tersedia.';
    final List characters = (args['characters'] as List?) ?? [];

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
                        if (image.isNotEmpty)
                          Image.asset(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                Container(color: _primaryBrown),
                          )
                        else
                          Container(color: _primaryBrown),
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
                                fontFamily: 'Serif', // Font disamakan
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Serif', // Font disamakan
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
                                      fontFamily: 'Serif', // Font disamakan
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
                                  fontFamily: 'Serif', // Font disamakan
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
                            fontFamily: 'Serif', // Font disamakan
                          ),
                        ),

                        const SizedBox(height: 30),
                        const Divider(),
                        const SizedBox(height: 20),

                        // 4. List Tokoh
                        if (characters.isNotEmpty) ...[
                          Text(
                            "Tokoh dalam Kisah",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _primaryBrown,
                              fontFamily: 'Serif', // Font disamakan
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 90,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: characters.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: _goldAccent,
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Ionicons.person,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        characters[index].toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _textBody,
                                          fontFamily: 'Serif', // Font disamakan
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 40),

                        // --- 5. INPUT RATING & ULASAN (BARU) ---
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

  // Widget Input Rating
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
              fontFamily: 'Serif', // Font disamakan
            ),
          ),
          const SizedBox(height: 15),

          // Row Bintang Interaktif
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
                        color: const Color(0xFFD4AF37), // Emas
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Input Text
          TextField(
            controller: controller.reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Tulis pendapat Anda tentang kisah ini...",
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontFamily: 'Serif', // Font disamakan
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

          // Tombol Kirim
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
                  fontFamily: 'Serif', // Font disamakan
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
