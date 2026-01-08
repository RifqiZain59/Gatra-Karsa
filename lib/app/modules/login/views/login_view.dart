import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../controllers/login_controller.dart';
import '../../register/views/register_view.dart';
import '../../register/bindings/register_binding.dart';
import '../../lupapassword/views/lupapassword_view.dart';

const Color primaryAccent = Color(0xFFD9C19D);
const Color darkColor = Color(0xFF4E342E);
const Color fieldFillColor = Color(0xFFF5F5F5);

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                const Text(
                  'Sugeng Rawuh',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan masuk untuk melanjutkan',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                _buildLabel('Email Address'),
                TextFormField(
                  controller: controller.emailController,
                  decoration: _inputDecoration(
                    'Masukkan email',
                    Ionicons.mail_outline,
                  ),
                ),
                const SizedBox(height: 20),

                _buildLabel('Password'),
                Obx(
                  () => TextFormField(
                    controller: controller.passwordController,
                    obscureText: controller.isObscure.value,
                    decoration:
                        _inputDecoration(
                          'Masukkan password',
                          Ionicons.lock_closed_outline,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isObscure.value
                                  ? Ionicons.eye_off_outline
                                  : Ionicons.eye_outline,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () => controller.toggleObscure(),
                          ),
                        ),
                  ),
                ),

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(() => const LupapasswordView()),
                    child: const Text(
                      'Lupa Kata Sandi?',
                      style: TextStyle(
                        color: darkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // TOMBOL LOGIN EMAIL
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          (controller.isLoading.value ||
                              controller.isGoogleLoading.value)
                          ? null
                          : () => controller.login(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: primaryAccent,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Masuk',
                              style: TextStyle(
                                color: primaryAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Atau masuk dengan",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 24),

                // TOMBOL LOGIN GOOGLE
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(
                    () => OutlinedButton.icon(
                      onPressed:
                          (controller.isLoading.value ||
                              controller.isGoogleLoading.value)
                          ? null
                          : () => controller.loginWithGoogle(),
                      icon: controller.isGoogleLoading.value
                          ? const SizedBox.shrink()
                          : const Icon(
                              Ionicons.logo_google,
                              color: Colors.red,
                              size: 20,
                            ),
                      label: controller.isGoogleLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          : const Text(
                              "Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? "),
                    GestureDetector(
                      onTap: () => Get.to(
                        () => const RegisterView(),
                        binding: RegisterBinding(),
                      ),
                      child: const Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          color: darkColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: darkColor,
        fontSize: 14,
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: fieldFillColor,
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkColor, width: 1.5),
        ),
      );
}
