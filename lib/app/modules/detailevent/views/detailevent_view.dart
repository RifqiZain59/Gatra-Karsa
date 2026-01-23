import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import '../controllers/detailevent_controller.dart';

class DetaileventView extends GetView<DetaileventController> {
  const DetaileventView({super.key});

  final Color _primaryBrown = const Color(0xFF4E342E);
  final Color _goldAccent = const Color(0xFFD4AF37);
  final Color _bgSoft = const Color(0xFFFAFAFA);
  final Color _textHeading = const Color(0xFF2D2D2D);
  final Color _textBody = const Color(0xFF616161);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DetaileventController>()) {
      Get.put(DetaileventController());
    }

    final ContentModel event = controller.event;
    final String date = event.subtitle.isNotEmpty ? event.subtitle : "TBA";
    final String time = event.time ?? "TBA";
    final String location =
        (event.location != null && event.location!.isNotEmpty)
        ? event.location!
        : "Lokasi belum tersedia";
    final String price = event.price ?? "Gratis";
    final String performer = event.performer ?? "";

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // 1. GAMBAR HEADER
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: _buildHeaderImage(event.imageUrl),
            ),

            // 2. NAVBAR
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _glassButton(
                    icon: Ionicons.arrow_back,
                    onTap: () => Get.back(),
                  ),
                  Obx(
                    () => _glassButton(
                      icon: controller.isSaved.value
                          ? Ionicons.bookmark
                          : Ionicons.bookmark_outline,
                      color: controller.isSaved.value
                          ? _goldAccent
                          : Colors.white,
                      onTap: () => controller.toggleSave(),
                    ),
                  ),
                ],
              ),
            ),

            // 3. KONTEN
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.40,
              child: Container(
                decoration: BoxDecoration(
                  color: _bgSoft,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KATEGORI
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _goldAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.category.toUpperCase(),
                          style: GoogleFonts.mulish(
                            color: _primaryBrown,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // JUDUL
                      Text(
                        event.title,
                        style: GoogleFonts.philosopher(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _textHeading,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // GRID INFO
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoTile(
                              Ionicons.calendar_clear_outline,
                              "Tanggal",
                              date,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoTile(
                              Ionicons.time_outline,
                              "Waktu",
                              time,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildLocationTile(location),
                      const SizedBox(height: 30),

                      // PERFORMER
                      if (performer.isNotEmpty && performer != "-") ...[
                        Text("Penampil Utama", style: _headingStyle),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _primaryBrown.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Ionicons.mic_outline,
                                  color: _primaryBrown,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    performer,
                                    style: GoogleFonts.mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: _textHeading,
                                    ),
                                  ),
                                  Text(
                                    "Tokoh / Seniman",
                                    style: GoogleFonts.mulish(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],

                      // DESKRIPSI
                      Text("Tentang Acara", style: _headingStyle),
                      const SizedBox(height: 10),
                      Text(
                        event.description.isNotEmpty
                            ? event.description
                            : "Tidak ada deskripsi.",
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.mulish(
                          fontSize: 15,
                          height: 1.8,
                          color: _textBody,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // REVIEW
                      _buildReviewSection(context),
                    ],
                  ),
                ),
              ),
            ),

            // 4. BOTTOM BAR
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  20 + MediaQuery.of(context).padding.bottom,
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
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Harga Tiket",
                          style: GoogleFonts.mulish(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          price,
                          style: GoogleFonts.philosopher(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _primaryBrown,
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
                          vertical: 16,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Ionicons.map_outline, size: 20),
                      label: Text(
                        "Petunjuk Arah",
                        style: GoogleFonts.mulish(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _headingStyle => GoogleFonts.philosopher(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: _textHeading,
  );

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _goldAccent, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.mulish(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.mulish(
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Ionicons.location_outline, color: _goldAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lokasi",
                  style: GoogleFonts.mulish(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: GoogleFonts.mulish(
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

  // --- REVIEW SECTION ---
  Widget _buildReviewSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.ulasanStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(height: 150, color: Colors.grey[100]);
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        var docs = snapshot.data?.docs ?? [];

        // --- SORTING MANUAL (Pengganti Index) ---
        docs.sort((a, b) {
          var dataA = a.data() as Map<String, dynamic>;
          var dataB = b.data() as Map<String, dynamic>;
          var timeA = dataA['created_at'];
          var timeB = dataB['created_at'];

          if (timeA is Timestamp && timeB is Timestamp) {
            return timeB.compareTo(timeA); // Descending (Terbaru di atas)
          }
          return 0;
        });
        // ----------------------------------------

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
                    blurRadius: 15,
                    offset: const Offset(0, 8),
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
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: GoogleFonts.philosopher(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _goldAccent,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  "/ 5.0",
                                  style: GoogleFonts.mulish(
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
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "$totalReviews Ulasan",
                            style: GoogleFonts.mulish(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Pengunjung",
                            style: GoogleFonts.mulish(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ulasan Terbaru", style: _headingStyle),
                GestureDetector(
                  onTap: () => _openRatingBottomSheet(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Tulis Ulasan",
                      style: GoogleFonts.mulish(
                        color: _goldAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (docs.isEmpty)
              Container(
                padding: const EdgeInsets.all(30),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Ionicons.chatbubble_ellipses_outline,
                      size: 40,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Belum ada ulasan.",
                      style: GoogleFonts.mulish(
                        color: Colors.grey[400],
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

  void _openRatingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
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
              const SizedBox(height: 20),
              Text(
                "Bagikan Pengalaman",
                style: GoogleFonts.philosopher(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(
                          index < controller.userRating.value
                              ? Ionicons.star
                              : Ionicons.star_outline,
                          color: _goldAccent,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: controller.reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Ceritakan pengalamanmu...",
                  hintStyle: GoogleFonts.mulish(color: Colors.grey[400]),
                  filled: true,
                  fillColor: _bgSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.submitReview();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Kirim Ulasan",
                    style: GoogleFonts.mulish(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage(String imageUrl) {
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
        if (cleanBase64.contains(','))
          cleanBase64 = cleanBase64.split(',').last;
        int mod4 = cleanBase64.length % 4;
        if (mod4 > 0) cleanBase64 += '=' * (4 - mod4);
        return Image.memory(base64Decode(cleanBase64), fit: BoxFit.cover);
      }
    } catch (e) {
      return Container(color: _primaryBrown);
    }
  }
}

// --- DEFINISI SLIDER ---
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
                          style: GoogleFonts.mulish(
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
                              style: GoogleFonts.mulish(
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
                  style: GoogleFonts.mulish(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
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
