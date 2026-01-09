import 'dart:async'; // Wajib untuk Timer Auto Slide
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

  // Warna Tema
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
        // 1. FIX: Mencegah layout hancur saat keyboard muncul
        resizeToAvoidBottomInset: false,

        // 2. FITUR: STICKY FOOTER (Tombol Navigasi Menempel di Bawah)
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(context).padding.bottom + 16,
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => controller.openMap(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBrown,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Ionicons.navigate, size: 20),
              label: const Text(
                "Navigasi ke Lokasi",
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        body: CustomScrollView(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
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
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Ionicons.location_sharp,
                              size: 18,
                              color: _goldAccent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                (museum.subtitle.isNotEmpty)
                                    ? museum.subtitle
                                    : "Lokasi tidak tersedia",
                                style: TextStyle(
                                  fontFamily: 'Serif',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _textBody,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                icon: Ionicons.time_outline,
                                title: "Kategori",
                                value: museum.category,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                        const SizedBox(height: 20),
                        Text(
                          "Tentang Museum",
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryBrown,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (museum.description.isNotEmpty)
                              ? museum.description
                              : "Deskripsi belum tersedia.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 15,
                            height: 1.5,
                            color: _textBody,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- C. BAGIAN ULASAN (AUTO SLIDE & DOTS) ---
                  // Kita panggil widget terpisah di sini
                  _buildReviewSection(context),

                  const SizedBox(height: 40), // Jarak aman dari sticky footer
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================
  //      WIDGET AREA
  // ==========================

  Widget _buildReviewSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.ulasanStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }

        List<DocumentSnapshot> docs = snapshot.data?.docs ?? [];
        int totalReviews = docs.length;
        double averageRating = 0.0;
        if (totalReviews > 0) {
          double totalStars = 0;
          for (var doc in docs) {
            var data = doc.data() as Map<String, dynamic>;
            totalStars += (data['rating'] ?? 0);
          }
          averageRating = totalStars / totalReviews;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KARTU RINGKASAN (SUMMARY)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _primaryBrown,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryBrown.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Serif',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < averageRating.round()
                                  ? Ionicons.star
                                  : Ionicons.star_outline,
                              color: const Color(0xFFD4AF37),
                              size: 18,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "dari $totalReviews ulasan",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Ionicons.chatbubbles_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. HEADER & TOMBOL TULIS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ulasan Terbaru",
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryBrown,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openRatingBottomSheet(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _goldAccent, width: 1.5),
                      shape: const StadiumBorder(),
                      foregroundColor: _textBody,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    icon: Icon(
                      Ionicons.create_outline,
                      size: 18,
                      color: _primaryBrown,
                    ),
                    label: Text(
                      "Tulis Ulasan",
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _primaryBrown,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. LOGIKA TAMPILAN ULASAN (KOSONG / ADA)
            if (totalReviews == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Ionicons.folder_open_outline,
                          color: Colors.grey[300],
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Belum ada ulasan.",
                          style: TextStyle(
                            fontFamily: 'Serif',
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              // 4. MEMANGGIL WIDGET SLIDER OTOMATIS (STATEFUL)
              _AutoPlayReviewSlider(
                docs: docs,
                primaryBrown: _primaryBrown,
                goldAccent: _goldAccent,
                textBody: _textBody,
                paperBg: _paperBg,
              ),
          ],
        );
      },
    );
  }

  void _openRatingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          // Padding viewInsets penting agar naik saat keyboard muncul
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Bagikan Pengalaman Anda",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                      color: _primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Beri rating dan ulasan untuk museum ini",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  const SizedBox(height: 25),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => controller.setRating(index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              index < controller.userRating.value
                                  ? Ionicons.star
                                  : Ionicons.star_outline,
                              color: const Color(0xFFD4AF37),
                              size: 42,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: controller.reviewController,
                    maxLines: 4,
                    style: const TextStyle(fontFamily: 'Serif'),
                    decoration: InputDecoration(
                      hintText: "Tulis komentar Anda di sini...",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: 'Serif',
                      ),
                      filled: true,
                      fillColor: _paperBg,
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
                        elevation: 3,
                        shadowColor: _primaryBrown.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Kirim Ulasan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- HELPER LAINNYA ---
  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) return Container(color: Colors.grey.shade300);
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            if (frame == null) return Container(color: Colors.grey.shade300);
            return child;
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
        if (mod4 > 0) cleanBase64 += '=' * (4 - mod4);
        Uint8List bytes = base64Decode(cleanBase64);
        return Image.memory(bytes, fit: BoxFit.cover);
      }
    } catch (e) {
      return Container(color: Colors.grey.shade300);
    }
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _goldAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _primaryBrown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: _primaryBrown, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 13,
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
}

// ===============================================
//   WIDGET KHUSUS: AUTO PLAY SLIDER + DOTS (FIXED)
// ===============================================
class _AutoPlayReviewSlider extends StatefulWidget {
  final List<DocumentSnapshot> docs;
  final Color primaryBrown;
  final Color goldAccent;
  final Color textBody;
  final Color paperBg;

  const _AutoPlayReviewSlider({
    required this.docs,
    required this.primaryBrown,
    required this.goldAccent,
    required this.textBody,
    required this.paperBg,
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
    // viewportFraction 0.85 agar kartu sebelah sedikit terlihat
    _pageController = PageController(viewportFraction: 0.85, initialPage: 0);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    // Geser setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentIndex < widget.docs.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. SLIDER (PageView)
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.docs.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              var data = widget.docs[index].data() as Map<String, dynamic>;
              // Padding horizontal agar ada jarak antar kartu saat di-scroll
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildCard(data),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // 2. DOTS INDICATOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            // Batasi dots maks 8 agar tidak kepanjangan jika ulasan banyak
            widget.docs.length > 8 ? 8 : widget.docs.length,
            (index) => _buildDot(index),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    // Logika agar dot tetap menyala jika ulasan > 8 (looping indikator sederhana)
    int displayIndex =
        _currentIndex % (widget.docs.length > 8 ? 8 : widget.docs.length);
    bool isActive = displayIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8, // Dot aktif melebar
      decoration: BoxDecoration(
        color: isActive ? widget.goldAccent : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // --- DESIGN CARD (SAMA SEPERTI YANG ANDA SUKA) ---
  Widget _buildCard(Map<String, dynamic> data) {
    String name = data['user_name'] ?? 'Pengguna';
    String photo = data['user_photo'] ?? '';
    String comment = data['comment'] ?? '';
    int rating = data['rating'] ?? 0;

    String dateStr = "";
    if (data['created_at'] != null && data['created_at'] is Timestamp) {
      DateTime dt = (data['created_at'] as Timestamp).toDate();
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      String year = dt.year.toString();
      dateStr = "$day/$month/$year";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.goldAccent, width: 1.5),
                  image: photo.isNotEmpty
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(photo)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: widget.paperBg,
                ),
                child: photo.isEmpty
                    ? Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "U",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.primaryBrown,
                            fontSize: 18,
                            fontFamily: 'Serif',
                          ),
                        ),
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
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: widget.textBody,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Ionicons.star,
                      size: 12,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$rating.0",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.withOpacity(0.1), height: 1),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 14,
                height: 1.5,
                color: widget.textBody.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
