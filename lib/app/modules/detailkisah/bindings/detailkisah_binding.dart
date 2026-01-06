import 'package:get/get.dart';

import '../controllers/detailkisah_controller.dart';

class DetailkisahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailkisahController>(
      () => DetailkisahController(),
    );
  }
}
