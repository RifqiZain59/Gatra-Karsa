import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

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
    if (!Get.isRegistered<MuseumController>()) {
      Get.put(MuseumController());
    }

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
                      // PERBAIKAN: Padding Top 0 (karena Header sudah punya padding bottom 20)
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.filteredMuseums.length,
                      itemBuilder: (context, index) {
                        return _buildMuseumCard(
                          controller.filteredMuseums[index],
                        );
                      },
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

  // --- HEADER SECTION ---
  Widget _buildHeaderSection() {
    return Container(
      // Padding bottom 20 (Sama dengan KisahView)
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: _bgColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Nav
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Ionicons.arrow_back, color: _primaryColor),
                ),
                Obx(
                  () => Text(
                    controller.isCollectionMode.value
                        ? 'Koleksi Museum'
                        : 'Jelajah Museum',
                    style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Serif',
                    ),
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

          // 2. SEARCH BAR + SAVE BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
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
                      style: const TextStyle(fontFamily: 'Serif'),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Ionicons.search_outline,
                          color: _secondaryColor.withOpacity(0.5),
                        ),
                        hintText: 'Cari museum...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontFamily: 'Serif',
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

                const SizedBox(width: 12),

                GestureDetector(
                  onTap: () => controller.toggleCollectionMode(),
                  child: Obx(
                    () => Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: controller.isCollectionMode.value
                            ? _primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: controller.isCollectionMode.value
                            ? null
                            : Border.all(color: _primaryColor.withOpacity(0.1)),
                      ),
                      child: Icon(
                        controller.isCollectionMode.value
                            ? Ionicons.bookmark
                            : Ionicons.bookmark_outline,
                        color: controller.isCollectionMode.value
                            ? _accentColor
                            : _primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Filter Tabs (Hanya muncul jika BUKAN mode koleksi)
          Obx(() {
            if (!controller.isCollectionMode.value) {
              return Column(
                children: [
                  const SizedBox(height: 15),
                  _buildFilterTabs(),
                  // Jarak ekstra 5px agar tidak terlalu mepet dengan list (Sama dengan KisahView)
                  const SizedBox(height: 5),
                ],
              );
            } else {
              return const SizedBox(height: 5);
            }
          }),
        ],
      ),
    );
  }

  // --- FILTER TABS ---
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
                      style: TextStyle(
                        color: isSelected ? _primaryColor : Colors.grey[400],
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontFamily: 'Serif',
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
            controller.isCollectionMode.value
                ? Ionicons.bookmark_outline
                : Ionicons.map_outline,
            size: 80,
            color: _secondaryColor.withOpacity(0.2),
          ),
          const SizedBox(height: 15),
          Text(
            controller.isCollectionMode.value
                ? "Belum ada koleksi"
                : "Tidak ditemukan",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _secondaryColor,
              fontFamily: 'Serif',
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
              // --- GAMBAR ---
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

                  // ICON SAVE
                  Positioned(
                    top: 15,
                    right: 15,
                    child: GestureDetector(
                      onTap: () => controller.toggleSave(item.id),
                      child: Obx(() {
                        bool isSaved = controller.savedIds.contains(item.id);
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            isSaved
                                ? Ionicons.bookmark
                                : Ionicons.bookmark_outline,
                            color: isSaved ? _accentColor : _primaryColor,
                            size: 18,
                          ),
                        );
                      }),
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
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                        fontFamily: 'Serif',
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
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontFamily: 'Serif',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                              style: TextStyle(
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
                            style: TextStyle(
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
    if (imageUrl.isEmpty) {
      return Container(color: Colors.grey[200]);
    }
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
        String base64String = imageUrl;
        if (base64String.contains(','))
          base64String = base64String.split(',').last;
        base64String = base64String.replaceAll(RegExp(r'\s+'), '');
        Uint8List bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
        );
      }
    } catch (e) {
      return Container(color: Colors.grey[200]);
    }
  }
}
