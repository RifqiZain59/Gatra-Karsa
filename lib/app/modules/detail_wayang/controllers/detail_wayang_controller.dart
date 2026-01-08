import 'package:get/get.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart'; // Pastikan import ini benar

class DetailWayangController extends GetxController {
  // Menyimpan data yang diterima dari halaman sebelumnya
  late ContentModel wayang;

  @override
  void onInit() {
    super.onInit();
    // Mengambil argumen dan memastikan tipenya ContentModel
    if (Get.arguments is ContentModel) {
      wayang = Get.arguments as ContentModel;
    } else {
      // Fallback jika data kosong/salah (opsional)
      wayang = ContentModel(
        id: '0',
        title: 'Unknown',
        subtitle: '',
        category: '',
        description: 'Data tidak ditemukan',
        imageUrl: '',
      );
    }
  }

  void openARView(String modelPath) {}
}
