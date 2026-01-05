import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:math' as math;
import '../controllers/quiz_controller.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({super.key});

  // --- PALET WARNA TEMA WAYANG ---
  static const Color primaryDark = Color(0xFF4E342E);
  static const Color primaryLight = Color(0xFF8D6E63);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color bgCream = Color(0xFFFAFAF5);
  static const Color textDark = Color(0xFF3E2723);
  static const Color errorRed = Color(0xFFC62828); // Warna Merah Wayang

  @override
  Widget build(BuildContext context) {
    Get.put(QuizController());

    return Scaffold(
      backgroundColor: bgCream,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "QUIZ WAYANG",
          style: TextStyle(
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: primaryDark,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.chevron_back, color: primaryDark),
          onPressed: () => Get.back(),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Obx(() {
        if (controller.isFinished.value) {
          return _buildResult();
        } else {
          return _buildGameBody(context);
        }
      }),
    );
  }

  Widget _buildGameBody(BuildContext context) {
    if (controller.questions.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: primaryDark));
    }

    var q = controller.questions[controller.currentIndex.value];
    var originalWord = q.originalWord.toUpperCase();

    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        int itemsPerRow = originalWord.length > 7 ? originalWord.length : 7;
        double boxSize = (availableWidth - 60) / itemsPerRow;

        if (boxSize < 34) boxSize = 34;
        if (boxSize > 50) boxSize = 50;

        return Stack(
          fit: StackFit.expand,
          children: [
            // --- BACKGROUND DAUN ---
            ..._buildDistributedLeaves(constraints),

            // --- KONTEN UTAMA ---
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Column(
                  children: [
                    _buildHeader(),

                    const Spacer(flex: 1),

                    // KARTU SOAL (HINT)
                    _buildHintCard(q.hint),

                    const Spacer(flex: 2),

                    // AREA GAME
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "JAWABAN",
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: primaryDark.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 5),

                        // SLOT JAWABAN USER
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(originalWord.length, (index) {
                            if (index < controller.userIncompleteWord.length) {
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  controller.removeLetter(index);
                                },
                                child: _letterBox(
                                  controller.userIncompleteWord[index],
                                  isFilled: true,
                                  size: boxSize,
                                ),
                              );
                            }
                            return _letterBox(
                              "",
                              isPlaceholder: true,
                              size: boxSize,
                            );
                          }),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          "PILIH TULISAN",
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: primaryDark.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 5),

                        // PILIHAN HURUF
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: q.scrambledLetters.asMap().entries.map((
                            entry,
                          ) {
                            bool isEmpty = entry.value == "";
                            return Opacity(
                              opacity: isEmpty ? 0.0 : 1.0,
                              child: GestureDetector(
                                onTap: isEmpty
                                    ? null
                                    : () {
                                        HapticFeedback.lightImpact();
                                        controller.addLetter(
                                          entry.value,
                                          entry.key,
                                        );
                                      },
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

                    const Spacer(flex: 2),

                    // TOMBOL AKSI
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- LOGIKA UTAMA TOMBOL & DIALOG ---

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Tombol Reset
        InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            controller.resetWord();
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: primaryDark.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: primaryDark.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Ionicons.refresh, color: primaryDark),
          ),
        ),
        const SizedBox(width: 16),

        // Tombol KUNCI JAWABAN
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();

                // 1. Ambil Data
                var currentQuestion =
                    controller.questions[controller.currentIndex.value];
                String correctAnswer = currentQuestion.originalWord
                    .replaceAll(" ", "")
                    .toUpperCase();
                String userAnswer = controller.userIncompleteWord
                    .join("")
                    .toUpperCase();

                // 2. Validasi Lokal (Tanpa memanggil controller dulu)
                if (userAnswer == correctAnswer) {
                  // Jika BENAR -> Pop Up Hijau
                  _showSuccessDialog();
                } else {
                  // Jika SALAH -> Pop Up Merah
                  _showFailureDialog();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: primaryDark.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "KUNCI JAWABAN",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- DIALOG POP UP MENGAMBANG (BENAR) ---
  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: bgCream,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Centang
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Ionicons.checkmark_outline,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "BENAR!",
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Jawaban Anda tepat sekali.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: primaryDark.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 25),

              // Tombol Lanjut
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Tutup Dialog
                    controller.checkAnswer(); // Panggil Logic Pindah Level
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: Colors.green.withOpacity(0.4),
                  ),
                  child: const Text(
                    "LANJUT LEVEL",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // --- DIALOG POP UP MENGAMBANG (SALAH) ---
  void _showFailureDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: bgCream,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Silang
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: errorRed, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: errorRed.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Ionicons.close_outline,
                  color: errorRed,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "KURANG TEPAT",
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: errorRed,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Susunan aksara belum sesuai.\nSilakan coba lagi.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: primaryDark.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 25),

              // Tombol Coba Lagi
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Hanya tutup dialog, jangan panggil controller
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: errorRed.withOpacity(0.4),
                  ),
                  child: const Text(
                    "COBA LAGI",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET PENDUKUNG UI (DAUN, HEADER, BOX) ---

  List<Widget> _buildDistributedLeaves(BoxConstraints constraints) {
    final List<Widget> leaves = [];
    final random = math.Random(42);
    const double cellSize = 90.0;
    int cols = (constraints.maxWidth / cellSize).ceil();
    int rows = (constraints.maxHeight / cellSize).ceil();

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        if (random.nextDouble() > 0.5) {
          double size = 30 + random.nextDouble() * 30;
          double offsetX = random.nextDouble() * (cellSize - size);
          double offsetY = random.nextDouble() * (cellSize - size);
          double left = (x * cellSize) + offsetX;
          double top = (y * cellSize) + offsetY;
          double rotation = random.nextDouble() * 2 * math.pi;
          double opacity = 0.03 + random.nextDouble() * 0.05;
          IconData iconData = random.nextBool()
              ? Ionicons.leaf
              : Ionicons.leaf_outline;

          leaves.add(
            Positioned(
              left: left,
              top: top,
              child: Transform.rotate(
                angle: rotation,
                child: Icon(
                  iconData,
                  size: size,
                  color: primaryDark.withOpacity(opacity),
                ),
              ),
            ),
          );
        }
      }
    }
    return leaves;
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "LEVEL ${controller.currentIndex.value + 1}",
              style: const TextStyle(
                fontFamily: 'Serif',
                color: primaryDark,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: accentGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: primaryDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Ionicons.star, size: 14, color: accentGold),
              const SizedBox(width: 6),
              Text(
                "${controller.score.value}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHintCard(String hintText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: primaryDark.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const Icon(Ionicons.bulb_outline, color: accentGold, size: 28),
          const SizedBox(height: 8),
          Text(
            hintText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textDark,
              height: 1.3,
              fontFamily: 'Serif',
            ),
          ),
        ],
      ),
    );
  }

  Widget _letterBox(
    String letter, {
    bool isFilled = false,
    bool isPlaceholder = false,
    bool isChoice = false,
    double size = 45,
  }) {
    if (isPlaceholder) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: primaryDark.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: primaryDark.withOpacity(0.15),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isChoice ? Colors.white : primaryDark,
        borderRadius: BorderRadius.circular(12),
        border: isChoice
            ? Border.all(color: primaryDark.withOpacity(0.2), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(isChoice ? 0.05 : 0.3),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: 'Serif',
          fontSize: size * 0.55,
          fontWeight: FontWeight.bold,
          color: isChoice ? textDark : accentGold,
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: accentGold.withOpacity(0.3), blurRadius: 40),
                ],
              ),
              child: const Icon(Ionicons.trophy, size: 80, color: accentGold),
            ),
            const SizedBox(height: 40),
            const Text(
              "LUAR BIASA!",
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryDark,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Tantangan terselesaikan.",
              style: TextStyle(
                fontSize: 16,
                color: primaryDark.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: primaryDark.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "SKOR AKHIR: ${controller.score.value}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton.icon(
              onPressed: () => controller.resetQuiz(),
              icon: const Icon(Ionicons.play),
              label: const Text("LEVEL SELANJUTNYA"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
