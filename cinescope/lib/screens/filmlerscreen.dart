import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'filmsayfasi.dart';
import 'dizilerscreen.dart';
import 'elestirilerscreen.dart';
import 'listelerscreen.dart';
import 'aramascreen.dart';
import 'mesajscreen.dart';
import 'bildirimscreen.dart';
import 'hesapscreen.dart';

class FilmlerScreen extends StatefulWidget {
  final int benimID;
  const FilmlerScreen({super.key, required this.benimID});

  @override
  State<FilmlerScreen> createState() => _FilmlerScreenState();
}

class _FilmlerScreenState extends State<FilmlerScreen> {
  static const String tmdbKey = "02f7a3e84e6acce9ce0b5583deffb717";
  static const String tmdbImg = "https://image.tmdb.org/t/p/w500";
  static const String apiBase =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev/api";
  static const String filmElestiriApi = "$apiBase/filmelestiri/populer"; //

  List popularFilms = [];
  List upcomingFilms = [];
  List<Map<String, dynamic>> filmElestirileri = [];

  bool loadingPopular = true;
  bool loadingUpcoming = true;
  bool loadingReviews = true;

  int bottomIndex = 0;
  int topIndex = 0;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  void _verileriYukle() {
    loadPopularFilms();
    loadUpcomingFilms();
    loadFilmElestirileri();
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
        loadingPopular = false;
      });
    }
  }

  Future<void> loadUpcomingFilms() async {
    final res = await http.get(
      Uri.parse(
        "https://api.themoviedb.org/3/movie/upcoming?api_key=$tmdbKey&language=tr-TR",
      ),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        upcomingFilms = data["results"] ?? [];
        loadingUpcoming = false;
      });
    }
  }

  Future<void> loadFilmElestirileri() async {
    try {
      final res = await http.get(
        Uri.parse(filmElestiriApi),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      if (res.statusCode == 200) {
        final List decoded = jsonDecode(res.body);
        setState(() {
          filmElestirileri =
              decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          loadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint("Eleştiri yükleme hatası: $e");
      setState(() => loadingReviews = false);
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
          loadingPopular ? _loader() : _filmGrid(popularFilms),

          _sectionTitle("Popüler Film Eleştirileri"),
          loadingReviews ? _loader() : _reviewList(filmElestirileri),

          _sectionTitle("Yakında Çıkacaklar"),
          loadingUpcoming ? _loader() : _filmGrid(upcomingFilms),
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
          if (i == bottomIndex && i == 0) {
            return;
          }

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

  Widget _topItem(String t, int i, {IconData? icon}) {
    bool isSelected = (i == 0);

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          return;
        }

        Widget page;
        switch (i) {
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 18,
              color: isSelected ? const Color(0xFFFFB3D9) : Colors.white70,
            ),
          if (icon != null) const SizedBox(width: 6),
          Text(
            t,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFFFFB3D9) : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _reviewList(List<Map<String, dynamic>> list) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length > 5 ? 5 : list.length,
      itemBuilder: (context, i) {
        final x = list[i];
        final String posterPath = x["poster"] ?? "";

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final res = await http.get(
                Uri.parse(
                  "https://api.themoviedb.org/3/movie/${x["filmID"]}?api_key=$tmdbKey&language=tr-TR",
                ),
              );
              if (!mounted) return;
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
                    child:
                        posterPath.isNotEmpty
                            ? Image.network(
                              "https://image.tmdb.org/t/p/w300$posterPath",
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 120,
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.white24,
                                    ),
                                  ),
                            )
                            : Container(
                              width: 80,
                              height: 120,
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.movie,
                                color: Colors.white24,
                              ),
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          x["filmAdi"] ?? "Film",
                          style: const TextStyle(
                            color: Color(0xFFFFB3D9),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          x["yorum"] ?? "",
                          maxLines: 4,
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
          ),
        );
      },
    );
  }
}
