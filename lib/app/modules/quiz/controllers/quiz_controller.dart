import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- MODEL DATA ---
class WordQuestion {
  final String originalWord;
  final String hint;
  List<String> scrambledLetters;

  WordQuestion({required this.originalWord, required this.hint})
    : scrambledLetters = (originalWord.toUpperCase().split('')..shuffle());
}

// --- CONTROLLER ---
class QuizController extends GetxController {
  var currentIndex = 0.obs;
  var userIncompleteWord = <String>[].obs;

  // VARIABLE BARU: Untuk melacak dari kotak mana huruf itu diambil
  // Agar saat dikembalikan, dia balik ke tempat asalnya.
  var answerOriginIndices = <int>[].obs;

  var score = 0.obs;
  var isFinished = false.obs;

  // --- BANK SOAL (Sampel) ---
  var questions = <WordQuestion>[
    // --- PANDAWA ---
    WordQuestion(
      originalWord: "YUDISTIRA",
      hint: "Sulung Pandawa yang tidak pernah berbohong",
    ),
    WordQuestion(
      originalWord: "BIMASENA",
      hint: "Pandawa kedua yang memiliki kuku Pancanaka",
    ),
    WordQuestion(
      originalWord: "ARJUNA",
      hint: "Penengah Pandawa, ksatria pemanah ulung",
    ),
    WordQuestion(
      originalWord: "NAKULA",
      hint: "Saudara kembar Sadewa yang ahli merawat kuda",
    ),
    WordQuestion(
      originalWord: "SADEWA",
      hint: "Si bungsu Pandawa yang ahli ilmu perbintangan",
    ),
    WordQuestion(
      originalWord: "GATOTKACA",
      hint: "Putra Bima yang otot kawat tulang besi",
    ),
    WordQuestion(
      originalWord: "ABIMANYU",
      hint: "Putra Arjuna yang gugur di medan Baratayuda",
    ),

    // --- KURAWA ---
    WordQuestion(
      originalWord: "DURYUDANA",
      hint: "Raja tertua dari 100 bersaudara Kurawa",
    ),
    WordQuestion(
      originalWord: "SANGKUNI",
      hint: "Patih Astina yang licik dan penuh tipu daya",
    ),
    WordQuestion(
      originalWord: "KARNA",
      hint: "Raja Awangga, saudara seibu Pandawa di pihak Kurawa",
    ),

    // --- PUNAKAWAN ---
    WordQuestion(
      originalWord: "SEMAR",
      hint: "Tokoh tertua Punakawan, penjelmaan Dewa",
    ),
    WordQuestion(
      originalWord: "PETRUK",
      hint: "Punakawan yang hidungnya sangat panjang",
    ),

    // --- Tambahkan sisa soal Anda di sini ---
  ].obs;

  // --- LOGIKA UTAMA ---

  // 1. Menambahkan Huruf (Dari Bawah ke Atas)
  void addLetter(String letter, int originalIndex) {
    var currentQ = questions[currentIndex.value];

    // Cek apakah slot jawaban masih muat
    if (userIncompleteWord.length < currentQ.originalWord.length) {
      // Masukkan huruf ke jawaban
      userIncompleteWord.add(letter);

      // Simpan index asalnya (supaya nanti bisa dibalikin)
      answerOriginIndices.add(originalIndex);

      // Kosongkan kotak di bawah (tapi posisinya tetap ada, jadi "")
      currentQ.scrambledLetters[originalIndex] = "";

      // Update UI
      questions.refresh();
      userIncompleteWord.refresh();
    }
  }

  // 2. Menghapus Huruf (Dari Atas ke Bawah - Fitur Baru)
  void removeLetter(int answerIndex) {
    if (answerIndex >= userIncompleteWord.length) return;

    var currentQ = questions[currentIndex.value];

    // Ambil huruf yang mau dihapus
    String letterToRestore = userIncompleteWord[answerIndex];

    // Ambil index asalnya dari list tracking
    int originIndex = answerOriginIndices[answerIndex];

    // Kembalikan huruf ke kotak asalnya di bawah
    currentQ.scrambledLetters[originIndex] = letterToRestore;

    // Hapus dari list jawaban & list tracking
    userIncompleteWord.removeAt(answerIndex);
    answerOriginIndices.removeAt(answerIndex);

    // Update UI
    questions.refresh();
    userIncompleteWord.refresh();
  }

  // 3. Reset Jawaban Saat Ini
  void resetWord() {
    var q = questions[currentIndex.value];

    // Kosongkan jawaban user
    userIncompleteWord.clear();
    answerOriginIndices.clear();

    // Kocok ulang huruf asli untuk soal ini
    q.scrambledLetters = q.originalWord.toUpperCase().split('')..shuffle();

    questions.refresh();
  }

  // 4. Cek Jawaban (Submit)
  void checkAnswer() {
    String finalWord = userIncompleteWord.join();
    String correctWord = questions[currentIndex.value].originalWord
        .toUpperCase();

    if (finalWord == correctWord) {
      // Jika Benar
      score.value += 10;
      Get.snackbar(
        "BENAR!",
        "Jawaban kamu tepat.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.all(20),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // Delay sedikit sebelum pindah soal agar user lihat notif
      Future.delayed(const Duration(milliseconds: 1000), () {
        nextQuestion();
      });
    } else {
      // Jika Salah
      Get.snackbar(
        "SALAH",
        "Susunan kata belum tepat, coba lagi!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        icon: const Icon(Icons.error, color: Colors.white),
      );
      resetWord();
    }
  }

  // 5. Pindah ke Soal Berikutnya
  void nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
      userIncompleteWord.clear();
      answerOriginIndices.clear(); // Jangan lupa bersihkan tracking index
    } else {
      isFinished.value = true;
    }
  }

  // 6. Reset Seluruh Game (Main Lagi)
  void resetQuiz() {
    currentIndex.value = 0;
    score.value = 0;
    isFinished.value = false;
    userIncompleteWord.clear();
    answerOriginIndices.clear();

    // Kocok ulang semua soal agar hurufnya beda posisi tiap main baru
    for (var q in questions) {
      q.scrambledLetters = q.originalWord.toUpperCase().split('')..shuffle();
    }
    questions.refresh();
  }
}
