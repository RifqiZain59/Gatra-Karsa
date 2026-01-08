import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../controllers/register_controller.dart';

const Color primaryAccent = Color(0xFFD9C19D);
const Color darkColor = Color(0xFF4E342E);
const Color fieldFillColor = Color(0xFFF5F5F5);

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RegisterController>()) {
      Get.put(RegisterController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: darkColor),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Daftar untuk mulai menjelajah dunia wayang!',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40.0),

                    // Nama Lengkap
                    _buildLabel('Nama Lengkap'),
                    TextFormField(
                      controller: controller.nameController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        'Masukkan nama lengkap',
                        Ionicons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Email
                    _buildLabel('Alamat Email'),
                    TextFormField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        'Masukkan email',
                        Ionicons.mail_outline,
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Password
                    _buildLabel('Kata Sandi'),
                    TextFormField(
                      controller: controller.passwordController,
                      obscureText: true,
                      decoration: _inputDecoration(
                        'Buat kata sandi',
                        Ionicons.lock_closed_outline,
                      ),
                    ),
                    const SizedBox(height: 40.0),

                    // Tombol Daftar
                    SizedBox(
                      width: double.infinity,
                      height: 55.0,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.register(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkColor,
                            foregroundColor: primaryAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: primaryAccent,
                                )
                              : const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Footer Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              color: darkColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: darkColor,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
      filled: true,
      fillColor: fieldFillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: darkColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
    );
  }
}
