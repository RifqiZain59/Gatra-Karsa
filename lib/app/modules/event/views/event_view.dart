import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatrakarsa/app/modules/detailevent/views/detailevent_view.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  // --- PALET WARNA ---
  final Color _primaryColor = const Color(0xFF4E342E); // Coklat Tua
  final Color _accentColor = const Color(0xFFD4AF37); // Emas
  final Color _bgColor = const Color(0xFFFAFAF5); // Krem
  final Color _secondaryColor = const Color(0xFF8D6E63); // Coklat Susu

  // --- CONTROLLERS & STATE ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // State untuk Tab Filter Baru
  int _activeTabIndex = 0;
  final List<String> _categories = [
    'Semua',
    'Pertunjukan',
    'Pameran',
    'Workshop',
  ];
  String _selectedCategory = "Semua";

  DateTime? _selectedDate;

  // --- DATA DUMMY EVENT ---
  final List<Map<String, dynamic>> events = [
    {
      'title': 'Pagelaran Wayang Kulit Semalam Suntuk',
      'category': 'Pertunjukan',
      'date': '15 Jan 2026',
      'timestamp': DateTime(2026, 1, 15),
      'time': '19:00 WIB',
      'location': 'Alun-Alun Keraton Surakarta',
      'image': 'assets/banner1.jpg',
      'price': 'Gratis',
      'isFeatured': true,
    },
    {
      'title': 'Festival Dalang Cilik Nasional',
      'category': 'Pertunjukan',
      'date': '20 Jan 2026',
      'timestamp': DateTime(2026, 1, 20),
      'time': '08:00 WIB',
      'location': 'Pendopo Taman Budaya',
      'image': 'assets/banner2.jpg',
      'price': 'Rp 25.000',
      'isFeatured': false,
    },
    {
      'title': 'Pameran Wayang Nusantara',
      'category': 'Pameran',
      'date': '02 Feb 2026',
      'timestamp': DateTime(2026, 2, 2),
      'time': '10:00 WIB',
      'location': 'Museum Wayang Kekayon',
      'image': 'assets/banner1.jpg',
      'price': 'Rp 10.000',
      'isFeatured': false,
    },
    {
      'title': 'Workshop Pembuatan Wayang',
      'category': 'Workshop',
      'date': '15 Jan 2026',
      'timestamp': DateTime(2026, 1, 15),
      'time': '13:00 WIB',
      'location': 'Sanggar Seni Sarotama',
      'image': 'assets/banner2.jpg',
      'price': 'Rp 50.000',
      'isFeatured': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA FILTER ---
  List<Map<String, dynamic>> get _filteredEvents {
    return events.where((event) {
      bool matchesSearch = event['title'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesCategory =
          _selectedCategory == "Semua" ||
          event['category'] == _selectedCategory;
      bool matchesDate = true;
      if (_selectedDate != null) {
        DateTime eventDate = event['timestamp'];
        matchesDate =
            eventDate.year == _selectedDate!.year &&
            eventDate.month == _selectedDate!.month &&
            eventDate.day == _selectedDate!.day;
      }
      return matchesSearch && matchesCategory && matchesDate;
    }).toList();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 1, 1),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: _primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 15),

          // --- TAB FILTER BARU ---
          _buildCategoryTabs(),

          const SizedBox(height: 15),

          // Tampilan Chip Tanggal (Jika ada tanggal dipilih)
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _accentColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Ionicons.calendar, size: 12, color: _primaryColor),
                        const SizedBox(width: 5),
                        Text(
                          "Filter: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                          style: TextStyle(
                            fontSize: 12,
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Serif', // Font disamakan
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () => setState(() => _selectedDate = null),
                          child: Icon(
                            Ionicons.close_circle,
                            size: 16,
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _filteredEvents.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(_filteredEvents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Ionicons.arrow_back, color: _primaryColor),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Kalender Event',
        style: TextStyle(
          color: _primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          fontFamily: 'Serif', // Font disamakan
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _selectedDate != null
                ? Ionicons.calendar
                : Ionicons.calendar_outline,
            color: _selectedDate != null ? _accentColor : _primaryColor,
          ),
          onPressed: _pickDate,
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
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 5),
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
          icon: Icon(Ionicons.search_outline, color: _secondaryColor),
          hintText: 'Cari acara wayang...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            fontFamily: 'Serif', // Font disamakan
          ),
          border: InputBorder.none,
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
    );
  }

  // --- WIDGET TAB KATEGORI BARU ---
  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(_categories.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 30), // Jarak antar tab
            child: _buildTabItem(_categories[index], index),
          );
        }),
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    bool isActive = _activeTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTabIndex = index;
          _selectedCategory = label;
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
              fontFamily: 'Serif', // Font disamakan
            ),
          ),
          const SizedBox(height: 6),
          // Indikator Garis Bawah Animasi
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            width: isActive ? 25 : 0, // Lebar garis saat aktif
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
            Ionicons.calendar_clear_outline,
            size: 60,
            color: _secondaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          Text(
            "Event tidak ditemukan",
            style: TextStyle(
              color: _secondaryColor.withOpacity(0.5),
              fontFamily: 'Serif', // Font disamakan
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.asset(
                  event['image'],
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 160,
                      color: _secondaryColor.withOpacity(0.2),
                      child: Icon(
                        Ionicons.image_outline,
                        size: 50,
                        color: _secondaryColor,
                      ),
                    );
                  },
                ),
              ),
              if (event['isFeatured'])
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Unggulan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif', // Font disamakan
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
                  event['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                    fontFamily: 'Serif', // Font disamakan
                  ),
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
                        event['location'],
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontFamily: 'Serif', // Font disamakan
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // --- TOMBOL NAVIGASI KE DETAIL ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => const DetaileventView(), arguments: event);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: _accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Lihat Detail",
                      style: TextStyle(
                        fontFamily: 'Serif', // Font disamakan
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
