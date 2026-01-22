import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui'; // Diperlukan untuk dekorasi
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/museum_controller.dart';
import '../../detailmuseum/views/detailmuseum_view.dart';

class MuseumView extends GetView<MuseumController> {
  const MuseumView({super.key});

  // --- PALET WARNA PREMIUM ---
  final Color _primaryColor = const Color(0xFF3E2723); // Coklat Tua
  final Color _accentColor = const Color(0xFFD4AF37); // Emas
  final Color _bgColor = const Color(0xFFFDFCF8); // Putih Tulang
  final Color _secondaryColor = const Color(0xFF5D4037);

  List<String> get _dynamicFilters {
    if (controller.allMuseums.isEmpty) return ['Semua'];
    Set<String> locations = controller.allMuseums
        .map((e) => e.subtitle.trim())
        .where((s) => s.isNotEmpty)
        .toSet();
    List<String> sortedList = locations.toList()..sort();
    return ['Semua', ...sortedList];
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MuseumController>()) Get.put(MuseumController());

    return Scaffold(
      backgroundColor: _bgColor,
      // Menggunakan Stack untuk background dekoratif
      body: Stack(
        children: [
          // --- BACKGROUND DECORATION ---
          Positioned(
            top: -60,
            left: -60,
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
            top: 150,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
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
                      if (controller.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: _primaryColor,
                          ),
                        );
                      }
                      if (controller.filteredMuseums.isEmpty) {
                        return _buildEmptyState();
                      }
                      return RefreshIndicator(
                        onRefresh: controller.refreshData,
                        color: _primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.filteredMuseums.length,
                          itemBuilder: (context, index) => _buildMuseumCard(
                            controller.filteredMuseums[index],
                          ),
                        ),
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
                  'Jelajah Museum',
                  style: GoogleFonts.philosopher(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 1,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.refreshData(),
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
                      Ionicons.refresh,
                      color: _primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 50,
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
                controller: controller.searchC,
                onChanged: (value) => controller.updateSearch(value),
                textInputAction: TextInputAction.search,
                style: GoogleFonts.mulish(color: _primaryColor),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Ionicons.search_outline,
                    color: _secondaryColor.withOpacity(0.5),
                  ),
                  hintText: 'Cari museum...',
                  hintStyle: GoogleFonts.mulish(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  suffixIcon: Obx(
                    () => controller.searchQuery.value.isNotEmpty
                        ? GestureDetector(
                            onTap: () => controller.clearSearch(),
                            child: Icon(
                              Ionicons.close_circle,
                              color: _secondaryColor.withOpacity(0.5),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Filter Tabs (Chips)
          _buildFilterTabs(),
        ],
      ),
    );
  }

  // Widget Filter Chips Modern
  Widget _buildFilterTabs() {
    return Obx(() {
      final filters = _dynamicFilters;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: filters.map((filterName) {
            final bool isSelected =
                controller.selectedFilter.value == filterName;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => controller.changeFilter(filterName),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? _primaryColor
                          : Colors.grey.withOpacity(0.2),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    filterName,
                    style: GoogleFonts.mulish(
                      color: isSelected ? _accentColor : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
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
              Ionicons.map_outline,
              size: 60,
              color: _secondaryColor.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Tidak ditemukan",
            style: GoogleFonts.mulish(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD MUSEUM (MODERN LOOK) ---
  Widget _buildMuseumCard(ContentModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.to(() => const DetailmuseumView(), arguments: item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- GAMBAR DENGAN BADGE HARGA ---
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: _buildImage(item.imageUrl),
                    ),
                  ),
                  // Badge Harga Floating
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Ionicons.pricetag,
                            size: 12,
                            color: _accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.price != null && item.price!.isNotEmpty
                                ? item.price!
                                : "Gratis",
                            style: GoogleFonts.mulish(
                              fontSize: 12,
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

              // --- INFORMASI ---
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.philosopher(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Tombol Panah Kecil
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Ionicons.arrow_forward,
                            size: 16,
                            color: _accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Lokasi
                    Row(
                      children: [
                        Icon(
                          Ionicons.location_sharp,
                          size: 14,
                          color: _secondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.subtitle.isNotEmpty
                                ? item.subtitle
                                : (item.location ?? "Lokasi tidak tersedia"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.mulish(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) return Container(color: Colors.grey[200]);
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
        );
      } else if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
        );
      } else {
        String base64String = imageUrl.replaceAll(RegExp(r'\s+'), '');
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }
        int mod4 = base64String.length % 4;
        if (mod4 > 0) base64String += '=' * (4 - mod4);
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
        );
      }
    } catch (e) {
      return Container(color: Colors.grey[200]);
    }
  }
}
