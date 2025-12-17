import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Kelas utama widget
class TentangkamiView extends StatelessWidget {
  const TentangkamiView({super.key});

  // Ganti warna latar belakang utama menjadi PUTIH (Colors.white)
  final Color customBackgroundColor = Colors.white;

  // Ganti warna System Navigation Bar menjadi PUTIH agar serasi
  final Color systemNavColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    // Mengatur warna tombol navigasi bawaan HP menjadi PUTIH
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: systemNavColor,
        // Gunakan Brightness.dark agar ikon terlihat di latar belakang putih
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Teks konten (tidak berubah)
    const String text1 =
        "Aplikasi ini dikembangkan untuk mengenali dan memberikan informasi mendalam tentang berbagai jenis wayang. Wayang adalah seni pertunjukan tradisional Indonesia yang kaya akan filosofi dan nilai budaya, diakui sebagai Warisan Budaya Takbenda oleh UNESCO.";
    const String text2 =
        "Kami menggunakan teknologi pengenalan gambar mutakhir untuk mengidentifikasi wayang, baik itu Wayang Kulit (dari Jawa/Bali), Wayang Golek (dari Sunda), atau jenis wayang lainnya. Tujuannya adalah melestarikan warisan ini dan mempermudah akses informasi tentang tokoh, cerita, dan gaya khas setiap wayang.";
    const String text3 =
        "Impian kami adalah menjadi sumber daya utama digital bagi pecinta dan pelajar budaya Indonesia. Dengan menggabungkan teknologi modern dan kekayaan budaya, kami bertekad memberikan pengalaman belajar yang interaktif dan menyenangkan mengenai dunia wayang yang menakjubkan.";

    // Gaya teks untuk konten
    const TextStyle bodyTextStyle = TextStyle(
      fontSize: 14.0,
      height: 1.5, // Spasi baris
      color: Colors.black87,
    );

    return Scaffold(
      // Latar belakang Scaffold: PUTIH
      backgroundColor: customBackgroundColor,
      appBar: AppBar(
        // === MENJAMIN IKON PANAH DI SEBELAH KIRI (Leading) ===
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, // Ikon panah kembali yang diminta
            color: Colors.black,
          ),
          onPressed: () {
            // Logika untuk kembali ke halaman sebelumnya
            Navigator.pop(context);
          },
        ),

        // Memastikan judul berada di tengah
        centerTitle: true,

        // === TITLE HANYA BERISI TULISAN (di Tengah) ===
        title: const Text(
          "Tentang Aplikasi Wayang",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        // ===============================================
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        // Menonaktifkan properti bawaan agar leading yang kita definisikan bekerja
        automaticallyImplyLeading: false,
      ),
      // Konten utama
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- Logo Aplikasi Wayang ---
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo2.png',
                      // UKURAN GAMBAR DIPERBESAR menjadi 150
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // --- Teks Konten ---
              Text(text1, style: bodyTextStyle, textAlign: TextAlign.justify),
              const SizedBox(height: 15),
              Text(text2, style: bodyTextStyle, textAlign: TextAlign.justify),
              const SizedBox(height: 15),
              Text(text3, style: bodyTextStyle, textAlign: TextAlign.justify),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
