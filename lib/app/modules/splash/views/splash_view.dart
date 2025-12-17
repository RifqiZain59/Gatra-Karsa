import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import untuk SystemChrome

import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan warna hex #D9C19D (ditambahkan 0xFF di depannya)
    const splashColor = Color(0xFFD9C19D);

    // Mengatur warna bilah navigasi sistem (tombol navigasi HP)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor:
            splashColor, // Mengubah warna bilah navigasi menjadi #D9C19D
        // Mengatur ikon navigasi menjadi gelap agar kontras dengan latar belakang terang
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Logika penundaan 5 detik dan navigasi
    // Catatan: Dalam proyek GetX yang ideal, logika ini ditempatkan di 'onReady' pada SplashController.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 5), () {
        // Pindah ke rute '/home' setelah penundaan.
        // Gunakan Get.offNamed untuk mencegah kembalinya ke splash screen.
        Get.offNamed('/home');
      });
    });

    return Scaffold(
      // Mengatur warna latar belakang menjadi #D9C19D
      backgroundColor: splashColor,

      // Menghapus AppBar di sini
      body: Align(
        // Mengganti Center dengan Align
        alignment: const Alignment(
          0.0,
          -0.85,
        ), // Posisi X tetap di tengah (0.0), Posisi Y digeser lebih jauh ke atas menjadi -0.85
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Menampilkan logo di tengah
            Image.asset(
              'assets/Dalang.png', // Path disesuaikan sesuai input terakhir
              width: 500, // Ukuran disesuaikan sesuai input terakhir
              height: 500, // Ukuran disesuaikan sesuai input terakhir
            ),

            // Menghapus widget Text 'Loading...' di sini
          ],
        ),
      ),
    );
  }
}
