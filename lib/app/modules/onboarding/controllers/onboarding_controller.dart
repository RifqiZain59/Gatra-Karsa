import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  // Page Controller untuk mengontrol PageView
  var pageController = PageController();

  // Variabel reaktif untuk melacak halaman saat ini
  var selectedPageIndex = 0.obs;

  // Data konten onboarding (Menggunakan aset yang ada di proyek Anda)
  final List<OnboardingContent> onboardingPages = [
    OnboardingContent(
      image: 'assets/Wayang Kulit.png',
      title: 'Warisan Budaya',
      description:
          'Kenali dan lestarikan seni pewayangan sebagai identitas bangsa yang tak ternilai.',
    ),
    OnboardingContent(
      image: 'assets/Wayang Madya.png',
      title: 'Kisah Penuh Makna',
      description:
          'Pelajari filosofi dan cerita mendalam di balik setiap tokoh wayang.',
    ),
    OnboardingContent(
      image: 'assets/Dalang.png',
      title: 'Gatra Karsa',
      description:
          'Jelajahi dunia pewayangan dengan cara yang interaktif dan menyenangkan.',
    ),
  ];

  // Update index saat halaman digeser
  void updatePage(int index) {
    selectedPageIndex.value = index;
  }

  // Fungsi navigasi tombol 'Next'
  void forwardAction() {
    if (selectedPageIndex.value == onboardingPages.length - 1) {
      // Jika di halaman terakhir, pindah ke Login atau Home
      Get.offNamed('/login'); // Sesuaikan rute ini
    } else {
      pageController.nextPage(duration: 300.milliseconds, curve: Curves.ease);
    }
  }
}

// Model data sederhana
class OnboardingContent {
  final String image;
  final String title;
  final String description;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}
