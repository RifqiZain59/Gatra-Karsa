import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';

class VideoController extends GetxController {
  // 1. Panggil ApiService yang sudah diperbaiki (No Index Error)
  final ApiService _apiService = ApiService();

  // State Variables
  var isLoading = true.obs;
  var videoList = <ContentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      isLoading(true);

      // Panggil fungsi spesifik untuk Video dari ApiService
      // Ini akan mengambil dari collection 'video'
      final videos = await _apiService.getVideos();

      if (videos.isNotEmpty) {
        videoList.assignAll(videos);
      } else {
        videoList.clear();
      }
    } catch (e) {
      print("Error fetching videos: $e");
      Get.snackbar("Info", "Gagal memuat data video.");
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshData() async {
    await fetchVideos();
  }
}
