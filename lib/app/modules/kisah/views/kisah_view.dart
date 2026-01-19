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
  final Color _primaryColor = const Color(0xFF4E342E);
  final Color _accentColor = const Color(0xFFD4AF37);
  final Color _bgColor = const Color(0xFFFAFAF5);
  final Color _secondaryColor = const Color(0xFF8D6E63);

  // --- LOCAL STATE ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "Semua";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA FILTER DATA ---
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
                  if (controller.kisahList.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada data kisah.",
                        style: GoogleFonts.mulish(color: _secondaryColor),
                      ),
                    );
                  }
                  final filteredData = _currentDataList;
                  if (filteredData.isEmpty) return _buildEmptyState();
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                  'Pustaka Kisah',
                  style: GoogleFonts.philosopher(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 24), // Penyeimbang layout
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Expanded agar search bar mengisi penuh lebar karena tombol kotak dihapus
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
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      style: GoogleFonts.mulish(),
                      decoration: InputDecoration(
                        icon: Icon(
                          Ionicons.search_outline,
                          color: _secondaryColor.withOpacity(0.5),
                        ),
                        hintText: 'Cari judul...',
                        hintStyle: GoogleFonts.mulish(
                          color: Colors.grey[400],
                          fontSize: 14,
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
                // BAGIAN KOTAK YANG DULUNYA ADA DI SINI SUDAH DIHAPUS
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildDynamicFilterTabs(), // Bagian ini TETAP ADA
          const SizedBox(height: 5),
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: dynamicCategories
              .map(
                (categoryName) => Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: _buildFilterTabItem(categoryName),
                ),
              )
              .toList(),
        ),
      );
    });
  }

  Widget _buildFilterTabItem(String label) {
    bool isActive = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.mulish(
              color: isActive ? _primaryColor : Colors.grey,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
            Ionicons.search,
            size: 60,
            color: _secondaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          Text(
            "Kisah tidak ditemukan",
            style: GoogleFonts.mulish(color: _secondaryColor.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(ContentModel story) {
    String duration = story.subtitle.isNotEmpty
        ? story.subtitle
        : "5 Menit Baca";
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
          onTap: () => Get.to(() => const DetailkisahView(), arguments: story),
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
                              style: GoogleFonts.mulish(
                                color: _primaryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
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
                                "4.8",
                                style: GoogleFonts.mulish(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                ),
                              ),
                              // ICON BOOKMARK DI SINI SUDAH DIHAPUS
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        story.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.philosopher(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        story.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.mulish(
                          fontSize: 11,
                          color: Colors.grey[600],
                          height: 1.4,
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
                              style: GoogleFonts.mulish(
                                fontSize: 10,
                                color: _secondaryColor,
                              ),
                            ),
                          ),
                          Text(
                            "BACA",
                            style: GoogleFonts.mulish(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
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
