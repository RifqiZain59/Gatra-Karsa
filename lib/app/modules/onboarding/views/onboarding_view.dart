import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';

// Warna yang diambil dari LoginView & SplashView
const Color primaryAccent = Color(0xFFD9C19D); // Beige/Tan (Warna Identitas)
const Color darkColor = Colors.black; // Hitam (Kontras)
const Color patternColor = Color(
  0xFF4E342E,
); // Coklat Tua (Untuk Motif Batik & Icon)

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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. BACKGROUND PATTERN (Batik Lingkaran)
          Positioned.fill(
            child: CustomPaint(
              painter: BatikPatternPainter(
                color: patternColor.withOpacity(0.05),
              ),
            ),
          ),

          // 2. KONTEN UTAMA
          SafeArea(
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

                      // --- PILIH ICON BERDASARKAN HALAMAN ---
                      // Mengganti gambar aset dengan Icon yang sesuai tema
                      IconData pageIcon;
                      if (index == 0) {
                        pageIcon =
                            Icons.theater_comedy; // Halaman 1: Wayang/Budaya
                      } else if (index == 1) {
                        pageIcon = Icons
                            .center_focus_strong; // Halaman 2: Deteksi/Kamera
                      } else {
                        pageIcon =
                            Icons.history_edu; // Halaman 3: Edukasi/Sejarah
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ILUSTRASI ICON DENGAN BACKGROUND LINGKARAN
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // Warna solid untuk menutupi pola batik di belakang
                                  color: Color.alphaBlend(
                                    primaryAccent.withOpacity(0.2),
                                    Colors.white,
                                  ),
                                ),
                                padding: const EdgeInsets.all(
                                  40,
                                ), // Padding diperbesar agar icon proporsional
                                child: FittedBox(
                                  // Agar icon menyesuaikan ukuran container
                                  child: Icon(
                                    pageIcon,
                                    color: patternColor, // Warna Coklat Tua
                                  ),
                                ),
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
                                color: Colors.black87,
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
                              // Jika aktif: Panjang 24, warna Hitam
                              width: controller.selectedPageIndex.value == index
                                  ? 24
                                  : 8,
                              decoration: BoxDecoration(
                                color:
                                    controller.selectedPageIndex.value == index
                                    ? darkColor
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Tombol Next / Start (ICON SAJA)
                      ElevatedButton(
                        onPressed: controller.forwardAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkColor, // Background Hitam
                          foregroundColor: primaryAccent, // Icon Beige
                          shape: const CircleBorder(), // BENTUK BULAT
                          padding: const EdgeInsets.all(20), // Ukuran tombol
                        ),
                        child: Obx(() {
                          final isLastPage =
                              controller.selectedPageIndex.value ==
                              controller.onboardingPages.length - 1;

                          return Icon(
                            isLastPage ? Icons.check : Icons.arrow_forward,
                            size: 28,
                            color: primaryAccent,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Class Painter untuk Pola Batik (Lingkaran)
class BatikPatternPainter extends CustomPainter {
  final Color color;
  BatikPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    double circleRadius = 30;
    double gap = circleRadius * 1.5;

    for (double y = 0; y < size.height + circleRadius; y += gap) {
      for (double x = 0; x < size.width + circleRadius; x += gap) {
        canvas.drawCircle(Offset(x, y), circleRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
