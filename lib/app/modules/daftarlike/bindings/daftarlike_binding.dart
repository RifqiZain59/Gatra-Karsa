import 'package:get/get.dart';

import '../controllers/daftarlike_controller.dart';

class DaftarlikeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarlikeController>(
      () => DaftarlikeController(),
    );
  }
}
