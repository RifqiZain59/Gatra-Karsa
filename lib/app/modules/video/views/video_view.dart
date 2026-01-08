import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart'; // Import plugin video

// --- Konfigurasi Warna Dasar ---
const Color backgroundBeige = Color(0xFFD9C19D);

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  int _activeTab = 0; // 0: Materi, 1: Jelajahi

  // Data Konten Teks (Tab Materi)
  final List<Map<String, dynamic>> materialContent = [
    {
      'title': 'Filosofi Wayang',
      'subtitle': 'Tuntunan Hidup',
      'desc':
          'Wayang melambangkan pertarungan abadi antara kebajikan dan kebatilan.',
      'color': const Color(0xFFF0E5FF),
      'music': 'Gamelan Instrumental - Klasik',
    },
  ];

  // Data Konten Video (Tab Jelajahi - Menggunakan file dari assets)
  final List<Map<String, dynamic>> exploreContent = [
    {
      'title': 'Live Performance',
      'subtitle': 'Dalang Kondang',
      'videoAsset':
          'assets/videos/wayang_video.mp4', // Ganti dengan nama file Anda
      'music': 'Gamelan Live - Malam',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final SystemUiOverlayStyle currentStyle = _activeTab == 0
        ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)
        : SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: currentStyle,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _activeTab == 0
                ? _buildReelsList(materialContent, isVideo: false)
                : _buildReelsList(exploreContent, isVideo: true),

            // Navigasi Tab Atas
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTabButton('Materi', 0),
                  const SizedBox(width: 30),
                  _buildTabButton('Jelajahi', 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    bool isActive = _activeTab == index;
    Color activeColor = _activeTab == 0 ? Colors.black : Colors.white;
    Color inactiveColor = _activeTab == 0 ? Colors.black54 : Colors.white60;

    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Serif', // Font disamakan
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 25,
              height: 2,
              color: activeColor,
            ),
        ],
      ),
    );
  }

  Widget _buildReelsList(
    List<Map<String, dynamic>> data, {
    required bool isVideo,
  }) {
    return PageView.builder(
      key: ValueKey('tab_$_activeTab'),
      scrollDirection: Axis.vertical,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return ReelsItem(
          data: data[index],
          isVideo: isVideo,
          isMaterialTab: _activeTab == 0,
        );
      },
    );
  }
}

class ReelsItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isVideo;
  final bool isMaterialTab;

  const ReelsItem({
    super.key,
    required this.data,
    required this.isVideo,
    required this.isMaterialTab,
  });

  @override
  State<ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<ReelsItem> {
  late VideoPlayerController _controller;
  bool isLiked = false;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _controller = VideoPlayerController.asset(widget.data['videoAsset'])
        ..initialize().then((_) {
          setState(() {});
          _controller.setLooping(true);
          _controller.play();
        });
    }
  }

  @override
  void dispose() {
    if (widget.isVideo) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color uiColor = widget.isMaterialTab ? Colors.black87 : Colors.white;

    return Stack(
      children: [
        // Background Konten
        widget.isVideo
            ? (_controller.value.isInitialized
                  ? SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ))
            : _buildTextLayout(),

        // Tombol Aksi Kanan
        Positioned(
          right: 15,
          bottom: 120,
          child: Column(
            children: [
              _actionIcon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                isLiked ? Colors.red : uiColor,
                '1.2k',
                () => setState(() => isLiked = !isLiked),
                uiColor,
              ),
              const SizedBox(height: 25),
              _actionIcon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                isSaved ? Colors.amber : uiColor,
                'Simpan',
                () => setState(() => isSaved = !isSaved),
                uiColor,
              ),
              const SizedBox(height: 25),
              _actionIcon(
                Icons.share,
                uiColor,
                'Bagikan',
                () => _showShareSheet(context),
                uiColor,
              ),
            ],
          ),
        ),

        // Info Footer
        Positioned(
          left: 20,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data['title'] ?? '',
                style: TextStyle(
                  color: uiColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Serif', // Font disamakan
                  shadows: widget.isMaterialTab
                      ? []
                      : [const Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.music_note, color: uiColor, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    widget.data['music'] ?? '',
                    style: TextStyle(
                      color: uiColor,
                      fontSize: 12,
                      fontFamily: 'Serif', // Font disamakan
                      shadows: widget.isMaterialTab
                          ? []
                          : [const Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextLayout() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundBeige,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.data['subtitle'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Serif', // Font disamakan
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.data['desc'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
                fontFamily: 'Serif', // Font disamakan
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(
    IconData icon,
    Color color,
    String label,
    VoidCallback onTap,
    Color labelColor,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, color: color, size: 35),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Serif', // Font disamakan
          ),
        ),
      ],
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bagikan Konten',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
                fontFamily: 'Serif', // Font disamakan
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareItem(Icons.message, 'WhatsApp', Colors.green),
                _shareItem(Icons.facebook, 'Facebook', Colors.blue),
                _shareItem(Icons.link, 'Salin Link', Colors.grey),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _shareItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontFamily: 'Serif', // Font disamakan
          ),
        ),
      ],
    );
  }
}
