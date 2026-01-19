import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart'; // IMPORT GOOGLE FONTS
import 'package:gatrakarsa/app/data/service/api_service.dart';
import '../controllers/detailkisah_controller.dart';

class DetailkisahView extends GetView<DetailkisahController> {
  const DetailkisahView({super.key});

  final Color _primaryBrown = const Color(0xFF4E342E);
  final Color _goldAccent = const Color(0xFFD4AF37);
  final Color _bgSoft = const Color(0xFFFAFAFA);
  final Color _textHeading = const Color(0xFF2D2D2D);
  final Color _textBody = const Color(0xFF616161);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DetailkisahController>()) {
      Get.put(DetailkisahController());
    }

    final ContentModel story = controller.story;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 1. GAMBAR BACKGROUND
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: _buildHeaderImage(story.imageUrl),
            ),

            // 2. TOMBOL BACK & BOOKMARK
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
                          : Colors.black,
                      onTap: () => controller.toggleSave(),
                    ),
                  ),
                ],
              ),
            ),

            // 3. KONTEN UTAMA
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
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle Bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // A. KATEGORI
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryBrown.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          story.category.toUpperCase(),
                          style: GoogleFonts.mulish(
                            // FONT KATEGORI
                            color: _primaryBrown,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // B. JUDUL UTAMA
                      Text(
                        story.title,
                        style: GoogleFonts.philosopher(
                          // FONT JUDUL
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _textHeading,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // C. KOTAK HIKMAH
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Ionicons.sparkles,
                              color: _goldAccent,
                              size: 28,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "INTISARI & HIKMAH",
                              style: GoogleFonts.mulish(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              story.subtitle.isNotEmpty
                                  ? "\"${story.subtitle}\""
                                  : "\"Cerita ini mengajarkan nilai luhur kehidupan.\"",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.philosopher(
                                // FONT KUTIPAN
                                fontSize: 18, // Sedikit diperbesar
                                fontStyle: FontStyle.italic,
                                color: _primaryBrown,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // AI SUMMARY
                      _AiSummaryGenerator(
                        description: story.description,
                        primaryColor: _primaryBrown,
                        accentColor: _goldAccent,
                      ),

                      const SizedBox(height: 30),

                      // D. ISI CERITA
                      Text("Kisah Selengkapnya", style: _headingStyle),
                      const SizedBox(height: 12),
                      Text(
                        story.description,
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.mulish(
                          // FONT BODY
                          fontSize: 16,
                          height: 1.8,
                          color: _textBody,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // E. ULASAN
                      _buildReviewSection(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _headingStyle => GoogleFonts.philosopher(
    // FONT SUB-JUDUL
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: _textHeading,
  );

  // ... (SISA KODE HELPER SAMA, HANYA GANTI DI TEXTSTYLE BAWAH INI)

  // (Helper Button & Image tetap sama seperti kode Anda sebelumnya)
  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black,
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
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
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
        if (cleanBase64.contains(','))
          cleanBase64 = cleanBase64.split(',').last;
        int mod4 = cleanBase64.length % 4;
        if (mod4 > 0) cleanBase64 += '=' * (4 - mod4);
        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: _bgSoft),
        );
      }
    } catch (e) {
      return Container(color: _bgSoft);
    }
  }

  // --- REVIEW SECTION UPDATE FONTS ---
  Widget _buildReviewSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.ulasanStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Container(height: 150, color: Colors.grey[100]);

        var docs = snapshot.data?.docs ?? [];
        int totalReviews = docs.length;
        double averageRating = 0.0;
        if (totalReviews > 0) {
          double totalStars = 0;
          for (var doc in docs)
            totalStars += (doc.data() as Map<String, dynamic>)['rating'] ?? 0;
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
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: GoogleFonts.philosopher(
                                  // ANGKA RATING BESAR
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _goldAccent,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 6),
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
                                size: 20,
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
                            "Pembaca",
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
                TextButton(
                  onPressed: () => _openRatingBottomSheet(context),
                  style: TextButton.styleFrom(foregroundColor: _goldAccent),
                  child: Text(
                    "Tulis Ulasan",
                    style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                      style: GoogleFonts.mulish(
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

  // --- MODAL & SLIDER JUGA DIUPDATE FONT-NYA ---
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
              const SizedBox(height: 25),
              Text(
                "Bagikan Pendapat",
                style: GoogleFonts.philosopher(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _primaryBrown,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Beri rating dan ulasan untuk cerita ini",
                style: GoogleFonts.mulish(
                  color: Colors.grey[500],
                  fontSize: 14,
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
                          size: 44,
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
                style: GoogleFonts.mulish(),
                decoration: InputDecoration(
                  hintText: "Tulis pendapat Anda di sini...",
                  hintStyle: GoogleFonts.mulish(color: Colors.grey[400]),
                  filled: true,
                  fillColor: _bgSoft,
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
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Kirim Ulasan",
                    style: GoogleFonts.mulish(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
            ],
          ),
        ),
      ),
    );
  }
}

// --- AI SUMMARY GENERATOR (UPDATED FONTS) ---
class _AiSummaryGenerator extends StatefulWidget {
  final String description;
  final Color primaryColor;
  final Color accentColor;
  const _AiSummaryGenerator({
    required this.description,
    required this.primaryColor,
    required this.accentColor,
  });
  @override
  State<_AiSummaryGenerator> createState() => _AiSummaryGeneratorState();
}

class _AiSummaryGeneratorState extends State<_AiSummaryGenerator> {
  bool _isLoading = false;
  bool _hasGenerated = false;
  String _generatedSummary = "";

  void _generateSummary() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          List<String> sentences = widget.description.split('.');
          if (sentences.length > 2) {
            _generatedSummary = "${sentences[0]}. ${sentences[1]}.";
          } else {
            _generatedSummary = widget.description;
          }
          _isLoading = false;
          _hasGenerated = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Ionicons.aperture_outline, color: widget.primaryColor),
                const SizedBox(width: 8),
                Text(
                  "AI Assistant",
                  style: GoogleFonts.mulish(
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                  ),
                ),
                const Spacer(),
                if (_hasGenerated)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Generated",
                      style: GoogleFonts.mulish(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!_hasGenerated && !_isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateSummary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: widget.primaryColor,
                    elevation: 0,
                    side: BorderSide(
                      color: widget.primaryColor.withOpacity(0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Ionicons.flash_outline, size: 18),
                  label: Text(
                    "Generate Simpulan Otomatis",
                    style: GoogleFonts.mulish(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Sedang memproses cerita...",
                      style: GoogleFonts.mulish(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_hasGenerated)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    "Simpulan:",
                    style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _generatedSummary,
                    style: GoogleFonts.mulish(
                      color: widget.primaryColor,
                      height: 1.5,
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
