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

  @override
  Widget build(BuildContext context) {
    // TIPS: Sebaiknya letakkan Get.put di Binding.
    // Namun untuk quick-fix agar tidak error jika tanpa binding:
    if (!Get.isRegistered<MuseumController>()) {
      Get.put(MuseumController());
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildSearchBar(),
          const SizedBox(height: 15),
          _buildCategoryTabs(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Destinasi Terpopuler",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                    fontFamily: 'Serif',
                  ),
                ),
                // Optional: Menampilkan jumlah data
                Obx(
                  () => Text(
                    "${controller.filteredMuseums.length} Tempat",
                    style: TextStyle(fontSize: 12, color: _secondaryColor),
                  ),
                ),
              ],
            ),
          ),
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
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.filteredMuseums.length,
                  itemBuilder: (context, index) {
                    return _buildMuseumCard(controller.filteredMuseums[index]);
                  },
                ),
              );
            }),
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
          fontSize: 22,
          fontFamily: 'Serif',
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => controller.refreshData(),
          icon: Icon(Ionicons.refresh, color: _primaryColor),
          tooltip: 'Refresh Data',
        ),
      ],
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) => controller.updateSearch(value),
          textInputAction:
              TextInputAction.search, // Menambahkan action search di keyboard
          style: TextStyle(fontFamily: 'Serif', color: _primaryColor),
          decoration: InputDecoration(
            prefixIcon: Icon(Ionicons.search_outline, color: _secondaryColor),
            hintText: 'Cari museum atau kota...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: 'Serif',
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final List<String> categories = [
      'Semua',
      'Yogyakarta',
      'Jawa Tengah',
      'Jakarta',
      'Jawa Barat',
      'Jawa Timur',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(categories.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Obx(
              () => GestureDetector(
                onTap: () =>
                    controller.changeCategory(index, categories[index]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: controller.activeTabIndex.value == index
                        ? _primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: controller.activeTabIndex.value == index
                        ? null
                        : Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: controller.activeTabIndex.value == index
                          ? Colors.white
                          : Colors.grey[600],
                      fontSize: 14,
                      fontWeight: controller.activeTabIndex.value == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontFamily: 'Serif',
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
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
            size: 80,
            color: _secondaryColor.withOpacity(0.2),
          ),
          const SizedBox(height: 15),
          Text(
            "Tidak ditemukan",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _secondaryColor,
              fontFamily: 'Serif',
            ),
          ),
          Text(
            "Coba kata kunci atau kategori lain",
            style: TextStyle(
              color: _secondaryColor.withOpacity(0.6),
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
                  // Badge Rating / Kategori
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
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Ionicons.star, color: _accentColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "4.8",
                            style: TextStyle(
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
                    // JUDUL
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

                    // LOKASI (Menggunakan Subtitle + Location)
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
                            // Logic: Tampilkan subtitle (Kota/Wilayah).
                            // Jika ada lokasi detail, gabungkan.
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

                    // BOTTOM ROW (Time & Price)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Jam Operasional
                        Row(
                          children: [
                            Icon(
                              Ionicons.time_outline,
                              size: 14,
                              color: _secondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.time ?? "08.00 - 16.00",
                              style: TextStyle(
                                fontSize: 12,
                                color: _secondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Harga / Label
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
    // Placeholder default
    const String assetPlaceholder = 'assets/banner1.jpg';

    if (imageUrl.isEmpty) {
      return Image.asset(assetPlaceholder, fit: BoxFit.cover);
    }

    try {
      // 1. URL HTTP/HTTPS
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: Icon(Ionicons.image_outline, color: Colors.grey[400]),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(assetPlaceholder, fit: BoxFit.cover);
          },
        );
      }
      // 2. ASSETS LOCAL
      else if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: Colors.grey),
        );
      }
      // 3. BASE64 STRING
      else {
        // Membersihkan string base64 dari prefix data:image jika ada
        String base64String = imageUrl;
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }

        // Dekode
        Uint8List bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(assetPlaceholder, fit: BoxFit.cover);
          },
        );
      }
    } catch (e) {
      // Fallback jika format string benar-benar rusak
      return Image.asset(assetPlaceholder, fit: BoxFit.cover);
    }
  }
}
