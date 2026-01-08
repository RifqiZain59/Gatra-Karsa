import 'package:get/get.dart';

import '../controllers/ketentuanpemakaian_controller.dart';

class KetentuanpemakaianBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KetentuanpemakaianController>(
      () => KetentuanpemakaianController(),
    );
  }
}
