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

  final Color _primaryColor = const Color(0xFF4E342E);
  final Color _accentColor = const Color(0xFFD4AF37);
  final Color _bgColor = const Color(0xFFFAFAF5);
  final Color _secondaryColor = const Color(0xFF8D6E63);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<EventController>()) Get.put(EventController());
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildHeaderSection(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: _primaryColor),
                );
              }
              if (controller.filteredEvents.isEmpty) return _buildEmptyState();
              return RefreshIndicator(
                onRefresh: controller.refreshData,
                color: _primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
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
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _bgColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Ionicons.arrow_back, color: _primaryColor),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Kalender Event',
        style: GoogleFonts.philosopher(
          color: _primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              controller.selectedDate.value != null
                  ? Ionicons.calendar
                  : Ionicons.calendar_outline,
              color: controller.selectedDate.value != null
                  ? _accentColor
                  : _primaryColor,
            ),
            onPressed: () => controller.pickDate(context),
            tooltip: 'Pilih Tanggal',
          ),
        ),
      ],
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: _bgColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      onChanged: (value) => controller.updateSearch(value),
                      style: GoogleFonts.mulish(),
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
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
                // BAGIAN KOTAK YANG DULUNYA ADA DI SINI SUDAH DIHAPUS
              ],
            ),
          ),
          const SizedBox(height: 15),
          Column(
            children: [
              _buildCategoryTabs(), // Tabs tetap ada
              const SizedBox(height: 5),
            ],
          ),
          Obx(() {
            if (controller.selectedDate.value != null) {
              final date = controller.selectedDate.value!;
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: GestureDetector(
                  onTap: () => controller.clearDate(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accentColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Ionicons.calendar, size: 14, color: _primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          "Filter: ${date.day}/${date.month}/${date.year}",
                          style: GoogleFonts.mulish(
                            fontSize: 12,
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Ionicons.close, size: 14, color: _primaryColor),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(controller.categories.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Obx(() {
                  final categoryName = controller.categories[index];
                  final bool isSelected =
                      controller.selectedCategory.value == categoryName;
                  return GestureDetector(
                    onTap: () => controller.changeCategory(categoryName),
                    child: Column(
                      children: [
                        Text(
                          categoryName,
                          style: GoogleFonts.mulish(
                            color: isSelected ? _primaryColor : Colors.grey,
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
                  );
                }),
              );
            }),
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
          Icon(
            Ionicons.calendar_clear_outline,
            size: 60,
            color: _secondaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          Text(
            "Event tidak ditemukan",
            style: GoogleFonts.mulish(color: _secondaryColor.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(ContentModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.to(() => const DetaileventView(), arguments: event),
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
                      height: 160,
                      width: double.infinity,
                      child: _buildImage(event.imageUrl),
                    ),
                  ),
                  // ICON BOOKMARK SUDAH DIHAPUS
                  if (event.status == 'Featured')
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Unggulan',
                          style: GoogleFonts.mulish(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.category.toUpperCase(),
                      style: GoogleFonts.mulish(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      style: GoogleFonts.philosopher(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Ionicons.location_outline,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            event.location ?? "Lokasi belum tersedia",
                            maxLines: 1,
                            style: GoogleFonts.mulish(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Ionicons.calendar_outline,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            event.subtitle.isNotEmpty
                                ? event.subtitle
                                : "Tanggal tidak tersedia",
                            maxLines: 1,
                            style: GoogleFonts.mulish(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Lihat Detail",
                          style: GoogleFonts.mulish(
                            color: _accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
