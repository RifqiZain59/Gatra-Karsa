import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';

class MuseumController extends GetxController {
  final ApiService _apiService = ApiService();

  // STATE UTAMA
  var isLoading = true.obs;
  var allMuseums = <ContentModel>[].obs;
  var filteredMuseums = <ContentModel>[].obs;

  // FILTER STATE
  var selectedFilter = "Semua".obs;
  var searchQuery = "".obs;

  // KOLEKSI STATE (BARU)
  var savedIds = <String>{}.obs; // Menyimpan ID museum yang disimpan
  var isCollectionMode = false.obs; // Apakah sedang mode melihat koleksi?

  final TextEditingController searchC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchMuseumData();
  }

  @override
  void onClose() {
    searchC.dispose();
    super.onClose();
  }

  void fetchMuseumData() async {
    try {
      isLoading(true);
      List<ContentModel> data = await _apiService.getMuseums();
      allMuseums.assignAll(data);
      runFilter();
    } catch (e) {
      print("Error fetching museums: $e");
    } finally {
      isLoading(false);
    }
  }

  // LOGIKA FILTER LENGKAP
  void runFilter() {
    List<ContentModel> result = allMuseums;

    // 1. Filter Mode Koleksi
    if (isCollectionMode.value) {
      result = result.where((item) => savedIds.contains(item.id)).toList();
    }

    // 2. Filter Lokasi (Subtitle)
    if (selectedFilter.value != "Semua") {
      result = result
          .where(
            (item) =>
                item.subtitle.toLowerCase().trim() ==
                selectedFilter.value.toLowerCase().trim(),
          )
          .toList();
    }

    // 3. Filter Search
    if (searchQuery.value.isNotEmpty) {
      String query = searchQuery.value.toLowerCase();
      result = result.where((item) {
        bool matchTitle = item.title.toLowerCase().contains(query);
        bool matchSubtitle = item.subtitle.toLowerCase().contains(query);
        return matchTitle || matchSubtitle;
      }).toList();
    }

    filteredMuseums.assignAll(result);
  }

  // --- AKSI USER ---

  void updateSearch(String query) {
    searchQuery.value = query;
    runFilter();
  }

  void clearSearch() {
    searchC.clear();
    updateSearch("");
  }

  void changeFilter(String value) {
    selectedFilter.value = value;
    runFilter();
  }

  // Toggle Mode Koleksi (Tombol di sebelah Search)
  void toggleCollectionMode() {
    isCollectionMode.value = !isCollectionMode.value;
    // Reset filter lain saat ganti mode agar UX lebih baik
    searchC.clear();
    searchQuery.value = "";
    selectedFilter.value = "Semua";
    runFilter();
  }

  // Toggle Simpan Item (Tombol di Card)
  void toggleSave(String id) {
    if (savedIds.contains(id)) {
      savedIds.remove(id);
      Get.snackbar(
        "Dihapus",
        "Museum dihapus dari koleksi",
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
        "Museum ditambahkan ke koleksi",
        backgroundColor: const Color(0xFF4E342E),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 1),
      );
    }
    // Jika sedang di tab koleksi, refresh agar item yang dihapus langsung hilang
    if (isCollectionMode.value) runFilter();
  }

  Future<void> refreshData() async {
    fetchMuseumData();
  }
}
