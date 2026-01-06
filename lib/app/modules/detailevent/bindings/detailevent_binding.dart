import 'package:get/get.dart';

import '../controllers/detailevent_controller.dart';

class DetaileventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetaileventController>(
      () => DetaileventController(),
    );
  }
}
