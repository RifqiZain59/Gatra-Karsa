import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui'; // Diperlukan untuk ImageFilter (Blur)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT HALAMAN-HALAMAN ---
import 'package:gatrakarsa/app/modules/detail_wayang/views/detail_wayang_view.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:gatrakarsa/app/modules/kamera/views/kamera_view.dart';
import '../../profile/views/profile_view.dart';
import '../../video/views/video_view.dart';
import '../../leaderboard/views/leaderboard_view.dart';
import '../../quiz/views/quiz_view.dart';
import '../../tokoh/views/tokoh_view.dart';
import '../../kisah/views/kisah_view.dart';
import '../../museum/views/museum_view.dart';
import '../../event/views/event_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // --- PALET WARNA PREMIUM (Elegant Heritage) ---
  final Color _primaryColor = const Color(0xFF3E2723); // Coklat Tua Elegant
  final Color _secondaryColor = const Color(0xFF5D4037); // Coklat Medium
  final Color _accentColor = const Color(0xFFD4AF37); // Emas (Gold)
  final Color _surfaceColor = const Color(0xFFFFFFFF); // Putih Bersih
  final Color _bgColor = const Color(0xFFFDFCF8); // Putih Tulang
  final Color _softShadow = const Color(0xFF3E2723).withOpacity(0.08);

  final List<Map<String, dynamic>> categories = [
    {'icon': Ionicons.people_outline, 'label': 'Tokoh', 'color': 0xFF5D4037},
    {'icon': Ionicons.book_outline, 'label': 'Kisah', 'color': 0xFF795548},
    {'icon': Ionicons.map_outline, 'label': 'Museum', 'color': 0xFF8D6E63},
    {'icon': Ionicons.calendar_outline, 'label': 'Event', 'color': 0xFFA1887F},
    {
      'icon': Ionicons.game_controller_outline,
      'label': 'Kuis',
      'color': 0xFF6D4C41,
    },
  ];

  final List<Map<String, dynamic>> articles = [
    {
      'title': 'Filosofi Gunungan dalam Pagelaran Wayang',
      'date': '2 Jan 2026',
      'tag': 'Filosofi',
      'image': 'assets/banner1.jpg',
    },
    {
      'title': 'Perbedaan Gaya Wayang Surakarta dan Yogyakarta',
      'date': '29 Des 2025',
      'tag': 'Wawasan',
      'image': 'assets/banner1.jpg',
    },
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // --- HELPER DECODE IMAGE (BASE64) ---
  Uint8List? _decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: _surfaceColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bgColor,
        extendBody: true,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContentBody(),
            const VideoView(),
            const KameraView(),
            const LeaderboardView(),
            const ProfileView(),
          ],
        ),
        bottomNavigationBar: _buildModernBottomNav(context),
        floatingActionButton: _buildGlowFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  // --- MAIN HOME CONTENT ---
  Widget _buildHomeContentBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. KOTAK SELAMAT DATANG (YANG DIPERBAIKI)
          _buildWelcomeHeader(),

          const SizedBox(height: 30),

          // 2. Grid Menu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Jelajahi",
                  style: GoogleFonts.philosopher(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(Ionicons.grid_outline, color: _accentColor, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildWayangMenuGrid(),

          const SizedBox(height: 30),

          // 3. Koleksi Favorit
          _buildFavoriteSection(),

          const SizedBox(height: 25),

          // 4. Artikel
          _buildSectionHeader('Wawasan Budaya', 'Lihat Semua'),
          const SizedBox(height: 15),
          _buildArticleList(),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  // --- WIDGET HEADER BARU (KOTAK SELAMAT DATANG - DIPERBAIKI) ---
  Widget _buildWelcomeHeader() {
    final User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: user != null
          ? FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots()
          : null,
      builder: (context, snapshot) {
        String displayName = "Sobat Wayang";
        String? photoBase64;
        String? photoUrl = user?.photoURL;

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          displayName = data['name'] ?? user?.displayName ?? "Sobat Wayang";
          photoBase64 = data['photoBase64'];
        }

        ImageProvider imageProvider;
        if (photoBase64 != null && photoBase64.isNotEmpty) {
          try {
            imageProvider = MemoryImage(base64Decode(photoBase64));
          } catch (e) {
            imageProvider = const NetworkImage(
              'https://i.pravatar.cc/150?img=32',
            );
          }
        } else {
          imageProvider = photoUrl != null
              ? NetworkImage(photoUrl)
              : const NetworkImage('https://i.pravatar.cc/150?img=32');
        }

        // Menggunakan Container dengan ClipRRect untuk memotong bentuk abstrak yang keluar
        return Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
            left: 24,
            right: 24,
          ),
          // ClipRRect memastikan hiasan tidak keluar dari kotak
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // LAYER 1: Background Gradient Dasar
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        // Gradien coklat yang lebih kaya
                        colors: [_primaryColor, const Color(0xFF4E342E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                // LAYER 2: Hiasan Abstrak Emas (Pojok Kanan Atas)
                Positioned(
                  top: -40,
                  right: -40,
                  child: Transform.rotate(
                    angle: -0.2, // Sedikit miring
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        // Warna emas transparan
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ),

                // LAYER 3: Hiasan Abstrak Gelap (Pojok Kiri Bawah)
                Positioned(
                  bottom: -30,
                  left: -20,
                  child: Transform.rotate(
                    angle: 0.3, // Miring berlawanan
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        // Warna gelap transparan untuk kedalaman
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),

                // LAYER 4: Konten Utama (Teks & Foto)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge kecil
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _accentColor.withOpacity(0.4),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                "GATRAKARSA APP",
                                style: GoogleFonts.mulish(
                                  color: _accentColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Sugeng Rawuh,',
                              style: GoogleFonts.philosopher(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.85),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayName,
                              style: GoogleFonts.philosopher(
                                // Menggunakan font philosopher agar lebih mewah
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Foto Profil dengan Border Emas
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _accentColor,
                              _accentColor.withOpacity(0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: _primaryColor,
                          backgroundImage: imageProvider,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ... SISA KODE (Grid Menu, Favorite, Artikel, dll) SAMA SEPERTI SEBELUMNYA ...
  Widget _buildWayangMenuGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.map((cat) {
          return GestureDetector(
            onTap: () {
              final label = cat['label'];
              if (label == 'Tokoh') {
                Get.to(() => const TokohView());
              } else if (label == 'Kisah') {
                Get.to(() => const KisahView());
              } else if (label == 'Museum') {
                Get.to(() => const MuseumView());
              } else if (label == 'Event') {
                Get.to(() => const EventView());
              } else if (label == 'Kuis') {
                Get.to(() => const QuizView());
              } else {
                Get.snackbar(
                  "Info",
                  "Segera Hadir",
                  backgroundColor: _primaryColor,
                  colorText: Colors.white,
                );
              }
            },
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Color(cat['color']).withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    cat['icon'],
                    color: Color(cat['color']),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  cat['label'],
                  style: GoogleFonts.mulish(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _secondaryColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFavoriteSection() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('saved_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }
        var docs = snapshot.data!.docs;
        int count = docs.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Koleksi Pribadi",
                style: GoogleFonts.philosopher(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- KOTAK STATISTIK BESAR ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _primaryColor.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Ionicons.heart, color: _primaryColor, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "Total Disukai",
                            style: GoogleFonts.mulish(
                              color: _secondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$count Item",
                        style: GoogleFonts.philosopher(
                          color: _primaryColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tersimpan di akun Anda",
                        style: GoogleFonts.mulish(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Ionicons.heart,
                        color: _primaryColor,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- LIST HORIZONTAL ---
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 24, right: 10),
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  ContentModel item = ContentModel(
                    id: data['id'] ?? '',
                    title: data['title'] ?? '',
                    subtitle: data['subtitle'] ?? '',
                    category: data['category'] ?? '',
                    description: data['description'] ?? '',
                    imageUrl: data['image_url'] ?? '',
                  );
                  Uint8List? imageBytes = _decodeImage(item.imageUrl);

                  return GestureDetector(
                    onTap: () =>
                        Get.to(() => const DetailWayangView(), arguments: item),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 16, bottom: 10),
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _softShadow,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: imageBytes != null
                                  ? Image.memory(imageBytes, fit: BoxFit.cover)
                                  : (item.imageUrl.startsWith('http')
                                        ? Image.network(
                                            item.imageUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/wayang purwa.png',
                                            fit: BoxFit.cover,
                                          )),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.category.toUpperCase(),
                                    style: GoogleFonts.mulish(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: _accentColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.philosopher(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryColor,
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
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArticleList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _softShadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        article['image'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Ionicons.bookmark_outline,
                                size: 12,
                                color: _accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                article['tag'],
                                style: GoogleFonts.mulish(
                                  fontSize: 11,
                                  color: _accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                article['date'],
                                style: GoogleFonts.mulish(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article['title'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.philosopher(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.philosopher(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          if (action.isNotEmpty)
            GestureDetector(
              onTap: () {},
              child: Text(
                action,
                style: GoogleFonts.mulish(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _accentColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlowFAB() {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _primaryColor,
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Ionicons.scan_outline, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _buildModernBottomNav(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10.0,
          color: Colors.white.withOpacity(0.9),
          elevation: 0,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavItem(
                      Ionicons.home_outline,
                      Ionicons.home,
                      0,
                      "Beranda",
                    ),
                    const SizedBox(width: 15),
                    _buildNavItem(
                      Ionicons.play_circle_outline,
                      Ionicons.play_circle,
                      1,
                      "Video",
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavItem(
                      Ionicons.trophy_outline,
                      Ionicons.trophy,
                      3,
                      "Peringkat",
                    ),
                    const SizedBox(width: 15),
                    _buildNavItem(
                      Ionicons.person_outline,
                      Ionicons.person,
                      4,
                      "Profil",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData inactiveIcon,
    IconData activeIcon,
    int index,
    String label,
  ) {
    final bool isSelected = _selectedIndex == index;
    return MaterialButton(
      minWidth: 60,
      onPressed: () => _onItemTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isSelected ? 8 : 0),
            decoration: isSelected
                ? BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  )
                : const BoxDecoration(),
            child: Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? _primaryColor : Colors.grey[400],
              size: 22,
            ),
          ),
          if (!isSelected) ...[
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.mulish(fontSize: 9, color: Colors.grey[400]),
            ),
          ],
        ],
      ),
    );
  }
}
