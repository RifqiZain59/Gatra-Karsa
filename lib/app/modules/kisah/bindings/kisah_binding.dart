import 'package:get/get.dart';

import '../controllers/kisah_controller.dart';

class KisahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KisahController>(
      () => KisahController(),
    );
  }
}
