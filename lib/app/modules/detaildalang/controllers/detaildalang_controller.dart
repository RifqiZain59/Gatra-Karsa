import 'package:gatrakarsa/app/data/service/api_service.dart';
import 'package:get/get.dart';

class DetaildalangController extends GetxController {
  // Menggunakan 'late' karena data pasti diinisialisasi di onInit
  // Pastikan model di api_service.dart sudah memiliki field 'location'
  late ContentModel dalang;

  @override
  void onInit() {
    super.onInit();

    // Mengambil data yang dikirimkan melalui Get.to(..., arguments: item)
    if (Get.arguments != null && Get.arguments is ContentModel) {
      dalang = Get.arguments as ContentModel;
    } else {
      // Jika terjadi kesalahan navigasi (argumen kosong),
      // kita buat objek kosong agar aplikasi tidak crash saat mencoba membaca 'dalang'
      dalang = ContentModel(
        id: '',
        title: 'Data Tidak Tersedia',
        subtitle: '',
        category: '',
        description: 'Gagal memuat detail data.',
        imageUrl: '',
        location: '-', // Sesuai permintaan untuk kotak asal daerah
      );

      // Memberikan pesan error di console untuk debugging
      print(
        "Error: DetaildalangController tidak menerima Get.arguments yang valid.",
      );
    }
  }
}
