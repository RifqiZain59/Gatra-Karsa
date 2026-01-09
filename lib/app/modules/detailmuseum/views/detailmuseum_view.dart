import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import '../controllers/detailmuseum_controller.dart';

class DetailmuseumView extends GetView<DetailmuseumController> {
  const DetailmuseumView({super.key});

  // --- PALET WARNA MODERN ---
  final Color _primaryBrown = const Color(0xFF4E342E);
  final Color _goldAccent = const Color(0xFFD4AF37);
  final Color _bgSoft = const Color(0xFFFAFAFA); // Putih tulang sangat muda
  final Color _textHeading = const Color(0xFF1A1A1A);
  final Color _textBody = const Color(0xFF616161);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DetailmuseumController>()) {
      Get.put(DetailmuseumController());
    }

    final ContentModel museum = controller.museum;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Status Bar (Atas)
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Icon Hitam
        statusBarBrightness: Brightness.light, // Untuk iOS
        // Navigation Bar (Bawah HP)
        systemNavigationBarColor: Colors.white, // Background Putih
        systemNavigationBarIconBrightness: Brightness.dark, // Icon Tombol Hitam
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            CustomScrollView(
              // FIX: ClampingScrollPhysics mencegah scroll berlebih di atas gambar
              physics: const ClampingScrollPhysics(),
              slivers: [
                // --- 1. HEADER IMAGE (Sliver App Bar) ---
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.9), // Glassy White
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Ionicons.arrow_back,
                        color: Colors.black,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Obx(
                        () => IconButton(
                          icon: Icon(
                            controller.isSaved.value
                                ? Ionicons.bookmark
                                : Ionicons.bookmark_outline,
                            color: controller.isSaved.value
                                ? _goldAccent
                                : Colors.black,
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
                      children: [_buildHeaderImage(museum.imageUrl)],
                    ),
                  ),
                ),

                // --- 2. KONTEN BODY ---
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      // Padding top 30 agar rapi karena garis dihapus
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 160),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FIX: Garis abu-abu (handle bar) DIHAPUS DISINI

                          // A. JUDUL BESAR
                          Text(
                            museum.title,
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _textHeading,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // B. INFO GRID (Lokasi, Kategori, Tiket)
                          _buildLocationTile(
                            museum.subtitle.isNotEmpty
                                ? museum.subtitle
                                : "Lokasi tidak tersedia",
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoTile(
                                  Ionicons.time_outline,
                                  "Kategori",
                                  museum.category,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoTile(
                                  Ionicons.ticket_outline,
                                  "Tiket Masuk",
                                  (museum.price != null &&
                                          museum.price!.isNotEmpty)
                                      ? museum.price!
                                      : "Gratis",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // C. DESKRIPSI
                          Text("Tentang Museum", style: _headingStyle),
                          const SizedBox(height: 10),
                          Text(
                            (museum.description.isNotEmpty)
                                ? museum.description
                                : "Deskripsi belum tersedia.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.8,
                              color: _textBody,
                              fontFamily: 'Serif',
                            ),
                          ),
                          const SizedBox(height: 30),

                          // D. SECTION ULASAN
                          _buildReviewSection(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- 3. FLOATING BOTTOM BAR (STICKY) ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  20 + MediaQuery.of(context).padding.bottom, // Safe Area Bawah
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
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                ),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.openMap(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      elevation: 5,
                      shadowColor: _primaryBrown.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Ionicons.navigate_outline, size: 20),
                    label: const Text(
                      "Navigasi ke Lokasi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Serif',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _headingStyle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: _textHeading,
    fontFamily: 'Serif',
  );

  // --- WIDGET HELPER ---

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _goldAccent, size: 24),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _textHeading,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(String location) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Ionicons.location_outline, color: _goldAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lokasi",
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _textHeading,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(String imageUrl) {
    if (imageUrl.isEmpty) return Container(color: _bgSoft);
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: _bgSoft),
        );
      } else if (imageUrl.startsWith('assets/')) {
        return Image.asset(imageUrl, fit: BoxFit.cover);
      } else {
        String cleanBase64 = imageUrl.replaceAll(RegExp(r'\s+'), '');
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',').last;
        }
        int mod4 = cleanBase64.length % 4;
        if (mod4 > 0) cleanBase64 += '=' * (4 - mod4);
        return Image.memory(base64Decode(cleanBase64), fit: BoxFit.cover);
      }
    } catch (e) {
      return Container(color: _bgSoft);
    }
  }

  // --- REVIEW SECTION ---
  Widget _buildReviewSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.ulasanStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }

        var docs = snapshot.data?.docs ?? [];
        int totalReviews = docs.length;
        double averageRating = 0.0;
        if (totalReviews > 0) {
          double totalStars = 0;
          for (var doc in docs) {
            totalStars += (doc.data() as Map<String, dynamic>)['rating'] ?? 0;
          }
          averageRating = totalStars / totalReviews;
        }

        return Column(
          children: [
            // A. KOTAK TOTAL ULASAN (Desain Gradien)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryBrown, _primaryBrown.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primaryBrown.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Ionicons.chatbubbles,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _goldAccent,
                                  fontFamily: 'Serif',
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  "/ 5.0",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < averageRating.round()
                                    ? Ionicons.star
                                    : Ionicons.star_outline,
                                color: _goldAccent,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "$totalReviews Ulasan",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Pengunjung",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // B. HEADER & TOMBOL TULIS (TEXT ONLY - TANPA GARIS BAWAH)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ulasan Terbaru", style: _headingStyle),
                TextButton(
                  onPressed: () => _openRatingBottomSheet(context),
                  style: TextButton.styleFrom(foregroundColor: _goldAccent),
                  child: const Text(
                    "Tulis Ulasan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.none, // Hapus Garis Bawah
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // C. SLIDER
            if (docs.isEmpty)
              Container(
                padding: const EdgeInsets.all(30),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _bgSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Ionicons.chatbubble_ellipses_outline,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Belum ada ulasan.",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              _AutoPlayReviewSlider(
                docs: docs,
                primaryBrown: _primaryBrown,
                goldAccent: _goldAccent,
              ),
          ],
        );
      },
    );
  }

  // --- MODAL POP-UP (BOTTOM SHEET) FIXED ---
  void _openRatingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // WAJIB: Agar bisa full screen/terdorong keyboard
      backgroundColor: Colors.transparent, // Transparan agar rounded terlihat
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            // Padding bawah dinamis mengikuti tinggi keyboard (viewInsets)
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle Bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Bagikan Pengalaman",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _primaryBrown,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Beri rating dan ulasan untuk museum ini",
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                    const SizedBox(height: 25),

                    // Input Rating Bintang
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => GestureDetector(
                            onTap: () => controller.setRating(index + 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Icon(
                                index < controller.userRating.value
                                    ? Ionicons.star
                                    : Ionicons.star_outline,
                                color: _goldAccent,
                                size: 44,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Input Text Area
                    TextField(
                      controller: controller.reviewController,
                      maxLines: 4,
                      style: const TextStyle(fontFamily: 'Serif'),
                      decoration: InputDecoration(
                        hintText: "Ceritakan pengalaman Anda...",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontFamily: 'Serif',
                        ),
                        filled: true,
                        fillColor: _bgSoft,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: _primaryBrown),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Tombol Kirim
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.submitReview();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBrown,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Kirim Ulasan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Safe Area agar tidak mepet bawah layar di iPhone X+
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- SLIDER REUSABLE ---
class _AutoPlayReviewSlider extends StatefulWidget {
  final List<DocumentSnapshot> docs;
  final Color primaryBrown;
  final Color goldAccent;

  const _AutoPlayReviewSlider({
    required this.docs,
    required this.primaryBrown,
    required this.goldAccent,
  });

  @override
  State<_AutoPlayReviewSlider> createState() => _AutoPlayReviewSliderState();
}

class _AutoPlayReviewSliderState extends State<_AutoPlayReviewSlider> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Fraction 0.90 agar kartu terlihat lebar dan sedikit intip kartu sebelah
    _pageController = PageController(viewportFraction: 0.90);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentIndex < widget.docs.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.docs.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              var data = widget.docs[index].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildReviewCard(data),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.docs.length > 5 ? 5 : widget.docs.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width:
                  (_currentIndex %
                          (widget.docs.length > 5 ? 5 : widget.docs.length)) ==
                      index
                  ? 20
                  : 6,
              decoration: BoxDecoration(
                color:
                    (_currentIndex %
                            (widget.docs.length > 5
                                ? 5
                                : widget.docs.length)) ==
                        index
                    ? widget.goldAccent
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> data) {
    String name = data['user_name'] ?? 'User';
    String photo = data['user_photo'] ?? '';
    String comment = data['comment'] ?? '';
    int rating = data['rating'] ?? 5;

    // Format Tanggal
    String dateStr = "";
    if (data['created_at'] != null && data['created_at'] is Timestamp) {
      DateTime dt = (data['created_at'] as Timestamp).toDate();
      dateStr =
          "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.format_quote_rounded,
              size: 40,
              color: widget.goldAccent.withOpacity(0.15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.goldAccent.withOpacity(0.1),
                      image: photo.isNotEmpty
                          ? DecorationImage(
                              image: MemoryImage(
                                base64Decode(
                                  photo.replaceAll(RegExp(r'\s+'), ''),
                                ),
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: photo.isEmpty
                        ? Icon(
                            Ionicons.person,
                            size: 20,
                            color: widget.goldAccent,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < rating
                                      ? Ionicons.star
                                      : Ionicons.star_outline,
                                  size: 12,
                                  color: widget.goldAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  comment,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
                    fontFamily: 'Serif',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
