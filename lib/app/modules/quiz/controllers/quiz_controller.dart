import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan ini untuk Auth

// ==========================================
// 1. MODEL DATA (Tetap dalam satu file)
// ==========================================
class WordQuestion {
  final String originalWord;
  final String hint;
  List<String> scrambledLetters;

  WordQuestion({required this.originalWord, required this.hint})
    : scrambledLetters = originalWord.toUpperCase().split('')..shuffle();
}

// ==========================================
// 2. CONTROLLER
// ==========================================
class QuizController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance Auth

  // --- STATE VARIABLES ---
  var currentIndex = 0.obs;
  var userIncompleteWord = <String>[].obs;
  var answerOriginIndices = <int>[].obs;
  var score = 0.obs;
  var isFinished = false.obs;
  var isLoading = false.obs;

  // --- BANK SOAL ---
  var questions = <WordQuestion>[
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
  ].obs;

  // --- LOGIKA GAME ---

  void addLetter(String letter, int originalIndex) {
    var currentQ = questions[currentIndex.value];
    if (userIncompleteWord.length < currentQ.originalWord.length) {
      userIncompleteWord.add(letter);
      answerOriginIndices.add(originalIndex);
      currentQ.scrambledLetters[originalIndex] = "";
      questions.refresh();
      userIncompleteWord.refresh();
    }
  }

  void removeLetter(int answerIndex) {
    if (answerIndex >= userIncompleteWord.length) return;
    var currentQ = questions[currentIndex.value];
    String letterToRestore = userIncompleteWord[answerIndex];
    int originIndex = answerOriginIndices[answerIndex];

    currentQ.scrambledLetters[originIndex] = letterToRestore;
    userIncompleteWord.removeAt(answerIndex);
    answerOriginIndices.removeAt(answerIndex);

    questions.refresh();
    userIncompleteWord.refresh();
  }

  void resetWord() {
    var q = questions[currentIndex.value];
    userIncompleteWord.clear();
    answerOriginIndices.clear();
    q.scrambledLetters = q.originalWord.toUpperCase().split('')..shuffle();
    questions.refresh();
  }

  // --- LOGIKA CEK JAWABAN & SIMPAN PER SOAL ---
  void checkAnswer() async {
    String finalWord = userIncompleteWord.join();
    String correctWord = questions[currentIndex.value].originalWord
        .toUpperCase();

    if (finalWord == correctWord) {
      // 1. TAMBAH SKOR
      score.value += 10;

      // 2. LANGSUNG SIMPAN KE DATABASE (Per Soal)
      // Kita panggil fungsi simpan tanpa menunggu (await) agar UI tidak nge-freeze lama,
      // atau pakai await jika ingin memastikan tersimpan baru pindah soal.
      await saveScorePerQuestion();

      Get.snackbar(
        "BENAR!",
        "Skor tersimpan. Lanjut...",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1200),
      );

      // Delay sedikit sebelum pindah
      Future.delayed(const Duration(seconds: 1), () {
        nextQuestion();
      });
    } else {
      Get.snackbar(
        "SALAH",
        "Susunan kata belum tepat, coba lagi!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
      resetWord();
    }
  }

  // --- FUNGSI SIMPAN KE FIREBASE ---
  Future<void> saveScorePerQuestion() async {
    User? user = _auth.currentUser;
    // Jika user belum login (misal mode tamu), kita skip atau handle error
    if (user == null) {
      print("User belum login, skor tidak disimpan ke cloud.");
      return;
    }

    try {
      // Kita gunakan .doc(user.uid) agar satu user hanya punya 1 dokumen leaderboard yang terus di-update.
      // SetOptions(merge: true) memastikan data lain (misal 'name') tidak hilang jika kita hanya update skor.
      await _firestore.collection('leaderboard').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? 'Sobat Wayang', // Default name
        'email': user.email,
        'score': score.value, // UPDATE SKOR TERBARU DI SINI
        'last_level_index':
            currentIndex.value, // Simpan progress level terakhir
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("Berhasil update skor ke Firebase: ${score.value}");
    } catch (e) {
      print("Gagal menyimpan skor: $e");
    }
  }

  void nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
      userIncompleteWord.clear();
      answerOriginIndices.clear();
    } else {
      isFinished.value = true;
      // Tidak perlu sendScoreToFirebase() lagi di sini karena sudah per soal.
    }
  }

  void resetQuiz() {
    currentIndex.value = 0;
    score.value = 0;
    isFinished.value = false;
    userIncompleteWord.clear();
    answerOriginIndices.clear();

    // Reset skor di database juga jika ingin mulai dari 0 (Opsional)
    // saveScorePerQuestion();

    for (var q in questions) {
      q.scrambledLetters = q.originalWord.toUpperCase().split('')..shuffle();
    }
    questions.shuffle();
    questions.refresh();
  }
}
