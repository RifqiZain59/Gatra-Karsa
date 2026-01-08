import 'dart:convert'; // Untuk decode Base64
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORT HALAMAN TUJUAN (Sesuaikan path folder Anda) ---
import 'package:gatrakarsa/app/modules/editprofile/views/editprofile_view.dart';
import 'package:gatrakarsa/app/modules/gantikatasandi/views/gantikatasandi_view.dart';
import 'package:gatrakarsa/app/modules/riwayatlogin/views/riwayatlogin_view.dart';

// --- IMPORT HALAMAN MENU BARU ---
import 'package:gatrakarsa/app/modules/tentangkami/views/tentangkami_view.dart';
import 'package:gatrakarsa/app/modules/ketentuanpemakaian/views/ketentuanpemakaian_view.dart';
import 'package:gatrakarsa/app/modules/kebijakanprivasi/views/kebijakanprivasi_view.dart';

// --- TEMA WARNA ---
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
        print("Gagal ambil data profil: $e");
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
          child: Column(
            children: [
              _buildHeaderSection(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // --- BAGIAN 1: PENGATURAN AKUN ---
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

                    // --- BAGIAN 2: TENTANG (NAVIGASI AKTIF) ---
                    _buildSectionTitle('Tentang Gatra Karsa'),
                    _buildMenuCard(context, [
                      _buildMenuItem(
                        Ionicons.information_circle_outline,
                        'Tentang Kami',
                        onTap: () => Get.to(
                          () => const TentangkamiView(),
                        ), // ARAHKAN KE TENTANG KAMI
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Ionicons.document_text_outline,
                        'Ketentuan Pemakaian',
                        onTap: () => Get.to(
                          () => const KetentuanpemakaianView(),
                        ), // ARAHKAN KE KETENTUAN
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        Ionicons.shield_checkmark_outline,
                        'Kebijakan Privasi',
                        onTap: () => Get.to(
                          () => const KebijakanprivasiView(),
                        ), // ARAHKAN KE KEBIJAKAN
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // --- BAGIAN 3: BANTUAN ---
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

                    // --- TOMBOL KELUAR ---
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
                        label: const Text(
                          'Keluar Aplikasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Serif',
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

  // --- WIDGET HELPERS ---
  Widget _buildHeaderSection(BuildContext context) {
    ImageProvider? imageProvider;
    if (_photoBase64 != null && _photoBase64!.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(_photoBase64!));
      } catch (e) {
        print("Error decoding image: $e");
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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [WayangColors.primaryDark, WayangColors.primaryLight],
              ),
            ),
          ),
          Positioned.fill(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
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
              ],
            ),
          ),
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Serif',
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
                    child: Text(
                      _userEmail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Serif',
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

  Widget _buildLeafDecor({double angle = 0, double size = 60}) {
    return Transform.rotate(
      angle: angle,
      child: Icon(
        Ionicons.leaf,
        size: size,
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
          fontFamily: 'Serif',
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
                    fontFamily: 'Serif',
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
