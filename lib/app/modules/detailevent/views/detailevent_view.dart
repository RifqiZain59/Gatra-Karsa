import 'dart:async'; // Wajib untuk Timer Auto Slide
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
// FIX IMPORT: Menggunakan controller event yang benar
import '../controllers/detailevent_controller.dart';

class DetaileventView extends GetView<DetaileventController> {
  const DetaileventView({super.key});

  // Warna Tema
  final Color _primaryBrown = const Color(0xFF3E2723);
  final Color _goldAccent = const Color(0xFFC5A059);
  final Color _paperBg = const Color(0xFFFDFBF7);
  final Color _textBody = const Color(0xFF4E342E);
  final Color _cardBg = const Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    // FIX CHECK: Pastikan controller yang dicek adalah DetaileventController
    if (!Get.isRegistered<DetaileventController>()) {
      Get.put(DetaileventController());
    }

    final ContentModel event = controller.event;

    // Data Helpers
    final String date = event.subtitle.isNotEmpty
        ? event.subtitle
        : "Tanggal Belum Tersedia";
    final String time = event.time ?? "Waktu Belum Tersedia";
    final String location =
        (event.location != null && event.location!.isNotEmpty)
        ? event.location!
        : "Lokasi Belum Tersedia";
    final String price = event.price ?? "Gratis";
    final String performer = event.performer ?? "-";

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
        // 1. FIX LAYOUT: Mencegah hancur saat keyboard muncul
        resizeToAvoidBottomInset: false,

        // 2. FITUR: STICKY FOOTER (Tombol Navigasi)
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Ionicons.navigate, size: 20),
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
                    _buildImage(event.imageUrl),
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

            // --- B. KONTEN INFORMASI ---
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
                    Text(
                      event.title,
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
                    _buildInfoRow(Ionicons.location_outline, location),

                    const SizedBox(height: 30),
                    const Divider(thickness: 1, height: 1),
                    const SizedBox(height: 20),

                    // Performer (Artis/Dalang)
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
                      event.description.isNotEmpty
                          ? event.description
                          : "Deskripsi belum tersedia.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: _textBody,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- C. SLIDER ULASAN (AUTO PLAY) ---
                    _buildReviewSectionWithPopup(context),

                    const SizedBox(height: 40), // Jarak aman ke footer
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET ULASAN ---
  Widget _buildReviewSectionWithPopup(BuildContext context) {
    // FIX ERROR: Menggunakan QuerySnapshot agar .docs dikenali
    return StreamBuilder<QuerySnapshot>(
      stream: controller.ulasanStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(height: 150, color: Colors.grey[100]);
        }

        // FIX ERROR: Casting snapshot.data ke QuerySnapshot atau cek null dengan benar
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
            // 1. Summary Card
            Container(
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
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < averageRating.round()
                                ? Ionicons.star
                                : Ionicons.star_outline,
                            color: const Color(0xFFD4AF37),
                            size: 18,
                          ),
                        ),
                      ),
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
                  const Icon(
                    Ionicons.chatbubbles_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 2. Header & Tombol Tulis
            Row(
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
                      color: _primaryBrown,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Slider
            if (totalReviews == 0)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Belum ada ulasan.",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              )
            else
              // Menggunakan Widget Slider Reusable
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

  // --- MODAL INPUT ULASAN ---
  void _openRatingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 25,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Bagikan Pengalaman Anda",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: _primaryBrown,
                ),
              ),
              const SizedBox(height: 25),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => GestureDetector(
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
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: controller.reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Tulis komentar...",
                  filled: true,
                  fillColor: _paperBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Kirim Ulasan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
  }

  // --- WIDGET HELPER ---
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
    if (imageUrl.isEmpty) return Container(color: _primaryBrown);
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
        String cleanBase64 = imageUrl.replaceAll(RegExp(r'\s+'), '');
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',').last;
        }
        int mod4 = cleanBase64.length % 4;
        if (mod4 > 0) cleanBase64 += '=' * (4 - mod4);
        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: _primaryBrown),
        );
      }
    } catch (e) {
      return Container(color: _primaryBrown);
    }
  }
}

// --- WIDGET AUTO SLIDER REUSABLE ---
class _AutoPlayReviewSlider extends StatefulWidget {
  final List<dynamic> docs;
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
    // Fraction 0.85 agar kartu sebelah sedikit terlihat
    _pageController = PageController(viewportFraction: 0.85);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
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
        // FIX: TINGGI SLIDER CUKUP UNTUK 3 BARIS TEXT
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.docs.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              var data = widget.docs[index].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildCard(data),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // DOTS INDICATOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.docs.length > 8 ? 8 : widget.docs.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width:
                  _currentIndex %
                          (widget.docs.length > 8 ? 8 : widget.docs.length) ==
                      index
                  ? 24
                  : 8,
              decoration: BoxDecoration(
                color:
                    _currentIndex %
                            (widget.docs.length > 8 ? 8 : widget.docs.length) ==
                        index
                    ? widget.goldAccent
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> data) {
    String name = data['user_name'] ?? 'Pengguna';
    String photo = data['user_photo'] ?? '';
    String comment = data['comment'] ?? '';
    int rating = data['rating'] ?? 0;
    String dateStr = "";
    if (data['created_at'] != null) {
      DateTime dt = data['created_at'].toDate();
      dateStr = "${dt.day}/${dt.month}/${dt.year}";
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
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
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

          // FIX TEXT OVERFLOW
          Text(
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
        ],
      ),
    );
  }
}
