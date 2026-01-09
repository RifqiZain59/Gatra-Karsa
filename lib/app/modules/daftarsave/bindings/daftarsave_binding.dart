import 'package:get/get.dart';

import '../controllers/daftarsave_controller.dart';

class DaftarsaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarsaveController>(
      () => DaftarsaveController(),
    );
  }
}
