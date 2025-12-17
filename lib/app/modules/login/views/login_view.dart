import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color primaryLightAccent = Color(0xFFD9C19D); // Light Tan/Beige
const Color darkContrastColor = Colors.black; // Kontras Gelap (Hitam)

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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

  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
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
                      const Text(
                        'Sign in now',
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: darkContrastColor,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Please sign in to continue our app',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: darkContrastColor,
                        ),
                      ),
                      const SizedBox(height: 40.0),

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

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forget Password?',
                            style: TextStyle(color: darkContrastColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

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
                            'Sign In',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: primaryLightAccent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),

                      // ===============================================
                      // Bagian yang dimodifikasi untuk navigasi "Sign up"
                      // ===============================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            // Panggil fungsi navigasi di sini
                            onPressed: _navigateToRegister,
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                color: darkContrastColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ===============================================
                      const SizedBox(height: 10.0),

                      const Center(child: Text('Or connect with')),
                      const SizedBox(height: 20.0),

                      // ===========================================
                      // PERUBAHAN: Menggunakan Image.asset untuk ikon Google
                      // ===========================================
                      SizedBox(
                        width: double.infinity,
                        height: 55.0,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Logika login Google
                          },
                          // Mengganti FaIcon dengan Image.asset
                          icon: Image.asset(
                            'assets/icon/google.png', // Ganti dengan path gambar Anda
                            height: 24.0, // Sesuaikan tinggi gambar
                            width: 24.0, // Sesuaikan lebar gambar
                          ),
                          label: const Text(
                            'Sign in with Google',
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
