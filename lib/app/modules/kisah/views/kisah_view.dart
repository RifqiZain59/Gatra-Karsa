import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import '../controllers/kisah_controller.dart';
import 'package:gatrakarsa/app/modules/detailkisah/views/detailkisah_view.dart';

class KisahView extends StatefulWidget {
  const KisahView({super.key});

  @override
  State<KisahView> createState() => _KisahViewState();
}

class _KisahViewState extends State<KisahView> {
  final KisahController controller = Get.put(KisahController());

  // --- PALET WARNA ---
  final Color _primaryColor = const Color(0xFF4E342E);
  final Color _accentColor = const Color(0xFFD4AF37);
  final Color _bgColor = const Color(0xFFFAFAF5);
  final Color _secondaryColor = const Color(0xFF8D6E63);

  // --- LOCAL STATE ---
  int _activeTab = 0; // 0: Jelajah, 1: Koleksi Saya
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "Semua";

  // Set ID lokal untuk fitur bookmark sementara
  final Set<String> _savedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA FILTER DATA ---
  List<ContentModel> get _currentDataList {
    List<ContentModel> source = controller.kisahList;

    // Filter jika Tab Koleksi aktif
    if (_activeTab == 1) {
      source = source.where((item) => _savedIds.contains(item.id)).toList();
    }

    return source.where((story) {
      bool matchesSearch = story.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesCategory = true;

      // Filter kategori hanya aktif di mode Jelajah (Tab 0)
      if (_activeTab == 0 && _selectedCategory != "Semua") {
        matchesCategory =
            story.category.toLowerCase().trim() ==
            _selectedCategory.toLowerCase().trim();
      }
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _toggleSave(String id) {
    setState(() {
      if (_savedIds.contains(id)) {
        _savedIds.remove(id);
        Get.snackbar(
          "Dihapus",
          "Dihapus dari koleksi",
          backgroundColor: Colors.grey,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 1),
        );
      } else {
        _savedIds.add(id);
        Get.snackbar(
          "Disimpan",
          "Ditambahkan ke koleksi",
          backgroundColor: _primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 1),
        );
      }
    });
  }

  // Fungsi ganti mode (Jelajah <-> Koleksi)
  void _toggleTabMode() {
    setState(() {
      _activeTab = _activeTab == 0 ? 1 : 0;
      // Reset search/filter saat ganti mode agar UX lebih baik
      _searchQuery = "";
      _searchController.clear();
      _selectedCategory = "Semua";
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
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER (Search + Filter + Koleksi Toggle)
              _buildHeaderSection(),

              // CONTENT
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: _primaryColor),
                    );
                  }
                  if (controller.kisahList.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada data kisah.",
                        style: TextStyle(
                          fontFamily: 'Serif',
                          color: _secondaryColor,
                        ),
                      ),
                    );
                  }

                  final filteredData = _currentDataList;

                  if (filteredData.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      return _buildStoryCard(filteredData[index]);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HEADER SECTION (UPDATED) ---
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: _bgColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Nav (Back & Title)
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
                  _activeTab == 0
                      ? 'Pustaka Kisah'
                      : 'Koleksi Saya', // Judul Dinamis
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. SEARCH BAR & KOLEKSI BUTTON (Digabung Sebaris)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // SEARCH BAR (Expanded)
                Expanded(
                  child: Container(
                    height: 50, // Tinggi fix agar sejajar tombol
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
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      style: const TextStyle(fontFamily: 'Serif'),
                      decoration: InputDecoration(
                        icon: Icon(
                          Ionicons.search_outline,
                          color: _secondaryColor.withOpacity(0.5),
                        ),
                        hintText: _activeTab == 0
                            ? 'Cari judul...'
                            : 'Cari koleksi...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontFamily: 'Serif',
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
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

                const SizedBox(width: 12),

                // TOMBOL KOLEKSI / BOOKMARK
                GestureDetector(
                  onTap: _toggleTabMode,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: _activeTab == 1 ? _primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: _activeTab == 1
                          ? null
                          : Border.all(color: _primaryColor.withOpacity(0.1)),
                    ),
                    child: Icon(
                      _activeTab == 1
                          ? Ionicons.bookmark
                          : Ionicons.bookmark_outline,
                      color: _activeTab == 1 ? _accentColor : _primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Dynamic Filter Tabs (Hanya muncul di Tab Jelajah/0)
          if (_activeTab == 0) ...[
            const SizedBox(height: 15),
            _buildDynamicFilterTabs(),
            const SizedBox(height: 5),
          ],
        ],
      ),
    );
  }

  // --- FILTER DINAMIS ---
  Widget _buildDynamicFilterTabs() {
    return Obx(() {
      Set<String> uniqueCategories = controller.kisahList
          .map((e) => e.category.trim())
          .where((cat) => cat.isNotEmpty)
          .toSet();

      List<String> dynamicCategories = ['Semua', ...uniqueCategories.toList()];
      if (dynamicCategories.length > 1) {
        dynamicCategories.sublist(1).sort();
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: dynamicCategories.map((categoryName) {
            return Padding(
              padding: const EdgeInsets.only(right: 30),
              child: _buildFilterTabItem(categoryName),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildFilterTabItem(String label) {
    bool isActive = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? _primaryColor : Colors.grey,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Serif',
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
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
              fontFamily: 'Serif',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(ContentModel story) {
    bool isSaved = _savedIds.contains(story.id);
    String duration = story.subtitle.isNotEmpty
        ? story.subtitle
        : "5 Menit Baca";
    String rating = "4.8";

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
                child: SizedBox(
                  width: 110,
                  height: 145,
                  child: _buildImage(story.imageUrl),
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
                              story.category.toUpperCase(),
                              style: TextStyle(
                                color: _primaryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontFamily: 'Serif',
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
                                rating,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                  fontFamily: 'Serif',
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _toggleSave(story.id),
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
                        story.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                          height: 1.2,
                          fontFamily: 'Serif',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        story.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          height: 1.4,
                          fontFamily: 'Serif',
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
                          Expanded(
                            child: Text(
                              duration,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: _secondaryColor,
                                fontFamily: 'Serif',
                              ),
                            ),
                          ),
                          Text(
                            "BACA",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                              fontFamily: 'Serif',
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

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty)
      return Container(color: _secondaryColor.withOpacity(0.2));
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) =>
              Container(color: _secondaryColor.withOpacity(0.2)),
        );
      } else if (imageUrl.startsWith('assets/')) {
        return Image.asset(imageUrl, fit: BoxFit.cover);
      } else {
        String cleanBase64 = imageUrl;
        if (cleanBase64.contains(','))
          cleanBase64 = cleanBase64.split(',').last;
        cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');
        int mod4 = cleanBase64.length % 4;
        if (mod4 > 0) cleanBase64 += '=' * (4 - mod4);
        Uint8List bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) =>
              Container(color: _secondaryColor.withOpacity(0.2)),
        );
      }
    } catch (e) {
      return Container(color: _secondaryColor.withOpacity(0.2));
    }
  }
}
