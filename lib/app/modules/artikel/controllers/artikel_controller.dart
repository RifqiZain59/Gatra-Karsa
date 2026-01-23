import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:get/get.dart';

class ArtikelController extends GetxController {
  final ApiService _apiService = ApiService();

  // State untuk loading dan menampung data
  var isLoading = true.obs;
  var artikelList = <ContentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchArtikel();
  }

  Future<void> fetchArtikel() async {
    try {
      isLoading(true);

      // PERBAIKAN: Memanggil getArtikel() sesuai update di ApiService
      // (Mengambil data dari collection 'articles' di Firebase)
      List<ContentModel> data = await _apiService.getArtikel();

      // Mengupdate list (baik ada data maupun kosong agar UI sinkron)
      artikelList.assignAll(data);
    } catch (e) {
      print("Error fetching artikel: $e");
      Get.snackbar("Terjadi Kesalahan", "Gagal memuat data artikel.");
    } finally {
      isLoading(false);
    }
  }

  // Fungsi untuk refresh data
  Future<void> refreshData() async {
    await fetchArtikel();
  }
}
