import 'dart:convert'; // Tambahan untuk decode Base64
import 'dart:typed_data'; // Tambahan untuk tipe data Uint8List
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
// Import model Anda
import 'package:gatrakarsa/app/data/service/api_service.dart';
import '../controllers/detail_wayang_controller.dart';

class DetailWayangView extends GetView<DetailWayangController> {
  const DetailWayangView({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PENYAMAAN TEMA WARNA ---
    const Color primaryDark = Color(0xFF4E342E);
    const Color goldAccent = Color(0xFFD4AF37);
    const Color background = Color(0xFFFAFAF5);
    const Color secondaryBrown = Color(0xFF8D6E63);

    // Ambil data dari controller yang sudah di-init
    final ContentModel data = controller.wayang;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // 1. Custom App Bar dengan LIKE BUTTON
                _buildAppBarWithLike(primaryDark, goldAccent),

                const SizedBox(height: 10),

                // 2. Header Title (Akses properti object dengan titik)
                _buildHeaderTitle(data.title, primaryDark, goldAccent),

                const SizedBox(height: 20),

                // 3. 3D Canvas Card (Akses imageUrl)
                _build3DCanvas(context, data.imageUrl, primaryDark, goldAccent),

                const SizedBox(height: 25),

                // 4. Interaction Chips (Tombol AR dihapus)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHintChip(
                      Ionicons.hand_left_outline,
                      "Putar",
                      primaryDark,
                    ),
                    const SizedBox(width: 12),
                    _buildHintChip(
                      Ionicons.resize_outline,
                      "Zoom",
                      primaryDark,
                    ),
                    // Bagian Tombol AR telah dihapus dari sini
                  ],
                ),

                const SizedBox(height: 40),

                // 5. Description Panel
                _buildDescriptionPanel(
                  data.description.isNotEmpty
                      ? data.description
                      : 'Informasi mengenai tokoh ini belum tersedia.',
                  primaryDark,
                  secondaryBrown,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildAppBarWithLike(Color color, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Ionicons.chevron_back, color: color, size: 24),
          ),
          Text(
            "DETAIL WAYANG",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 2.0,
              fontFamily: 'Serif',
            ),
          ),
          IconButton(
            onPressed: () {
              Get.snackbar(
                "Disukai",
                "Tokoh ditambahkan ke favorit",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: color,
                colorText: Colors.white,
                duration: const Duration(seconds: 1),
              );
            },
            icon: Icon(Ionicons.heart_outline, color: color, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitle(String title, Color color, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.5,
              height: 1.1,
              fontFamily: 'Serif',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Divider(
                  color: color.withOpacity(0.2),
                  endIndent: 15,
                  indent: 40,
                ),
              ),
              Icon(Ionicons.star, size: 14, color: accent),
              Expanded(
                child: Divider(
                  color: color.withOpacity(0.2),
                  indent: 15,
                  endIndent: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build3DCanvas(
    BuildContext context,
    String path,
    Color primary,
    Color accent,
  ) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      height: screenHeight * 0.45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Icon(
              Ionicons.cube_outline,
              color: accent.withOpacity(0.8),
              size: 24,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            // Pass path langsung, widget akan handle logika decode
            child: ImageOneFinger360(imagePath: path),
          ),
        ],
      ),
    );
  }

  Widget _buildHintChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
              fontFamily: 'Serif',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionPanel(String desc, Color primary, Color secondary) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.fromLTRB(30, 40, 30, 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 25,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                "DESKRIPSI TOKOH",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: primary,
                  letterSpacing: 1.0,
                  fontFamily: 'Serif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            desc,
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: primary.withOpacity(0.8),
              fontWeight: FontWeight.w400,
              fontFamily: 'Serif',
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

// --- LOGIC IMAGE INTERACTION (Sudah Support Network, Asset & Base64/Bytes) ---

class ImageOneFinger360 extends StatefulWidget {
  final String imagePath;
  const ImageOneFinger360({super.key, required this.imagePath});

  @override
  State<ImageOneFinger360> createState() => _ImageOneFinger360State();
}

class _ImageOneFinger360State extends State<ImageOneFinger360> {
  double _rotationY = 0.0;
  double _rotationX = 0.0;
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;

  // Cache untuk bytes image jika hasil decode base64
  Uint8List? _decodedBytes;

  @override
  void initState() {
    super.initState();
    _tryDecodeImage();
  }

  @override
  void didUpdateWidget(covariant ImageOneFinger360 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _tryDecodeImage();
    }
  }

  // Logika Cerdas untuk Menentukan Tipe Gambar
  void _tryDecodeImage() {
    String path = widget.imagePath;
    _decodedBytes = null;

    // 1. Jika kosong atau URL atau path Asset (biasanya ada slash atau extension), skip decode
    if (path.isEmpty || path.startsWith('http') || path.startsWith('assets/')) {
      return;
    }

    // 2. Coba decode sebagai Base64
    try {
      if (path.contains(',')) {
        // Format data:image/png;base64,...
        _decodedBytes = base64Decode(path.split(',').last);
      } else {
        // Format raw base64 string
        _decodedBytes = base64Decode(path);
      }
    } catch (e) {
      // Jika gagal decode, biarkan null (akan dianggap asset biasa nanti jika tidak null)
      print("Gagal decode base64 di DetailWayang: $e");
      _decodedBytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage = widget.imagePath.startsWith('http');
    bool isMemoryImage = _decodedBytes != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (details) => _previousScale = _scale,
      onScaleUpdate: (details) {
        setState(() {
          if (details.pointerCount > 1) {
            _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
          } else {
            if (_scale > 1.1) {
              _offset += details.focalPointDelta;
            } else {
              _rotationY += details.focalPointDelta.dx * 0.01;
              _rotationX -= details.focalPointDelta.dy * 0.01;
            }
          }
        });
      },
      onDoubleTap: () {
        setState(() {
          _scale = 1.0;
          _offset = Offset.zero;
          _rotationX = 0;
          _rotationY = 0;
        });
      },
      child: Center(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale)
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rotationX)
            ..rotateY(_rotationY),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: widget.imagePath.isEmpty
                ? const Icon(
                    Icons.image_not_supported_outlined,
                    size: 50,
                    color: Colors.grey,
                  )
                : isMemoryImage
                // PRIORITAS 1: Tampilkan dari Memory (Base64/Byte)
                ? Image.memory(
                    _decodedBytes!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                      color: Colors.redAccent,
                    ),
                  )
                : isNetworkImage
                // PRIORITAS 2: Tampilkan dari URL (Firebase Storage dll)
                ? Image.network(
                    widget.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                      color: Colors.redAccent,
                    ),
                  )
                // PRIORITAS 3: Tampilkan dari Asset Lokal
                : Image.asset(
                    widget.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                      color: Colors.redAccent,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
