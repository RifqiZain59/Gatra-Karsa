import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';

class TentangkamiView extends StatelessWidget {
  const TentangkamiView({super.key});

  // Tema Warna Gatra Karsa
  final Color primaryDark = const Color(0xFF4E342E);
  final Color accentGold = const Color(0xFFD4AF37);
  final Color backgroundColor = const Color(0xFFFAFAF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        // === PENGATURAN STATUS BAR & NAVIGATION BAR ===
        systemOverlayStyle: SystemUiOverlayStyle(
          // 1. Status Bar (Atas)
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Ikon hitam (Android)
          statusBarBrightness: Brightness.light, // Ikon hitam (iOS)
          // 2. Navigation Bar (Bawah)
          systemNavigationBarColor: Colors.white, // NAV BAR JADI PUTIH
          systemNavigationBarIconBrightness:
              Brightness.dark, // IKON NAV BAR JADI HITAM
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        // ==============================================
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Tentang Gatra Karsa",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Logo Section
              Center(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryDark.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logo2.png',
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Ionicons.image_outline,
                      size: 80,
                      color: accentGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Versi 1.0.0",
                style: TextStyle(
                  color: primaryDark.withOpacity(0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),

              // Konten Kartu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildInfoCard(
                      icon: Ionicons.ribbon_outline,
                      title: "Misi Budaya",
                      content:
                          "Aplikasi ini dikembangkan untuk mengenali dan memberikan informasi mendalam tentang berbagai jenis wayang. Wayang adalah seni pertunjukan tradisional Indonesia yang diakui sebagai Warisan Budaya Takbenda oleh UNESCO.",
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      icon: Ionicons.hardware_chip_outline,
                      title: "Teknologi Cerdas",
                      content:
                          "Kami menggunakan teknologi pengenalan gambar mutakhir untuk mengidentifikasi Wayang Kulit, Wayang Golek, hingga Wayang Madya. Kami bertekad mempermudah akses informasi tentang tokoh dan cerita wayang.",
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      icon: Ionicons.earth_outline,
                      title: "Impian Kami",
                      content:
                          "Menjadi sumber daya utama digital bagi pecinta budaya. Dengan menggabungkan teknologi modern dan kekayaan budaya, kami memberikan pengalaman belajar yang interaktif dan menyenangkan.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),
              Text(
                "© 2026 Gatra Karsa Team",
                style: TextStyle(
                  color: primaryDark.withOpacity(0.4),
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentGold, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                  fontFamily: 'Serif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: primaryDark.withOpacity(0.75),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
