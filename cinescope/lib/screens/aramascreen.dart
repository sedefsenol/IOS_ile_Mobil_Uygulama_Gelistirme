import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'filmlerscreen.dart';
import 'dizilerscreen.dart';
import 'elestirilerscreen.dart';
import 'filmsayfasi.dart';
import 'dizisayfasi.dart';
import 'mesajscreen.dart';
import 'bildirimscreen.dart';
import 'hesapscreen.dart';

class AramaScreen extends StatefulWidget {
  final int benimID;
  const AramaScreen({super.key, required this.benimID});

  @override
  State<AramaScreen> createState() => _AramaScreenState();
}

class _AramaScreenState extends State<AramaScreen> {
  static const String tmdbKey = "02f7a3e84e6acce9ce0b5583deffb717";
  static const String img = "https://image.tmdb.org/t/p/w300";

  int topIndex = 3;
  int bottomIndex = 0;

  int tur = 0;

  int? selectedGenre;
  int? selectedYear;
  int? selectedRating;

  List results = [];
  List<Map<String, dynamic>> genres = [];
  bool loading = false;

  final TextEditingController aramaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadGenres();
  }

  Future<void> loadGenres() async {
    final type = tur == 0 ? "movie" : "tv";

    final res = await http.get(
      Uri.parse(
        "https://api.themoviedb.org/3/genre/$type/list"
        "?api_key=$tmdbKey&language=tr-TR",
      ),
    );

    final data = jsonDecode(res.body);
    setState(() {
      genres =
          (data["genres"] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
    });
  }

  Future<void> search() async {
    setState(() => loading = true);

    final type = tur == 0 ? "movie" : "tv";
    final q = aramaCtrl.text.trim();

    String url;

    if (q.isNotEmpty) {
      url =
          "https://api.themoviedb.org/3/search/$type"
          "?api_key=$tmdbKey"
          "&language=tr-TR"
          "&query=${Uri.encodeComponent(q)}";
    } else {
      url =
          "https://api.themoviedb.org/3/discover/$type"
          "?api_key=$tmdbKey"
          "&language=tr-TR"
          "&with_genres=${selectedGenre ?? ""}"
          "&primary_release_year=${selectedYear ?? ""}"
          "&vote_average.gte=${selectedRating ?? 0}"
          "&sort_by=popularity.desc";
    }

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    setState(() {
      results = data["results"] ?? [];
      loading = false;
    });
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
              _top("Filmler", 0),
              const SizedBox(width: 16),
              _top("Diziler", 1),
              const SizedBox(width: 16),
              _top("Eleştiriler", 2),
              const Spacer(),
              _top("Arama", 3, icon: Icons.search),
            ],
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _dropdown<int>(
                hint: "Tür",
                value: tur,
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text("Film", style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text("Dizi", style: TextStyle(color: Colors.white)),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    tur = v!;
                    selectedGenre = null;
                    loadGenres();
                  });
                },
              ),

              _dropdown<int>(
                hint: "Kategori",
                value: selectedGenre,
                items:
                    genres
                        .map(
                          (g) => DropdownMenuItem<int>(
                            value: g["id"],
                            child: Text(
                              g["name"],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => selectedGenre = v),
              ),

              _dropdown<int>(
                hint: "Yıl",
                value: selectedYear,
                items: List.generate(30, (i) {
                  final y = DateTime.now().year - i;
                  return DropdownMenuItem(
                    value: y,
                    child: Text(
                      y.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }),
                onChanged: (v) => setState(() => selectedYear = v),
              ),

              _dropdown<int>(
                hint: "Puan",
                value: selectedRating,
                items: List.generate(
                  10,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(
                      "${i + 1}+",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                onChanged: (v) => setState(() => selectedRating = v),
              ),
            ],
          ),

          const SizedBox(height: 14),

          TextField(
            controller: aramaCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Film veya dizi ara...",
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF262626),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: search,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB3D9),
            ),
            child: const Text("Ara", style: TextStyle(color: Colors.black)),
          ),

          const SizedBox(height: 20),

          if (loading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFB3D9)),
            ),

          if (!loading)
            ...results.map(
              (x) => _listItem(
                title: tur == 0 ? x["title"] : x["name"],
                poster: x["poster_path"],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              tur == 0
                                  ? FilmSayfasi(
                                    benimID: widget.benimID,
                                    film: x,
                                  )
                                  : DiziSayfasi(
                                    benimID: widget.benimID,
                                    dizi: x,
                                  ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: const Color(0xFFFFB3D9),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          Widget page;
          switch (i) {
            case 0:
              page = HomeScreen(benimID: widget.benimID);
              break;
            case 1:
              page = MesajScreen(benimID: widget.benimID);
              break;
            case 2:
              page = BildirimScreen(benimID: widget.benimID);
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
    );
  }

  Widget _top(String t, int i, {IconData? icon}) => GestureDetector(
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
          return;
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
            color: i == topIndex ? const Color(0xFFFFB3D9) : Colors.white70,
          ),
        if (icon != null) const SizedBox(width: 6),
        Text(
          t,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: i == topIndex ? const Color(0xFFFFB3D9) : Colors.white70,
          ),
        ),
      ],
    ),
  );

  Widget _dropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF262626),
      borderRadius: BorderRadius.circular(18),
    ),
    child: DropdownButton<T>(
      value: value,
      hint: Text(hint, style: const TextStyle(color: Colors.white70)),
      style: const TextStyle(color: Colors.white),
      underline: const SizedBox(),
      dropdownColor: const Color(0xFF262626),
      iconEnabledColor: const Color(0xFFFFB3D9),
      items: items,
      onChanged: onChanged,
    ),
  );

  Widget _listItem({
    required String title,
    required String? poster,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              poster != null ? "$img$poster" : "",
              width: 60,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, _, _) => Container(
                    width: 60,
                    height: 90,
                    color: const Color(0xFF262626),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFB3D9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
