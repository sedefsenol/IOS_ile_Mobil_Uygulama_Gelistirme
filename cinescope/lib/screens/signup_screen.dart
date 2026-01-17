import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final isimCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final passAgainCtrl = TextEditingController();

  bool loading = false;
  String mesaj = "";

  final String registerUrl =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev/api/kullanici";

  Future<void> kayitOl() async {
    setState(() {
      loading = true;
      mesaj = "";
    });

    if (isimCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        userCtrl.text.trim().isEmpty ||
        passCtrl.text.trim().isEmpty ||
        passAgainCtrl.text.trim().isEmpty) {
      setState(() {
        mesaj = "Lütfen tüm alanları doldurun.";
        loading = false;
      });
      return;
    }

    if (passCtrl.text != passAgainCtrl.text) {
      setState(() {
        mesaj = "Şifreler uyuşmuyor.";
        loading = false;
      });
      return;
    }

    try {
      final res = await http.post(
        Uri.parse(registerUrl),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "Isim": isimCtrl.text.trim(),
          "Email": emailCtrl.text.trim(),
          "KullaniciAdi": userCtrl.text.trim(),
          "Sifre": passCtrl.text.trim(),
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      } else {
        setState(() {
          mesaj = "Kayıt sırasında hata oluştu.";
        });
      }
    } catch (_) {
      setState(() {
        mesaj = "Sunucuya bağlanılamadı.";
      });
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: const Color(0xFF262626),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3A3A3A)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "CineScope Kayıt Ol",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFB3D9),
                  ),
                ),

                const SizedBox(height: 20),

                if (mesaj.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      mesaj,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),

                _input(isimCtrl, "İsim Soyisim"),
                const SizedBox(height: 12),
                _input(emailCtrl, "Email"),
                const SizedBox(height: 12),
                _input(userCtrl, "Kullanıcı Adı"),
                const SizedBox(height: 12),
                _input(passCtrl, "Şifre", obscure: true),
                const SizedBox(height: 12),
                _input(passAgainCtrl, "Şifre Tekrar", obscure: true),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: loading ? null : kayitOl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB3D9),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        loading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                            : const Text(
                              "Kayıt Ol",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Zaten hesabın var mı?",
                      style: TextStyle(color: Color(0xFF9A9A9A)),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Giriş Yap",
                        style: TextStyle(
                          color: Color(0xFFFFB3D9),
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

  Widget _input(
    TextEditingController ctrl,
    String hint, {
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9A9A9A)),
        filled: true,
        fillColor: const Color(0xFF1F1F1F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
      ),
    );
  }
}
