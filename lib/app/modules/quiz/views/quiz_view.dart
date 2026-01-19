import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Penting untuk SystemUiOverlayStyle
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import '../controllers/quiz_controller.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({super.key});

  // --- Palet Warna Premium ---
  static const Color primaryDark = Color(0xFF3E2723);
  static const Color primaryLight = Color(0xFF5D4037);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color bgLight = Color(0xFFF5F5F0);
  static const Color surfaceWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    // Pastikan controller ada
    if (!Get.isRegistered<QuizController>()) Get.put(QuizController());

    return Scaffold(
      backgroundColor: bgLight,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // --- PERBAIKAN DI SINI: Pasang style langsung di AppBar ---
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Android: Icon Hitam
          statusBarBrightness: Brightness.light, // iOS: Icon Hitam
        ),
        // ---------------------------------------------------------
        title: Text(
          "QUIZ WAYANG",
          style: GoogleFonts.philosopher(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: primaryDark,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: surfaceWhite.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Ionicons.chevron_back, color: primaryDark),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFEFEBE9), // Coklat sangat muda
              bgLight,
            ],
          ),
        ),
        child: Obx(
          () => controller.isFinished.value
              ? _buildResult()
              : _buildGameBody(context),
        ),
      ),
    );
  }

  Widget _buildGameBody(BuildContext context) {
    var q = controller.questions[controller.currentIndex.value];
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hitung ukuran kotak responsif
        double boxSize = math.min((constraints.maxWidth - 60) / 8, 55.0);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildScoreHeader(),
                const Spacer(flex: 1),

                // Kartu Hint dengan efek elevasi
                _buildHintCard(q.hint),

                const Spacer(flex: 2),

                // Area Jawaban (Kotak Kosong)
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
                        hasLetter ? controller.userIncompleteWord[index] : "",
                        isPlaceholder: !hasLetter,
                        size: boxSize,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                // Area Pilihan Huruf
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: q.scrambledLetters.asMap().entries.map((entry) {
                    bool isEmpty = entry.value == "";
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isEmpty ? 0.0 : 1.0,
                      child: GestureDetector(
                        onTap: isEmpty
                            ? null
                            : () =>
                                  controller.addLetter(entry.value, entry.key),
                        child: _letterBox(
                          entry.value,
                          isChoice: true,
                          size: boxSize,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const Spacer(flex: 3),
                _buildActionButtons(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: surfaceWhite,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentGold.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Ionicons.trophy, size: 80, color: accentGold),
            ),
            const SizedBox(height: 30),
            Text(
              "LUAR BIASA!",
              style: GoogleFonts.philosopher(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryDark,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Kamu berhasil menyelesaikan kuis ini.",
              textAlign: TextAlign.center,
              style: GoogleFonts.mulish(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    "SKOR AKHIR",
                    style: GoogleFonts.mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "${controller.score.value}",
                    style: GoogleFonts.philosopher(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => controller.resetQuiz(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  elevation: 10,
                  shadowColor: primaryDark.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "MAIN LAGI",
                  style: GoogleFonts.mulish(
                    color: Colors.white,
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

  Widget _buildScoreHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "LEVEL",
              style: GoogleFonts.mulish(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.0,
              ),
            ),
            Text(
              "${controller.currentIndex.value + 1}",
              style: GoogleFonts.philosopher(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryDark, primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryDark.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Ionicons.star, color: accentGold, size: 18),
              const SizedBox(width: 8),
              Text(
                "${controller.score.value}",
                style: GoogleFonts.mulish(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHintCard(String hint) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.fromLTRB(25, 40, 25, 25),
          decoration: BoxDecoration(
            color: surfaceWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                  fontSize: 18,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: primaryDark,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            child: Text(
              "PETUNJUK",
              style: GoogleFonts.mulish(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: surfaceWhite,
            borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(16),
              onTap: () => controller.resetWord(),
              child: const Icon(Ionicons.refresh, size: 26, color: primaryDark),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => controller.checkAnswer(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                elevation: 8,
                shadowColor: primaryDark.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "CEK JAWABAN",
                style: GoogleFonts.mulish(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
            : (isChoice ? surfaceWhite : primaryDark),
        borderRadius: BorderRadius.circular(14),
        border: isPlaceholder
            ? Border.all(color: primaryDark.withOpacity(0.2), width: 1.5)
            : (isChoice
                  ? Border.all(color: primaryDark.withOpacity(0.2), width: 1.5)
                  : null),
        boxShadow: !isPlaceholder
            ? [
                BoxShadow(
                  color: (isChoice ? Colors.black : accentGold).withOpacity(
                    0.15,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Text(
        letter,
        style: GoogleFonts.philosopher(
          fontSize: size * 0.55,
          fontWeight: FontWeight.bold,
          color: isChoice ? primaryDark : accentGold,
        ),
      ),
    );
  }
}
