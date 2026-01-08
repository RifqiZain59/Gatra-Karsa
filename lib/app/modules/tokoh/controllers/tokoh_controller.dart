import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:get/get.dart';

class TokohController extends GetxController {
  // Instance ApiService
  final ApiService _apiService = ApiService();

  // State Variables (Observable)
  // List untuk menampung data
  var wayangList = <ContentModel>[].obs;
  var dalangList = <ContentModel>[].obs;

  // Loading indicators untuk masing-masing kategori
  var isLoadingWayang = false.obs;
  var isLoadingDalang = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Panggil data saat controller pertama kali diinisialisasi
    fetchWayangData();
    fetchDalangData();
  }

  /// Mengambil data Tokoh Wayang
  Future<void> fetchWayangData() async {
    try {
      isLoadingWayang.value = true;

      // Memanggil fungsi getTokohWayang dari ApiService
      List<ContentModel> result = await _apiService.getTokohWayang();

      // Memasukkan data ke dalam observable list
      wayangList.assignAll(result);
    } catch (e) {
      print("Error di Controller (Wayang): $e");
      Get.snackbar('Error', 'Gagal memuat data Wayang');
    } finally {
      isLoadingWayang.value = false;
    }
  }

  /// Mengambil data Tokoh Dalang
  Future<void> fetchDalangData() async {
    try {
      isLoadingDalang.value = true;

      // Memanggil fungsi getTokohDalang dari ApiService
      List<ContentModel> result = await _apiService.getTokohDalang();

      // Memasukkan data ke dalam observable list
      dalangList.assignAll(result);
    } catch (e) {
      print("Error di Controller (Dalang): $e");
      Get.snackbar('Error', 'Gagal memuat data Dalang');
    } finally {
      isLoadingDalang.value = false;
    }
  }

  // Fungsi refresh (opsional, jika ingin pull-to-refresh di UI)
  Future<void> refreshAll() async {
    await Future.wait([fetchWayangData(), fetchDalangData()]);
  }
}
