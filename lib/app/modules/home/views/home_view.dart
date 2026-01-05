import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

// --- IMPORT HALAMAN-HALAMAN ---
import 'package:gatrakarsa/app/modules/detail_wayang/views/detail_wayang_view.dart';
import '../../deteksi/views/deteksi_view.dart';
import '../../profile/views/profile_view.dart';
import '../../video/views/video_view.dart';
import '../../leaderboard/views/leaderboard_view.dart';
import '../../quiz/views/quiz_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // --- PALET WARNA WAYANG ---
  final Color _primaryColor = const Color(0xFF4E342E); // Coklat Tua
  final Color _accentColor = const Color(0xFFD4AF37); // Emas
  final Color _bgColor = const Color(0xFFFAFAF5); // Krem
  final Color _secondaryColor = const Color(0xFF8D6E63); // Coklat Susu

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> banners = [
    'assets/banner1.jpg',
    'assets/banner1.jpg',
    'assets/banner1.jpg',
  ];

  // --- KATEGORI MENU ---
  final List<Map<String, dynamic>> categories = [
    {
      'icon': Ionicons.people,
      'label': 'Tokoh',
      'color': 0xFF5D4037, // Coklat Kopi
    },
    {
      'icon': Ionicons.book,
      'label': 'Kisah',
      'color': 0xFF795548, // Coklat Tanah
    },
    {
      'icon': Ionicons.map,
      'label': 'Museum',
      'color': 0xFF8D6E63, // Coklat Bata
    },
    {
      'icon': Ionicons.calendar,
      'label': 'Event',
      'color': 0xFFA1887F, // Coklat Abu
    },
    // MENU BARU: KUIS (Warna disesuaikan agar senada)
    {
      'icon': Ionicons.game_controller,
      'label': 'Kuis',
      'color': 0xFF6D4C41, // Coklat Kayu (Disamakan dengan tema)
    },
  ];

  final List<Map<String, dynamic>> popularCharacters = [
    {
      'title': 'Arjuna',
      'imagePath': 'assets/wayang purwa.png',
      'role': 'Pandawa',
      'desc': 'Ksatria penengah Pandawa yang tampan dan lemah lembut.',
    },
    {
      'title': 'Bima',
      'imagePath': 'assets/Wayang Madya.png',
      'role': 'Pandawa',
      'desc': 'Sosok yang gagah berani, jujur, dan taat pada guru.',
    },
    {
      'title': 'Gatotkaca',
      'imagePath': 'assets/Wayang Kulit.png',
      'role': 'Pringgondani',
      'desc': 'Ksatria berotot kawat tulang besi, bisa terbang.',
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

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bgColor,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContentBody(), // 0
            const VideoView(), // 1
            const DeteksiView(), // 2
            const LeaderboardView(), // 3 (Klasemen)
            const ProfileView(), // 4
          ],
        ),
        bottomNavigationBar: _buildBottomAppBar(context),
        floatingActionButton: _buildScanFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHomeContentBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomHeader(),
          const SizedBox(height: 20),
          _buildBannerSection(),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Jelajahi Dunia Wayang",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 15),
          // MENU GRID
          _buildWayangMenuGrid(),
          const SizedBox(height: 30),
          _buildSectionHeader('Tokoh Populer', 'Lihat Semua'),
          const SizedBox(height: 15),
          _buildCharacterList(),
          const SizedBox(height: 30),
          _buildSectionHeader('Wawasan Budaya', ''),
          const SizedBox(height: 15),
          _buildArticleList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        left: 24,
        right: 24,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E342E).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _accentColor, width: 2),
            ),
            child: const CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sugeng Rawuh,',
                style: TextStyle(fontSize: 12, color: _secondaryColor),
              ),
              Text(
                'Marina',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _buildHeaderIcon(Ionicons.time_outline, () {}),
              const SizedBox(width: 10),
              _buildHeaderIcon(Ionicons.notifications_outline, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: _secondaryColor.withOpacity(0.2)),
        ),
        child: Icon(icon, color: _primaryColor, size: 22),
      ),
    );
  }

  Widget _buildBannerSection() {
    return SizedBox(
      height: 170,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(banners[index], fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [
                              _primaryColor.withOpacity(0.9),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 25,
                        left: 15,
                        right: 15,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _accentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Highlight Minggu Ini",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Misteri Semar & \nFilosofi Punakawan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: _currentPage == index ? 24 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? _accentColor
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MENU GRID DENGAN WRAP (Warna sudah disamakan) ---
  Widget _buildWayangMenuGrid() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 20,
        spacing: 12,
        children: categories.map((cat) {
          return SizedBox(
            width: 70,
            child: GestureDetector(
              onTap: () {
                if (cat['label'] == 'Kuis') {
                  Get.to(() => const QuizView());
                } else {
                  Get.snackbar(
                    "Info",
                    "Menu ${cat['label']} diklik",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: _primaryColor,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 1),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(cat['color']).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      cat['icon'],
                      color: Color(cat['color']),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['label'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          if (action.isNotEmpty)
            Text(
              action,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _secondaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCharacterList() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24, right: 10),
        physics: const BouncingScrollPhysics(),
        itemCount: popularCharacters.length,
        itemBuilder: (context, index) {
          final item = popularCharacters[index];
          return GestureDetector(
            onTap: () =>
                Get.to(() => const DetailWayangView(), arguments: item),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        image: DecorationImage(
                          image: AssetImage(item['imagePath']),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['role'],
                          style: TextStyle(
                            color: _accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['title'],
                              style: TextStyle(
                                color: _primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Ionicons.heart_outline,
                              size: 20,
                              color: _secondaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  article['image'],
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        article['tag'],
                        style: TextStyle(
                          fontSize: 10,
                          color: _secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article['date'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- NAVIGATION BAR & FAB ---

  Widget _buildScanFAB() {
    return SizedBox(
      width: 65,
      height: 65,
      child: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: _primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Ionicons.scan_outline, size: 28, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      elevation: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildNavItem(Ionicons.home_outline, Ionicons.home, 0, "Home"),
                _buildNavItem(
                  Ionicons.play_circle_outline,
                  Ionicons.play_circle,
                  1,
                  "Video",
                ),
              ],
            ),
            Row(
              children: [
                _buildNavItem(
                  Ionicons.trophy_outline,
                  Ionicons.trophy,
                  3,
                  "Klasemen",
                ),
                _buildNavItem(
                  Ionicons.person_outline,
                  Ionicons.person,
                  4,
                  "Profile",
                ),
              ],
            ),
          ],
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
      minWidth: 70,
      onPressed: () => _onItemTapped(index),
      splashColor: _accentColor.withOpacity(0.2),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: isSelected ? _primaryColor : Colors.grey[400],
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? _primaryColor : Colors.grey[400],
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
