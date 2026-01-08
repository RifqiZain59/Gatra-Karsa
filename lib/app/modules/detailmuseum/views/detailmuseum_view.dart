import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../controllers/detailmuseum_controller.dart';

class DetailmuseumView extends GetView<DetailmuseumController> {
  const DetailmuseumView({super.key});

  // --- PALET WARNA TEMA WAYANG ---
  final Color _primaryBrown = const Color(0xFF3E2723); // Coklat Tua
  final Color _goldAccent = const Color(0xFFC5A059); // Emas
  final Color _paperBg = const Color(0xFFFDFBF7); // Krem
  final Color _textBody = const Color(0xFF4E342E); // Coklat Teks
  final Color _cardBg = const Color(0xFFFFFFFF); // Putih Bersih

  @override
  Widget build(BuildContext context) {
    // Injeksi Controller
    Get.put(DetailmuseumController());

    // --- 1. DATA HANDLING ---
    final Map<String, dynamic> args = Get.arguments ?? {};

    final String name = args['name'] ?? 'Museum Wayang Kekayon';
    final String image = args['image'] ?? '';
    final String address = args['address'] ?? 'Jl. Wonosari Km 7, Yogyakarta';
    final String description =
        args['description'] ??
        'Museum ini menyimpan berbagai koleksi wayang dari seluruh nusantara, mulai dari wayang kulit purwa hingga wayang golek modern.';
    final String price = args['price'] ?? 'Rp 20.000';
    final String hours = args['hours'] ?? '08.00 - 16.00 WIB';
    final List gallery =
        args['gallery'] ?? ['assets/gallery1.png', 'assets/gallery2.png'];

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
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // --- A. HEADER IMAGE ---
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: _primaryBrown,

                  // Tombol Back
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

                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gambar Utama
                        if (image.isNotEmpty)
                          Image.asset(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                Container(color: _primaryBrown),
                          )
                        else
                          Container(color: _primaryBrown),

                        // Gradient Overlay
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                _paperBg,
                                _paperBg.withOpacity(0.2),
                                Colors.transparent,
                                Colors.black45,
                              ],
                              stops: const [0.0, 0.2, 0.6, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- B. KONTEN INFORMASI ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // 1. Judul & Alamat
                        Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Serif', // Font disamakan
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: _primaryBrown,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Ionicons.location_sharp,
                              size: 16,
                              color: _goldAccent,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                address,
                                style: TextStyle(
                                  fontFamily: 'Serif', // Font disamakan
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 2. Info Grid (Jam & Harga)
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                icon: Ionicons.time_outline,
                                title: "Jam Buka",
                                value: hours,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInfoCard(
                                icon: Ionicons.ticket_outline,
                                title: "Tiket Masuk",
                                value: price,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 3. Deskripsi
                        Text(
                          "Tentang Museum",
                          style: TextStyle(
                            fontFamily: 'Serif', // Font disamakan
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryBrown,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontFamily: 'Serif', // Font disamakan
                            fontSize: 15,
                            height: 1.6,
                            color: _textBody,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 4. Koleksi Unggulan
                        if (gallery.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Koleksi Unggulan",
                                style: TextStyle(
                                  fontFamily: 'Serif', // Font disamakan
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryBrown,
                                ),
                              ),
                              Text(
                                "Lihat Semua",
                                style: TextStyle(
                                  fontFamily: 'Serif', // Font disamakan
                                  fontSize: 12,
                                  color: _goldAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: gallery.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[200],
                                    image: DecorationImage(
                                      image: AssetImage(gallery[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Fallback
                                  child: gallery[index] == ''
                                      ? const Center(
                                          child: Icon(Ionicons.image),
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),

                        // 5. INPUT RATING & ULASAN (BARU)
                        _buildRatingInput(context),

                        const SizedBox(height: 30),

                        // 6. Tombol Petunjuk Arah
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: () => controller.openMap(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBrown,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: _primaryBrown.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: const Icon(Ionicons.map),
                            label: const Text(
                              "Petunjuk Arah",
                              style: TextStyle(
                                fontFamily: 'Serif', // Font disamakan
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

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

  // --- WIDGET HELPER: INFO CARD ---
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _goldAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryBrown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primaryBrown, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Serif', // Font disamakan
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Serif', // Font disamakan
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _textBody,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: INPUT RATING ---
  Widget _buildRatingInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            "Bagaimana pengalamanmu?",
            style: TextStyle(
              fontFamily: 'Serif', // Font disamakan
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _primaryBrown,
            ),
          ),
          const SizedBox(height: 10),

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
                        color: Colors.amber, // Warna Bintang
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Text Field Ulasan
          TextField(
            controller: controller.reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Tulis ulasan Anda di sini...",
              hintStyle: TextStyle(
                fontFamily: 'Serif', // Font disamakan
                color: Colors.grey[400],
                fontSize: 14,
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
                backgroundColor: _goldAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Kirim Ulasan",
                style: TextStyle(
                  fontFamily: 'Serif', // Font disamakan
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
