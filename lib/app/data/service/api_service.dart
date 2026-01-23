import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================
// 1. MODEL DATA (SUDAH DIPERBAIKI)
// ==========================================
class ContentModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String description;
  final String imageUrl;

  // --- FIELD BARU: LINK ---
  // Ditambahkan agar View tidak error saat memanggil artikel.link
  final String? link;

  // Variable khusus video
  final String? video_link;

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
    this.link, // <--- Tambahkan di Constructor
    this.video_link,
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
      category: data['category'] ?? 'Umum',
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',

      // --- MAPPING LINK ---
      // Mencoba membaca dari field 'link', jika tidak ada coba 'url', jika tidak ada 'website'
      // Ini untuk jaga-jaga jika nama field di database berbeda-beda
      link: data['link'] ?? data['url'] ?? data['website'],

      // Mapping Video
      video_link: data['video_link'] ?? data['video_url'],

      mapsUrl: data['maps_url'],
      phone: data['phone'],
      price: data['price'],
      time: data['time'],
      performer: data['performer'],
      location: data['location'] ?? data['address'],
      status: data['status'],
      createdAt: data['created_at'],
    );
  }
}

// ==========================================
// 2. API SERVICE
// ==========================================
class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper: Fetch & Sort Manual
  Future<List<ContentModel>> _fetchAndSort(String collectionName) async {
    try {
      // 1. Ambil data query standar (Hanya status Publish)
      QuerySnapshot snapshot = await _firestore
          .collection(collectionName)
          .where('status', isEqualTo: 'Publish')
          .get();

      // 2. Convert ke List Object
      List<ContentModel> dataList = snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();

      // 3. Sorting Manual (Terbaru di atas)
      dataList.sort((a, b) {
        var t1 = a.createdAt ?? Timestamp(0, 0);
        var t2 = b.createdAt ?? Timestamp(0, 0);
        return t2.compareTo(t1); // Descending
      });

      return dataList;
    } catch (e) {
      print("Error fetching $collectionName: $e");
      return [];
    }
  }

  // ==========================================
  // A. FUNGSI GET DATA
  // ==========================================

  Future<List<ContentModel>> getArtikel() async =>
      await _fetchAndSort('articles');

  Future<List<ContentModel>> getTokohWayang() async =>
      await _fetchAndSort('wayang');
  Future<List<ContentModel>> getTokohDalang() async =>
      await _fetchAndSort('dalang');
  Future<List<ContentModel>> getMuseums() async =>
      await _fetchAndSort('museum');
  Future<List<ContentModel>> getEvents() async => await _fetchAndSort('events');
  Future<List<ContentModel>> getVideos() async => await _fetchAndSort('video');

  // ==========================================
  // B. FUNGSI LAINNYA
  // ==========================================

  Future<void> submitUlasan({
    required String contentId,
    required String targetName,
    required String category,
    required int rating,
    required String comment,
    required String userId,
    required String userName,
  }) async {
    try {
      String photoBase64 = '';
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          final d = userDoc.data() as Map<String, dynamic>;
          photoBase64 = d['photoBase64'] ?? '';
        }
      } catch (_) {}

      await _firestore.collection('reviews').add({
        'content_id': contentId,
        'content_title': targetName,
        'type': category,
        'user_id': userId,
        'user_name': userName,
        'user_photo': photoBase64,
        'rating': rating,
        'comment': comment,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Gagal kirim ulasan: $e");
    }
  }

  Stream<QuerySnapshot> streamUlasan(String contentId) {
    return _firestore
        .collection('reviews')
        .where('content_id', isEqualTo: contentId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<void> saveLeaderboard({
    required String userId,
    required int newScore,
  }) async {
    try {
      final docRef = _firestore.collection('leaderboard').doc(userId);
      DocumentSnapshot docSnap = await docRef.get();
      int currentScore = 0;

      String userName = 'User';
      String photo = '';
      try {
        DocumentSnapshot uDoc = await _firestore
            .collection('users')
            .doc(userId)
            .get();
        if (uDoc.exists) {
          var d = uDoc.data() as Map<String, dynamic>;
          userName = d['name'] ?? d['username'] ?? 'User';
          photo = d['photoBase64'] ?? '';
        }
      } catch (_) {}

      if (docSnap.exists) {
        currentScore = (docSnap.data() as Map<String, dynamic>)['score'] ?? 0;
      }

      if (newScore > currentScore) {
        await docRef.set({
          'user_id': userId,
          'name': userName,
          'user_photo': photo,
          'score': newScore,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error leaderboard: $e");
    }
  }
}
