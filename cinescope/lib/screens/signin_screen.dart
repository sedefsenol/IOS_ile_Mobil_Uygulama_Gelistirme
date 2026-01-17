import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;
  String hata = "";

  Future<void> login() async {
    setState(() {
      loading = true;
      hata = "";
    });

    try {
      final res = await http.post(
        Uri.parse(
          "https://unfrounced-cordia-equiponderant.ngrok-free.dev/api/kullanici/login",
        ),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "kullaniciAdi": userCtrl.text.trim(),
          "sifre": passCtrl.text.trim(),
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final int benimID = data["id"] ?? data["ID"];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(benimID: benimID)),
        );
      } else {
        setState(() {
          hata = "Kullanıcı adı veya şifre yanlış.";
        });
      }
    } catch (_) {
      setState(() {
        hata = "Sunucuya bağlanılamadı.";
      });
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F), // CineScope bg
      body: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: const Color(0xFF262626), // card
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3A3A3A)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "CineScope",
                style: TextStyle(
                  color: Color(0xFFFFB3D9),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 22),

              if (hata.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    hata,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),

              TextField(
                controller: userCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Kullanıcı Adı",
                  hintStyle: const TextStyle(color: Color(0xFF9A9A9A)),
                  filled: true,
                  fillColor: const Color(0xFF1F1F1F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Şifre",
                  hintStyle: const TextStyle(color: Color(0xFF9A9A9A)),
                  filled: true,
                  fillColor: const Color(0xFF1F1F1F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
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
                            "Giriş Yap",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Hesabın yok mu?",
                    style: TextStyle(color: Color(0xFF9A9A9A)),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      "Kayıt Ol",
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
    );
  }
}
