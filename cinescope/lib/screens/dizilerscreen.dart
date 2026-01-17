import 'dart:convert';
import 'package:cinescope/screens/dizisayfasi.dart';
import 'package:cinescope/screens/filmlerscreen.dart';
import 'package:cinescope/screens/listelerscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'elestirilerscreen.dart';
import 'aramascreen.dart';
import 'mesajscreen.dart';
import 'bildirimscreen.dart';
import 'hesapscreen.dart';

class DizilerScreen extends StatefulWidget {
  final int benimID;
  const DizilerScreen({super.key, required this.benimID});

  @override
  State<DizilerScreen> createState() => _DizilerScreenState();
}

class _DizilerScreenState extends State<DizilerScreen> {
  static const String tmdbKey = "02f7a3e84e6acce9ce0b5583deffb717";
  static const String tmdbImg = "https://image.tmdb.org/t/p/w500";

  static const String diziElestiriApi =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev/api/dizielestiri/populer";

  List popularDiziler = [];
  List sonCikanDiziler = [];
  List<Map<String, dynamic>> diziElestirileri = [];

  bool loadingPopular = true;
  bool loadingSon = true;
  bool loadingReviews = true;

  int bottomIndex = 0;
  int topIndex = 1;

  @override
  void initState() {
    super.initState();
    loadPopularDiziler();
    loadSonCikanDiziler();
    loadDiziElestirileri();
  }

  Future<void> loadPopularDiziler() async {
    final res = await http.get(
      Uri.parse(
        "https://api.themoviedb.org/3/tv/popular?api_key=$tmdbKey&language=tr-TR",
      ),
    );
    final data = jsonDecode(res.body);
    setState(() {
      popularDiziler = data["results"] ?? [];
      loadingPopular = false;
    });
  }

  Future<void> loadSonCikanDiziler() async {
    final res = await http.get(
      Uri.parse(
        "https://api.themoviedb.org/3/tv/on_the_air?api_key=$tmdbKey&language=tr-TR",
      ),
    );
    final data = jsonDecode(res.body);
    setState(() {
      sonCikanDiziler = data["results"] ?? [];
      loadingSon = false;
    });
  }

  Future<void> loadDiziElestirileri() async {
    try {
      final res = await http.get(
        Uri.parse(diziElestiriApi),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final List decoded = jsonDecode(res.body);
      setState(() {
        diziElestirileri =
            decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        loadingReviews = false;
      });
    } catch (_) {
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
          _sectionTitle("Popüler Diziler"),
          loadingPopular ? _loader() : _diziGrid(popularDiziler),

          _sectionTitle("Popüler Dizi Eleştirileri"),
          loadingReviews ? _loader() : _reviewList(diziElestirileri),

          _sectionTitle("Son Çıkan Diziler"),
          loadingSon ? _loader() : _diziGrid(sonCikanDiziler),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: const Color(0xFFFFB3D9),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(benimID: widget.benimID),
              ),
            );
          } else if (i == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MesajScreen(benimID: widget.benimID),
              ),
            );
          } else if (i == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BildirimScreen(benimID: widget.benimID),
              ),
            );
          } else if (i == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HesapScreen(benimID: widget.benimID),
              ),
            );
          }
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

  Widget _loader() => const Padding(
    padding: EdgeInsets.all(16),
    child: CircularProgressIndicator(),
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
            color: topIndex == i ? const Color(0xFFFFB3D9) : Colors.white70,
          ),
        if (icon != null) const SizedBox(width: 6),
        Text(
          t,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: topIndex == i ? const Color(0xFFFFB3D9) : Colors.white70,
          ),
        ),
      ],
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

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiziSayfasi(benimID: widget.benimID, dizi: d),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "$tmdbImg${d["poster_path"]}",
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    color: const Color(0xFF262626),
                    child: const Icon(
                      Icons.tv,
                      color: Colors.white24,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _reviewList(List<Map<String, dynamic>> list) => ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: list.length > 5 ? 5 : list.length,
    itemBuilder: (context, i) {
      final x = list[i];

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final int? diziId = x["diziID"] ?? x["DiziID"];
            final int? elestiriId = x["id"] ?? x["Id"];

            if (diziId == null) return;

            final res = await http.get(
              Uri.parse(
                "https://api.themoviedb.org/3/tv/$diziId"
                "?api_key=$tmdbKey&language=tr-TR",
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
                      ustElestiriId: elestiriId,
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
                  child: Image.network(
                    "https://image.tmdb.org/t/p/w300${x["poster"]}",
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        x["diziAdi"] ?? x["DiziAdi"] ?? "",
                        style: const TextStyle(
                          color: Color(0xFFFFB3D9),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        x["yorum"] ?? x["Yorum"] ?? "",
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
