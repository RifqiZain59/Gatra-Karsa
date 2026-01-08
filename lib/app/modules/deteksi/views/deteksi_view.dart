import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// --- KONSTANTA WARNA ---
const Color _faceDetectionBackground = Colors.white;
const Color _primaryGreen = Color(0xFF00C853);
const Color _darkText = Color(0xFF212121);
const Color _customBackground = Color(0xFFD9C19D);
const Color _navBarColor = Color(0xFF1E2135);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const DeteksiView());
}

class DeteksiView extends StatelessWidget {
  const DeteksiView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // MENGUBAH FONT GLOBAL MENJADI SERIF
      theme: ThemeData(fontFamily: 'Serif'),
      home: const FaceDetectionScreen(),
    );
  }
}

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;

  Future<void> _openGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _processImage() async {
    if (_imageFile == null) return;

    setState(() => _isAnalyzing = true);

    // Simulasi loading selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // LOGIKA OTOMATIS: Hapus gambar tepat sebelum pop-up muncul
    setState(() {
      _isAnalyzing = false;
      _imageFile = null; // GAMBAR DIHAPUS DI SINI
    });

    if (mounted) {
      _showResultSheet();
    }
  }

  void _showResultSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Icon(Icons.check_circle, color: _primaryGreen, size: 70),
            const SizedBox(height: 16),
            const Text(
              "Deteksi Selesai!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif', // Font disamakan
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Karakter: Gatotkaca\nJenis: Wayang Kulit Purwa",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                fontFamily: 'Serif', // Font disamakan
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navBarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Tutup",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif', // Font disamakan
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _customBackground,
      appBar: AppBar(
        title: const Text(
          'Deteksi Gambar Wayang',
          style: TextStyle(
            color: _darkText,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif', // Font disamakan
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Tombol Back agar bisa kembali ke HomeView
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildImagePickerArea(),
            const SizedBox(height: 30),
            _buildActionButton(),
            const Spacer(),
            _buildStatusCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerArea() {
    return GestureDetector(
      onTap: _isAnalyzing ? null : _openGallery,
      child: AspectRatio(
        aspectRatio: 1 / 1.1,
        child: Container(
          decoration: BoxDecoration(
            color: _faceDetectionBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Pilih Gambar dari Galeri",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Serif', // Font disamakan
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              CustomPaint(
                size: const Size(double.infinity, double.infinity),
                painter: FramePainter(),
              ),
              if (_isAnalyzing)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: _primaryGreen),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    bool isEnabled = _imageFile != null && !_isAnalyzing;
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? _processImage : null,
        icon: const Icon(Icons.analytics_outlined),
        label: Text(
          _imageFile == null ? "Belum Ada Gambar" : "Mulai Deteksi",
          style: const TextStyle(
            fontFamily: 'Serif', // Font disamakan
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _navBarColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            _imageFile == null
                ? Icons.info_outline
                : Icons.check_circle_outline,
            color: _imageFile == null ? Colors.orange : _primaryGreen,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              _imageFile == null
                  ? "Masukkan foto wayang untuk memulai proses identifikasi."
                  : "Gambar siap dianalisis.",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontFamily: 'Serif', // Font disamakan
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    const l = 30.0;
    const r = 20.0;
    canvas.drawLine(const Offset(r, r), const Offset(r + l, r), paint);
    canvas.drawLine(const Offset(r, r), const Offset(r, r + l), paint);
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
