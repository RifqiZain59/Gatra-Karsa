import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import '../controllers/quiz_controller.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({super.key});

  // --- Palet Warna Premium (Earth Tone & Gold) ---
  static const Color primaryDark = Color(0xFF3E2723);
  static const Color primaryLight = Color(0xFF5D4037);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color bgLight = Color(0xFFFDFCF8); // Putih Tulang
  static const Color surfaceWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<QuizController>()) Get.put(QuizController());

    return Scaffold(
      backgroundColor: bgLight,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
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
            bottom: -50,
            right: -50,
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
          Obx(
            () => controller.isFinished.value
                ? _buildResult()
                : _buildGameBody(context),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      title: Text(
        "KUIS WAYANG",
        style: GoogleFonts.philosopher(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: primaryDark,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      // --- PERBAIKAN POSISI ICON ARROW ---
      leadingWidth: 80, // Memberikan ruang lebih untuk margin kiri
      leading: Container(
        // Margin kiri 24 disamakan dengan padding horizontal body (24)
        margin: const EdgeInsets.only(left: 24, top: 8, bottom: 8, right: 8),
        decoration: BoxDecoration(
          color: surfaceWhite,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: IconButton(
          icon: const Icon(Ionicons.chevron_back, color: primaryDark, size: 20),
          onPressed: () => Get.back(),
          padding: EdgeInsets.zero, // Memastikan icon tepat di tengah lingkaran
        ),
      ),
    );
  }

  Widget _buildGameBody(BuildContext context) {
    var q = controller.questions[controller.currentIndex.value];
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsif grid size
        double boxSize = math.min((constraints.maxWidth - 60) / 8, 50.0);

        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // --- HEADER SCORE ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildScoreHeader(),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // --- HINT CARD (Soal) ---
                      _buildHintCard(q.hint),

                      const SizedBox(height: 30),

                      // --- SLOT JAWABAN (KOTAK ISIAN) ---
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: List.generate(q.originalWord.length, (index) {
                          bool hasLetter =
                              index < controller.userIncompleteWord.length;
                          return GestureDetector(
                            onTap: hasLetter
                                ? () => controller.removeLetter(index)
                                : null,
                            child: _letterBox(
                              hasLetter
                                  ? controller.userIncompleteWord[index]
                                  : "",
                              isPlaceholder: !hasLetter,
                              size: boxSize,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 40),

                      // --- AREA KEYBOARD (PILIHAN HURUF) ---
                      // Ini adalah kotak besar yang membungkus pilihan
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryDark.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(
                                0,
                                -5,
                              ), // Shadow ke atas sedikit
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "PILIH HURUF",
                              style: GoogleFonts.mulish(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: q.scrambledLetters.asMap().entries.map((
                                entry,
                              ) {
                                bool isEmpty = entry.value == "";
                                return AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: isEmpty ? 0.0 : 1.0,
                                  child: GestureDetector(
                                    onTap: isEmpty
                                        ? null
                                        : () => controller.addLetter(
                                            entry.value,
                                            entry.key,
                                          ),
                                    child: _letterBox(
                                      entry.value,
                                      isChoice: true,
                                      size: boxSize,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // --- TOMBOL AKSI ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                child: _buildActionButtons(),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- HEADER SCORE & LEVEL ---
  Widget _buildScoreHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Level Indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryDark.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Ionicons.game_controller,
                  size: 20,
                  color: primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "LEVEL",
                    style: GoogleFonts.mulish(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    "${controller.currentIndex.value + 1}",
                    style: GoogleFonts.philosopher(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Score Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryDark, primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primaryDark.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Ionicons.star, color: accentGold, size: 16),
                const SizedBox(width: 8),
                Text(
                  "${controller.score.value} Poin",
                  style: GoogleFonts.mulish(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- KARTU HINT (SOAL) ---
  Widget _buildHintCard(String hint) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.fromLTRB(25, 40, 25, 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: accentGold.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                hint,
                textAlign: TextAlign.center,
                style: GoogleFonts.mulish(
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w700,
                  color: primaryDark,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: accentGold.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        // Badge "Petunjuk"
        Positioned(
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: accentGold,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accentGold.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Ionicons.bulb, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  "TEBAK KATA",
                  style: GoogleFonts.mulish(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- TOMBOL AKSI ---
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Tombol Reset
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => controller.resetWord(),
              child: const Icon(Ionicons.refresh, size: 24, color: primaryDark),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Tombol Cek
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.checkAnswer(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                elevation: 8,
                shadowColor: primaryDark.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Ionicons.checkmark_circle, color: accentGold),
                  const SizedBox(width: 10),
                  Text(
                    "CEK JAWABAN",
                    style: GoogleFonts.mulish(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- KOTAK HURUF ---
  Widget _letterBox(
    String letter, {
    bool isPlaceholder = false,
    bool isChoice = false,
    double size = 50,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isPlaceholder
            ? Colors.white
            : (isChoice
                  ? bgLight
                  : primaryDark), // Tombol keyboard lebih terang
        borderRadius: BorderRadius.circular(12),
        border: isPlaceholder
            ? Border.all(color: Colors.grey.withOpacity(0.3), width: 2)
            : (isChoice
                  ? Border.all(color: primaryDark.withOpacity(0.1), width: 1)
                  : null),
        boxShadow: !isPlaceholder
            ? [
                BoxShadow(
                  color: (isChoice ? Colors.black : accentGold).withOpacity(
                    0.15,
                  ),
                  blurRadius: isChoice ? 4 : 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Text(
        letter,
        style: GoogleFonts.philosopher(
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
          color: isChoice ? primaryDark : accentGold,
        ),
      ),
    );
  }

  // --- HALAMAN HASIL ---
  Widget _buildResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentGold.withOpacity(0.1),
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentGold.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Ionicons.trophy,
                    size: 60,
                    color: accentGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              "LUAR BIASA!",
              style: GoogleFonts.philosopher(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryDark,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Semua pertanyaan berhasil dijawab.",
              textAlign: TextAlign.center,
              style: GoogleFonts.mulish(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryDark.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "TOTAL SKOR",
                    style: GoogleFonts.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${controller.score.value}",
                    style: GoogleFonts.philosopher(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: accentGold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () => controller.resetQuiz(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryDark, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "MAIN LAGI",
                  style: GoogleFonts.mulish(
                    color: primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
