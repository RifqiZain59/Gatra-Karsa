import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/modules/detailmuseum/views/detailmuseum_view.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class MuseumView extends StatefulWidget {
  const MuseumView({super.key});

  @override
  State<MuseumView> createState() => _MuseumViewState();
}

class _MuseumViewState extends State<MuseumView> {
  // --- PALET WARNA ---
  final Color _primaryColor = const Color(0xFF4E342E); // Coklat Tua
  final Color _accentColor = const Color(0xFFD4AF37); // Emas
  final Color _bgColor = const Color(0xFFFAFAF5); // Krem
  final Color _secondaryColor = const Color(0xFF8D6E63); // Coklat Susu

  // --- STATE VARIABLES ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // State untuk Tab Filter Baru
  int _activeTabIndex = 0;
  final List<String> _categories = [
    'Semua',
    'Yogyakarta',
    'Jawa Tengah',
    'Jakarta',
    'Jawa Barat',
  ];
  String _selectedCategory = "Semua";

  // --- DATA DUMMY MUSEUM ---
  final List<Map<String, dynamic>> museums = [
    {
      'name': 'Museum Wayang Kekayon',
      'location': 'Bantul, Yogyakarta',
      'image': 'assets/banner1.jpg',
      'openHours': '08.00 - 14.00 WIB',
      'price': 'Rp 20.000',
      'rating': 4.7,
      'distance': '2.5 km',
    },
    {
      'name': 'Museum Sonobudoyo',
      'location': 'Kota Yogyakarta',
      'image': 'assets/banner2.jpg',
      'openHours': '08.00 - 15.30 WIB',
      'price': 'Rp 10.000',
      'rating': 4.8,
      'distance': '5.0 km',
    },
    {
      'name': 'Museum Wayang Jakarta',
      'location': 'Kota Tua, Jakarta',
      'image': 'assets/banner1.jpg',
      'openHours': '09.00 - 15.00 WIB',
      'price': 'Rp 5.000',
      'rating': 4.6,
      'distance': '120 km',
    },
    {
      'name': 'Museum Radya Pustaka',
      'location': 'Surakarta, Jawa Tengah',
      'image': 'assets/banner2.jpg',
      'openHours': '09.00 - 15.00 WIB',
      'price': 'Rp 10.000',
      'rating': 4.5,
      'distance': '60 km',
    },
    {
      'name': 'Museum Sri Baduga',
      'location': 'Bandung, Jawa Barat',
      'image': 'assets/banner1.jpg',
      'openHours': '08.00 - 16.00 WIB',
      'price': 'Rp 15.000',
      'rating': 4.4,
      'distance': '150 km',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA FILTER ---
  List<Map<String, dynamic>> get _filteredMuseums {
    return museums.where((museum) {
      // 1. Filter Search (Nama Museum)
      bool matchesSearch = museum['name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      // 2. Filter Kategori (Berdasarkan Lokasi)
      bool matchesCategory = true;
      if (_selectedCategory != "Semua") {
        matchesCategory = museum['location'].toString().contains(
          _selectedCategory,
        );
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 15),

          // --- TAB FILTER BARU ---
          _buildCategoryTabs(),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(
              "Destinasi Terpopuler",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
                fontFamily: 'Serif', // Font disamakan
              ),
            ),
          ),

          // --- LIST MUSEUM ---
          Expanded(
            child: _filteredMuseums.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredMuseums.length,
                    itemBuilder: (context, index) {
                      return _buildMuseumCard(_filteredMuseums[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _bgColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Ionicons.arrow_back, color: _primaryColor),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Jelajah Museum',
        style: TextStyle(
          color: _primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          fontFamily: 'Serif', // Font disamakan
        ),
      ),
      actions: [],
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
            icon: Icon(Ionicons.search_outline, color: _secondaryColor),
            hintText: 'Cari museum wayang...',
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
    );
  }

  // --- WIDGET TAB KATEGORI BARU ---
  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_categories.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 30), // Jarak antar tab
            child: _buildTabItem(_categories[index], index),
          );
        }),
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    bool isActive = _activeTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTabIndex = index;
          _selectedCategory = label;
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
          // Indikator Garis Bawah Animasi
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            width: isActive ? 25 : 0, // Lebar garis saat aktif
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
          Icon(Ionicons.map, size: 60, color: _secondaryColor.withOpacity(0.3)),
          const SizedBox(height: 10),
          Text(
            "Museum tidak ditemukan",
            style: TextStyle(
              color: _secondaryColor.withOpacity(0.5),
              fontFamily: 'Serif', // Font disamakan
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuseumCard(Map<String, dynamic> museum) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E342E).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // NAVIGASI KE DetailMuseumView
            Get.to(() => const DetailmuseumView(), arguments: museum);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.asset(
                      museum['image'],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: _secondaryColor.withOpacity(0.2),
                          child: Icon(
                            Ionicons.image_outline,
                            size: 50,
                            color: _secondaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Ionicons.star,
                            color: Colors.orange,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            museum['rating'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                              fontFamily: 'Serif', // Font disamakan
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Info Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            museum['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                              fontFamily: 'Serif', // Font disamakan
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Location Row
                    Row(
                      children: [
                        Icon(
                          Ionicons.location_outline,
                          size: 16,
                          color: _secondaryColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          museum['location'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontFamily: 'Serif', // Font disamakan
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Ionicons.navigate_circle_outline,
                          size: 16,
                          color: _accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          museum['distance'],
                          style: TextStyle(
                            color: _accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Serif', // Font disamakan
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 15),
                    // Details Row (Jam & Harga)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Ionicons.time_outline,
                              size: 16,
                              color: _primaryColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              museum['openHours'],
                              style: TextStyle(
                                fontSize: 12,
                                color: _primaryColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Serif', // Font disamakan
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            museum['price'],
                            style: TextStyle(
                              fontSize: 12,
                              color: _primaryColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Serif', // Font disamakan
                            ),
                          ),
                        ),
                      ],
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
}
