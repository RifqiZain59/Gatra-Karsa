import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';

// --- TEMA WARNA WAYANG ---
class WayangColors {
  static const Color primaryDark = Color(0xFF4E342E); // Coklat Tua
  static const Color primaryLight = Color(0xFF8D6E63); // Coklat Susu
  static const Color goldAccent = Color(0xFFD4AF37); // Emas
  static const Color background = Color(0xFFFAFAF5); // Krem
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF3E2723);
  static const Color textSecondary = Color(0xFF795548);
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Gatra Karsa',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Serif', // Set font global
        scaffoldBackgroundColor: WayangColors.background,
        primaryColor: WayangColors.primaryDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const CustomerProfileScreen(),
    );
  }
}

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 1. HEADER KOTAK DENGAN POLA DAUN TERSEBAR RAPI
              _buildHeaderSection(context),

              // 2. CONTENT SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    _buildSectionTitle('Pengaturan Akun'),
                    _buildMenuCard(context, [
                      _buildMenuItem(
                        Ionicons.person_outline,
                        'Edit Profil',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Ionicons.lock_closed_outline,
                        'Ganti Kata Sandi',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Ionicons.time_outline,
                        'Riwayat Login',
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 32),

                    _buildSectionTitle('Tentang Gatra Karsa'),
                    _buildMenuCard(context, [
                      _buildMenuItem(
                        Ionicons.information_circle_outline,
                        'Tentang Kami',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Ionicons.document_text_outline,
                        'Ketentuan Pemakaian',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Ionicons.shield_checkmark_outline,
                        'Kebijakan Privasi',
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 32),

                    _buildSectionTitle('Pusat Bantuan'),
                    _buildMenuCard(context, [
                      _buildMenuItem(
                        Ionicons.logo_whatsapp,
                        'Hubungi CS (WhatsApp)',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Ionicons.help_circle_outline,
                        'FAQ',
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 40),

                    // TOMBOL KELUAR
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red[700],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Ionicons.log_out_outline),
                        label: const Text(
                          'Keluar Aplikasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Serif', // Font disamakan
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET: Header Kotak dengan Pola Daun Tersebar
  Widget _buildHeaderSection(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          // Layer 1: Background Gradien Coklat
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [WayangColors.primaryDark, WayangColors.primaryLight],
              ),
            ),
          ),

          // Layer 2: POLA DAUN (Watermark Pattern)
          // Menggunakan Positioned untuk menyebar daun agar tidak berdempetan
          Positioned.fill(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // --- BAGIAN ATAS (Kiri, Tengah, Kanan) ---
                Positioned(
                  top: -20,
                  left: -20,
                  child: _buildLeafDecor(angle: -0.8, size: 80),
                ),
                Positioned(
                  top: 10,
                  left: 100,
                  child: _buildLeafDecor(angle: 0.5, size: 50),
                ),
                Positioned(
                  top: -10,
                  right: 80,
                  child: _buildLeafDecor(angle: -0.3, size: 60),
                ),
                Positioned(
                  top: 20,
                  right: -30,
                  child: _buildLeafDecor(angle: 0.9, size: 70),
                ),

                // --- BAGIAN TENGAH (Pinggir Kiri & Kanan) ---
                Positioned(
                  top: 100,
                  left: -40,
                  child: _buildLeafDecor(angle: 1.2, size: 90),
                ),
                Positioned(
                  top: 120,
                  right: -20,
                  child: _buildLeafDecor(angle: -1.5, size: 85),
                ),
                Positioned(
                  top: 110,
                  left: 40,
                  child: _buildLeafDecor(angle: 0.2, size: 40),
                ), // Kecil
                Positioned(
                  top: 130,
                  right: 60,
                  child: _buildLeafDecor(angle: 0.4, size: 45),
                ), // Kecil
                // --- BAGIAN BAWAH (Kiri, Tengah, Kanan) ---
                Positioned(
                  bottom: 20,
                  left: -10,
                  child: _buildLeafDecor(angle: 0.7, size: 60),
                ),
                Positioned(
                  bottom: -30,
                  left: 80,
                  child: _buildLeafDecor(angle: -0.4, size: 80),
                ),
                Positioned(
                  bottom: 10,
                  right: 100,
                  child: _buildLeafDecor(angle: 0.6, size: 50),
                ),
                Positioned(
                  bottom: -20,
                  right: -10,
                  child: _buildLeafDecor(angle: -0.9, size: 75),
                ),
              ],
            ),
          ),

          // Layer 3: Konten Profil Utama (Paling Atas)
          SafeArea(
            bottom: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: WayangColors.goldAccent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: WayangColors.background,
                      child: Icon(
                        Ionicons.person,
                        size: 55,
                        color: WayangColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Alex Richards',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      fontFamily: 'Serif', // Font disamakan
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'alex.richards@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Serif', // Font disamakan
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk membuat ikon daun dekorasi
  Widget _buildLeafDecor({double angle = 0, double size = 60}) {
    return Transform.rotate(
      angle: angle,
      child: Icon(
        Ionicons.leaf,
        size: size,
        // Opacity sangat rendah agar tidak mengganggu teks
        color: WayangColors.goldAccent.withOpacity(0.08),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: WayangColors.primaryDark.withOpacity(0.8),
          fontFamily: 'Serif', // Font disamakan (sebelumnya 'Sans')
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, List<Widget> children) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: WayangColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: WayangColors.primaryDark.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: WayangColors.primaryDark.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: WayangColors.primaryDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: WayangColors.textPrimary,
                    fontFamily: 'Serif', // Font disamakan
                  ),
                ),
              ),
              const Icon(
                Ionicons.chevron_forward,
                size: 18,
                color: WayangColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: WayangColors.primaryDark.withOpacity(0.05),
      indent: 16,
      endIndent: 16,
    );
  }
}
