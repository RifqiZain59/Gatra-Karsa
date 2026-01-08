import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../controllers/detailevent_controller.dart';

class DetaileventView extends GetView<DetaileventController> {
  const DetaileventView({super.key});

  // --- PALET WARNA TEMA WAYANG ---
  final Color _primaryBrown = const Color(0xFF3E2723); // Coklat Tua
  final Color _goldAccent = const Color(0xFFC5A059); // Emas
  final Color _paperBg = const Color(0xFFFDFBF7); // Krem Kertas
  final Color _textBody = const Color(0xFF4E342E); // Coklat Teks
  final Color _cardBg = const Color(0xFFFFFFFF); // Putih

  @override
  Widget build(BuildContext context) {
    // Injeksi Controller
    Get.put(DetaileventController());

    // --- 1. DATA HANDLING ---
    final Map<String, dynamic> args = Get.arguments ?? {};

    final String title = args['title'] ?? 'Pagelaran Wayang Kulit: Baratayuda';
    final String image = args['image'] ?? '';
    final String date = args['date'] ?? 'Sabtu, 24 Oktober 2024';
    final String time = args['time'] ?? '19.30 - 23.00 WIB';
    final String location = args['location'] ?? 'Alun-Alun Kidul, Yogyakarta';
    final String price = args['price'] ?? 'Rp 50.000';
    final String dalang =
        args['dalang'] ?? 'Ki Manteb Sudarsono (Alm. Tribute)';
    final String description =
        args['description'] ??
        'Saksikan pagelaran wayang kulit spektakuler yang menceritakan puncak perang Baratayuda. Acara ini menggabungkan tata cahaya modern dengan gamelan tradisional.';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _paperBg,

        // --- CONTENT BODY ---
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // A. HEADER IMAGE
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: _primaryBrown,

              // Tombol Back (Kiri)
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                ),
                child: IconButton(
                  icon: const Icon(Ionicons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),

              // [DIHAPUS] Tombol Simpan di kanan sudah dihilangkan
              actions: const [],

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
                            _paperBg.withOpacity(0.5),
                            Colors.transparent,
                            Colors.black45,
                          ],
                          stops: const [0.0, 0.15, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // B. KONTEN DETAIL
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Badge Kategori
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryBrown.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "SENI PERTUNJUKAN",
                        style: TextStyle(
                          color: _primaryBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontFamily: 'Serif', // Font disamakan
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Judul Acara
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Serif', // Font disamakan
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _primaryBrown,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info Waktu & Lokasi
                    _buildInfoRow(Ionicons.calendar_outline, date),
                    const SizedBox(height: 12),
                    _buildInfoRow(Ionicons.time_outline, time),
                    const SizedBox(height: 12),
                    _buildInfoRow(Ionicons.location_outline, location),

                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 20),

                    // Bagian Dalang / Penampil
                    Text(
                      "Dalang Utama",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primaryBrown,
                        fontFamily: 'Serif', // Font disamakan
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: _goldAccent,
                            child: const Icon(
                              Ionicons.person,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dalang,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _textBody,
                                    fontFamily: 'Serif', // Font disamakan
                                  ),
                                ),
                                const Text(
                                  "Maestro Pedalangan",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontFamily: 'Serif', // Font disamakan
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Deskripsi
                    Text(
                      "Tentang Acara",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primaryBrown,
                        fontFamily: 'Serif', // Font disamakan
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: _textBody,
                        fontFamily: 'Serif', // Font disamakan
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- INPUT RATING & ULASAN ---
                    _buildRatingSection(context),

                    const SizedBox(height: 100), // Spacer bawah
                  ],
                ),
              ),
            ),
          ],
        ),

        // --- BOTTOM BAR (NAVIGASI PETA) ---
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Harga Tiket",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Serif', // Font disamakan
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryBrown,
                      fontFamily: 'Serif', // Font disamakan
                    ),
                  ),
                ],
              ),
              const Spacer(),

              ElevatedButton.icon(
                onPressed: () => controller.openMap(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Ionicons.map),
                label: const Text(
                  "Petunjuk Arah",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Serif', // Font disamakan
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: INPUT RATING ---
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
            "Bagaimana pengalaman Anda?",
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
              hintText: "Bagikan pendapat Anda tentang acara ini...",
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
                backgroundColor: _goldAccent,
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

  // Widget Helper untuk Baris Info (Icon + Text)
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _goldAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: _textBody,
              height: 1.2,
              fontFamily: 'Serif', // Font disamakan
            ),
          ),
        ),
      ],
    );
  }
}
