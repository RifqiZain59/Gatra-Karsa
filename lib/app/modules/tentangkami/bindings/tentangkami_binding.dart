import 'package:get/get.dart';

import '../controllers/tentangkami_controller.dart';

class TentangkamiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TentangkamiController>(
      () => TentangkamiController(),
    );
  }
}
