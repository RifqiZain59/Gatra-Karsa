import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/event_controller.dart';
import '../../detailevent/views/detailevent_view.dart';

class EventView extends GetView<EventController> {
  const EventView({super.key});

  // --- PALET WARNA PREMIUM ---
  final Color _primaryColor = const Color(0xFF3E2723); // Coklat Tua
  final Color _accentColor = const Color(0xFFD4AF37); // Emas
  final Color _bgColor = const Color(0xFFFDFCF8); // Putih Tulang
  final Color _secondaryColor = const Color(0xFF5D4037);

  // --- GENERATE FILTER KATEGORI DINAMIS ---
  List<String> get _dynamicCategories {
    var source = controller.filteredEvents;

    if (source.isEmpty) return ['Semua'];

    Set<String> categories = source
        .map((e) => e.category.trim())
        .where((c) => c.isNotEmpty)
        .toSet();

    List<String> sorted = categories.toList()..sort();
    return ['Semua', ...sorted];
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<EventController>()) Get.put(EventController());

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // --- BACKGROUND DECORATION ---
          Positioned(
            top: -80,
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
            top: 120,
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
                  _buildHeaderSection(context),

                  // --- FILTER TANGGAL AKTIF (CHIP) ---
                  // Logic tetap ada jika tanggal tersetting secara programatik
                  Obx(() {
                    if (controller.selectedDate.value != null) {
                      final date = controller.selectedDate.value!;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 15),
                        child: GestureDetector(
                          onTap: () => controller.clearDate(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _accentColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _accentColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Ionicons.calendar,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Filter: ${date.day}/${date.month}/${date.year}",
                                  style: GoogleFonts.mulish(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Ionicons.close_circle,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // --- LIST EVENT ---
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: _primaryColor,
                          ),
                        );
                      }
                      if (controller.filteredEvents.isEmpty) {
                        return _buildEmptyState();
                      }
                      return RefreshIndicator(
                        onRefresh: controller.refreshData,
                        color: _primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.filteredEvents.length,
                          itemBuilder: (context, index) =>
                              _buildEventCard(controller.filteredEvents[index]),
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

  Widget _buildHeaderSection(BuildContext context) {
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
                  'Kalender Event',
                  style: GoogleFonts.philosopher(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                    letterSpacing: 1,
                  ),
                ),
                // --- DUMMY SIZED BOX (Pengganti Icon Kalender agar Judul Center) ---
                const SizedBox(width: 40),
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
                onChanged: (value) => controller.updateSearch(value),
                style: GoogleFonts.mulish(color: _primaryColor),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Ionicons.search_outline,
                    color: _secondaryColor.withOpacity(0.5),
                  ),
                  hintText: 'Cari acara wayang...',
                  hintStyle: GoogleFonts.mulish(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  suffixIcon: Obx(
                    () => controller.searchQuery.value.isNotEmpty
                        ? GestureDetector(
                            onTap: () => controller.updateSearch(""),
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

          // --- FILTER KATEGORI (TABS) ---
          _buildCategoryTabs(),
        ],
      ),
    );
  }

  // --- WIDGET TAB KATEGORI ---
  Widget _buildCategoryTabs() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() {
        // Menggunakan categoryList dari Controller
        final categories = controller.categoryList;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: categories.map((cat) {
              final bool isSelected = controller.selectedCategory.value == cat;

              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () => controller.changeCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
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
                      cat,
                      style: GoogleFonts.mulish(
                        color: isSelected ? _accentColor : Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }),
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
              Ionicons.calendar_clear_outline,
              size: 60,
              color: _secondaryColor.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Tidak ada event ditemukan",
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

  // --- CARD EVENT PREMIUM ---
  Widget _buildEventCard(ContentModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Get.to(() => const DetaileventView(), arguments: event),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- GAMBAR EVENT ---
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: _buildImage(event.imageUrl),
                    ),
                  ),

                  // Badge Kategori
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        event.category.toUpperCase(),
                        style: GoogleFonts.mulish(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Badge Tanggal
                  if (event.subtitle.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Ionicons.calendar,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              event.subtitle,
                              style: GoogleFonts.mulish(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // --- INFO TEXT ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.philosopher(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Ionicons.location_sharp,
                          size: 16,
                          color: _secondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.location ?? "Lokasi belum tersedia",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.mulish(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (event.price != null && event.price!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              event.price!,
                              style: GoogleFonts.mulish(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Text(
                          "Lihat Detail",
                          style: GoogleFonts.mulish(
                            color: _accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Ionicons.arrow_forward_circle,
                          color: _accentColor,
                          size: 18,
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
    const String assetPlaceholder = 'assets/banner1.jpg';
    if (imageUrl.isEmpty) {
      return Image.asset(assetPlaceholder, fit: BoxFit.cover);
    }
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) =>
              Image.asset(assetPlaceholder, fit: BoxFit.cover),
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
          errorBuilder: (c, e, s) =>
              Image.asset(assetPlaceholder, fit: BoxFit.cover),
        );
      }
    } catch (e) {
      return Image.asset(assetPlaceholder, fit: BoxFit.cover);
    }
  }
}
