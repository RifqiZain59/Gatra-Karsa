import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/modules/daftarlike/views/daftarlike_view.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT HALAMAN LAIN ---
import 'package:gatrakarsa/app/modules/deteksi/views/deteksi_view.dart';
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
  int _currentlyPlayingIndex = -1;

  // --- PALET WARNA ---
  final Color _primaryColor = const Color(0xFF3E2723); // Coklat Tua
  final Color _secondaryColor = const Color(0xFF5D4037); // Coklat Medium
  final Color _accentColor = const Color(0xFFD4AF37); // Emas
  final Color _surfaceColor = const Color(0xFFFFFFFF);
  final Color _bgColor = const Color(0xFFFDFCF8);
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

  final List<Map<String, dynamic>> audioCollections = [
    {
      'title': 'Suling Bambu',
      'subtitle': 'Melodi Ketenangan Sunda',
      'duration': '03:45',
      'icon': Ionicons.musical_note,
    },
    {
      'title': 'Gamelan Jawa',
      'subtitle': 'Harmoni Keraton Surakarta',
      'duration': '05:12',
      'icon': Ionicons.disc,
    },
    {
      'title': 'Tembang Sinden',
      'subtitle': 'Vokal Klasik Tradisional',
      'duration': '04:20',
      'icon': Ionicons.mic,
    },
    {
      'title': 'Gender Wayang',
      'subtitle': 'Iringan Dalang Bercerita',
      'duration': '02:55',
      'icon': Ionicons.flower,
    },
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
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
            const DeteksiView(),
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

  Widget _buildHomeContentBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 30),
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

          // --- BAGIAN INI DIPERBAIKI (Kotak Lebih Bagus & Icon Like) ---
          _buildFavoriteSection(),

          const SizedBox(height: 25),
          _buildSectionHeader('Suara Tradisi', 'Putar Semua'),
          const SizedBox(height: 15),
          _buildAudioList(),
        ],
      ),
    );
  }

  // --- BAGIAN FAVORIT (Desain Baru: Gradient & Mewah) ---
  Widget _buildFavoriteSection() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
        }

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

            // KOTAK STATISTIK DIPERBAIKI (GRADIENT PREMIUM)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              // Tambahkan clip agar dekorasi lingkaran tidak keluar kotak
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                // Menggunakan Gradient agar tidak polos
                gradient: LinearGradient(
                  colors: [_primaryColor, _secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // --- Dekorasi Latar Belakang (Agar tidak polos) ---
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -40,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // --- Konten Utama ---
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Icon kecil menjadi Heart (Like)
                                Icon(
                                  Ionicons.heart,
                                  color: _accentColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Total Disukai",
                                  style: GoogleFonts.mulish(
                                    color: Colors.white.withOpacity(
                                      0.8,
                                    ), // Teks putih agar kontras
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
                                color: Colors.white, // Teks putih
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // --- TOMBOL LIHAT (Desain Gold) ---
                            GestureDetector(
                              onTap: () {
                                // Navigasi ke Halaman Daftar Save
                                Get.to(() => const DaftarlikeView());
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _accentColor, // Tombol warna Emas
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Lihat Semua",
                                      style: GoogleFonts.mulish(
                                        color: _primaryColor, // Teks Coklat Tua
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Ionicons.arrow_forward,
                                      color: _primaryColor,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Icon Besar di Kanan (Heart / Like) - Transparan
                        Icon(
                          Ionicons.heart, // Menggunakan icon Like
                          color: Colors.white.withOpacity(0.15),
                          size: 80,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // --- WIDGET HELPER LAINNYA ---

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
        return Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
            left: 24,
            right: 24,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryColor, const Color(0xFF4E342E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // Dekorasi Header
                Positioned(
                  top: -40,
                  right: -40,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -20,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
              if (label == 'Tokoh')
                Get.to(() => const TokohView());
              else if (label == 'Kisah')
                Get.to(() => const KisahView());
              else if (label == 'Museum')
                Get.to(() => const MuseumView());
              else if (label == 'Event')
                Get.to(() => const EventView());
              else if (label == 'Kuis')
                Get.to(() => const QuizView());
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

  Widget _buildAudioList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: audioCollections.length,
      itemBuilder: (context, index) {
        final audio = audioCollections[index];
        final bool isPlaying = _currentlyPlayingIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isPlaying ? _primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isPlaying ? _primaryColor.withOpacity(0.3) : _softShadow,
                blurRadius: isPlaying ? 12 : 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: isPlaying
                ? Border.all(color: _accentColor, width: 1)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  if (_currentlyPlayingIndex == index) {
                    _currentlyPlayingIndex = -1;
                  } else {
                    _currentlyPlayingIndex = index;
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? Colors.white.withOpacity(0.1)
                            : _primaryColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isPlaying ? Ionicons.pause : Ionicons.play,
                          color: isPlaying ? _accentColor : _primaryColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            audio['title'],
                            style: GoogleFonts.philosopher(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isPlaying ? Colors.white : _primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            audio['subtitle'],
                            style: GoogleFonts.mulish(
                              fontSize: 12,
                              color: isPlaying
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isPlaying)
                          MusicVisualizer(color: _accentColor)
                        else
                          Icon(
                            audio['icon'],
                            size: 18,
                            color: Colors.grey[300],
                          ),
                        const SizedBox(height: 6),
                        Text(
                          audio['duration'],
                          style: GoogleFonts.mulish(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPlaying ? _accentColor : Colors.grey[400],
                          ),
                        ),
                      ],
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
            Text(
              action,
              style: GoogleFonts.mulish(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _accentColor,
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

class MusicVisualizer extends StatefulWidget {
  final Color color;
  const MusicVisualizer({super.key, required this.color});
  @override
  State<MusicVisualizer> createState() => _MusicVisualizerState();
}

class _MusicVisualizerState extends State<MusicVisualizer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (i) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 3, end: 12),
            duration: Duration(milliseconds: 300 + (i * 100)),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                width: 3,
                height: value,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            },
            onEnd: () {
              if (mounted) setState(() {});
            },
          );
        }),
      ),
    );
  }
}
