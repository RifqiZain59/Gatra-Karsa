import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/modules/detail_wayang/views/detail_wayang_view.dart';
import 'package:gatrakarsa/app/modules/detaildalang/views/detaildalang_view.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class TokohView extends StatefulWidget {
  const TokohView({super.key});

  @override
  State<TokohView> createState() => _TokohViewState();
}

class _TokohViewState extends State<TokohView> {
  // --- PALET WARNA ---
  final Color _primaryColor = const Color(0xFF4E342E); // Coklat Tua
  final Color _accentColor = const Color(0xFFD4AF37); // Emas
  final Color _bgColor = const Color(0xFFFAFAF5); // Krem
  final Color _secondaryColor = const Color(0xFF8D6E63); // Coklat Susu

  // --- STATE VARIABLES ---
  int _activeTab = 0; // 0: Tokoh Wayang, 1: Tokoh Dalang
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "Semua";

  // --- DATA DUMMY WAYANG ---
  final List<Map<String, dynamic>> wayangList = [
    {
      'name': 'Yudhistira',
      'role': 'Pandawa',
      'trait': 'Jujur & Adil',
      'image': 'assets/wayang purwa.png',
    },
    {
      'name': 'Bima',
      'role': 'Pandawa',
      'trait': 'Gagah Berani',
      'image': 'assets/Wayang Madya.png',
    },
    {
      'name': 'Arjuna',
      'role': 'Pandawa',
      'trait': 'Lemah Lembut',
      'image': 'assets/wayang purwa.png',
    },
    {
      'name': 'Semar',
      'role': 'Punakawan',
      'trait': 'Bijaksana',
      'image': 'assets/Wayang Kulit.png',
    },
    {
      'name': 'Gatotkaca',
      'role': 'Pringgondani',
      'trait': 'Otot Kawat',
      'image': 'assets/Wayang Kulit.png',
    },
    {
      'name': 'Rahwana',
      'role': 'Kurawa',
      'trait': 'Angkara Murka',
      'image': 'assets/Wayang Madya.png',
    },
    {
      'name': 'Karna',
      'role': 'Kurawa',
      'trait': 'Dermawan',
      'image': 'assets/Wayang Madya.png',
    },
  ];

  // --- DATA DUMMY DALANG ---
  final List<Map<String, dynamic>> dalangList = [
    {
      'name': 'Ki Manteb Soedharsono',
      'title': 'Dalang Setan',
      'origin': 'Surakarta',
      'image': 'assets/Dalang.png',
    },
    {
      'name': 'Ki Anom Suroto',
      'title': 'Maestro',
      'origin': 'Surakarta',
      'image': 'assets/Dalang.png',
    },
    {
      'name': 'Ki Seno Nugroho',
      'title': 'Wayang Gaul',
      'origin': 'Yogyakarta',
      'image': 'assets/Dalang.png',
    },
    {
      'name': 'Ki Enthus Susmono',
      'title': 'Dalang Edan',
      'origin': 'Tegal',
      'image': 'assets/Dalang.png',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA FILTER DINAMIS ---
  List<String> get _currentFilters {
    if (_activeTab == 0) {
      return ['Semua', 'Pandawa', 'Kurawa', 'Punakawan', 'Pringgondani'];
    }
    return ['Semua', 'Surakarta', 'Yogyakarta', 'Tegal'];
  }

  List<Map<String, dynamic>> get _filteredData {
    List<Map<String, dynamic>> source = _activeTab == 0
        ? wayangList
        : dalangList;

    return source.where((item) {
      bool matchesSearch = item['name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      String categoryKey = _activeTab == 0 ? 'role' : 'origin';
      bool matchesCategory =
          _selectedCategory == "Semua" ||
          item[categoryKey] == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
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
              // --- HEADER SECTION ---
              _buildHeaderSection(),

              // --- CONTENT GRID ---
              Expanded(
                child: _filteredData.isEmpty
                    ? _buildEmptyState()
                    : _buildContentGrid(_filteredData),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                  'Ensiklopedia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 2. MAIN TABS (Wayang vs Dalang)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMainTabButton('Tokoh Wayang', 0),
              const SizedBox(width: 40),
              _buildMainTabButton('Tokoh Dalang', 1),
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
                  hintText: _activeTab == 0
                      ? 'Cari wayang...'
                      : 'Cari dalang...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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

          const SizedBox(height: 15),

          // 4. FILTER TABS (NEW STYLE: Text + Underline)
          _buildFilterTabs(),
        ],
      ),
    );
  }

  // --- WIDGET TOMBOL TAB UTAMA ---
  Widget _buildMainTabButton(String label, int index) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
          _searchQuery = "";
          _searchController.clear();
          _selectedCategory = "Semua"; // Reset filter
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

  // --- WIDGET FILTER TABS (Pengganti Chips) ---
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        // Generate list berdasarkan filter aktif (Wayang/Dalang)
        children: List.generate(_currentFilters.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 30), // Jarak antar item
            child: _buildFilterTabItem(_currentFilters[index]),
          );
        }),
      ),
    );
  }

  Widget _buildFilterTabItem(String label) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? _primaryColor : Colors.grey,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          // Garis Bawah Filter
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            width: isSelected ? 20 : 0,
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
            Ionicons.search,
            size: 60,
            color: _secondaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          Text(
            "Data tidak ditemukan",
            style: TextStyle(color: _secondaryColor.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  // --- GRID BUILDER ---
  Widget _buildContentGrid(List<Map<String, dynamic>> data) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) => _activeTab == 0
          ? _buildWayangCard(data[index])
          : _buildDalangCard(data[index]),
    );
  }

  // --- CARD: TOKOH WAYANG ---
  Widget _buildWayangCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const DetailWayangView(), arguments: item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.08),
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
              child: Container(
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                child: Image.asset(
                  item['image'],
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) =>
                      Icon(Ionicons.person, size: 40, color: _secondaryColor),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['role'].toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['trait'],
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Ionicons.heart_outline,
                          size: 16,
                          color: _secondaryColor,
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
    );
  }

  // --- CARD: TOKOH DALANG ---
  Widget _buildDalangCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const DetaildalangView(), arguments: item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _secondaryColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _accentColor, width: 2),
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: _bgColor,
                backgroundImage: AssetImage(item['image']),
                child: Image.asset(
                  item['image'],
                  errorBuilder: (c, e, s) => Icon(
                    Ionicons.mic_outline,
                    size: 25,
                    color: _secondaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item['name'],
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item['title'],
              style: TextStyle(
                fontSize: 10,
                color: _accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['origin'],
                style: TextStyle(fontSize: 9, color: _secondaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
