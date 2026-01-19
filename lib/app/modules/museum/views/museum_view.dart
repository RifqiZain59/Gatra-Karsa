import 'dart:convert';
import 'dart:typed_data';
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

  final Color _primaryColor = const Color(0xFF4E342E);
  final Color _accentColor = const Color(0xFFD4AF37);
  final Color _bgColor = const Color(0xFFFAFAF5);
  final Color _secondaryColor = const Color(0xFF8D6E63);

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
      body: AnnotatedRegion<SystemUiOverlayStyle>(
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
                      child: CircularProgressIndicator(color: _primaryColor),
                    );
                  }
                  if (controller.filteredMuseums.isEmpty) {
                    return _buildEmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: controller.refreshData,
                    color: _primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.filteredMuseums.length,
                      itemBuilder: (context, index) =>
                          _buildMuseumCard(controller.filteredMuseums[index]),
                    ),
                  );
                }),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  'Jelajah Museum',
                  style: GoogleFonts.philosopher(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.refreshData(),
                  child: Icon(Ionicons.refresh, color: _primaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Expanded agar search bar mengisi penuh
                Expanded(
                  child: Container(
                    height: 50,
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
                      controller: controller.searchC,
                      onChanged: (value) => controller.updateSearch(value),
                      textInputAction: TextInputAction.search,
                      style: GoogleFonts.mulish(),
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
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
                // BAGIAN KOTAK YANG DULUNYA ADA DI SINI SUDAH DIHAPUS
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildFilterTabs(), // Filter tabs TETAP ADA
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Obx(() {
      final filters = _dynamicFilters;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: filters.map((filterName) {
            final bool isSelected =
                controller.selectedFilter.value == filterName;
            return Padding(
              padding: const EdgeInsets.only(right: 30),
              child: GestureDetector(
                onTap: () => controller.changeFilter(filterName),
                child: Column(
                  children: [
                    Text(
                      filterName,
                      style: GoogleFonts.mulish(
                        color: isSelected ? _primaryColor : Colors.grey[400],
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
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
          Icon(
            Ionicons.map_outline,
            size: 80,
            color: _secondaryColor.withOpacity(0.2),
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

  Widget _buildMuseumCard(ContentModel item) {
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
          onTap: () => Get.to(() => const DetailmuseumView(), arguments: item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  // ICON BOOKMARK YANG MELAYANG DI GAMBAR SUDAH DIHAPUS
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.philosopher(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Ionicons.location_outline,
                          size: 16,
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
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Ionicons.pricetag_outline,
                              size: 14,
                              color: _secondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.category,
                              style: GoogleFonts.mulish(
                                fontSize: 12,
                                color: _secondaryColor,
                                fontWeight: FontWeight.w500,
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
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.price != null && item.price!.isNotEmpty
                                ? item.price!
                                : "Gratis",
                            style: GoogleFonts.mulish(
                              fontSize: 11,
                              color: _primaryColor,
                              fontWeight: FontWeight.bold,
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
