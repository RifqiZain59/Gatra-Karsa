import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart'; // Sesuaikan import ini

class VideoController extends GetxController {
  // Inisialisasi Service
  final ApiService _apiService = ApiService();

  // State Variables
  var isLoading = true.obs;
  var videoList = <ContentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVideos(); // Ambil data saat controller dibuat
  }

  /// Fungsi utama mengambil data video dari API Service
  Future<void> fetchVideos() async {
    try {
      isLoading.value = true;

      // Memanggil fungsi getVideos() yang sudah kita update logikanya
      // (Filter otomatis: 'video', 'dokumenter', atau punya videoUrl)
      final videos = await _apiService.getVideos();

      if (videos.isNotEmpty) {
        videoList.assignAll(videos);
      } else {
        videoList.clear();
      }
    } catch (e) {
      print("Error fetching videos: $e");
      // Opsional: Tampilkan snackbar error jika perlu
    } finally {
      isLoading.value = false;
    }
  }

  /// Fungsi untuk Pull-to-Refresh
  Future<void> refreshData() async {
    await fetchVideos();
  }
}
