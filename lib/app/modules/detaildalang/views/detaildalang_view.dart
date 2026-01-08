import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

// Import Controller
import '../controllers/detaildalang_controller.dart';

class DetaildalangView extends GetView<DetaildalangController> {
  const DetaildalangView({super.key});

  // --- PALET WARNA ---
  final Color _primaryBrown = const Color(0xFF3E2723);
  final Color _goldAccent = const Color(0xFFC5A059);
  final Color _paperBg = const Color(0xFFFDFBF7);
  final Color _textSecondary = const Color(0xFF5D4037);

  // --- HELPER: DECODE GAMBAR BASE64 ---
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
    // Ambil data ContentModel dari controller
    final ContentModel dalang = controller.dalang;

    // Decode gambar
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
            // Ornamen Background
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

                        // 1. Kategori Badge
                        Center(child: _buildCategoryBadge(dalang.category)),
                        const SizedBox(height: 20),

                        // 2. Nama Tokoh (Title)
                        Center(
                          child: Text(
                            dalang.title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Serif',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _primaryBrown,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        // --- TULISAN DI BAWAH NAMA DIHAPUS ---
                        const SizedBox(height: 32),

                        // 3. --- KOTAK INFO (ASAL DAERAH & NOMOR HP) ---
                        Row(
                          children: [
                            _buildInfoCard(
                              Ionicons.map_outline,
                              "Asal Daerah",
                              // Menampilkan location, jika kosong baru subtitle
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

                        // Divider Ornamen
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

                        // 4. Riwayat Singkat (Deskripsi)
                        Text(
                          "Riwayat Singkat",
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryBrown,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dalang.description,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 15,
                            height: 1.8,
                            color: _textSecondary,
                          ),
                        ),

                        // Jarak bawah setelah deskripsi
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

  // --- WIDGET BUILDERS ---

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
        style: TextStyle(
          fontFamily: 'Serif',
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
