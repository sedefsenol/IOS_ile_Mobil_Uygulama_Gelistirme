import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'mesajscreen.dart';
import 'bildirimscreen.dart';
import 'filmsayfasi.dart';
import 'dizisayfasi.dart';

class HesapScreen extends StatefulWidget {
  final int benimID;
  const HesapScreen({super.key, required this.benimID});

  @override
  State<HesapScreen> createState() => _HesapScreenState();
}

class _HesapScreenState extends State<HesapScreen> {
  static const String apiBase =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev";
  static const String tmdbKey = "02f7a3e84e6acce9ce0b5583deffb717";
  static const String tmdbImg = "https://image.tmdb.org/t/p/w300";

  Map<String, dynamic>? profil;

  List izlenenFilmler = [];
  List izlenenDiziler = [];
  List filmElestiriler = [];
  List diziElestiriler = [];
  List listeler = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _getProfil(),
      _getIzlenenler(),
      _getElestiriler(),
      _getListeler(),
    ]);
    if (mounted) setState(() => loading = false);
  }

  Future<void> _getProfil() async {
    final res = await http.get(
      Uri.parse("$apiBase/api/kullanici/profil-detay/${widget.benimID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (res.statusCode == 200) profil = jsonDecode(res.body);
  }

  Future<void> _getIzlenenler() async {
    final resF = await http.get(
      Uri.parse("$apiBase/api/film/izlenen/${widget.benimID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    final resD = await http.get(
      Uri.parse("$apiBase/api/dizi/izlenen/${widget.benimID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (resF.statusCode == 200) izlenenFilmler = jsonDecode(resF.body);
    if (resD.statusCode == 200) izlenenDiziler = jsonDecode(resD.body);
  }

  Future<void> _getElestiriler() async {
    final resF = await http.get(
      Uri.parse("$apiBase/api/filmelestiri/user/${widget.benimID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    final resD = await http.get(
      Uri.parse("$apiBase/api/dizielestiri/user/${widget.benimID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (resF.statusCode == 200) filmElestiriler = jsonDecode(resF.body);
    if (resD.statusCode == 200) diziElestiriler = jsonDecode(resD.body);
  }

  Future<void> _getListeler() async {
    final res = await http.get(
      Uri.parse("$apiBase/api/liste/user/${widget.benimID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (res.statusCode == 200) listeler = jsonDecode(res.body);
  }

  int getToplamElestiriSayisi() =>
      filmElestiriler.length + diziElestiriler.length;

  String getRozet() {
    int t = (profil?['filmSayisi'] ?? 0) + (profil?['diziSayisi'] ?? 0);
    if (t < 5) return "🐣 Yeni Üye";
    if (t < 15) return "🌱 Başlayan İzleyici";
    if (t < 30) return "🎬 Film & Dizi Sever";
    if (t < 60) return "🍿 Tutkulu İzleyici";
    return "👑 Efsane";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text(
          "Profilim",
          style: TextStyle(
            color: Color(0xFFFFB3D9),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AyarlarScreen(benimID: widget.benimID),
                ),
              );
            },
          ),
        ],
      ),

      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFB3D9)),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profilCard(),
                    const SizedBox(height: 16),
                    _aboutCard(),
                    const SizedBox(height: 16),
                    _statsGrid(),

                    _section("İzlediğim Filmler"),
                    _posterRow(izlenenFilmler, filmMi: true),

                    _section("İzlediğim Diziler"),
                    _posterRow(izlenenDiziler, filmMi: false),

                    _section("Yaptığım Film Eleştirileri"),
                    _reviewList(filmElestiriler, filmMi: true),

                    _section("Yaptığım Dizi Eleştirileri"),
                    _reviewList(diziElestiriler, filmMi: false),
                  ],
                ),
              ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: const Color(0xFFFFB3D9),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 3) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      i == 0
                          ? HomeScreen(benimID: widget.benimID)
                          : i == 1
                          ? MesajScreen(benimID: widget.benimID)
                          : BildirimScreen(benimID: widget.benimID),
            ),
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
    );
  }

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
    child: Text(
      t,
      style: const TextStyle(
        color: Color(0xFFFFB3D9),
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _profilCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF262626),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 10),
        Row(
          children: [
            _chip("${profil?['takipciSayisi'] ?? 0} Takipçi"),
            const SizedBox(width: 10),
            _chip("${profil?['takipEdilenSayisi'] ?? 0} Takip"),
          ],
        ),
      ],
    ),
  );

  Widget _chip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF1F1F1F),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      t,
      style: const TextStyle(
        color: Color(0xFFFFB3D9),
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    ),
  );

  Widget _aboutCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF262626),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      (profil?['hakkimda'] == null ||
              profil!['hakkimda'].toString().trim().isEmpty)
          ? "Henüz bir hakkımda yazısı eklenmemiş."
          : profil!['hakkimda'],
      style: const TextStyle(color: Colors.white70),
    ),
  );

  Widget _statsGrid() => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 5,
    children: [
      _stat("${profil?['filmSayisi']}", "FİLM"),
      _stat("${profil?['diziSayisi']}", "DİZİ"),
      _stat("${profil?['listeSayisi']}", "LİSTE"),
      _stat("${getToplamElestiriSayisi()}", "ELEŞTİRİ"),
      _stat(getRozet(), "ROZET"),
    ],
  );

  Widget _stat(String v, String l) => Column(
    children: [
      Text(
        v,
        style: const TextStyle(
          color: Color(0xFFFFB3D9),
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(l, style: const TextStyle(color: Colors.white54, fontSize: 10)),
    ],
  );

  Widget _posterRow(List list, {required bool filmMi}) => SizedBox(
    height: 110,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: list.length > 6 ? 6 : list.length,
      itemBuilder: (_, i) {
        final x = list[i];
        return GestureDetector(
          onTap: () async {
            final url =
                filmMi
                    ? "https://api.themoviedb.org/3/movie/${x['filmID']}?api_key=$tmdbKey&language=tr-TR"
                    : "https://api.themoviedb.org/3/tv/${x['diziID']}?api_key=$tmdbKey&language=tr-TR";

            final res = await http.get(Uri.parse(url));
            if (!mounted) return;
            final data = jsonDecode(res.body);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        filmMi
                            ? FilmSayfasi(benimID: widget.benimID, film: data)
                            : DiziSayfasi(benimID: widget.benimID, dizi: data),
              ),
            );
          },
          child: Container(
            width: 70,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage("$tmdbImg${x['posterPath']}"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _reviewList(List list, {required bool filmMi}) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "Henüz eleştiri yok.",
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return Column(
      children:
          list.take(5).map<Widget>((x) {
            final String? posterPath = x['posterPath'];
            final bool posterVar =
                posterPath != null && posterPath.toString().isNotEmpty;

            return GestureDetector(
              onTap: () async {
                final String url =
                    filmMi
                        ? "https://api.themoviedb.org/3/movie/${x['filmId']}?api_key=$tmdbKey&language=tr-TR"
                        : "https://api.themoviedb.org/3/tv/${x['diziId']}?api_key=$tmdbKey&language=tr-TR";

                final res = await http.get(Uri.parse(url));
                if (!mounted) return;
                final data = jsonDecode(res.body);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            filmMi
                                ? FilmSayfasi(
                                  benimID: widget.benimID,
                                  film: data,
                                  ustElestiriId: x['id'],
                                )
                                : DiziSayfasi(
                                  benimID: widget.benimID,
                                  dizi: data,
                                  ustElestiriId: x['id'],
                                ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    left: BorderSide(color: Color(0xFFFFB3D9), width: 3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    posterVar
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            "$tmdbImg$posterPath",
                            width: 55,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Container(
                          width: 55,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            filmMi ? Icons.movie : Icons.tv,
                            color: Colors.white38,
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
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            x['yorum'] ?? "",
                            maxLines: 3,
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
              ),
            );
          }).toList(),
    );
  }
}

class AyarlarScreen extends StatelessWidget {
  final int benimID;
  const AyarlarScreen({super.key, required this.benimID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text(
          "Ayarlar",
          style: TextStyle(color: Color(0xFFFFB3D9)),
        ),
      ),
      body: const Center(
        child: Text("Ayarlar Sayfası", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
