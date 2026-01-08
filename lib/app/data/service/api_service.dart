import 'package:cloud_firestore/cloud_firestore.dart';

// Model data yang disesuaikan dengan skema Firestore di app.py
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
  final String? location; // Digunakan untuk 'Asal Daerah' di Detail Dalang
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
      location: data['location'], // Mengambil field 'location' dari Firestore
      status: data['status'],
      createdAt: data['created_at'],
    );
  }
}

class ApiService {
  // Nama koleksi disesuaikan dengan COLLECTION_NAME di app.py
  final CollectionReference _adminCollection = FirebaseFirestore.instance
      .collection('admin');

  /// Mengambil data Tokoh Dalang
  /// Logika filter menggunakan daftar kategori yang ada di app.py
  Future<List<ContentModel>> getTokohDalang() async {
    List<String> kategoriDalang = [
      'Dalang',
      'Maestro',
      'Legend',
      'Senior',
      'Profesional',
      'Dalang Muda',
    ];

    try {
      // Query Firestore sesuai dengan route '/tokoh-dalang' di app.py
      QuerySnapshot snapshot = await _adminCollection
          .where('category', whereIn: kategoriDalang)
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

  /// Mengambil data Tokoh Wayang
  /// Logika filter menggunakan daftar kategori wayang di app.py
  Future<List<ContentModel>> getTokohWayang() async {
    List<String> wayangCats = [
      'Wayang Kulit',
      'Wayang Golek',
      'Wayang Orang',
      'Wayang Klithik',
      'Wayang Beber',
      'Lainnya',
    ];

    try {
      QuerySnapshot snapshot = await _adminCollection
          .where('category', whereIn: wayangCats)
          .where('status', isEqualTo: 'Publish')
          .get();

      // Filter tambahan di client-side untuk memastikan murni data wayang (tanpa maps/time)
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
}
