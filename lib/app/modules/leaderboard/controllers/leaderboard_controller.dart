import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class LeaderboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State Variables
  var leaderboardData = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _bindLeaderboardStream();
  }

  // Mengambil data secara realtime (Stream)
  void _bindLeaderboardStream() {
    isLoading.value = true;

    _firestore
        .collection('leaderboard')
        .orderBy('score', descending: true) // Urutkan dari skor tertinggi
        .limit(50) // Batasi 50 besar agar performa tetap ringan
        .snapshots()
        .listen(
          (snapshot) {
            List<Map<String, dynamic>> tempList = [];

            // Proses data dari snapshot dengan index (untuk ranking)
            for (var i = 0; i < snapshot.docs.length; i++) {
              var doc = snapshot.docs[i];
              var data = doc.data();

              tempList.add({
                'id': doc.id,
                'name': data['name'] ?? 'Tanpa Nama',
                'score': data['score'] ?? 0,
                'photoUrl': data['photoUrl'] ?? '', // Jika ada foto profil
                'rank': i + 1, // Ranking berdasarkan urutan
              });
            }

            leaderboardData.assignAll(tempList);
            isLoading.value = false;
          },
          onError: (error) {
            print("Error fetching leaderboard: $error");
            isLoading.value = false;
          },
        );
  }
}
