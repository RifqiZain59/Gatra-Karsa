import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================
// 1. MODEL DATA (CONTENT MODEL)
// ==========================================
class ContentModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String description;
  final String imageUrl;
  final String? videoUrl; // Link YouTube
  final String? mapsUrl;
  final String? phone;
  final String? price;
  final String? time;
  final String? performer;
  final String? location;
  final String? status;
  final Timestamp? createdAt;

  ContentModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.videoUrl,
    this.mapsUrl,
    this.phone,
    this.price,
    this.time,
    this.performer,
    this.location,
    this.status,
    this.createdAt,
  });

  factory ContentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ContentModel(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
      videoUrl: data['video_url'],
      mapsUrl: data['maps_url'],
      phone: data['phone'],
      price: data['price'],
      time: data['time'],
      performer: data['performer'],
      location: data['location'] ?? data['address'] ?? data['alamat'],
      status: data['status'],
      createdAt: data['created_at'],
    );
  }
}

// ==========================================
// 2. API SERVICE
// ==========================================
class ApiService {
  // Referensi ke Koleksi Utama 'admin'
  final CollectionReference _adminCollection = FirebaseFirestore.instance
      .collection('admin');

  // Referensi ke Koleksi Users (untuk mengambil data photoBase64)
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  // --- LIST KATEGORI ---
  final List<String> _dalangCats = [
    'Dalang',
    'Maestro',
    'Legend',
    'Senior',
    'Profesional',
    'Dalang Muda',
  ];

  final List<String> _wayangCats = [
    'Wayang Kulit',
    'Wayang Golek',
    'Wayang Orang',
    'Wayang Klithik',
    'Wayang Beber',
    'Lainnya',
  ];

  final List<String> _eventCats = [
    'Event',
    'Agenda',
    'Jadwal',
    'Pertunjukan',
    'Festival',
  ];

  final List<String> _museumCats = [
    'Museum',
    'Galeri',
    'Cagar Budaya',
    'Sanggar',
    'Tempat',
  ];

  List<String> get _nonKisahCats => [
    ..._dalangCats,
    ..._wayangCats,
    ..._eventCats,
    ..._museumCats,
    'Video',
  ];

  // ==========================================
  // A. FUNGSI PENGAMBILAN KONTEN (GET)
  // ==========================================

  /// 1. GET VIDEO
  Future<List<ContentModel>> getVideos() async {
    try {
      QuerySnapshot snapshot = await _adminCollection
          .where('status', isEqualTo: 'Publish')
          .get();
      List<ContentModel> allData = snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();
      return allData.where((item) {
        final cat = item.category.toLowerCase().trim();
        final hasVideoUrl = item.videoUrl != null && item.videoUrl!.isNotEmpty;
        return cat.contains('video') ||
            cat.contains('dokumenter') ||
            hasVideoUrl;
      }).toList();
    } catch (e) {
      print("Error fetching Videos: $e");
      return [];
    }
  }

  /// 2. GET TOKOH DALANG
  Future<List<ContentModel>> getTokohDalang() async {
    try {
      QuerySnapshot snapshot = await _adminCollection
          .where('category', whereIn: _dalangCats)
          .where('status', isEqualTo: 'Publish')
          .get();
      return snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching Dalang: $e");
      return [];
    }
  }

  /// 3. GET TOKOH WAYANG
  Future<List<ContentModel>> getTokohWayang() async {
    try {
      QuerySnapshot snapshot = await _adminCollection
          .where('category', whereIn: _wayangCats)
          .where('status', isEqualTo: 'Publish')
          .get();
      return snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching Wayang: $e");
      return [];
    }
  }

  /// 4. GET MUSEUM
  Future<List<ContentModel>> getMuseums() async {
    try {
      QuerySnapshot snapshot = await _adminCollection
          .where('status', isEqualTo: 'Publish')
          .get();
      List<ContentModel> allData = snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();
      return allData.where((item) {
        final cat = item.category;
        bool isMuseumCat = _museumCats.contains(cat);
        bool hasLocation = item.mapsUrl != null && item.mapsUrl!.isNotEmpty;
        bool isEvent =
            _eventCats.contains(cat) ||
            (item.time != null && item.time!.isNotEmpty) ||
            (item.performer != null && item.performer!.isNotEmpty);
        return isMuseumCat || (hasLocation && !isEvent);
      }).toList();
    } catch (e) {
      print("Error fetching Museums: $e");
      return [];
    }
  }

  /// 5. GET EVENTS
  Future<List<ContentModel>> getEvents() async {
    try {
      QuerySnapshot snapshot = await _adminCollection
          .where('status', isEqualTo: 'Publish')
          .get();
      List<ContentModel> allData = snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();
      return allData.where((item) {
        final cat = item.category;
        bool isEventCat = _eventCats.contains(cat);
        bool hasEventProps =
            (item.time != null && item.time!.isNotEmpty) ||
            (item.performer != null && item.performer!.isNotEmpty);
        return isEventCat || hasEventProps;
      }).toList();
    } catch (e) {
      print("Error fetching Events: $e");
      return [];
    }
  }

  /// 6. GET KISAH
  Future<List<ContentModel>> getKisah() async {
    try {
      QuerySnapshot snapshot = await _adminCollection
          .where('status', isEqualTo: 'Publish')
          .get();
      return snapshot.docs.map((doc) => ContentModel.fromFirestore(doc)).where((
        item,
      ) {
        bool isExcluded = _nonKisahCats.contains(item.category);
        bool hasMaps = item.mapsUrl != null && item.mapsUrl!.isNotEmpty;
        bool hasTime = item.time != null && item.time!.isNotEmpty;
        bool hasPerformer =
            item.performer != null && item.performer!.isNotEmpty;
        return !isExcluded && !hasMaps && !hasTime && !hasPerformer;
      }).toList();
    } catch (e) {
      print("Error fetching Kisah: $e");
      return [];
    }
  }

  // ==========================================
  // B. FUNGSI ULASAN (AMBIL DARI USERS COLLECTION)
  // ==========================================

  Future<void> submitUlasan({
    required String contentId,
    required String targetName,
    required String category,
    required String subtitle,
    // imageUrl DIHAPUS DARI SINI
    required int rating,
    required String comment,
    required String userId,
    required String userName,
  }) async {
    try {
      // 1. Ambil Data Foto User (Base64) dari Koleksi Users
      String photoBase64 = '';
      try {
        DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          photoBase64 = userData['photoBase64'] ?? '';
        }
      } catch (e) {
        print("Gagal mengambil foto profil user: $e");
      }

      // 2. Simpan Ulasan ke Sub-collection: admin/{id}/ulasan
      await _adminCollection.doc(contentId).collection('ulasan').add({
        'user_id': userId,
        'user_name': userName,

        // Foto User (Dari DB)
        'user_photo': photoBase64,

        'rating': rating,
        'comment': comment,
        'created_at': FieldValue.serverTimestamp(),

        // Data pelengkap
        'target_name': targetName,
        'category': category,
        'subtitle': subtitle,
        // 'image_url' TIDAK DISIMPAN LAGI
      });
    } catch (e) {
      throw Exception("Gagal menyimpan ulasan: $e");
    }
  }

  Stream<QuerySnapshot> streamUlasan(String contentId) {
    return _adminCollection
        .doc(contentId)
        .collection('ulasan')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<void> saveLeaderboard({
    required String userId,
    required int newScore,
  }) async {
    try {
      final DocumentReference docRef = FirebaseFirestore.instance
          .collection('leaderboard')
          .doc(userId);

      // 1. Ambil Data User (Nama & Foto) agar muncul di Leaderboard
      String userName = 'Unknown User';
      String photoBase64 = '';

      try {
        DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          userName = userData['name'] ?? userData['username'] ?? 'User';
          photoBase64 = userData['photoBase64'] ?? '';
        }
      } catch (e) {
        print("Gagal ambil data user: $e");
      }

      // 2. Cek Skor Lama (Opsional: Agar hanya update jika High Score)
      // Jika ingin selalu overwrite (misal history), langsung gunakan .set() tanpa cek
      DocumentSnapshot docSnap = await docRef.get();
      int currentHighScore = 0;

      if (docSnap.exists) {
        final data = docSnap.data() as Map<String, dynamic>;
        currentHighScore = data['score'] ?? 0;
      }

      // 3. Simpan jika skor baru lebih tinggi atau data belum ada
      if (newScore > currentHighScore || !docSnap.exists) {
        await docRef.set({
          'user_id': userId,
          'user_name': userName,
          'user_photo': photoBase64,
          'score': newScore,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print("Highscore updated: $newScore");
      } else {
        print(
          "Score $newScore tidak lebih tinggi dari $currentHighScore. Tidak disimpan.",
        );
      }
    } catch (e) {
      print("Error saving leaderboard: $e");
      rethrow;
    }
  }
}
