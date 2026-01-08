import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';
// Pastikan import model sesuai lokasi file Anda
// import 'package:gatrakarsa/app/data/models/content_model.dart';

class MuseumController extends GetxController {
  final ApiService _apiService = ApiService();

  var museumList = <ContentModel>[].obs;
  var isLoading = true.obs;

  var searchQuery = ''.obs;
  var selectedCategory = 'Semua'.obs;
  var activeTabIndex = 0.obs;

  // Filter Data
  List<ContentModel> get filteredMuseums {
    return museumList.where((item) {
      // 1. Search by Name (Title) OR Subtitle
      // Agar user bisa mencari berdasarkan nama museum atau nama daerahnya (subtitle)
      bool matchesSearch =
          item.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          item.subtitle.toLowerCase().contains(searchQuery.value.toLowerCase());

      // 2. Filter Category (Menggunakan Subtitle sebagai acuan Lokasi/Kategori)
      // Mengambil data subtitle, jika kosong default string kosong
      String dataCategory = item.subtitle;

      bool matchesCategory = selectedCategory.value == "Semua";

      if (!matchesCategory) {
        // Cek apakah subtitle mengandung kata kunci kategori (misal: "Yogyakarta", "Solo")
        matchesCategory = dataCategory.toLowerCase().contains(
          selectedCategory.value.toLowerCase(),
        );
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchMuseums();
  }

  Future<void> fetchMuseums() async {
    try {
      isLoading(true);

      // Ambil data dari API Service
      List<ContentModel> result = await _apiService.getMuseums();
      museumList.assignAll(result);

      // DEBUG: Cek apakah subtitle terbaca
      if (result.isNotEmpty) {
        print("✅ Museum Loaded: ${result.length} items");
        print("   Title    : ${result[0].title}");
        print("   Subtitle : ${result[0].subtitle}"); // Field subtitle
        print("   Location : ${result[0].location}"); // Field location asli
      } else {
        print("⚠️ Data Museum Kosong");
      }
    } catch (e) {
      print("❌ Error: $e");
      Get.snackbar("Error", "Gagal memuat data museum");
    } finally {
      isLoading(false);
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void changeCategory(int index, String category) {
    activeTabIndex.value = index;
    selectedCategory.value = category;
  }

  Future<void> refreshData() async {
    await fetchMuseums();
  }
}
