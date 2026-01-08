import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart'; // Pastikan path import ini sesuai

class KisahController extends GetxController {
  // 1. Inisialisasi API Service
  final ApiService _apiService = ApiService();

  // 2. Variabel Reactive (Obs)
  var isLoading = true.obs; // Untuk status loading (berputar)
  var kisahList = <ContentModel>[].obs; // List untuk menampung data kisah

  @override
  void onInit() {
    super.onInit();
    // 3. Panggil data otomatis saat halaman dibuka
    fetchKisahData();
  }

  /// Fungsi untuk mengambil data dari Firebase via ApiService
  void fetchKisahData() async {
    try {
      isLoading(true); // Mulai loading

      // Panggil getKisah() yang sudah memfilter data (bukan Event/Museum/Wayang)
      List<ContentModel> data = await _apiService.getKisah();

      // Masukkan data ke list
      kisahList.assignAll(data);
    } catch (e) {
      print("Error fetching Kisah: $e");
      Get.snackbar("Maaf", "Gagal memuat data kisah.");
    } finally {
      isLoading(false); // Selesai loading
    }
  }

  /// Fungsi Refresh (Opsional: jika ingin pakai Pull-to-Refresh)
  Future<void> refreshData() async {
    fetchKisahData();
  }
}
