import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart'; // IMPORT FONT
import '../controllers/leaderboard_controller.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  const LeaderboardView({super.key});

  static const Color primaryDark = Color(0xFF4E342E);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentSilver = Color(0xFFB0BEC5);
  static const Color accentBronze = Color(0xFF8D6E63);
  static const Color bgCream = Color(0xFFFAFAF5);
  static const Color textDark = Color(0xFF3E2723);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LeaderboardController>())
      Get.put(LeaderboardController());
    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value)
            return const Center(
              child: CircularProgressIndicator(color: primaryDark),
            );
          if (controller.leaderboardData.isEmpty) return _buildEmptyState();

          final allData = controller.leaderboardData;
          bool showPodium =
              allData.isNotEmpty && (allData[0]['score'] as int) > 0;
          Map<String, dynamic>? juara1 = allData.isNotEmpty ? allData[0] : null;
          Map<String, dynamic>? juara2 = allData.length > 1 ? allData[1] : null;
          Map<String, dynamic>? juara3 = allData.length > 2 ? allData[2] : null;
          List<Map<String, dynamic>> restData = allData.length > 3
              ? allData.sublist(3)
              : [];
          if (!showPodium) restData = allData;

          return Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "PAPAN PERINGKAT",
                style: GoogleFonts.philosopher(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: primaryDark,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              if (showPodium)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (juara2 != null)
                          _buildPodiumUser(
                            name: juara2['name'],
                            score: juara2['score'],
                            rank: 2,
                            color: accentSilver,
                            size: 90,
                          )
                        else
                          const SizedBox(width: 90),
                        if (juara1 != null)
                          _buildPodiumUser(
                            name: juara1['name'],
                            score: juara1['score'],
                            rank: 1,
                            color: accentGold,
                            size: 110,
                            isCenter: true,
                          ),
                        if (juara3 != null)
                          _buildPodiumUser(
                            name: juara3['name'],
                            score: juara3['score'],
                            rank: 3,
                            color: accentBronze,
                            size: 90,
                          )
                        else
                          const SizedBox(width: 90),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
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
                  child: restData.isEmpty && showPodium
                      ? const Center(child: Text("Belum ada pemain lain."))
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: restData.length,
                          separatorBuilder: (ctx, i) =>
                              const Divider(color: Color(0xFFEEEEEE)),
                          itemBuilder: (context, index) =>
                              _buildListItem(restData[index]),
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Ionicons.stats_chart_outline,
            size: 80,
            color: Colors.grey,
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

  Widget _buildPodiumUser({
    required String name,
    required int score,
    required int rank,
    required Color color,
    required double size,
    bool isCenter = false,
  }) {
    double stairHeight = rank == 1
        ? 80.0
        : rank == 2
        ? 55.0
        : 35.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Icon(
              Ionicons.trophy,
              color: color,
              size: isCenter ? 30 : 24,
            ),
          ),
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
                name.isNotEmpty ? name[0].toUpperCase() : "?",
                style: GoogleFonts.philosopher(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: size + 20,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.mulish(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: textDark,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$score pts",
            style: GoogleFonts.mulish(
              color: primaryDark.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: size,
            height: stairHeight,
            decoration: BoxDecoration(
              color: color,
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
            child: Text(
              "$rank",
              style: GoogleFonts.philosopher(
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
              style: GoogleFonts.mulish(
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              data['name'],
              style: GoogleFonts.mulish(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
          Text(
            "${data['score']} pts",
            style: GoogleFonts.mulish(
              fontWeight: FontWeight.bold,
              color: primaryDark.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
