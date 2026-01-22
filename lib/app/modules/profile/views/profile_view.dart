import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORT HALAMAN (Sesuaikan dengan project Anda)
import 'package:gatrakarsa/app/modules/editprofile/views/editprofile_view.dart';
import 'package:gatrakarsa/app/modules/gantikatasandi/views/gantikatasandi_view.dart';
import 'package:gatrakarsa/app/modules/riwayatlogin/views/riwayatlogin_view.dart';
import 'package:gatrakarsa/app/modules/tentangkami/views/tentangkami_view.dart';
import 'package:gatrakarsa/app/modules/ketentuanpemakaian/views/ketentuanpemakaian_view.dart';
import 'package:gatrakarsa/app/modules/kebijakanprivasi/views/kebijakanprivasi_view.dart';
import 'package:gatrakarsa/app/modules/daftarsave/views/daftarsave_view.dart';
import 'package:gatrakarsa/app/modules/ulasan/views/ulasan_view.dart';

class WayangColors {
  static const Color primaryDark = Color(0xFF4E342E);
  static const Color primaryLight = Color(0xFF8D6E63);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color background = Color(0xFFFAFAF5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF3E2723);
  static const Color textSecondary = Color(0xFF795548);
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String _userName = "Memuat...";
  String _userEmail = "Memuat email...";
  String? _photoUrl;
  String? _photoBase64;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? "-";
        _photoUrl = user.photoURL;
      });
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          setState(() {
            _userName = data?['name'] ?? user.displayName ?? "Sobat Wayang";
            _photoBase64 = data?['photoBase64'];
          });
        }
      } catch (e) {
        print("Gagal: $e");
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar("Error", "Gagal keluar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WayangColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // HEADER (KOTAK COKLAT + BATIK)
              _buildHeaderSection(context),

              // KONTEN MENU
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSectionTitle('Koleksi Saya'),
                    _buildMenuCard(context, [
                      _buildMenuItem(
                        Ionicons.bookmark_outline,
                        'Daftar Simpanan',
                        onTap: () => Get.to(() => const DaftarsaveView()),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Aktivitas Saya'),
                    _buildMenuCard(context, [
                      _buildMenuItem(
                        Ionicons.star_outline,
                        'Ulasan & Rating',
                        onTap: () => Get.to(() => const UlasanView()),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Pengaturan Akun'),
                    _buildMenuCard(context, [
                      _buildMenuItem(
                        Ionicons.person_outline,
                        'Edit Profil',
                        onTap: () => Get.to(
                          () => const EditprofileView(),
                        )?.then((_) => _fetchUserData()),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Ionicons.lock_closed_outline,
                        'Ganti Kata Sandi',
                        onTap: () => Get.to(() => const GantikatasandiView()),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Ionicons.time_outline,
                        'Riwayat Login',
                        onTap: () => Get.to(() => const RiwayatloginView()),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Tentang Gatra Karsa'),
                    _buildMenuCard(context, [
                      _buildMenuItem(
                        Ionicons.information_circle_outline,
                        'Tentang Kami',
                        onTap: () => Get.to(() => const TentangkamiView()),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Ionicons.document_text_outline,
                        'Ketentuan Pemakaian',
                        onTap: () =>
                            Get.to(() => const KetentuanpemakaianView()),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Ionicons.shield_checkmark_outline,
                        'Kebijakan Privasi',
                        onTap: () => Get.to(() => const KebijakanprivasiView()),
                      ),
                    ]),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleLogout,
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
                        label: Text(
                          'Keluar Aplikasi',
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    // --- Jarak Aman Bawah ---
                    SizedBox(
                      height: 120 + MediaQuery.of(context).padding.bottom,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildHeaderSection(BuildContext context) {
    ImageProvider? imageProvider;
    if (_photoBase64 != null && _photoBase64!.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(_photoBase64!));
      } catch (e) {
        print("Error");
      }
    }
    if (imageProvider == null && _photoUrl != null && _photoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_photoUrl!);
    }
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          // 1. Lapisan Dasar (Gradien Coklat) - KOTAK (Tanpa Radius)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [WayangColors.primaryDark, WayangColors.primaryLight],
              ),
              // borderRadius dihapus agar kotak tegas
            ),
          ),

          // 2. Lapisan Pola Batik (Hanya di dalam header)
          Positioned.fill(
            child: CustomPaint(
              painter: BatikPatternPainter(
                // Warna emas transparan agar terlihat di atas coklat
                color: WayangColors.goldAccent.withOpacity(0.08),
              ),
            ),
          ),

          // 3. Konten Profil (Foto dan Nama)
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
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: WayangColors.background,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(
                              Ionicons.person,
                              size: 55,
                              color: WayangColors.primaryLight,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userName,
                    style: GoogleFonts.philosopher(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      _userEmail,
                      style: GoogleFonts.mulish(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.philosopher(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: WayangColors.primaryDark.withOpacity(0.8),
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
        border: Border.all(color: WayangColors.primaryDark.withOpacity(0.05)),
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
                  style: GoogleFonts.mulish(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: WayangColors.textPrimary,
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

// --- BATIK PATTERN PAINTER (MOTIF KAWUNG) ---
class BatikPatternPainter extends CustomPainter {
  final Color color;

  BatikPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    double circleRadius = 30;
    double gap = circleRadius * 1.5;

    for (double y = 0; y < size.height + circleRadius; y += gap) {
      for (double x = 0; x < size.width + circleRadius; x += gap) {
        canvas.drawCircle(Offset(x, y), circleRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
