import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Definisi warna utama
const Color primaryLightAccent = Color(0xFFD9C19D); // Light Tan/Beige
const Color darkContrastColor = Colors.black; // Kontras Gelap (Hitam)

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool _isPasswordVisible = false;

  void _setSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: primaryLightAccent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: primaryLightAccent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _setSystemUIOverlayStyle();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primaryLightAccent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Header Text untuk Pendaftaran
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: darkContrastColor,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Register to start using our app',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: darkContrastColor,
                        ),
                      ),
                      const SizedBox(height: 40.0),

                      // ===========================================
                      // FIELD NAMA BARU
                      // ===========================================
                      TextFormField(
                        initialValue: 'Nama Lengkap',
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 20.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // ===========================================

                      // Field Email
                      TextFormField(
                        initialValue: 'www.uihut@gmail.com',
                        decoration: InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 20.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Field Password
                      TextFormField(
                        obscureText: !_isPasswordVisible,
                        initialValue: '********',
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 20.0,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // Opsi lupakan kata sandi dihapus dari halaman Register
                      // const Align(
                      //   alignment: Alignment.centerRight,
                      //   child: TextButton(
                      //     onPressed: () {},
                      //     child: Text(
                      //       'Forget Password?',
                      //       style: TextStyle(color: darkContrastColor),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 30.0),

                      // Tombol Register
                      SizedBox(
                        width: double.infinity,
                        height: 55.0,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkContrastColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text(
                            'Sign Up', // Diubah dari Sign In
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: primaryLightAccent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),

                      // Teks "Already have an account?"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'), // Diubah
                          TextButton(
                            onPressed: () {
                              // Navigasi ke halaman Login: menggunakan pushReplacementNamed agar tidak bisa kembali ke halaman Register
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/login');
                            },
                            child: const Text(
                              'Sign in', // Diubah
                              style: TextStyle(
                                color: darkContrastColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),

                      const Center(child: Text('Or register with')), // Diubah
                      const SizedBox(height: 20.0),

                      // Tombol Sign Up with Google
                      SizedBox(
                        width: double.infinity,
                        height: 55.0,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Logika pendaftaran Google
                          },
                          // Menggunakan Image.asset untuk ikon Google (Pastikan path aset Anda benar)
                          icon: Image.asset(
                            'assets/icon/google.png', // Ganti dengan path gambar Anda
                            height: 24.0, // Sesuaikan tinggi gambar
                            width: 24.0, // Sesuaikan lebar gambar
                          ),
                          label: const Text(
                            'Sign up with Google', // Diubah dari Sign in
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: darkContrastColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: primaryLightAccent,
                            side: const BorderSide(
                              color: darkContrastColor,
                              width: 2.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
