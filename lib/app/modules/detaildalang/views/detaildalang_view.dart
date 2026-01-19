import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart'; // IMPORT FONT
import '../controllers/detaildalang_controller.dart';

class DetaildalangView extends GetView<DetaildalangController> {
  const DetaildalangView({super.key});

  final Color _primaryBrown = const Color(0xFF3E2723);
  final Color _goldAccent = const Color(0xFFC5A059);
  final Color _paperBg = const Color(0xFFFDFBF7);
  final Color _textSecondary = const Color(0xFF5D4037);

  Uint8List? _decodeImage(String base64String) {
    if (base64String.isEmpty) return null;
    try {
      if (base64String.contains(',')) {
        return base64Decode(base64String.split(',').last);
      }
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ContentModel dalang = controller.dalang;
    final Uint8List? imageBytes = _decodeImage(dalang.imageUrl);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _paperBg,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned(
              top: 300,
              right: -50,
              child: Opacity(
                opacity: 0.05,
                child: Icon(Ionicons.leaf, size: 400, color: _primaryBrown),
              ),
            ),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(imageBytes),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Center(child: _buildCategoryBadge(dalang.category)),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            dalang.title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.philosopher(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _primaryBrown,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            _buildInfoCard(
                              Ionicons.map_outline,
                              "Asal Daerah",
                              (dalang.location != null &&
                                      dalang.location!.isNotEmpty)
                                  ? dalang.location!
                                  : (dalang.subtitle.isNotEmpty
                                        ? dalang.subtitle
                                        : "-"),
                            ),
                            const SizedBox(width: 16),
                            _buildInfoCard(
                              Ionicons.call_outline,
                              "Nomor HP",
                              dalang.phone ?? "-",
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: _goldAccent.withOpacity(0.3),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Icon(
                                Ionicons.flower_outline,
                                size: 16,
                                color: _goldAccent,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: _goldAccent.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Riwayat Singkat",
                          style: GoogleFonts.philosopher(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryBrown,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dalang.description,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.mulish(
                            fontSize: 15,
                            height: 1.8,
                            color: _textSecondary,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 40,
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

  Widget _buildSliverAppBar(Uint8List? imageBytes) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      stretch: true,
      backgroundColor: _primaryBrown,
      elevation: 0,
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
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            imageBytes != null
                ? Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (c, e, s) => _buildImageError(),
                  )
                : _buildImageError(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    _paperBg,
                    _paperBg.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black26,
                  ],
                  stops: const [0.0, 0.15, 0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: _primaryBrown,
      child: const Icon(Ionicons.person, size: 80, color: Colors.white24),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: _goldAccent),
        borderRadius: BorderRadius.circular(20),
        color: _goldAccent.withOpacity(0.1),
      ),
      child: Text(
        category.toUpperCase(),
        style: GoogleFonts.mulish(
          color: _primaryBrown,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4E342E).withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryBrown.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: _primaryBrown, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.mulish(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.mulish(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
