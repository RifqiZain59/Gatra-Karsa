import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final Color _primaryColor = const Color(0xFF3E2723); // Coklat Tua
  final Color _accentColor = const Color(0xFFD4AF37); // Emas
  final Color _bgColor = const Color(0xFFFDFCF8); // Putih Tulang
  final Color _secondaryColor = const Color(0xFF5D4037);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "Semua";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA FILTER ---
  List<ContentModel> get _currentDataList {
    List<ContentModel> source = controller.kisahList;
    return source.where((story) {
      bool matchesSearch = story.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesCategory = true;
      if (_selectedCategory != "Semua") {
        matchesCategory =
            story.category.toLowerCase().trim() ==
            _selectedCategory.toLowerCase().trim();
      }
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // --- BACKGROUND DECORATION ---
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentColor.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryColor.withOpacity(0.05),
              ),
            ),
          ),

          // --- CONTENT ---
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeaderSection(),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: _primaryColor,
                          ),
                        );
                      }

                      final filteredData = _currentDataList;

                      if (controller.kisahList.isEmpty ||
                          filteredData.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) =>
                            _buildStoryCard(filteredData[index]),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigasi & Judul (PERBAIKAN: Menggunakan Expanded agar tidak overflow)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Ionicons.arrow_back,
                      color: _primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Pustaka Kisah',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.philosopher(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                // Spacer dummy agar judul di tengah (ukuran sama dengan tombol back)
                const SizedBox(width: 36),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.mulish(color: _primaryColor),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Ionicons.search_outline,
                    color: _secondaryColor.withOpacity(0.5),
                  ),
                  hintText: 'Cari legenda atau mitos...',
                  hintStyle: GoogleFonts.mulish(
                    color: Colors.grey[400],
                    fontSize: 14,
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

          const SizedBox(height: 20),

          // Filter Chips
          _buildDynamicFilterTabs(),
        ],
      ),
    );
  }

  Widget _buildDynamicFilterTabs() {
    return Obx(() {
      Set<String> uniqueCategories = controller.kisahList
          .map((e) => e.category.trim())
          .where((cat) => cat.isNotEmpty)
          .toSet();
      List<String> dynamicCategories = ['Semua', ...uniqueCategories.toList()];
      if (dynamicCategories.length > 1) dynamicCategories.sublist(1).sort();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: dynamicCategories
              .map(
                (categoryName) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildFilterChip(categoryName),
                ),
              )
              .toList(),
        ),
      );
    });
  }

  Widget _buildFilterChip(String label) {
    bool isActive = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _accentColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? _accentColor : Colors.grey.withOpacity(0.2),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _accentColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.mulish(
            color: isActive ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
            ),
            child: Icon(
              Ionicons.book_outline,
              size: 50,
              color: _secondaryColor.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Kisah tidak ditemukan",
            style: GoogleFonts.mulish(
              color: _secondaryColor.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD KISAH ---
  Widget _buildStoryCard(ContentModel story) {
    String duration = story.subtitle.isNotEmpty
        ? story.subtitle
        : "5 Menit Baca";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E2723).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.to(() => const DetailkisahView(), arguments: story),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Header
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: Stack(
                    children: [
                      Positioned.fill(child: _buildImage(story.imageUrl)),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            story.category.toUpperCase(),
                            style: GoogleFonts.mulish(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Info Konten
              Padding(
                // PERBAIKAN: Padding dikurangi sedikit agar konten lebih muat
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.philosopher(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      story.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.mulish(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // PERBAIKAN UTAMA: Menggunakan Flexible untuk teks agar tidak overflow
                    Row(
                      children: [
                        Icon(
                          Ionicons.time_outline,
                          size: 14,
                          color: _accentColor,
                        ),
                        const SizedBox(width: 6),
                        // Gunakan Flexible pada teks durasi
                        Flexible(
                          child: Text(
                            duration,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.mulish(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(), // Spacer aman di sini karena Flexible
                        Text(
                          "BACA SEKARANG",
                          style: GoogleFonts.mulish(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _accentColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Ionicons.arrow_forward,
                          size: 14,
                          color: _accentColor,
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

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(color: _secondaryColor.withOpacity(0.2));
    }
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
        String cleanBase64 = imageUrl.replaceAll(RegExp(r'\s+'), '');
        if (cleanBase64.contains(',')) {
          cleanBase64 = cleanBase64.split(',').last;
        }
        int mod4 = cleanBase64.length % 4;
        if (mod4 > 0) cleanBase64 += '=' * (4 - mod4);
        return Image.memory(
          base64Decode(cleanBase64),
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
