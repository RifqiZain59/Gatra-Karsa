import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';

class EventController extends GetxController {
  final ApiService _apiService = ApiService();

  // STATE UTAMA
  var isLoading = true.obs;
  var allEvents = <ContentModel>[].obs;
  var filteredEvents = <ContentModel>[].obs;

  // FILTER STATE
  var categories = <String>['Semua'].obs;
  var selectedCategory = 'Semua'.obs;
  var searchQuery = ''.obs;
  var selectedDate = Rxn<DateTime>();

  // --- KOLEKSI STATE (BARU) ---
  var savedIds = <String>{}.obs; // Set ID yang disimpan
  var isCollectionMode = false.obs; // Mode filter: Semua vs Koleksi

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  void fetchEvents() async {
    try {
      isLoading(true);
      List<ContentModel> data = await _apiService.getEvents();
      allEvents.assignAll(data);
      _extractCategories();
      runFilter();
    } catch (e) {
      print("Error fetching events: $e");
    } finally {
      isLoading(false);
    }
  }

  void _extractCategories() {
    Set<String> uniqueCats = allEvents
        .map((e) => e.category.trim())
        .where((c) => c.isNotEmpty)
        .toSet();
    List<String> sorted = uniqueCats.toList()..sort();
    categories.assignAll(['Semua', ...sorted]);
  }

  // LOGIKA FILTER LENGKAP
  void runFilter() {
    List<ContentModel> result = allEvents;

    // 1. Filter Mode Koleksi (Jadwal Saya)
    if (isCollectionMode.value) {
      result = result.where((item) => savedIds.contains(item.id)).toList();
    }

    // 2. Filter Kategori
    if (selectedCategory.value != 'Semua') {
      result = result
          .where(
            (item) =>
                item.category.toLowerCase().trim() ==
                selectedCategory.value.toLowerCase().trim(),
          )
          .toList();
    }

    // 3. Filter Search
    if (searchQuery.value.isNotEmpty) {
      String query = searchQuery.value.toLowerCase();
      result = result.where((item) {
        return item.title.toLowerCase().contains(query) ||
            (item.location ?? "").toLowerCase().contains(query);
      }).toList();
    }

    // 4. Filter Date (Opsional)
    if (selectedDate.value != null) {
      // Logic tanggal bisa disesuaikan
    }

    filteredEvents.assignAll(result);
  }

  // --- ACTIONS ---

  void changeCategory(String category) {
    selectedCategory.value = category;
    runFilter();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    runFilter();
  }

  // Toggle Mode Koleksi (Tombol di sebelah Search)
  void toggleCollectionMode() {
    isCollectionMode.value = !isCollectionMode.value;
    // Reset filter lain agar UX lebih baik
    selectedCategory.value = 'Semua';
    searchQuery.value = '';
    runFilter();
  }

  // Toggle Simpan Item (Tombol di Card)
  void toggleSave(String id) {
    if (savedIds.contains(id)) {
      savedIds.remove(id);
      Get.snackbar(
        "Dihapus",
        "Event dihapus dari jadwal saya",
        backgroundColor: Colors.grey,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 1),
      );
    } else {
      savedIds.add(id);
      Get.snackbar(
        "Disimpan",
        "Event ditambahkan ke jadwal saya",
        backgroundColor: const Color(0xFF4E342E),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 1),
      );
    }
    // Jika sedang di mode koleksi, refresh agar item hilang real-time
    if (isCollectionMode.value) runFilter();
  }

  // Date Picker Logic
  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4E342E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF4E342E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      runFilter();
    }
  }

  void clearDate() {
    selectedDate.value = null;
    runFilter();
  }

  Future<void> refreshData() async {
    fetchEvents();
  }
}
