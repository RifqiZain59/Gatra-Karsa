import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/leaderboard_controller.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  const LeaderboardView({super.key});

  // --- PALET WARNA TEMA WAYANG ---
  static const Color primaryDark = Color(0xFF4E342E);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentSilver = Color(0xFFB0BEC5);
  static const Color accentBronze = Color(0xFF8D6E63);
  static const Color bgCream = Color(0xFFFAFAF5);
  static const Color textDark = Color(0xFF3E2723);

  @override
  Widget build(BuildContext context) {
    // --- DATA DUMMY ---
    final List<Map<String, dynamic>> mockData = [
      {'name': 'Arjuna_01', 'score': 2500, 'rank': 1},
      {'name': 'BimaSakti', 'score': 2350, 'rank': 2},
      {'name': 'GatotKaca', 'score': 2100, 'rank': 3},
      {'name': 'Srikandi_Pro', 'score': 1900, 'rank': 4},
      {'name': 'Yudistira', 'score': 1850, 'rank': 5},
      {'name': 'Nakula', 'score': 1700, 'rank': 6},
      {'name': 'Sadewa', 'score': 1650, 'rank': 7},
      {'name': 'Semar_M', 'score': 1500, 'rank': 8},
      {'name': 'Petruk_O', 'score': 1400, 'rank': 9},
      {'name': 'Gareng_99', 'score': 1200, 'rank': 10},
    ];

    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // --- JUDUL HALAMAN ---
            const Text(
              "PAPAN PERINGKAT",
              style: TextStyle(
                fontFamily: 'Serif',
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: primaryDark,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 20),

            // --- BAGIAN ATAS: PODIUM TOP 3 ---
            if (mockData.length >= 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  // CrossAxisAlignment.end PENTING agar kotak "tangga" rata bawah
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Juara 2 (Perak) - Kiri
                      _buildPodiumUser(
                        name: mockData[1]['name'],
                        score: mockData[1]['score'],
                        rank: 2,
                        color: accentSilver,
                        size: 90,
                      ),
                      // Juara 1 (Emas) - Tengah
                      _buildPodiumUser(
                        name: mockData[0]['name'],
                        score: mockData[0]['score'],
                        rank: 1,
                        color: accentGold,
                        size: 110,
                        isCenter: true, // Untuk membuatnya sedikit lebih besar
                      ),
                      // Juara 3 (Tembaga) - Kanan
                      _buildPodiumUser(
                        name: mockData[2]['name'],
                        score: mockData[2]['score'],
                        rank: 3,
                        color: accentBronze,
                        size: 90,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // --- BAGIAN BAWAH: LIST VIEW SISA ---
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: primaryDark.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    top: 20,
                    bottom: 30,
                    left: 20,
                    right: 20,
                  ),
                  itemCount: mockData.length - 3,
                  separatorBuilder: (ctx, i) =>
                      const Divider(color: Color(0xFFEEEEEE)),
                  itemBuilder: (context, index) {
                    final data = mockData[index + 3];
                    return _buildListItem(data);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PODIUM DENGAN KOTAK TANGGA ---
  Widget _buildPodiumUser({
    required String name,
    required int score,
    required int rank,
    required Color color,
    required double size,
    bool isCenter = false,
  }) {
    // Tentukan tinggi kotak tangga berdasarkan ranking
    double stairHeight;
    if (rank == 1) {
      stairHeight = 80.0; // Paling tinggi
    } else if (rank == 2) {
      stairHeight = 55.0; // Sedang
    } else {
      stairHeight = 35.0; // Paling pendek
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4), // Jarak antar podium
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 1. PIALA (Emas/Perak/Perunggu)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Icon(
              Ionicons.trophy,
              color: color,
              size: isCenter ? 30 : 24,
            ),
          ),

          // 2. AVATAR
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: color, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0] : "?",
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 3. NAMA
          SizedBox(
            width: size + 10,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: textDark,
              ),
            ),
          ),

          // 4. TOTAL POINT (BADGE KECIL)
          const SizedBox(height: 4),
          Text(
            "$score pts",
            style: TextStyle(
              color: primaryDark.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // 5. KOTAK TANGGA (PODIUM BOX) -- FITUR BARU
          Container(
            width: size, // Lebar kotak sama dengan lebar avatar
            height: stairHeight,
            decoration: BoxDecoration(
              color: color, // Warna kotak mengikuti warna juara
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            // Angka Besar di dalam kotak (1, 2, 3)
            child: Text(
              "$rank",
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: isCenter ? 32 : 24,
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET LIST ITEM ---
  Widget _buildListItem(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: bgCream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryDark.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryDark.withOpacity(0.1),
            ),
            child: Text(
              "${data['rank']}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              data['name'],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
          Text(
            "${data['score']} pts",
            style: TextStyle(
              fontFamily: 'Serif',
              fontWeight: FontWeight.bold,
              color: primaryDark.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
