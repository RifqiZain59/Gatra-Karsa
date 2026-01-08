import 'package:get/get.dart';

import '../controllers/riwayatlogin_controller.dart';

class RiwayatloginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatloginController>(
      () => RiwayatloginController(),
    );
  }
}
