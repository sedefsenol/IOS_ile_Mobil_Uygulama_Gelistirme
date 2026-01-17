import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'mesajscreen.dart';
import 'bildirimscreen.dart';
import 'hesapscreen.dart';
import 'filmsayfasi.dart';
import 'dizisayfasi.dart';
import 'kullanicisayfasi.dart';
import 'aramascreen.dart';
import 'filmlerscreen.dart';
import 'dizilerscreen.dart';
import 'listelerscreen.dart';

class ElestirilerScreen extends StatefulWidget {
  final int benimID;
  const ElestirilerScreen({super.key, required this.benimID});

  @override
  State<ElestirilerScreen> createState() => _ElestirilerScreenState();
}

class _ElestirilerScreenState extends State<ElestirilerScreen> {
  static const String apiBase =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev";
  static const String tmdbKey = "02f7a3e84e6acce9ce0b5583deffb717";
  static const String tmdbImg = "https://image.tmdb.org/t/p/w300";

  final String filmPopulerApi = "$apiBase/api/filmelestiri/populer";
  final String filmSonApi = "$apiBase/api/filmelestiri/son";

  final String diziPopulerApi = "$apiBase/api/dizielestiri/populer";
  final String diziSonApi = "$apiBase/api/dizielestiri/son";

  final String populerKullaniciApi = "$apiBase/api/kullanici/populer";

  List<Map<String, dynamic>> populerFilm = [];
  List<Map<String, dynamic>> sonFilm = [];
  List<Map<String, dynamic>> populerDizi = [];
  List<Map<String, dynamic>> sonDizi = [];
  List<Map<String, dynamic>> populerKullanicilar = [];

  bool lPopFilm = true;
  bool lSonFilm = true;
  bool lPopDizi = true;
  bool lSonDizi = true;
  bool lUser = true;

  int bottomIndex = 2;
  int topIndex = 2;

  @override
  void initState() {
    super.initState();
    _load(filmPopulerApi, (d) => populerFilm = d, () => lPopFilm = false);
    _load(filmSonApi, (d) => sonFilm = d, () => lSonFilm = false);
    _load(diziPopulerApi, (d) => populerDizi = d, () => lPopDizi = false);
    _load(diziSonApi, (d) => sonDizi = d, () => lSonDizi = false);
    _load(
      populerKullaniciApi,
      (d) => populerKullanicilar = d,
      () => lUser = false,
    );
  }

  int _getUserId(Map<String, dynamic> u) {
    final dynamic v =
        u["kullaniciID"] ?? u["kullaniciId"] ?? u["id"] ?? u["ID"];
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  Future<void> _load(
    String url,
    Function(List<Map<String, dynamic>>) onData,
    VoidCallback onDone,
  ) async {
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      if (res.statusCode != 200 || res.body.isEmpty) {
        onData([]);
        return;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        onData(decoded.map((e) => Map<String, dynamic>.from(e)).toList());
      } else {
        onData([]);
      }
    } catch (_) {
      onData([]);
    } finally {
      if (mounted) setState(onDone);
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
              _top("Filmler", 0),
              const SizedBox(width: 16),
              _top("Diziler", 1),
              const SizedBox(width: 16),
              _top("Eleştiriler", 2),
              const SizedBox(width: 16),
              _top("Listeler", 4),
              const Spacer(),
              _top("Arama", 3, icon: Icons.search),
            ],
          ),
        ),
      ),

      body: ListView(
        children: [
          _title("Popüler Film Eleştirileri"),
          lPopFilm ? _loader() : _filmReviewList(populerFilm),

          _title("Son Film Eleştirileri"),
          lSonFilm ? _loader() : _filmReviewList(sonFilm),

          _title("Popüler Dizi Eleştirileri"),
          lPopDizi ? _loader() : _diziReviewList(populerDizi),

          _title("Son Dizi Eleştirileri"),
          lSonDizi ? _loader() : _diziReviewList(sonDizi),

          _title("Popüler Kullanıcılar"),
          lUser ? _loader() : _userList(populerKullanicilar),
        ],
      ),

      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _filmReviewList(List<Map<String, dynamic>> list) =>
      _reviewBase(list, true);

  Widget _diziReviewList(List<Map<String, dynamic>> list) =>
      _reviewBase(list, false);

  Widget _reviewBase(
    List<Map<String, dynamic>> list,
    bool isFilm,
  ) => ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: list.length > 5 ? 5 : list.length,
    itemBuilder: (_, i) {
      final x = list[i];
      final poster = x["poster"] ?? x["posterPath"] ?? "";

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final id = isFilm ? x["filmID"] : x["diziID"];
            final url =
                isFilm
                    ? "https://api.themoviedb.org/3/movie/$id?api_key=$tmdbKey&language=tr-TR"
                    : "https://api.themoviedb.org/3/tv/$id?api_key=$tmdbKey&language=tr-TR";

            final res = await http.get(Uri.parse(url));
            if (!mounted || res.statusCode != 200) return;

            final data = jsonDecode(res.body);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        isFilm
                            ? FilmSayfasi(
                              benimID: widget.benimID,
                              film: data,
                              ustElestiriId: x["id"],
                            )
                            : DiziSayfasi(
                              benimID: widget.benimID,
                              dizi: data,
                              ustElestiriId: x["id"],
                            ),
              ),
            );
          },
          child: _reviewCard(
            poster,
            isFilm ? x["filmAdi"] : x["diziAdi"],
            x["yorum"],
          ),
        ),
      );
    },
  );

  Widget _reviewCard(String poster, String title, String yorum) => Container(
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
              poster.isNotEmpty
                  ? Image.network(
                    "$tmdbImg$poster",
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                  : Container(width: 80, height: 120, color: Colors.black26),
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
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _userList(List<Map<String, dynamic>> list) => Column(
    children:
        list.take(5).map((u) {
          final int kullaniciId = _getUserId(u);
          final foto = (u["profilFoto"] ?? "Gorsel/pp.png").toString();
          final fotoUrl = "$apiBase/$foto";

          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(fotoUrl)),
            title: Text(
              u["kullaniciAdi"] ?? "",
              style: const TextStyle(color: Color(0xFFFFB3D9)),
            ),
            subtitle: Text(
              "${u["takipciSayisi"] ?? 0} takipçi",
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () {
              if (kullaniciId == 0) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => KullaniciSayfasi(
                        benimID: widget.benimID,
                        kullaniciID: kullaniciId,
                      ),
                ),
              );
            },
          );
        }).toList(),
  );

  Widget _loader() => const Padding(
    padding: EdgeInsets.all(20),
    child: CircularProgressIndicator(color: Color(0xFFFFB3D9)),
  );

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

  Widget _title(String t) => Padding(
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
