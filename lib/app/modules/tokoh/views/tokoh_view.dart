import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT SERVICE & CONTROLLERS ---
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:gatrakarsa/app/modules/tokoh/controllers/tokoh_controller.dart';

// --- IMPORT MODUL DETAIL ---
import 'package:gatrakarsa/app/modules/detail_wayang/views/detail_wayang_view.dart';
import 'package:gatrakarsa/app/modules/detail_wayang/bindings/detail_wayang_binding.dart';
import 'package:gatrakarsa/app/modules/detaildalang/views/detaildalang_view.dart';
import 'package:gatrakarsa/app/modules/detaildalang/controllers/detaildalang_controller.dart';

class TokohView extends StatefulWidget {
  const TokohView({super.key});

  @override
  State<TokohView> createState() => _TokohViewState();
}

class _TokohViewState extends State<TokohView> {
  final TokohController controller = Get.put(TokohController());

  // --- PALET WARNA PREMIUM ---
  final Color _primaryColor = const Color(0xFF3E2723); // Coklat Tua
  final Color _accentColor = const Color(0xFFD4AF37); // Emas
  final Color _bgColor = const Color(0xFFFDFCF8); // Putih Tulang
  final Color _secondaryColor = const Color(0xFF5D4037);

  int _activeTab = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "Semua";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper Decode Image
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

  List<String> get _dynamicFilters {
    List<ContentModel> source = _activeTab == 0
        ? controller.wayangList
        : controller.dalangList;
    Set<String> uniqueCategories = source
        .map((e) => e.category.trim())
        .where((cat) => cat.isNotEmpty)
        .toSet();
    List<String> sortedCats = uniqueCategories.toList()..sort();
    return ['Semua', ...sortedCats];
  }

  List<ContentModel> get _filteredData {
    List<ContentModel> source = _activeTab == 0
        ? controller.wayangList
        : controller.dalangList;
    return source.where((item) {
      bool matchesSearch = item.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesCategory = true;
      if (_selectedCategory != "Semua") {
        matchesCategory = item.category.trim() == _selectedCategory.trim();
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
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentColor.withOpacity(0.15),
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

          // --- MAIN CONTENT ---
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
                      bool isLoading = _activeTab == 0
                          ? controller.isLoadingWayang.value
                          : controller.isLoadingDalang.value;

                      if (isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: _primaryColor,
                          ),
                        );
                      }

                      final dataToShow = _filteredData;

                      if (dataToShow.isEmpty) return _buildEmptyState();

                      return _buildContentGrid(dataToShow);
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
        children: [
          // Navigasi & Judul
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
                Text(
                  'Ensiklopedia',
                  style: GoogleFonts.philosopher(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // --- TAB SWITCHER (Kapsul) ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(child: _buildCapsuleTab("Wayang", 0)),
                Expanded(child: _buildCapsuleTab("Dalang", 1)),
              ],
            ),
          ),

          const SizedBox(height: 20),

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
                  hintText: _activeTab == 0
                      ? 'Cari tokoh wayang...'
                      : 'Cari tokoh dalang...',
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
          const SizedBox(height: 15),

          // Filter Tabs
          _buildFilterTabs(),
        ],
      ),
    );
  }

  Widget _buildCapsuleTab(String label, int index) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() {
        _activeTab = index;
        _searchQuery = "";
        _searchController.clear();
        _selectedCategory = "Semua";
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? _primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.mulish(
              color: isActive ? _accentColor : Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() {
        final filters = _dynamicFilters;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: filters
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildFilterChip(category),
                  ),
                )
                .toList(),
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _accentColor : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.mulish(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
              Ionicons.search,
              size: 50,
              color: _secondaryColor.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Data tidak ditemukan",
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

  Widget _buildContentGrid(List<ContentModel> data) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) => _activeTab == 0
          ? _buildWayangCard(data[index])
          : _buildDalangCard(data[index]),
    );
  }

  // --- KARTU WAYANG ---
  Widget _buildWayangCard(ContentModel item) {
    Uint8List? imageBytes = _decodeImage(item.imageUrl);
    return GestureDetector(
      onTap: () => Get.to(
        () => const DetailWayangView(),
        arguments: item,
        binding: DetailWayangBinding(),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3E2723).withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        colors: [Colors.white, Color(0xFFFFF8E1)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: imageBytes != null
                          ? Image.memory(
                              imageBytes,
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            )
                          : Center(
                              child: Icon(
                                Ionicons.person,
                                size: 40,
                                color: _secondaryColor.withOpacity(0.3),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        item.category.toUpperCase(),
                        style: GoogleFonts.mulish(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: _accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
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
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.philosopher(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.mulish(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        Obx(() {
                          bool isLiked = controller.favoriteIds.contains(
                            item.id,
                          );
                          return Icon(
                            isLiked ? Ionicons.heart : Ionicons.heart_outline,
                            size: 18,
                            color: isLiked ? Colors.red : Colors.grey[400],
                          );
                        }),
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

  // --- KARTU DALANG ---
  Widget _buildDalangCard(ContentModel item) {
    Uint8List? imageBytes = _decodeImage(item.imageUrl);
    return GestureDetector(
      onTap: () => Get.to(
        () => const DetaildalangView(),
        arguments: item,
        binding: BindingsBuilder(() {
          Get.put(DetaildalangController());
        }),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                gradient: LinearGradient(
                  colors: [_accentColor, _accentColor.withOpacity(0.4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _bgColor,
                backgroundImage: imageBytes != null
                    ? MemoryImage(imageBytes)
                    : null,
                child: imageBytes == null
                    ? Icon(
                        Ionicons.mic,
                        size: 30,
                        color: _secondaryColor.withOpacity(0.5),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.philosopher(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // --- PERUBAHAN DI SINI: MENGGUNAKAN KATEGORI ---
            Text(
              item.category.isNotEmpty ? item.category : "Dalang Profesional",
              style: GoogleFonts.mulish(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
            // ----------------------------------------------
            const SizedBox(height: 8),
            if (item.location != null && item.location!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Ionicons.location_outline,
                      size: 10,
                      color: _secondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        item.location!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.mulish(
                          fontSize: 10,
                          color: _secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
