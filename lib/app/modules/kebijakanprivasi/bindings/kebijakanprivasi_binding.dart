import 'package:get/get.dart';

import '../controllers/kebijakanprivasi_controller.dart';

class KebijakanprivasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KebijakanprivasiController>(
      () => KebijakanprivasiController(),
    );
  }
}
