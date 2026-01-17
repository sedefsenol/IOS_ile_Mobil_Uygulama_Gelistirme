import 'dart:convert';
import 'package:cinescope/screens/kullanicisayfasi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'mesajscreen.dart';
import 'hesapscreen.dart';

class BildirimScreen extends StatefulWidget {
  final int benimID;
  const BildirimScreen({super.key, required this.benimID});

  @override
  State<BildirimScreen> createState() => _BildirimScreenState();
}

class _BildirimScreenState extends State<BildirimScreen> {
  static const String apiBase =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev";

  List bildirimler = [];
  List onerilenler = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => loading = true);
    await Future.wait([_bildirimleriGetir(), _onerilenleriGetir()]);
    setState(() => loading = false);
  }

  Future<void> _bildirimleriGetir() async {
    final res = await http.get(
      Uri.parse("$apiBase/api/bildirim/${widget.benimID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (res.statusCode == 200) {
      bildirimler = jsonDecode(res.body);
    }
  }

  Future<void> _onerilenleriGetir() async {
    final res = await http.get(
      Uri.parse("$apiBase/api/kullanici/onerilen/${widget.benimID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (res.statusCode == 200) {
      onerilenler = jsonDecode(res.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF1F1F1F),

        appBar: AppBar(
          backgroundColor: const Color(0xFF1F1F1F),
          title: const Text(
            "Aktivite",
            style: TextStyle(
              color: Color(0xFFFFB3D9),
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFB3D9),
            labelColor: Color(0xFFFFB3D9),
            unselectedLabelColor: Colors.white54,
            tabs: [Tab(text: "Bildirim"), Tab(text: "Önerilen")],
          ),
        ),

        body:
            loading
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFB3D9)),
                )
                : TabBarView(
                  children: [_bildirimListesi(), _onerilenListesi()],
                ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          backgroundColor: const Color(0xFF1F1F1F),
          selectedItemColor: const Color(0xFFFFB3D9),
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          onTap: (i) {
            if (i == 2) return;
            Widget page;
            switch (i) {
              case 0:
                page = HomeScreen(benimID: widget.benimID);
                break;
              case 1:
                page = MesajScreen(benimID: widget.benimID);
                break;
              case 3:
                page = HesapScreen(benimID: widget.benimID);
                break;
              default:
                return;
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Anasayfa"),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: "Mesaj"),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Bildirim",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hesap"),
          ],
        ),
      ),
    );
  }

  Widget _bildirimListesi() {
    if (bildirimler.isEmpty) {
      return const Center(
        child: Text(
          "Henüz bildirim yok.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bildirimler.length,
      itemBuilder: (_, i) {
        final b = bildirimler[i];
        final gonderen = b["gonderenAdi"] ?? "Bir kullanıcı";
        final mesaj = b["mesaj"] ?? "";

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF262626),
            borderRadius: BorderRadius.circular(12),
            border: const Border(
              left: BorderSide(color: Color(0xFFFFB3D9), width: 4),
            ),
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white),
              children: [
                TextSpan(
                  text: "$gonderen ",
                  style: const TextStyle(
                    color: Color(0xFFFFB3D9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: mesaj),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _onerilenListesi() {
    if (onerilenler.isEmpty) {
      return const Center(
        child: Text(
          "Şu an öneri yok.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: onerilenler.length,
      itemBuilder: (context, i) {
        final u = onerilenler[i];

        final int ortakFilm = u["ortakFilm"] ?? 0;
        final int ortakDizi = u["ortakDizi"] ?? 0;

        int uyum = (ortakFilm * 8 + ortakDizi * 10).clamp(20, 95);

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => KullaniciSayfasi(
                      benimID: widget.benimID,
                      kullaniciID: u["id"],
                    ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFF33252E),
                  child: Icon(Icons.person, color: Color(0xFFFFB3D9)),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u["kullaniciAdi"] ?? "",
                        style: const TextStyle(
                          color: Color(0xFFFFB3D9),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "%$uyum uyumlu ",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB3D9),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Takip Et",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
