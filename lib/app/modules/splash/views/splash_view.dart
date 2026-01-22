import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';
import '../../onboarding/views/onboarding_view.dart';
import '../../onboarding/bindings/onboarding_binding.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna aksen (Beige/Tan)
    const Color primaryAccent = Color(0xFFD9C19D);
    // Warna Dark (Coklat Tua) untuk pola batik
    const Color primaryDark = Color(0xFF4E342E);

    // Mengatur UI Overlay
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 5), () {
        Get.off(() => const OnboardingView(), binding: OnboardingBinding());
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      // ResizeToAvoidBottomInset false agar keyboard tidak mengganggu (jika ada)
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 0. Background Pattern (Batik Lingkaran)
          // Ditaruh paling bawah agar tertutup oleh lingkaran dekorasi
          Positioned.fill(
            child: CustomPaint(
              painter: BatikPatternPainter(
                color: primaryDark.withOpacity(0.05),
              ),
            ),
          ),

          // 1. Dekorasi Lingkaran Latar Belakang (Pojok Kanan Atas)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Solid color (Opaque) menutupi pola
                color: Color.alphaBlend(
                  primaryAccent.withOpacity(0.1),
                  Colors.white,
                ),
              ),
            ),
          ),

          // 2. Dekorasi Lingkaran Latar Belakang (Pojok Kiri Bawah)
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Solid color (Opaque) untuk menutupi pola
                color: Color.alphaBlend(
                  primaryAccent.withOpacity(0.1),
                  Colors.white,
                ),
              ),
            ),
          ),

          // 3. Konten Utama di Tengah
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gambar dengan latar belakang lingkaran
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Solid color (Opaque) agar pola tidak tembus ke area gambar utama
                    color: Color.alphaBlend(
                      primaryAccent.withOpacity(0.2),
                      Colors.white,
                    ),
                  ),
                  child: Image.asset(
                    'assets/Dalang.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                // Judul Aplikasi
                const Text(
                  'Gatra Karsa',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // 4. Loading Indicator & Versi (PERBAIKAN POSISI)
          Positioned(
            bottom: 0, // Tempelkan ke dasar layar
            left: 0,
            right: 0,
            // Gunakan SafeArea agar otomatis menyesuaikan dengan Navigasi Bar HP apapun
            child: SafeArea(
              top: false, // Bagian atas tidak perlu safe area di sini
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 20.0,
                ), // Beri jarak sedikit dari area aman
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: primaryAccent,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'V 1.0.0',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
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
