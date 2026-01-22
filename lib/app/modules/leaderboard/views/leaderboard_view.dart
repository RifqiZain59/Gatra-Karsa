import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/leaderboard_controller.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  const LeaderboardView({super.key});

  // --- PALET WARNA PREMIUM ---
  static const Color primaryDark = Color(0xFF3E2723);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentSilver = Color(0xFFB0BEC5);
  static const Color accentBronze = Color(0xFF8D6E63);
  static const Color bgCream = Color(0xFFFDFCF8);
  static const Color textDark = Color(0xFF3E2723);

  @override
  Widget build(BuildContext context) {
    // Pastikan controller ter-inject
    if (!Get.isRegistered<LeaderboardController>()) {
      Get.put(LeaderboardController());
    }

    return Scaffold(
      backgroundColor: bgCream,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // --- 1. BACKGROUND DECORATION ---
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentGold.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryDark.withOpacity(0.05),
              ),
            ),
          ),

          // --- 2. MAIN CONTENT ---
          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryDark),
                );
              }
              if (controller.leaderboardData.isEmpty) return _buildEmptyState();

              final allData = controller.leaderboardData;
              bool showPodium =
                  allData.isNotEmpty && (allData[0]['score'] as int) > 0;

              Map<String, dynamic>? juara1 = allData.isNotEmpty
                  ? allData[0]
                  : null;
              Map<String, dynamic>? juara2 = allData.length > 1
                  ? allData[1]
                  : null;
              Map<String, dynamic>? juara3 = allData.length > 2
                  ? allData[2]
                  : null;

              List<Map<String, dynamic>> restData = allData.length > 3
                  ? allData.sublist(3)
                  : [];

              if (!showPodium) restData = allData;

              return Column(
                children: [
                  const SizedBox(height: 10),
                  // HEADER TITLE
                  Text(
                    "PAPAN PERINGKAT",
                    style: GoogleFonts.philosopher(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: primaryDark,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- PODIUM SECTION ---
                  // Menggunakan Flexible agar tidak kaku, tapi dengan min height
                  if (showPodium)
                    SizedBox(
                      height:
                          300, // PERBAIKAN: Tinggi ditambah agar elemen muat (sebelumnya 240)
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Juara 2 (Kiri)
                            Expanded(
                              child: juara2 != null
                                  ? _buildPodiumUser(
                                      name: juara2['name'],
                                      score: juara2['score'],
                                      rank: 2,
                                      color: accentSilver,
                                      avatarSize: 65, // Ukuran disesuaikan
                                      podiumHeight: 90,
                                    )
                                  : const SizedBox(),
                            ),

                            // Juara 1 (Tengah)
                            Expanded(
                              flex: 1,
                              child: juara1 != null
                                  ? _buildPodiumUser(
                                      name: juara1['name'],
                                      score: juara1['score'],
                                      rank: 1,
                                      color: accentGold,
                                      avatarSize: 85, // Ukuran disesuaikan
                                      podiumHeight: 120,
                                      isCenter: true,
                                    )
                                  : const SizedBox(),
                            ),

                            // Juara 3 (Kanan)
                            Expanded(
                              child: juara3 != null
                                  ? _buildPodiumUser(
                                      name: juara3['name'],
                                      score: juara3['score'],
                                      rank: 3,
                                      color: accentBronze,
                                      avatarSize: 65, // Ukuran disesuaikan
                                      podiumHeight: 70,
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // --- LIST SECTION (RANK 4 DST) ---
                  // Menggunakan Expanded agar mengisi sisa layar ke bawah
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Dekorasi Handle Bar (Garis kecil di atas)
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 12),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),

                          // Dekorasi Watermark
                          Positioned(
                            bottom: -20,
                            right: -20,
                            child: Icon(
                              Ionicons.trophy,
                              size: 150,
                              color: accentGold.withOpacity(0.05),
                            ),
                          ),

                          // List Content
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 25,
                            ), // Jarak untuk handle bar
                            child: restData.isEmpty && showPodium
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Ionicons.ribbon_outline,
                                          size: 40,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Belum ada pemain lain.",
                                          style: GoogleFonts.mulish(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      10,
                                      20,
                                      20,
                                    ),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: restData.length,
                                    itemBuilder: (context, index) {
                                      int actualRank = showPodium
                                          ? index + 4
                                          : index + 1;
                                      return _buildListItem(
                                        restData[index],
                                        actualRank,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: primaryDark.withOpacity(0.1), blurRadius: 20),
              ],
            ),
            child: const Icon(
              Ionicons.trophy_outline,
              size: 60,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Belum ada data peringkat",
            style: GoogleFonts.mulish(color: textDark, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- WIDGET PODIUM (Juara 1, 2, 3) ---
  Widget _buildPodiumUser({
    required String name,
    required int score,
    required int rank,
    required Color color,
    required double avatarSize,
    required double podiumHeight,
    bool isCenter = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Mahkota Juara 1
        if (rank == 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Icon(Ionicons.ribbon, color: accentGold, size: 28),
          ),

        // Avatar
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: color, width: isCenter ? 4 : 3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: GoogleFonts.philosopher(
                fontSize: avatarSize * 0.4,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Nama User
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.mulish(
              fontWeight: FontWeight.bold,
              fontSize: isCenter ? 13 : 11,
              color: textDark,
            ),
          ),
        ),

        // Skor
        Text(
          "$score pts",
          style: GoogleFonts.mulish(
            color: primaryDark.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        // Balok Podium
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: podiumHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            "$rank",
            style: GoogleFonts.philosopher(
              fontSize: isCenter ? 48 : 32,
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET LIST ITEM (Rank 4 dst) ---
  Widget _buildListItem(Map<String, dynamic> data, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgCream,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryDark.withOpacity(0.1)),
            ),
            child: Text(
              "$rank",
              style: GoogleFonts.philosopher(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),

          const SizedBox(width: 15),

          // Avatar Kecil
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accentGold.withOpacity(0.6),
                  accentGold.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              data['name'].isNotEmpty ? data['name'][0].toUpperCase() : "?",
              style: GoogleFonts.philosopher(
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
          ),

          const SizedBox(width: 15),

          // Nama & Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: GoogleFonts.mulish(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Sobat Gatrakarsa",
                  style: GoogleFonts.mulish(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Skor Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryDark,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryDark.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              "${data['score']} pts",
              style: GoogleFonts.mulish(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
