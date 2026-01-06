import 'package:get/get.dart';

import '../controllers/detailmuseum_controller.dart';

class DetailmuseumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailmuseumController>(
      () => DetailmuseumController(),
    );
  }
}
