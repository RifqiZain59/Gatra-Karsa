import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../controllers/detaildalang_controller.dart';

class DetaildalangView extends GetView<DetaildalangController> {
  const DetaildalangView({super.key});

  // --- PALET WARNA WAYANG ---
  final Color _primaryBrown = const Color(0xFF3E2723);
  final Color _goldAccent = const Color(0xFFC5A059);
  final Color _paperBg = const Color(0xFFFDFBF7);
  final Color _textSecondary = const Color(0xFF5D4037);

  @override
  Widget build(BuildContext context) {
    // Data Dummy
    final Map<String, dynamic> dalang =
        Get.arguments ??
        {
          'name': 'Ki Nartosabdo',
          'title': 'Maestro Karawitan & Dalang',
          'origin': 'Klaten, Jawa Tengah',
          'image': 'assets/Dalang.png',
          'bio':
              'Ki Nartosabdo adalah seorang seniman musik dan dalang wayang kulit legendaris dari Jawa Tengah. Beliau dikenal karena pembaharuan dalam seni pedalangan.',
        };

    // 1. PERBAIKAN SYSTEM UI (Navigasi Bar Putih)
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Status Bar (Atas)
        statusBarColor: Colors.transparent, // Transparan agar gambar terlihat
        statusBarIconBrightness: Brightness.light, // Ikon putih (jam, baterai)
        // Navigation Bar (Bawah) - SESUAI REQUEST
        systemNavigationBarColor:
            Colors.white, // Warna background Nav Bar Putih
        systemNavigationBarIconBrightness:
            Brightness.dark, // Ikon (Back/Home) Hitam
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _paperBg,
        extendBodyBehindAppBar: true, // Gambar tetap tembus ke atas
        body: Stack(
          children: [
            // Background Ornament
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
                _buildSliverAppBar(dalang),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Center(child: _buildCategoryBadge()),
                        const SizedBox(height: 16),

                        // Nama & Gelar
                        Center(
                          child: Text(
                            dalang['name'].toString().toUpperCase(),
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
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            dalang['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: _goldAccent,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Info Row
                        Row(
                          children: [
                            _buildInfoCard(
                              Ionicons.map_outline,
                              "Asal Daerah",
                              dalang['origin'],
                            ),
                            const SizedBox(width: 16),
                            _buildInfoCard(
                              Ionicons.trophy_outline,
                              "Status",
                              "Legenda",
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Divider
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

                        // Biography
                        Text(
                          "Riwayat Singkat",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryBrown,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dalang['bio'] ?? "",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.8,
                            color: _textSecondary,
                          ),
                        ),

                        const SizedBox(height: 40),

                        _buildPlayButton(),

                        // 2. PERBAIKAN PADDING BAWAH (Agar tidak tabrakan)
                        // Mengambil tinggi safe area bawah (nav bar) + spasi tambahan
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

  // --- WIDGET BUILDERS (Sama seperti sebelumnya) ---

  Widget _buildSliverAppBar(Map<String, dynamic> dalang) {
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
            Image.asset(
              dalang['image'],
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (c, e, s) => Container(
                color: _primaryBrown,
                child: const Icon(
                  Ionicons.person,
                  size: 80,
                  color: Colors.white24,
                ),
              ),
            ),
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

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: _goldAccent),
        borderRadius: BorderRadius.circular(20),
        color: _goldAccent.withOpacity(0.1),
      ),
      child: Text(
        "MAESTRO DALANG",
        style: TextStyle(
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
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
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

  Widget _buildPlayButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryBrown, const Color(0xFF5D4037)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryBrown.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.snackbar(
              "Info",
              "Fitur audio akan segera hadir",
              backgroundColor: Colors.white,
              colorText: _primaryBrown,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Ionicons.play, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              const Text(
                "Dengarkan Cuplikan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
