import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// Ganti import ini sesuai path controller Anda
import '../controllers/deteksi_controller.dart';

// --- KONSTANTA WARNA TEMA WAYANG ---
class WayangColors {
  static const Color primaryDark = Color(0xFF4E342E); // Coklat Tua
  static const Color primaryLight = Color(0xFF8D6E63); // Coklat Muda
  static const Color goldAccent = Color(0xFFD4AF37); // Emas
  static const Color background = Color(0xFFFAFAF5); // Cream/Kertas Tua
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF3E2723);
}

class DeteksiView extends StatelessWidget {
  const DeteksiView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi Controller
    final DeteksiController controller = Get.put(DeteksiController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WayangColors.background,
      appBar: AppBar(
        // --- PERUBAHAN DI SINI: MENGHAPUS ICON PANAH ---
        automaticallyImplyLeading: false, // Memastikan tidak ada panah otomatis
        // leading: ... (Bagian ini sudah dihapus)
        title: const Text(
          'Deteksi Wayang',
          style: TextStyle(
            color: WayangColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Hiasan kecil di pojok kanan atas
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.theater_comedy,
              color: WayangColors.primaryDark.withOpacity(0.5),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. LATAR BELAKANG BERPOLA
          Positioned.fill(child: CustomPaint(painter: BatikPatternPainter())),

          // 2. KONTEN UTAMA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Text Header Kecil
                  Text(
                    "Unggah foto wayang untuk\nmengidentifikasi tokohnya",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Serif',
                      color: WayangColors.textPrimary.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // AREA GAMBAR
                  Expanded(flex: 3, child: _buildImagePickerArea(controller)),

                  const SizedBox(height: 30),

                  // TOMBOL AKSI
                  _buildActionButton(context, controller),

                  const Spacer(),

                  // STATUS KARTU
                  _buildStatusCard(controller),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerArea(DeteksiController controller) {
    return GestureDetector(
      onTap: () => _showPickerOptions(controller),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: WayangColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: WayangColors.goldAccent.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: WayangColors.primaryDark.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gambar Utama
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Obx(() {
                if (controller.imageFile.value != null) {
                  return Image.file(
                    controller.imageFile.value!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: WayangColors.background,
                            border: Border.all(
                              color: WayangColors.goldAccent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            size: 40,
                            color: WayangColors.primaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Ketuk Area Ini",
                          style: TextStyle(
                            color: WayangColors.primaryLight,
                            fontFamily: 'Serif',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Ambil Foto / Galeri",
                          style: TextStyle(
                            color: WayangColors.primaryLight.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }),
            ),

            // Frame Dekoratif (Pojok Emas)
            IgnorePointer(
              child: CustomPaint(
                size: const Size(double.infinity, double.infinity),
                painter: FramePainter(),
              ),
            ),

            // LOADING OVERLAY
            Obx(
              () => controller.isAnalyzing.value
                  ? Container(
                      decoration: BoxDecoration(
                        color: WayangColors.primaryDark.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: WayangColors.goldAccent,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Sedang Menganalisis...",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Serif',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickerOptions(DeteksiController controller) {
    if (controller.isAnalyzing.value) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: WayangColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Sumber Gambar",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                color: WayangColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildOptionButton(
                    icon: Icons.photo_library_outlined,
                    label: "Galeri",
                    onTap: () {
                      Get.back();
                      controller.pickImage(ImageSource.gallery);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOptionButton(
                    icon: Icons.camera_alt_outlined,
                    label: "Kamera",
                    onTap: () {
                      Get.back();
                      controller.pickImage(ImageSource.camera);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: WayangColors.primaryLight.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
          color: WayangColors.background,
        ),
        child: Column(
          children: [
            Icon(icon, color: WayangColors.primaryDark, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: WayangColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    DeteksiController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(() {
        bool isEnabled =
            controller.imageFile.value != null && !controller.isAnalyzing.value;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isEnabled
                ? const LinearGradient(
                    colors: [
                      WayangColors.primaryDark,
                      WayangColors.primaryLight,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: WayangColors.primaryDark.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton.icon(
            onPressed: isEnabled
                ? () async {
                    await controller.runDetection();
                    if (controller.wayangName.value.isNotEmpty) {
                      _showResultSheet(context, controller);
                    }
                  }
                : null,
            icon: const Icon(Icons.search, color: Colors.white),
            label: Text(
              controller.imageFile.value == null
                  ? "Pilih Gambar Terlebih Dahulu"
                  : "IDENTIFIKASI WAYANG",
              style: const TextStyle(
                fontFamily: 'Serif',
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(DeteksiController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Obx(
            () => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: controller.imageFile.value == null
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                controller.imageFile.value == null
                    ? Icons.priority_high
                    : Icons.check,
                color: controller.imageFile.value == null
                    ? Colors.orange
                    : Colors.green,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Status Sistem",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    controller.imageFile.value == null
                        ? "Menunggu input gambar..."
                        : "Gambar siap diproses.",
                    style: const TextStyle(
                      color: WayangColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultSheet(BuildContext context, DeteksiController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WayangColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: WayangColors.goldAccent, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 30, spreadRadius: 5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Sheet dengan motif
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: WayangColors.primaryDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Text(
                "HASIL DETEKSI",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: WayangColors.goldAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontFamily: 'Serif',
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: WayangColors.goldAccent,
                        width: 2,
                      ),
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.person_search_outlined,
                      color: WayangColors.primaryDark,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Obx(
                    () => Column(
                      children: [
                        Text(
                          controller.wayangName.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: WayangColors.textPrimary,
                            fontFamily: 'Serif',
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: WayangColors.goldAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Kecocokan: ${(controller.confidence.value * 100).toStringAsFixed(1)}%",
                            style: const TextStyle(
                              color: WayangColors.primaryDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(
                          height: 30,
                          color: WayangColors.primaryLight,
                        ),
                        Text(
                          controller.wayangHistory.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: WayangColors.textPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WayangColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Tutup",
                        style: TextStyle(
                          color: WayangColors.goldAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

// --- PAINTERS (TETAP SAMA SEPERTI SEBELUMNYA) ---

class FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WayangColors.goldAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintThin = Paint()
      ..color = WayangColors.goldAccent.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const l = 40.0; // Panjang siku
    const r = 20.0; // Jarak dari tepi

    // Pojok Kiri Atas
    canvas.drawLine(const Offset(r, r), const Offset(r + l, r), paint);
    canvas.drawLine(const Offset(r, r), const Offset(r, r + l), paint);
    canvas.drawLine(
      const Offset(r + 5, r + 5),
      const Offset(r + l - 5, r + 5),
      paintThin,
    );
    canvas.drawLine(
      const Offset(r + 5, r + 5),
      const Offset(r + 5, r + l - 5),
      paintThin,
    );

    // Pojok Kanan Atas
    canvas.drawLine(
      Offset(size.width - r, r),
      Offset(size.width - r - l, r),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - r, r),
      Offset(size.width - r, r + l),
      paint,
    );

    // Pojok Kiri Bawah
    canvas.drawLine(
      Offset(r, size.height - r),
      Offset(r + l, size.height - r),
      paint,
    );
    canvas.drawLine(
      Offset(r, size.height - r),
      Offset(r, size.height - r - l),
      paint,
    );

    // Pojok Kanan Bawah
    canvas.drawLine(
      Offset(size.width - r, size.height - r),
      Offset(size.width - r - l, size.height - r),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - r, size.height - r),
      Offset(size.width - r, size.height - r - l),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

class BatikPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WayangColors.primaryDark.withOpacity(0.05)
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
  bool shouldRepaint(CustomPainter old) => false;
}
