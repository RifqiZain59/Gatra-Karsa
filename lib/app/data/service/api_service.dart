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
      // Pastikan key ini sesuai dengan app.py ('video_url')
      videoUrl: data['video_url'],
      mapsUrl: data['maps_url'],
      phone: data['phone'],
      price: data['price'],
      time: data['time'],
      performer: data['performer'],
      // Prioritas field lokasi: location -> address -> alamat
      location: data['location'] ?? data['address'] ?? data['alamat'],
      status: data['status'],
      createdAt: data['created_at'],
    );
  }
}

// ==========================================
// 2. API SERVICE (SINKRONISASI APP.PY)
// ==========================================
class ApiService {
  final CollectionReference _adminCollection = FirebaseFirestore.instance
      .collection('admin');

  // --- LIST KATEGORI (HARUS SAMA DENGAN APP.PY) ---
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

  // Digunakan untuk filter Kisah (Blacklist)
  // Di app.py: NON_KISAH_CATS = ... + ['Video']
  List<String> get _nonKisahCats => [
    ..._dalangCats,
    ..._wayangCats,
    ..._eventCats,
    ..._museumCats,
    'Video',
  ];

  // --- FUNGSI PENGAMBILAN DATA ---

  /// 1. GET VIDEO (UPDATE TERBARU)
  /// Logic App.py:
  /// cat = raw_cat.lower().strip()
  /// if ('video' in cat) or ('dokumenter' in cat) or ('video_url' in data):
  Future<List<ContentModel>> getVideos() async {
    try {
      // Kita ambil semua data 'Publish' lalu filter di Dart (Client-side)
      // karena Firestore tidak bisa query 'contains string' atau 'OR' beda field dengan mudah.
      QuerySnapshot snapshot = await _adminCollection
          .where('status', isEqualTo: 'Publish')
          .get();

      List<ContentModel> allData = snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();

      return allData.where((item) {
        // Ambil kategori, ubah ke huruf kecil, hilangkan spasi
        final cat = item.category.toLowerCase().trim();

        // Cek apakah punya Link Youtube
        final hasVideoUrl = item.videoUrl != null && item.videoUrl!.isNotEmpty;

        // Logic Filter
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
  /// Logic App.py:
  /// Masuk Museum jika (Kategori Museum) ATAU (Punya Maps TAPI BUKAN Event)
  Future<List<ContentModel>> getMuseums() async {
    try {
      QuerySnapshot snapshot = await _adminCollection
          .where('status', isEqualTo: 'Publish')
          .get();

      List<ContentModel> allData = snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();

      return allData.where((item) {
        final cat = item.category; // Case sensitive sesuai list _museumCats

        bool isMuseumCat = _museumCats.contains(cat);
        bool hasLocation = item.mapsUrl != null && item.mapsUrl!.isNotEmpty;

        // Cek Event (Anti-Overlap)
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
  /// Logic App.py:
  /// Masuk Event jika (Kategori Event) ATAU (Punya Time/Performer)
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
  /// Logic App.py:
  /// BUKAN Kategori Khusus (Dalang/Wayang/Event/Museum/Video)
  /// DAN TIDAK punya ciri (Maps/Time/Performer)
  Future<List<ContentModel>> getKisah() async {
    try {
      QuerySnapshot snapshot = await _adminCollection
          .where('status', isEqualTo: 'Publish')
          .get();

      return snapshot.docs.map((doc) => ContentModel.fromFirestore(doc)).where((
        item,
      ) {
        // Cek Blacklist (Case Sensitive sesuai array di atas)
        // Note: app.py menggunakan cat.title() untuk pengecekan list,
        // tapi di sini kita anggap input admin sudah konsisten Title Case.
        // Jika ingin aman, ubah item.category.toTitleCase().
        bool isExcluded = _nonKisahCats.contains(item.category);

        // Cek Properti Terlarang
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
}
