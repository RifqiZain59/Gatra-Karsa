import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';
import '../../onboarding/views/onboarding_view.dart';
// 1. IMPORT Binding yang baru dibuat
import '../../onboarding/bindings/onboarding_binding.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    const splashColor = Color(0xFFD9C19D);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: splashColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: splashColor,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 5), () {
        // 2. Tambahkan parameter 'binding' di sini
        Get.off(
          () => const OnboardingView(),
          binding: OnboardingBinding(), // Inisialisasi Controller
        );
      });
    });

    return Scaffold(
      backgroundColor: splashColor,
      body: Align(
        alignment: const Alignment(0.0, -0.85),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset('assets/Dalang.png', width: 500, height: 500)],
        ),
      ),
    );
  }
}
