import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../controllers/ketentuanpemakaian_controller.dart';

class KetentuanpemakaianView extends GetView<KetentuanpemakaianController> {
  const KetentuanpemakaianView({super.key});

  // Tema Warna Gatra Karsa (Sama dengan Kebijakan Privasi)
  final Color primaryDark = const Color(0xFF4E342E);
  final Color accentGold = const Color(0xFFD4AF37);
  final Color backgroundColor = const Color(0xFFFAFAF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Ketentuan Pemakaian",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: primaryDark.withOpacity(0.1), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- HEADER SECTION (KOTAK SIKU / TEGAS) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero, // SIKU
                boxShadow: [
                  BoxShadow(
                    color: primaryDark.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Ionicons.document_text,
                      size: 40,
                      color: accentGold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Aturan & Etika Pengguna",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- CONTENT LIST (KARTU MELENGKUNG) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildPolicyItem(
                    icon: Ionicons
                        .shield_checkmark_outline, // FIX: Nama ikon yang benar
                    title: "Persetujuan Layanan",
                    desc:
                        "Dengan mengakses Gatra Karsa, Anda setuju untuk mematuhi seluruh aturan yang berlaku demi kenyamanan bersama.",
                  ),
                  _buildPolicyItem(
                    icon: Ionicons.copy_outline,
                    title: "Hak Kekayaan Intelektual",
                    desc:
                        "Seluruh konten, ilustrasi wayang, dan materi edukasi adalah milik Gatra Karsa. Dilarang menggandakan tanpa izin tertulis.",
                  ),
                  _buildPolicyItem(
                    icon: Ionicons.hand_right_outline,
                    title: "Batasan Perilaku",
                    desc:
                        "Pengguna dilarang melakukan tindakan yang merugikan sistem atau pengguna lain, termasuk upaya peretasan atau spam.",
                  ),
                  _buildPolicyItem(
                    icon: Ionicons.alert_circle_outline,
                    title: "Perubahan Ketentuan",
                    desc:
                        "Kami dapat memperbarui ketentuan ini kapan saja. Kami menyarankan Anda untuk memeriksa halaman ini secara berkala.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- CONTACT FOOTER (KARTU MELENGKUNG PREMIUM) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Perlu penjelasan lebih lanjut?",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: accentGold),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "legal@gatrakarsa.id",
                          style: TextStyle(
                            color: accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ITEM ---
  Widget _buildPolicyItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Icon(icon, color: accentGold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
