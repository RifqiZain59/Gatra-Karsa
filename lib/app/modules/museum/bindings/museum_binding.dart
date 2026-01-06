import 'package:get/get.dart';

import '../controllers/museum_controller.dart';

class MuseumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MuseumController>(
      () => MuseumController(),
    );
  }
}
