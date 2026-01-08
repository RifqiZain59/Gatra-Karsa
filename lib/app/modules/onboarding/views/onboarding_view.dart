import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';

// Warna yang diambil dari LoginView & SplashView
const Color primaryAccent = Color(0xFFD9C19D); // Beige/Tan (Warna Identitas)
const Color darkColor = Colors.black; // Hitam (Kontras)

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengatur UI Overlay agar status bar menyatu dengan background putih
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white, // Nav bar putih
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent, // Status bar transparan
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white, // Menggunakan Putih (Seperti Home)
      body: SafeArea(
        child: Column(
          children: [
            // Tombol Skip
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Get.offNamed('/login'),
                child: const Text(
                  'Skip',
                  style: TextStyle(color: darkColor, fontSize: 16),
                ),
              ),
            ),

            // Konten PageView
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.updatePage,
                itemCount: controller.onboardingPages.length,
                itemBuilder: (context, index) {
                  final item = controller.onboardingPages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gambar
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              // Opsional: Menambahkan lingkaran aksen samar di belakang gambar
                              shape: BoxShape.circle,
                              color: primaryAccent.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Image.asset(item.image, fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Judul
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: darkColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Deskripsi
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors
                                .black87, // Hitam agak pudar agar nyaman dibaca
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bagian Bawah: Dots & Tombol
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indikator Titik (Dots)
                  Obx(
                    () => Row(
                      children: List.generate(
                        controller.onboardingPages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          height: 8,
                          // Jika aktif: Hitam, Jika tidak: Abu-abu/Beige Pudar
                          width: controller.selectedPageIndex.value == index
                              ? 24
                              : 8,
                          decoration: BoxDecoration(
                            color: controller.selectedPageIndex.value == index
                                ? darkColor
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tombol Next / Start
                  ElevatedButton(
                    onPressed: controller.forwardAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          darkColor, // Background Hitam (Konsisten dengan Login)
                      foregroundColor: primaryAccent, // Teks Beige
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Obx(() {
                      return Text(
                        controller.selectedPageIndex.value ==
                                controller.onboardingPages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
