import 'dart:convert';
import 'package:cinescope/screens/kullanicisayfasi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'filmlerscreen.dart';
import 'filmsayfasi.dart';
import 'dizilerscreen.dart';
import 'dizisayfasi.dart';
import 'elestirilerscreen.dart';
import 'listelerscreen.dart';
import 'aramascreen.dart';
import 'mesajscreen.dart';
import 'bildirimscreen.dart';
import 'hesapscreen.dart';

class HomeScreen extends StatefulWidget {
  final int benimID;
  const HomeScreen({super.key, required this.benimID});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String tmdbKey = "02f7a3e84e6acce9ce0b5583deffb717";
  static const String tmdbImg = "https://image.tmdb.org/t/p/w500";

  static const String apiBase =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev/api";
  static const String diziElestiriApi = "$apiBase/dizielestiri/populer";
  static const String filmElestiriApi = "$apiBase/filmelestiri/populer";
  static const String populerKullaniciApi = "$apiBase/kullanici/populer";

  List popularFilms = [];
  List popularSeries = [];
  List<Map<String, dynamic>> diziElestirileri = [];
  List<Map<String, dynamic>> filmElestirileri = [];
  List<Map<String, dynamic>> populerKullanicilar = [];

  bool loadingFilms = true;
  bool loadingSeries = true;
  bool loadingDiziReviews = true;
  bool loadingFilmReviews = true;
  bool loadingUsers = true;

  int bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  void _verileriYukle() {
    loadPopularFilms();
    loadPopularSeries();
    loadDiziElestirileri();
    loadFilmElestirileri();
    loadPopulerKullanicilar();
  }

  Future<void> loadPopularFilms() async {
    final res = await http.get(
      Uri.parse(
        "https://api.themoviedb.org/3/movie/popular?api_key=$tmdbKey&language=tr-TR",
      ),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        popularFilms = data["results"] ?? [];
        loadingFilms = false;
      });
    }
  }

  Future<void> loadPopularSeries() async {
    final res = await http.get(
      Uri.parse(
        "https://api.themoviedb.org/3/tv/popular?api_key=$tmdbKey&language=tr-TR",
      ),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        popularSeries = data["results"] ?? [];
        loadingSeries = false;
      });
    }
  }

  Future<void> loadDiziElestirileri() async {
    final res = await http.get(
      Uri.parse(diziElestiriApi),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (res.statusCode == 200) {
      final List decoded = jsonDecode(res.body);
      setState(() {
        diziElestirileri =
            decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        loadingDiziReviews = false;
      });
    }
  }

  Future<void> loadFilmElestirileri() async {
    final res = await http.get(
      Uri.parse(filmElestiriApi),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (res.statusCode == 200) {
      final List decoded = jsonDecode(res.body);
      setState(() {
        filmElestirileri =
            decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        loadingFilmReviews = false;
      });
    }
  }

  Future<void> loadPopulerKullanicilar() async {
    final res = await http.get(
      Uri.parse(populerKullaniciApi),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (res.statusCode == 200) {
      final List decoded = jsonDecode(res.body);
      setState(() {
        populerKullanicilar =
            decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        loadingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: Row(
            children: [
              const Text(
                "CineScope",
                style: TextStyle(
                  color: Color(0xFFFFB3D9),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 24),
              _topItem("Filmler", 0),
              const SizedBox(width: 16),
              _topItem("Diziler", 1),
              const SizedBox(width: 16),
              _topItem("Eleştiriler", 2),
              const SizedBox(width: 16),
              _topItem("Listeler", 4),
              const Spacer(),
              _topItem("Arama", 3, icon: Icons.search),
            ],
          ),
        ),
      ),

      body: ListView(
        children: [
          _sectionTitle("Popüler Filmler"),
          loadingFilms ? _loader() : _filmGrid(popularFilms),

          _sectionTitle("Popüler Dizi Eleştirileri"),
          loadingDiziReviews ? _loader() : _diziReviewList(),

          _sectionTitle("Popüler Kullanıcılar"),
          loadingUsers ? _loader() : _userList(populerKullanicilar),

          _sectionTitle("Popüler Diziler"),
          loadingSeries ? _loader() : _diziGrid(popularSeries),

          _sectionTitle("Popüler Film Eleştirileri"),
          loadingFilmReviews ? _loader() : _filmReviewList(),
          const SizedBox(height: 30),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: const Color(0xFFFFB3D9),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == bottomIndex) return;

          Widget screen;
          switch (i) {
            case 0:
              screen = HomeScreen(benimID: widget.benimID);
              break;
            case 1:
              screen = MesajScreen(benimID: widget.benimID);
              break;
            case 2:
              screen = BildirimScreen(benimID: widget.benimID);
              break;
            case 3:
              screen = HesapScreen(benimID: widget.benimID);
              break;
            default:
              screen = HomeScreen(benimID: widget.benimID);
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => screen),
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

  Widget _loader() => const Center(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: CircularProgressIndicator(color: Color(0xFFFFB3D9)),
    ),
  );

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 26, 16, 14),
    child: Row(
      children: [
        Container(width: 5, height: 22, color: const Color(0xFFFFB3D9)),
        const SizedBox(width: 10),
        Text(
          t,
          style: const TextStyle(
            color: Color(0xFFFFB3D9),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ],
    ),
  );

  Widget _filmGrid(List list) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length > 5 ? 5 : list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (context, i) {
        final f = list[i];
        return InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FilmSayfasi(benimID: widget.benimID, film: f),
                ),
              ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "$tmdbImg${f["poster_path"]}",
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    ),
  );

  Widget _diziGrid(List list) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length > 5 ? 5 : list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (context, i) {
        final d = list[i];
        return InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiziSayfasi(benimID: widget.benimID, dizi: d),
                ),
              ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "$tmdbImg${d["poster_path"]}",
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    ),
  );

  Widget _diziReviewList() => ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: diziElestirileri.length > 3 ? 3 : diziElestirileri.length,
    itemBuilder: (context, i) {
      final x = diziElestirileri[i];
      return _reviewCard(
        poster: x["poster"],
        title: x["diziAdi"],
        yorum: x["yorum"],
        onTap: () async {
          final res = await http.get(
            Uri.parse(
              "https://api.themoviedb.org/3/tv/${x["diziID"]}?api_key=$tmdbKey&language=tr-TR",
            ),
          );
          final diziData = jsonDecode(res.body);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => DiziSayfasi(
                    benimID: widget.benimID,
                    dizi: diziData,
                    ustElestiriId: x["id"],
                  ),
            ),
          );
        },
      );
    },
  );

  Widget _filmReviewList() => ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: filmElestirileri.length > 3 ? 3 : filmElestirileri.length,
    itemBuilder: (context, i) {
      final x = filmElestirileri[i];
      return _reviewCard(
        poster: x["poster"],
        title: x["filmAdi"],
        yorum: x["yorum"],
        onTap: () async {
          final res = await http.get(
            Uri.parse(
              "https://api.themoviedb.org/3/movie/${x["filmID"]}?api_key=$tmdbKey&language=tr-TR",
            ),
          );
          final filmData = jsonDecode(res.body);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => FilmSayfasi(
                    benimID: widget.benimID,
                    film: filmData,
                    ustElestiriId: x["id"],
                  ),
            ),
          );
        },
      );
    },
  );

  Widget _reviewCard({
    required String poster,
    required String title,
    required String yorum,
    required VoidCallback onTap,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: Color(0xFFFFB3D9), width: 3),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "https://image.tmdb.org/t/p/w300$poster",
                width: 80,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFFFB3D9),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    yorum,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _userList(List<Map<String, dynamic>> list) => Column(
    children:
        list.take(5).map((u) {
          final foto = u["profilFoto"] ?? "Gorsel/pp.png";

          return InkWell(
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
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  "https://unfrounced-cordia-equiponderant.ngrok-free.dev/$foto",
                ),
              ),
              title: Text(
                u["kullaniciAdi"],
                style: const TextStyle(color: Color(0xFFFFB3D9)),
              ),
              subtitle: Text(
                "${u["takipciSayisi"]} takipçi",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.white38,
              ),
            ),
          );
        }).toList(),
  );

  Widget _topItem(String t, int i, {IconData? icon}) => GestureDetector(
    onTap: () {
      Widget page;
      switch (i) {
        case 0:
          page = FilmlerScreen(benimID: widget.benimID);
          break;
        case 1:
          page = DizilerScreen(benimID: widget.benimID);
          break;
        case 2:
          page = ElestirilerScreen(benimID: widget.benimID);
          break;
        case 3:
          page = AramaScreen(benimID: widget.benimID);
          break;
        case 4:
          page = ListelerScreen(benimID: widget.benimID);
          break;
        default:
          return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    },
    child: Row(
      children: [
        if (icon != null) Icon(icon, size: 18, color: Colors.white70),
        if (icon != null) const SizedBox(width: 6),
        Text(
          t,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    ),
  );
}
