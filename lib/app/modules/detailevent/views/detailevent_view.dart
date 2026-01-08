import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart'; // Pastikan path import ini sesuai
import '../controllers/detailevent_controller.dart';

class DetaileventView extends GetView<DetaileventController> {
  const DetaileventView({super.key});

  final Color _primaryBrown = const Color(0xFF3E2723);
  final Color _goldAccent = const Color(0xFFC5A059);
  final Color _paperBg = const Color(0xFFFDFBF7);
  final Color _textBody = const Color(0xFF4E342E);
  final Color _cardBg = const Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    // Safety check: Memastikan controller ter-inject
    if (!Get.isRegistered<DetaileventController>()) {
      Get.put(DetaileventController());
    }

    final ContentModel event = controller.event;

    // --- SETUP DATA ---
    final String title = event.title;
    final String image = event.imageUrl;

    // Subtitle digunakan sebagai Tanggal
    final String date = event.subtitle.isNotEmpty
        ? event.subtitle
        : "Tanggal Belum Tersedia";

    final String time = event.time ?? "Waktu Belum Tersedia";

    // Prioritas Lokasi: location -> address -> alamat (di handle di Model)
    // Di sini kita hanya menampilkan teksnya
    final String location =
        (event.location != null && event.location!.isNotEmpty)
        ? event.location!
        : "Lokasi Belum Tersedia";

    final String price = event.price ?? "Gratis";
    final String performer = event.performer ?? "-";
    final String description = event.description.isNotEmpty
        ? event.description
        : "Deskripsi belum tersedia.";

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _paperBg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- A. HEADER IMAGE & APPBAR ---
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: _primaryBrown,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.4),
                ),
                child: IconButton(
                  icon: const Icon(Ionicons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              actions: [
                Obx(
                  () => Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: IconButton(
                      icon: Icon(
                        controller.isSaved.value
                            ? Ionicons.bookmark
                            : Ionicons.bookmark_outline,
                        color: _goldAccent,
                      ),
                      onPressed: () => controller.toggleSave(),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(image),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                            _paperBg.withOpacity(0.1),
                            _paperBg,
                          ],
                          stops: const [0.0, 0.4, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- B. KONTEN DETAIL ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Badge Kategori
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryBrown.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _primaryBrown.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        event.category.toUpperCase(),
                        style: TextStyle(
                          color: _primaryBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Judul
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _primaryBrown,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Rows
                    _buildInfoRow(Ionicons.calendar_outline, date),
                    const SizedBox(height: 12),
                    _buildInfoRow(Ionicons.time_outline, time),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Ionicons.location_outline,
                      location,
                    ), // Tampilkan teks lokasi

                    const SizedBox(height: 30),
                    const Divider(thickness: 1, height: 1),
                    const SizedBox(height: 20),

                    // Section Performer
                    if (performer != "-" && performer.isNotEmpty) ...[
                      Text(
                        "Penampil / Tokoh",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _primaryBrown,
                          fontFamily: 'Serif',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
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
                                    performer,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: _textBody,
                                      fontFamily: 'Serif',
                                    ),
                                  ),
                                  const Text(
                                    "Artis Utama / Dalang",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontFamily: 'Serif',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Deskripsi
                    Text(
                      "Tentang Acara",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primaryBrown,
                        fontFamily: 'Serif',
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
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Rating
                    _buildRatingSection(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),

        // --- C. BOTTOM BAR (TOMBOL BUKA MAPS) ---
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      fontFamily: 'Serif',
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryBrown,
                      fontFamily: 'Serif',
                    ),
                  ),
                ],
              ),
              // TOMBOL PETUNJUK ARAH
              // Fungsi ini memanggil controller.openMap() yang sudah menggunakan 'maps_url'
              ElevatedButton.icon(
                onPressed: () => controller.openMap(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Ionicons.map, size: 20),
                label: const Text(
                  "Petunjuk Arah",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Serif',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

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
              height: 1.3,
              fontFamily: 'Serif',
            ),
          ),
        ),
      ],
    );
  }

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
        // Pembersihan Base64
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
                        size: 32,
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
            style: const TextStyle(fontFamily: 'Serif'),
            decoration: InputDecoration(
              hintText: "Bagikan pendapat Anda...",
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
                backgroundColor: _goldAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
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
}
