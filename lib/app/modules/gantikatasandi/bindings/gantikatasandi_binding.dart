import 'package:get/get.dart';

import '../controllers/gantikatasandi_controller.dart';

class GantikatasandiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GantikatasandiController>(
      () => GantikatasandiController(),
    );
  }
}
