import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFA000),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A237E),
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "WAYANG PUZZLE",
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isFinished.value) {
            return _buildResult();
          } else {
            return _buildGameBody(context);
          }
        }),
      ),
    );
  }

  Widget _buildGameBody(BuildContext context) {
    var q = controller.questions[controller.currentIndex.value];
    var originalWord = q.originalWord.toUpperCase();

    return LayoutBuilder(
      builder: (context, constraints) {
        double boxSize = (constraints.maxWidth - 120) / 7;
        if (boxSize > 44) boxSize = 44;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // --- HEADER: Level & Score ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 25,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "LEVEL ${controller.currentIndex.value + 1}",
                            style: const TextStyle(
                              color: Color(0xFF1A237E),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              "★ ${controller.score.value}",
                              style: const TextStyle(
                                color: Color(0xFF1A237E),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- KARTU HINT ---
                  Container(
                    padding: const EdgeInsets.all(22),
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                    ),
                    child: Text(
                      q.hint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),

                  // SPASI LEBAR ANTARA HINT DAN SUSUNAN KATA
                  const SizedBox(height: 60),

                  // --- AREA JAWABAN (SUSUNAN KATA) ---
                  const Text(
                    "SUSUNAN KATA",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(originalWord.length, (index) {
                        if (index < controller.userIncompleteWord.length) {
                          return _letterBox(
                            controller.userIncompleteWord[index],
                            isSelected: true,
                            size: boxSize,
                          );
                        }
                        return _letterBox(
                          "",
                          isPlaceholder: true,
                          size: boxSize,
                        );
                      }),
                    ),
                  ),

                  // SPASI SANGAT LEBAR ANTARA SUSUNAN KATA DAN PILIH HURUF
                  const SizedBox(height: 80),

                  // --- AREA PILIHAN HURUF ---
                  const Text(
                    "PILIH HURUF",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: q.scrambledLetters.asMap().entries.map((entry) {
                        bool isEmpty = entry.value == "";
                        return Opacity(
                          opacity: isEmpty ? 0.0 : 1.0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: isEmpty
                                ? null
                                : () => controller.addLetter(
                                    entry.value,
                                    entry.key,
                                  ),
                            child: _letterBox(entry.value, size: boxSize),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // SPASI LEBAR SEBELUM TOMBOL SUBMIT
                  const SizedBox(height: 60),

                  const Spacer(),

                  // --- TOMBOL AKSI ---
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget pendukung (_letterBox, _buildActionButtons, _buildResult) tetap sama
  Widget _letterBox(
    String letter, {
    bool isSelected = false,
    bool isPlaceholder = false,
    double size = 45,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size + 6,
      decoration: BoxDecoration(
        color: isPlaceholder
            ? Colors.black.withOpacity(0.12)
            : (isSelected ? const Color(0xFF1A237E) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isPlaceholder
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => controller.resetWord(),
              icon: const Icon(
                Icons.history_rounded,
                size: 30,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.checkAnswer(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
              ),
              child: const Text(
                "SUBMIT JAWABAN",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, size: 130, color: Color(0xFF1A237E)),
          const SizedBox(height: 20),
          const Text(
            "LUAR BIASA!",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "SKOR AKHIR: ${controller.score.value}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 60),
          ElevatedButton.icon(
            onPressed: () => controller.resetQuiz(),
            icon: const Icon(Icons.replay),
            label: const Text("MAIN LAGI"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
