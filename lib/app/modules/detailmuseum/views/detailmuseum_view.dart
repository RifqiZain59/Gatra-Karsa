import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import '../controllers/detailmuseum_controller.dart';

class DetailmuseumView extends GetView<DetailmuseumController> {
  const DetailmuseumView({super.key});

  final Color _primaryBrown = const Color(0xFF3E2723);
  final Color _goldAccent = const Color(0xFFC5A059);
  final Color _paperBg = const Color(0xFFFDFBF7);
  final Color _textBody = const Color(0xFF4E342E);
  final Color _cardBg = const Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DetailmuseumController>()) {
      Get.put(DetailmuseumController());
    }

    final ContentModel museum = controller.museum;

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
                    Obx(
                      () => Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
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
                        _buildImage(museum.imageUrl),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                _paperBg,
                                _paperBg.withOpacity(0.1),
                                Colors.transparent,
                                Colors.black45,
                              ],
                              stops: const [0.0, 0.1, 0.5, 1.0],
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
                        const SizedBox(height: 15),

                        // 1. JUDUL
                        Text(
                          museum.title,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: _primaryBrown,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 2. SUBTITLE (LOKASI)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Ionicons.location_sharp,
                              size: 20,
                              color: _goldAccent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                (museum.subtitle.isNotEmpty)
                                    ? museum.subtitle
                                    : "Lokasi tidak tersedia",
                                style: TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _textBody,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 3. INFO GRID
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                icon: Ionicons.time_outline,
                                title: "Kategori",
                                value: museum.category,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInfoCard(
                                icon: Ionicons.ticket_outline,
                                title: "Tiket Masuk",
                                value:
                                    (museum.price != null &&
                                        museum.price!.isNotEmpty)
                                    ? museum.price!
                                    : "Gratis",
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 4. DESKRIPSI
                        Text(
                          "Tentang Museum",
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryBrown,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (museum.description.isNotEmpty)
                              ? museum.description
                              : "Deskripsi belum tersedia.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 15,
                            height: 1.6,
                            color: _textBody,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 5. LIST ULASAN (DI ATAS)
                        _buildReviewList(),

                        const SizedBox(height: 30),

                        // 6. INPUT RATING (DI BAWAH)
                        _buildRatingSection(context),

                        const SizedBox(height: 30),

                        // 7. TOMBOL ARAH
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
                                fontFamily: 'Serif',
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

  // --- WIDGET HELPER ---

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) return Container(color: _primaryBrown);
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator(color: _goldAccent));
          },
          errorBuilder: (c, e, s) => Container(color: _primaryBrown),
        );
      } else if (imageUrl.startsWith('assets/')) {
        return Image.asset(imageUrl, fit: BoxFit.cover);
      } else {
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
        return Image.memory(bytes, fit: BoxFit.cover);
      }
    } catch (e) {
      return Container(color: _primaryBrown);
    }
  }

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
              fontFamily: 'Serif',
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _textBody,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

  Widget _buildReviewList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ulasan Pengunjung",
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _primaryBrown,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: controller.ulasanStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Text(
                "Gagal memuat ulasan.",
                style: TextStyle(color: Colors.red[300]),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Text(
                    "Belum ada ulasan. Jadilah yang pertama!",
                    style: TextStyle(
                      fontFamily: 'Serif',
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                var data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return _buildReviewItem(data);
              },
            );
          },
        ),
      ],
    );
  }

  // --- WIDGET ITEM ULASAN (UPDATED: DATE FORMAT DD/MM/YYYY) ---
  Widget _buildReviewItem(Map<String, dynamic> data) {
    String name = data['user_name'] ?? 'Pengguna';
    String photo = data['user_photo'] ?? '';
    String comment = data['comment'] ?? '';
    int rating = data['rating'] ?? 0;

    // --- Format Tanggal (NUMERIK dengan Slash) ---
    // Format: DD/MM/YYYY (Contoh: 10/01/2026)
    String dateStr = "";
    if (data['created_at'] != null && data['created_at'] is Timestamp) {
      DateTime dt = (data['created_at'] as Timestamp).toDate();
      // Menggunakan padLeft agar 1 digit menjadi 2 digit (e.g., 1 -> 01)
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      String year = dt.year.toString();

      // PERUBAHAN DI SINI: Menggunakan '/'
      dateStr = "$day/$month/$year";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _goldAccent.withOpacity(0.2),
              image: photo.isNotEmpty
                  ? DecorationImage(
                      image: MemoryImage(base64Decode(photo)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photo.isEmpty
                ? Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "U",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryBrown,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Konten Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER: NAMA (Kiri) & TANGGAL (Kanan)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _textBody,
                      ),
                    ),
                    Text(
                      dateStr, // Menggunakan format DD/MM/YYYY
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // 2. RATING BINTANG (Di bawah Username)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Ionicons.star : Ionicons.star_outline,
                      size: 14,
                      color: Colors.amber,
                    );
                  }),
                ),

                const SizedBox(height: 6),

                // 3. KOMENTAR
                Text(
                  comment,
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 13,
                    color: _textBody.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
