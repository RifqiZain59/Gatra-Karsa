import 'package:get/get.dart';

import '../controllers/detaildalang_controller.dart';

class DetaildalangBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetaildalangController>(
      () => DetaildalangController(),
    );
  }
}
