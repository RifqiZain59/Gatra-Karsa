import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart'; // Import package Ionicons

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengubah warna hex menjadi objek Color Flutter
    final Color backgroundColor = const Color(0xFFD9C19D); // #D9C19D

    // Warna untuk ikon Navigation Bar bawaan HP (sesuaikan dengan Brightness.light)
    final Brightness systemIconBrightness = Brightness.dark;

    // Pengaturan tema dasar aplikasi
    return MaterialApp(
      title: 'Profile',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: Colors.white,
        hintColor: Colors.grey[600],
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: Colors.grey[900],
          ), // Teks utama lebih gelap
          titleMedium: TextStyle(color: Colors.grey[900]),
          headlineSmall: TextStyle(color: Colors.grey[900]),
        ),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.grey[800]),
          actionsIconTheme: IconThemeData(color: Colors.grey[800]),
          titleTextStyle: TextStyle(
            color: Colors.grey[900], // Warna judul AppBar
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: backgroundColor,
            systemNavigationBarIconBrightness: systemIconBrightness,
            statusBarIconBrightness: systemIconBrightness,
            statusBarColor: backgroundColor,
          ),
        ),
      ),
      home: const CustomerProfileScreen(),
    );
  }
}

// -------------------------------------------------------------

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        // --- PERUBAHAN DI SINI ---
        // Menghapus 'leading' (yang berisi tombol panah kembali)
        // agar tidak ada ikon di sebelah kiri 'Profile'.
        // leading: IconButton(
        //   icon: const Icon(
        //     Ionicons.arrow_back_outline,
        //   ),
        //   onPressed: () {
        //     // Aksi kembali
        //   },
        // ),

        // Menambahkan properti ini untuk memastikan Flutter tidak
        // secara otomatis menambahkan tombol kembali.
        automaticallyImplyLeading: false,

        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildProfileHeader(context),
            const SizedBox(height: 16.0),
            _buildSectionTitle('Gatra Karsa', context),
            _buildSettingsList(context),
            const SizedBox(height: 16.0),
            _buildSectionTitle('Support', context),
            _buildSupportList(context),
            const SizedBox(height: 16.0),
            _buildSectionTitle('Actions', context),
            _buildLogoutSection(),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membangun Header Profil
  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: <Widget>[
          // Avatar Pengguna
          CircleAvatar(
            radius: 24,
            // Jika Anda tidak punya aset 'assets/profile_pic.png', gunakan saja Child Icon
            // backgroundImage: const AssetImage('assets/profile_pic.png'),
            child: Icon(
              Ionicons.person_circle_outline, // Ikon profil yang lebih menonjol
              size: 40, // Ukuran diperbesar agar terlihat seperti avatar
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(width: 16.0),
          // Detail Nama dan Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Alex Richards',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  'alex.Richards@***ple.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          // Tombol Edit
          IconButton(
            icon: Icon(
              Ionicons.create_outline, // Ikon edit
              size: 20,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              // Aksi edit profil
            },
          ),
        ],
      ),
    );
  }

  // Fungsi pembangun untuk judul bagian
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  // FUNGSI PENGATURAN
  Widget _buildSettingsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: <Widget>[
          // ITEM: Tentang Kami
          const ProfileListItem(
            icon: Ionicons.information_circle_outline,
            text: 'Tentang Kami',
            isGrouped: true,
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[200],
          ),
          // ITEM: History Login
          const ProfileListItem(
            icon: Ionicons.time_outline,
            text: 'History Login',
            isGrouped: true,
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[200],
          ),
          // Item: Ketentuan Pemakaian
          const ProfileListItem(
            icon: Ionicons.reader_outline,
            text: 'Ketentuan Pemakaian',
            isGrouped: true,
          ),
        ],
      ),
    );
  }

  // Fungsi pembangun untuk Daftar Dukungan (Support)
  Widget _buildSupportList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: <Widget>[
          // Item: Customer Service WhatsApp
          const ProfileListItem(
            icon: Ionicons.logo_whatsapp,
            text: 'Customer Service WhatsApp',
            isGrouped: true,
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[200],
          ),
          // Item: Help dan FAQ
          const ProfileListItem(
            icon: Ionicons.help_circle_outline,
            text: 'Help dan FAQ',
            isGrouped: true,
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[200],
          ),
          // Item: Pusat Bantuan
          const ProfileListItem(
            icon: Ionicons.headset_outline,
            text: 'Pusat Bantuan',
            isGrouped: true,
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[200],
          ),
          // Item: Lapor Masalah
          const ProfileListItem(
            icon: Ionicons.mail_outline,
            text: 'Lapor Masalah',
            isGrouped: true,
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[200],
          ),
          // Item: Kebijakan Privasi
          const ProfileListItem(
            icon: Ionicons.shield_checkmark_outline,
            text: 'Kebijakan Privasi',
            isGrouped: true,
          ),
        ],
      ),
    );
  }

  // FUNGSI Bagian Logout
  Widget _buildLogoutSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const ProfileListItem(
        // Ikon keluar
        icon: Ionicons.log_out_outline,
        text: 'Logout',
        isGrouped: false,
      ),
    );
  }
}

// -------------------------------------------------------------

// Widget kustom untuk setiap item dalam daftar
class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isGrouped;

  const ProfileListItem({
    super.key,
    required this.icon,
    required this.text,
    this.isGrouped = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Aksi ketika item diklik
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Anda mengklik: $text')));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration:
            const BoxDecoration(), // Menghapus dekorasi yang tidak perlu di sini
        child: Row(
          children: <Widget>[
            // Ikon Ionicons
            Icon(icon, size: 24, color: Theme.of(context).hintColor),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            // Ikon panah ke kanan
            Icon(
              Ionicons.chevron_forward_outline,
              size: 16,
              color: Theme.of(context).hintColor,
            ),
          ],
        ),
      ),
    );
  }
}
