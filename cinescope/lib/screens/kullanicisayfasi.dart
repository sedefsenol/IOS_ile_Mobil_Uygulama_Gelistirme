import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'mesajscreen.dart';
import 'bildirimscreen.dart';
import 'hesapscreen.dart';

import 'sohbetscreen.dart';

class KullaniciSayfasi extends StatefulWidget {
  final int benimID;
  final int kullaniciID;

  const KullaniciSayfasi({
    super.key,
    required this.benimID,
    required this.kullaniciID,
  });

  @override
  State<KullaniciSayfasi> createState() => _KullaniciSayfasiState();
}

class _KullaniciSayfasiState extends State<KullaniciSayfasi> {
  static const String apiBase =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev";
  static const String tmdbImg = "https://image.tmdb.org/t/p/w300";

  Map<String, dynamic>? profil;
  bool takipEdiyor = false;
  bool loading = true;

  List izlenenFilmler = [];
  List izlenenDiziler = [];
  List filmElestiriler = [];
  List diziElestiriler = [];

  int bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _getProfil(),
      _getTakipDurum(),
      _getIzlenenler(),
      _getElestiriler(),
    ]);
    if (mounted) setState(() => loading = false);
  }

  Future<void> _getProfil() async {
    final r = await http.get(
      Uri.parse("$apiBase/api/kullanici/profil-detay/${widget.kullaniciID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (r.statusCode == 200) profil = jsonDecode(r.body);
  }

  Future<void> _getTakipDurum() async {
    final r = await http.get(
      Uri.parse(
        "$apiBase/api/takip/durum?benimID=${widget.benimID}&profilID=${widget.kullaniciID}",
      ),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (r.statusCode == 200) {
      final d = jsonDecode(r.body);
      takipEdiyor = d["takipEdiyor"] == true;
    }
  }

  Future<void> _toggleTakip() async {
    if (takipEdiyor) {
      await http.delete(
        Uri.parse(
          "$apiBase/api/takip/sil?benimID=${widget.benimID}&profilID=${widget.kullaniciID}",
        ),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
    } else {
      await http.post(
        Uri.parse("$apiBase/api/takip/ekle"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "takipEdenID": widget.benimID,
          "takipEdilenID": widget.kullaniciID,
        }),
      );
    }
    await _getTakipDurum();
    if (mounted) setState(() {});
  }

  Future<void> _getIzlenenler() async {
    final f = await http.get(
      Uri.parse("$apiBase/api/film/izlenen/${widget.kullaniciID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    final d = await http.get(
      Uri.parse("$apiBase/api/dizi/izlenen/${widget.kullaniciID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    izlenenFilmler = f.statusCode == 200 ? jsonDecode(f.body) : [];
    izlenenDiziler = d.statusCode == 200 ? jsonDecode(d.body) : [];
  }

  Future<void> _getElestiriler() async {
    final f = await http.get(
      Uri.parse("$apiBase/api/filmelestiri/user/${widget.kullaniciID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    final d = await http.get(
      Uri.parse("$apiBase/api/dizielestiri/user/${widget.kullaniciID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    filmElestiriler = f.statusCode == 200 ? jsonDecode(f.body) : [];
    diziElestiriler = d.statusCode == 200 ? jsonDecode(d.body) : [];
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1F1F1F),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFB3D9)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        title: Text(
          profil?['kullaniciAdi'] ?? "Profil",
          style: const TextStyle(
            color: Color(0xFFFFB3D9),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFB3D9)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profilCard(),
            const SizedBox(height: 12),
            _aboutCard(),
            const SizedBox(height: 10),
            _statsGrid(),

            _section("İzlediği Filmler"),
            _miniPosterRow(izlenenFilmler, filmMi: true),

            _section("İzlediği Diziler"),
            _miniPosterRow(izlenenDiziler, filmMi: false),

            _section("Son Film Eleştirileri"),
            _reviewList(filmElestiriler, filmMi: true),

            _section("Son Dizi Eleştirileri"),
            _reviewList(diziElestiriler, filmMi: false),
          ],
        ),
      ),

      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _profilCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF262626),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Color(0xFFFFB3D9), size: 36),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                profil?['kullaniciAdi'] ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _toggleTakip,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      takipEdiyor ? Colors.grey : const Color(0xFFFFB3D9),
                ),
                child: Text(
                  takipEdiyor ? "Takip Ediliyor" : "Takip Et",
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => SohbetScreen(
                            benimID: widget.benimID,
                            hedefID: widget.kullaniciID,
                            hedefAdi: profil?['kullaniciAdi'] ?? "",
                            profilFoto: profil?['profilFoto'],
                          ),
                    ),
                  );
                },
                child: const Text(
                  "Mesaj Gönder",
                  style: TextStyle(color: Color(0xFFFFB3D9), fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFB3D9)),
                ),
                child: const Text(
                  "Ortak Liste",
                  style: TextStyle(color: Color(0xFFFFB3D9), fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _aboutCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF262626),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      profil?['hakkimda'] ?? "Hakkında bilgisi yok.",
      style: const TextStyle(color: Colors.white70),
    ),
  );

  Widget _statsGrid() => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 6,
      children: [
        _stat("${profil?['filmSayisi'] ?? 0}", "FİLM"),
        _stat("${profil?['diziSayisi'] ?? 0}", "DİZİ"),
        _stat("${profil?['listeSayisi'] ?? 0}", "LİSTE"),
        _stat("⭐", "ROZET"),
      ],
    ),
  );

  Widget _stat(String v, String l) => Column(
    children: [
      Text(
        v,
        style: const TextStyle(
          color: Color(0xFFFFB3D9),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      const SizedBox(height: 2),
      Text(l, style: const TextStyle(color: Colors.white54, fontSize: 11)),
    ],
  );

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
    child: Text(
      t,
      style: const TextStyle(
        color: Color(0xFFFFB3D9),
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  );

  Widget _miniPosterRow(List list, {required bool filmMi}) {
    if (list.isEmpty) {
      return const Text(
        "Hiç içerik yok.",
        style: TextStyle(color: Colors.white38),
      );
    }

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length > 5 ? 5 : list.length,
        itemBuilder: (_, i) {
          final x = list[i];
          final poster = x['posterPath'];

          return Container(
            width: 85,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage("$tmdbImg$poster"),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _reviewList(List list, {required bool filmMi}) {
    if (list.isEmpty) {
      return const Text(
        "Henüz eleştiri yok.",
        style: TextStyle(color: Colors.white38),
      );
    }

    return Column(
      children:
          list.take(3).map<Widget>((x) {
            final poster = x['posterPath'];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      "$tmdbImg$poster",
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filmMi ? x['filmAdi'] : x['diziAdi'],
                          style: const TextStyle(
                            color: Color(0xFFFFB3D9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          x['yorum'] ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _bottomNav() => BottomNavigationBar(
    currentIndex: bottomIndex,
    backgroundColor: const Color(0xFF1F1F1F),
    selectedItemColor: const Color(0xFFFFB3D9),
    unselectedItemColor: Colors.white70,
    type: BottomNavigationBarType.fixed,
    onTap: (i) {
      if (i == bottomIndex) return;
      Widget page =
          i == 0
              ? HomeScreen(benimID: widget.benimID)
              : i == 1
              ? MesajScreen(benimID: widget.benimID)
              : i == 2
              ? BildirimScreen(benimID: widget.benimID)
              : HesapScreen(benimID: widget.benimID);
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
  );
}
