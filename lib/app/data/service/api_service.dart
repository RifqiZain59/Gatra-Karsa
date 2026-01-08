import 'package:cloud_firestore/cloud_firestore.dart';

// --- MODEL DATA ---
class ContentModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String description;
  final String imageUrl;
  final String? videoUrl;
  final String? mapsUrl;
  final String? phone;
  final String? price;
  final String? time;
  final String? performer;
  final String? location; // Field Lokasi
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
      // PASTIKAN field ini sesuai dengan di database ('location' atau 'address' atau 'alamat')
      // Jika di database namanya 'address', ganti jadi data['address']
      location: data['location'] ?? data['address'] ?? data['alamat'],
      status: data['status'],
      createdAt: data['created_at'],
    );
  }
}

// --- API SERVICE ---
class ApiService {
  final CollectionReference _adminCollection = FirebaseFirestore.instance
      .collection('admin');

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

  final List<String> _nonKisahCats = [
    'Dalang',
    'Maestro',
    'Legend',
    'Senior',
    'Profesional',
    'Dalang Muda',
    'Wayang Kulit',
    'Wayang Golek',
    'Wayang Orang',
    'Wayang Klithik',
    'Wayang Beber',
    'Lainnya',
    'Event',
    'Agenda',
    'Jadwal',
    'Video',
    'Museum',
    'Galeri',
  ];

  /// 1. GET TOKOH DALANG
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

  /// 2. GET TOKOH WAYANG
  Future<List<ContentModel>> getTokohWayang() async {
    try {
      QuerySnapshot snapshot = await _adminCollection
          .where('category', whereIn: _wayangCats)
          .where('status', isEqualTo: 'Publish')
          .get();

      return snapshot.docs.map((doc) => ContentModel.fromFirestore(doc)).where((
        item,
      ) {
        bool hasMaps = item.mapsUrl != null && item.mapsUrl!.isNotEmpty;
        bool hasTime = item.time != null && item.time!.isNotEmpty;
        return !hasMaps && !hasTime;
      }).toList();
    } catch (e) {
      print("Error fetching Wayang: $e");
      return [];
    }
  }

  /// 3. GET MUSEUM (Logic Sesuai app.py)
  Future<List<ContentModel>> getMuseums() async {
    try {
      QuerySnapshot snapshot = await _adminCollection
          .where('status', isEqualTo: 'Publish')
          .get();

      List<ContentModel> allData = snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();

      return allData.where((item) {
        // Logic: Ada maps_url ATAU (ada price TAPI tidak ada performer & time)
        bool hasMaps = item.mapsUrl != null && item.mapsUrl!.isNotEmpty;
        bool hasPrice = item.price != null && item.price!.isNotEmpty;
        bool hasPerformer =
            item.performer != null && item.performer!.isNotEmpty;
        bool hasTime = item.time != null && item.time!.isNotEmpty;

        return hasMaps || (hasPrice && !hasPerformer && !hasTime);
      }).toList();
    } catch (e) {
      print("Error fetching Museums: $e");
      return [];
    }
  }

  /// 4. GET EVENTS
  Future<List<ContentModel>> getEvents() async {
    try {
      QuerySnapshot snapshot = await _adminCollection
          .where('status', isEqualTo: 'Publish')
          .get();

      List<ContentModel> allData = snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();

      return allData.where((item) {
        bool isDalangOrWayang =
            _dalangCats.contains(item.category) ||
            _wayangCats.contains(item.category);
        if (isDalangOrWayang) return false;

        bool hasPerformer =
            item.performer != null && item.performer!.isNotEmpty;
        bool hasTime = item.time != null && item.time!.isNotEmpty;

        return hasPerformer || hasTime;
      }).toList();
    } catch (e) {
      print("Error fetching Events: $e");
      return [];
    }
  }

  /// 5. GET KISAH
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
        bool hasPhone = item.phone != null && item.phone!.isNotEmpty;

        return !isExcluded && !hasMaps && !hasTime && !hasPhone;
      }).toList();
    } catch (e) {
      print("Error fetching Kisah: $e");
      return [];
    }
  }
}
