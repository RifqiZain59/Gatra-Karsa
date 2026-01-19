import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gatrakarsa/app/data/service/api_service.dart';

class TokohController extends GetxController {
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data List
  var wayangList = <ContentModel>[].obs;
  var dalangList = <ContentModel>[].obs;

  // Loading States
  var isLoadingWayang = true.obs;
  var isLoadingDalang = true.obs;

  // --- TAMBAHAN: LIST ID YANG DI-LIKE ---
  var favoriteIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWayang();
    fetchDalang();

    // Panggil fungsi pemantau favorit
    listenToFavorites();
  }

  // --- LOGIKA MENGAMBIL DAFTAR FAVORIT (REALTIME) ---
  void listenToFavorites() {
    User? user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .snapshots()
          .listen((snapshot) {
            // Ambil semua ID dokumen yang ada di koleksi favorites
            favoriteIds.value = snapshot.docs.map((doc) => doc.id).toList();
          });
    } else {
      favoriteIds.clear();
    }
  }

  void fetchWayang() async {
    isLoadingWayang.value = true;
    try {
      var data = await _apiService.getTokohWayang();
      wayangList.assignAll(data);
    } finally {
      isLoadingWayang.value = false;
    }
  }

  void fetchDalang() async {
    isLoadingDalang.value = true;
    try {
      var data = await _apiService.getTokohDalang();
      dalangList.assignAll(data);
    } finally {
      isLoadingDalang.value = false;
    }
  }
}
