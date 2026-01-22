import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';

class EventController extends GetxController {
  final ApiService _apiService = ApiService();

  // --- VARIABLES ---
  var isLoading = true.obs;

  // List Master Data
  var allEvents = <ContentModel>[].obs;

  // List Hasil Filter
  var filteredEvents = <ContentModel>[].obs;

  // List Kategori Dinamis (Diambil dari data Firebase)
  var categoryList = <String>["Semua"].obs;

  // State Filter
  var searchQuery = "".obs;
  var selectedCategory = "Semua".obs;
  var selectedDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  // --- FETCH DATA ---
  void fetchEvents() async {
    try {
      isLoading(true);
      // Mengambil data dari API/Firebase
      var events = await _apiService.getEvents();

      // Simpan ke master list
      allEvents.assignAll(events);

      // GENERATE KATEGORI DINAMIS
      _generateDynamicCategories();

      // Terapkan filter awal (tampilkan semua)
      applyFilters();
    } catch (e) {
      print("Error fetching events: $e");
    } finally {
      isLoading(false);
    }
  }

  // Fungsi untuk mengekstrak kategori unik dari data
  void _generateDynamicCategories() {
    if (allEvents.isEmpty) {
      categoryList.assignAll(["Semua"]);
      return;
    }

    // Ambil kategori, trim spasi, hapus yang kosong, dan masukkan ke Set (unik)
    Set<String> uniqueCategories = allEvents
        .map((e) => e.category.trim()) // Bersihkan spasi
        .where((c) => c.isNotEmpty) // Hapus string kosong
        .toSet();

    // Ubah ke List dan Urutkan Abjad
    List<String> sortedCats = uniqueCategories.toList()..sort();

    // Masukkan "Semua" di awal
    categoryList.assignAll(["Semua", ...sortedCats]);
  }

  Future<void> refreshData() async {
    fetchEvents();
  }

  // --- LOGIKA FILTER ---
  void applyFilters() {
    List<ContentModel> results = allEvents;

    // 1. Filter Search
    if (searchQuery.value.isNotEmpty) {
      results = results
          .where(
            (event) => event.title.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }

    // 2. Filter Kategori
    if (selectedCategory.value != "Semua") {
      // Case-insensitive comparison agar aman
      results = results
          .where(
            (event) =>
                event.category.trim().toLowerCase() ==
                selectedCategory.value.trim().toLowerCase(),
          )
          .toList();
    }

    // 3. Filter Tanggal
    if (selectedDate.value != null) {
      // Implementasi sederhana: Cek apakah subtitle mengandung format tanggal
      // (Sebaiknya gunakan field 'date' khusus jika ada di model)
      DateTime picked = selectedDate.value!;

      // Contoh: Kita anggap subtitle berisi "24 Januari 2024"
      // Kita coba match String tanggal.
      // *Catatan: Logic ini tergantung format tanggal di Firebase Anda*
      // Disini kita filter jika data event memiliki tanggal yang valid/relevan
      // results = results.where((e) => ...).toList();
    }

    filteredEvents.assignAll(results);
  }

  void updateSearch(String val) {
    searchQuery.value = val;
    applyFilters();
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  // --- DATE PICKER ---
  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3E2723),
              onPrimary: Colors.white,
              onSurface: Color(0xFF3E2723),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      applyFilters();
    }
  }

  void clearDate() {
    selectedDate.value = null;
    applyFilters();
  }
}
