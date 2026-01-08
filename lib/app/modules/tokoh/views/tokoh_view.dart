import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

// --- IMPORT VIEW & CONTROLLER ---
import 'package:gatrakarsa/app/modules/detail_wayang/views/detail_wayang_view.dart';
// TAMBAHKAN IMPORT BINDING INI:
import 'package:gatrakarsa/app/modules/detail_wayang/bindings/detail_wayang_binding.dart';

import 'package:gatrakarsa/app/modules/detaildalang/views/detaildalang_view.dart';
import 'package:gatrakarsa/app/modules/detaildalang/controllers/detaildalang_controller.dart';
import 'package:gatrakarsa/app/modules/tokoh/controllers/tokoh_controller.dart';

class TokohView extends StatefulWidget {
  const TokohView({super.key});

  @override
  State<TokohView> createState() => _TokohViewState();
}

class _TokohViewState extends State<TokohView> {
  // ... (kode variable dan state lainnya tetap sama) ...
  final TokohController controller = Get.put(TokohController());
  final Color _primaryColor = const Color(0xFF4E342E);
  final Color _accentColor = const Color(0xFFD4AF37);
  final Color _bgColor = const Color(0xFFFAFAF5);
  final Color _secondaryColor = const Color(0xFF8D6E63);

  int _activeTab = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "Semua";

  // ... (kode dispose, decodeImage, filter tetap sama) ...

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  List<String> get _currentFilters {
    if (_activeTab == 0) {
      return [
        'Semua',
        'Wayang Kulit',
        'Wayang Golek',
        'Wayang Orang',
        'Lainnya',
      ];
    }
    return ['Semua', 'Dalang', 'Maestro', 'Legend', 'Dalang Muda'];
  }

  List<ContentModel> get _filteredData {
    List<ContentModel> source = _activeTab == 0
        ? controller.wayangList
        : controller.dalangList;

    return source.where((item) {
      bool matchesSearch = item.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesCategory =
          _selectedCategory == "Semua" || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ... (kode build method tetap sama sampai pemanggilan _buildWayangCard) ...
    return Scaffold(
      backgroundColor: _bgColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
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
                      child: CircularProgressIndicator(color: _primaryColor),
                    );
                  }
                  if (_filteredData.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildContentGrid(_filteredData);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Widget header dan tabs tetap sama) ...
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: _bgColor),
      child: Column(
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
                  'Ensiklopedia',
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
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMainTabButton('Tokoh Wayang', 0),
              const SizedBox(width: 40),
              _buildMainTabButton('Tokoh Dalang', 1),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
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
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Ionicons.search_outline,
                    color: _secondaryColor.withOpacity(0.5),
                  ),
                  hintText: _activeTab == 0
                      ? 'Cari wayang...'
                      : 'Cari dalang...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: 'Serif',
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
          _buildFilterTabs(),
        ],
      ),
    );
  }

  Widget _buildMainTabButton(String label, int index) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
          _searchQuery = "";
          _searchController.clear();
          _selectedCategory = "Semua";
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? _primaryColor : Colors.grey,
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Serif',
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            width: isActive ? 30 : 0,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(_currentFilters.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 30),
              child: _buildFilterTabItem(_currentFilters[index]),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFilterTabItem(String label) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? _primaryColor : Colors.grey,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
            "Data tidak ditemukan",
            style: TextStyle(
              color: _secondaryColor.withOpacity(0.5),
              fontFamily: 'Serif',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentGrid(List<ContentModel> data) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) => _activeTab == 0
          ? _buildWayangCard(data[index])
          : _buildDalangCard(data[index]),
    );
  }

  // --- PERBAIKAN DI SINI ---
  Widget _buildWayangCard(ContentModel item) {
    Uint8List? imageBytes = _decodeImage(item.imageUrl);

    return GestureDetector(
      onTap: () {
        // PERBAIKAN: Tambahkan 'binding: DetailWayangBinding()'
        Get.to(
          () => const DetailWayangView(),
          arguments: item,
          binding: DetailWayangBinding(),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: imageBytes != null
                      ? Image.memory(
                          imageBytes,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Icon(
                            Ionicons.person,
                            size: 40,
                            color: _secondaryColor,
                          ),
                        )
                      : Icon(Ionicons.person, size: 40, color: _secondaryColor),
                ),
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
                      item.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                        letterSpacing: 0.5,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.subtitle,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Serif',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Ionicons.heart_outline,
                          size: 16,
                          color: _secondaryColor,
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
    );
  }

  // ... (buildDalangCard tetap sama) ...
  Widget _buildDalangCard(ContentModel item) {
    Uint8List? imageBytes = _decodeImage(item.imageUrl);
    return GestureDetector(
      onTap: () {
        Get.to(
          () => const DetaildalangView(),
          arguments: item,
          binding: BindingsBuilder(() {
            Get.put(DetaildalangController());
          }),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _secondaryColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                border: Border.all(color: _accentColor, width: 2),
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: _bgColor,
                backgroundImage: imageBytes != null
                    ? MemoryImage(imageBytes)
                    : null,
                child: imageBytes == null
                    ? Icon(
                        Ionicons.mic_outline,
                        size: 25,
                        color: _secondaryColor,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
                fontFamily: 'Serif',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              style: TextStyle(
                fontSize: 10,
                color: _accentColor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Serif',
              ),
            ),
            const SizedBox(height: 8),
            if (item.location != null && item.location!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.location!,
                  style: TextStyle(
                    fontSize: 9,
                    color: _secondaryColor,
                    fontFamily: 'Serif',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
