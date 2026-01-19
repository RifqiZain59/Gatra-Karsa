import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/kamera_controller.dart';

class KameraView extends GetView<KameraController> {
  const KameraView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KameraView'), centerTitle: true),
      body: const Center(
        child: Text('KameraView is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
