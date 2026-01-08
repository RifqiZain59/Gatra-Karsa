import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/modules/detailkisah/views/detailkisah_view.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class KisahView extends StatefulWidget {
  const KisahView({super.key});

  @override
  State<KisahView> createState() => _KisahViewState();
}

class _KisahViewState extends State<KisahView> {
  // --- PALET WARNA ---
  final Color _primaryColor = const Color(0xFF4E342E); // Coklat Tua
  final Color _accentColor = const Color(0xFFD4AF37); // Emas
  final Color _bgColor = const Color(0xFFFAFAF5); // Krem
  final Color _secondaryColor = const Color(0xFF8D6E63); // Coklat Susu

  // --- CONTROLLER & STATE ---
  int _activeTab = 0; // 0: Jelajah, 1: Koleksi Saya
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Custom Filter Tabs
  int _activeFilterIndex = 0;
  final List<String> _categories = [
    'Semua',
    'Epos',
    'Legenda',
    'Tragedi',
    'Filosofi',
    'Romansa',
  ];
  String _selectedCategory = "Semua";

  // --- DATA DUMMY KISAH ---
  List<Map<String, dynamic>> stories = [
    {
      'id': 1,
      'title': 'Mahabharata: Bharatayuddha',
      'category': 'Epos',
      'desc':
          'Puncak pertempuran besar antara Pandawa dan Kurawa di padang Kurusetra.',
      'image': 'assets/banner1.jpg',
      'duration': '15 Menit Baca',
      'rating': 4.9,
      'isSaved': false,
    },
    {
      'id': 2,
      'title': 'Ramayana: Penculikan Shinta',
      'category': 'Legenda',
      'desc':
          'Kisah dramatis Rahwana menculik Dewi Shinta dan perjuangan Rama.',
      'image': 'assets/banner2.jpg',
      'duration': '12 Menit Baca',
      'rating': 4.8,
      'isSaved': true,
    },
    {
      'id': 3,
      'title': 'Gatotkaca Gugur',
      'category': 'Tragedi',
      'desc':
          'Pengorbanan sang ksatria Pringgondani yang gugur oleh senjata Konta.',
      'image': 'assets/banner1.jpg',
      'duration': '8 Menit Baca',
      'rating': 4.7,
      'isSaved': false,
    },
    {
      'id': 4,
      'title': 'Bima Suci: Dewa Ruci',
      'category': 'Filosofi',
      'desc':
          'Perjalanan spiritual Bima mencari air kehidupan hingga bertemu Dewa Ruci.',
      'image': 'assets/banner2.jpg',
      'duration': '20 Menit Baca',
      'rating': 5.0,
      'isSaved': false,
    },
    {
      'id': 5,
      'title': 'Arjuna Wiwaha',
      'category': 'Romansa',
      'desc':
          'Kisah asmara dan pertapaan Arjuna saat diuji oleh para bidadari kayangan.',
      'image': 'assets/banner1.jpg',
      'duration': '10 Menit Baca',
      'rating': 4.6,
      'isSaved': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA FILTER ---
  List<Map<String, dynamic>> get _currentDataList {
    List<Map<String, dynamic>> source = _activeTab == 0
        ? stories // Tab 0: Semua data
        : stories.where((s) => s['isSaved'] == true).toList(); // Tab 1: Koleksi

    return source.where((story) {
      bool matchesSearch = story['title'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      bool matchesCategory = true;
      if (_activeTab == 0) {
        matchesCategory =
            _selectedCategory == "Semua" ||
            story['category'] == _selectedCategory;
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _toggleSave(int id) {
    setState(() {
      final index = stories.indexWhere((element) => element['id'] == id);
      if (index != -1) {
        bool currentStatus = stories[index]['isSaved'] == true;
        stories[index]['isSaved'] = !currentStatus;

        if (stories[index]['isSaved']) {
          Get.snackbar(
            "Disimpan",
            "Ditambahkan ke koleksi",
            backgroundColor: _primaryColor,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 1),
            margin: const EdgeInsets.all(10),
          );
        } else {
          Get.snackbar(
            "Dihapus",
            "Dihapus dari koleksi",
            backgroundColor: Colors.grey,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 1),
            margin: const EdgeInsets.all(10),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER SECTION (Custom Tabs) ---
              _buildHeaderSection(),

              // --- CONTENT SECTION ---
              Expanded(
                child: _currentDataList.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _currentDataList.length,
                        itemBuilder: (context, index) {
                          return _buildStoryCard(_currentDataList[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HEADER WIDGET ---
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: _bgColor),
      child: Column(
        children: [
          // 1. Tombol Back & Judul
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Ionicons.arrow_back, color: _primaryColor),
                ),
                Text(
                  'Pustaka Kisah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                    fontFamily: 'Serif', // Font disamakan
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 2. MAIN TAB (Jelajah vs Koleksi)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMainTabButton('Jelajah', 0),
              const SizedBox(width: 40),
              _buildMainTabButton('Koleksi Saya', 1),
            ],
          ),

          const SizedBox(height: 20),

          // 3. SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Ionicons.search_outline,
                    color: _secondaryColor.withOpacity(0.5),
                  ),
                  hintText: 'Cari judul kisah...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: 'Serif', // Font disamakan
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                          child: Icon(
                            Ionicons.close_circle,
                            color: _secondaryColor.withOpacity(0.5),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),

          // 4. FILTER TABS (Hanya muncul di Tab Jelajah)
          if (_activeTab == 0) ...[
            const SizedBox(height: 15),
            _buildFilterTabs(),
          ],
        ],
      ),
    );
  }

  // --- WIDGET LOGIKA TAB UTAMA ---
  Widget _buildMainTabButton(String label, int index) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
          _searchQuery = "";
          _searchController.clear();
          if (index == 0) _selectedCategory = "Semua";
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? _primaryColor : Colors.grey,
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Serif', // Font disamakan
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            width: isActive ? 30 : 0,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET LOGIKA TAB FILTER ---
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_categories.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 30),
            child: _buildFilterTabItem(_categories[index], index),
          );
        }),
      ),
    );
  }

  Widget _buildFilterTabItem(String label, int index) {
    bool isActive = _activeFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilterIndex = index;
          _selectedCategory = label;
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? _primaryColor : Colors.grey,
              fontSize: 14, // Lebih kecil dari Main Tab
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Serif', // Font disamakan
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2, // Lebih tipis dari Main Tab
            width: isActive ? 20 : 0,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _activeTab == 0 ? Ionicons.search : Ionicons.bookmark_outline,
            size: 60,
            color: _secondaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          Text(
            _activeTab == 0 ? "Kisah tidak ditemukan" : "Belum ada koleksi",
            style: TextStyle(
              color: _secondaryColor.withOpacity(0.5),
              fontFamily: 'Serif', // Font disamakan
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(Map<String, dynamic> story) {
    bool isSaved = story['isSaved'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E342E).withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(() => const DetailkisahView(), arguments: story);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.asset(
                  story['image'],
                  width: 110,
                  height: 145,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 110,
                    height: 145,
                    color: _secondaryColor.withOpacity(0.2),
                    child: Icon(
                      Ionicons.book_outline,
                      size: 40,
                      color: _secondaryColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              story['category'].toUpperCase(),
                              style: TextStyle(
                                color: _primaryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontFamily: 'Serif', // Font disamakan
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Ionicons.star,
                                size: 12,
                                color: _accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                story['rating'].toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                  fontFamily: 'Serif', // Font disamakan
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _toggleSave(story['id']),
                                child: Icon(
                                  isSaved
                                      ? Ionicons.bookmark
                                      : Ionicons.bookmark_outline,
                                  size: 18,
                                  color: isSaved
                                      ? _accentColor
                                      : _secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        story['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                          height: 1.2,
                          fontFamily: 'Serif', // Font disamakan
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        story['desc'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          height: 1.4,
                          fontFamily: 'Serif', // Font disamakan
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Ionicons.time_outline,
                            size: 12,
                            color: _secondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            story['duration'],
                            style: TextStyle(
                              fontSize: 10,
                              color: _secondaryColor,
                              fontFamily: 'Serif', // Font disamakan
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "BACA",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                              fontFamily: 'Serif', // Font disamakan
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Ionicons.arrow_forward_circle,
                            size: 16,
                            color: _primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
