import 'package:gatrakarsa/app/modules/detail_wayang/views/detail_wayang_view.dart';
import 'package:get/get.dart';

class DetailWayangController extends GetxController {
  void openARView(String modelPath) {
    // Navigasi ke halaman AR dengan membawa path model 3D
    Get.to(() => const DetailWayangView(), arguments: modelPath);
  }
}
