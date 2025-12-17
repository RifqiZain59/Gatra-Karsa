import 'package:get/get.dart';

import '../controllers/detail_wayang_controller.dart';

class DetailWayangBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailWayangController>(
      () => DetailWayangController(),
    );
  }
}
