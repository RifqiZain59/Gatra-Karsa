import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:ui'; // Untuk ImageFilter (Blur)
import '../controllers/verification_controller.dart';

class VerificationView extends GetView<VerificationController> {
  const VerificationView({super.key});

  // --- PALET WARNA TEMA WAYANG (Revised) ---
  final Color _primaryBrown = const Color(0xFF3E2723); // Coklat Tua Gelap
  final Color _secondaryBrown = const Color(0xFF5D4037); // Coklat Medium
  final Color _accentGold = const Color(0xFFD4AF37); // Emas Asli
  final Color _softGold = const Color(0xFFF9F1D8); // Emas Pucat (Background)
  final Color _textDark = const Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<VerificationController>()) {
      Get.put(VerificationController());
    }

    final String userEmail =
        FirebaseAuth.instance.currentUser?.email ?? "Email tidak terdeteksi";

    return Scaffold(
      backgroundColor: _softGold,
      body: Stack(
        children: [
          // 1. BACKGROUND DECORATION (Organic Blobs)
          Positioned(
            top: -100,
            left: -50,
            child: _buildBlurCircle(300, _accentGold.withOpacity(0.2)),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildBlurCircle(250, _primaryBrown.withOpacity(0.1)),
          ),

          // 2. PATTERN BATIK ABSTRAK (Garis-garis halus)
          // Menggunakan CustomPaint atau sekadar Container miring untuk estetika
          Positioned(
            top: 100,
            right: -20,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 100,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _accentGold.withOpacity(0.1),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),

          // 3. KONTEN UTAMA
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- GLASS CARD ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 40,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryBrown.withOpacity(0.1),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // ICON DENGAN GLOW EFFECT
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _accentGold.withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: _primaryBrown,
                                  child: Icon(
                                    Ionicons.mail_unread, // Ikon lebih relevan
                                    size: 40,
                                    color: _accentGold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),

                              // JUDUL DENGAN GRADASI EMAS (Text Gradient)
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [_primaryBrown, _secondaryBrown],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: const Text(
                                  'Verifikasi Akun',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color:
                                        Colors.white, // Warna dasar untuk mask
                                    fontFamily: 'Serif',
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text(
                                'Demi keamanan data wayang Anda,\nkonfirmasi identitas diperlukan.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 25),

                              // EMAIL CONTAINER (Style: Ticket/Card)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _primaryBrown.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _primaryBrown.withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Link dikirim ke:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userEmail,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 25),

                              // STATUS MESSAGE
                              Obx(
                                () => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: controller.isEmailVerified.value
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        controller.isEmailVerified.value
                                            ? Icons.check_circle
                                            : Icons.sync,
                                        size: 16,
                                        color: controller.isEmailVerified.value
                                            ? Colors.green
                                            : Colors.orange[800],
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          controller.statusMessage.value,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                controller.isEmailVerified.value
                                                ? Colors.green[800]
                                                : Colors.orange[900],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // TOMBOL UTAMA (GRADIENT BUTTON)
                              Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [_primaryBrown, _secondaryBrown],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryBrown.withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Obx(
                                  () => ElevatedButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () => controller
                                              .checkVerificationManual(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: controller.isLoading.value
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: _accentGold,
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Saya Sudah Verifikasi",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: _accentGold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                color: _accentGold,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- FOOTER SECTION ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFooterButton(
                          icon: Ionicons.refresh_outline,
                          label: "Kirim Ulang",
                          onTap: () => controller.resendVerificationEmail(),
                          isLoading: controller.isLoading.value,
                        ),
                        Container(
                          height: 20,
                          width: 1,
                          color: Colors.grey[400],
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        _buildFooterButton(
                          icon: Ionicons.log_out_outline,
                          label: "Ganti Akun",
                          onTap: () => controller.cancelVerification(),
                          isDestructive: true,
                        ),
                      ],
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

  // Widget Helper: Lingkaran Blur untuk Background
  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  // Widget Helper: Tombol Footer Minimalis
  Widget _buildFooterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Opacity(
        opacity: isLoading ? 0.5 : 1.0,
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDestructive ? Colors.red[400] : _primaryBrown,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDestructive ? Colors.red[400] : _primaryBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
