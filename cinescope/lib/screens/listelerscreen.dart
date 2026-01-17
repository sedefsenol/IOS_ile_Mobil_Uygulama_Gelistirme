import 'dart:convert';
import 'package:cinescope/screens/liste_detay_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'filmlerscreen.dart';
import 'filmsayfasi.dart';
import 'dizilerscreen.dart';
import 'elestirilerscreen.dart';
import 'aramascreen.dart';
import 'mesajscreen.dart';
import 'bildirimscreen.dart';
import 'hesapscreen.dart';

class ListelerScreen extends StatefulWidget {
  final int benimID;
  const ListelerScreen({super.key, required this.benimID});

  @override
  State<ListelerScreen> createState() => _ListelerScreenState();
}

class _ListelerScreenState extends State<ListelerScreen> {
  static const String apiBase =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev/api";
  static const String tmdbImg = "https://image.tmdb.org/t/p/w500";
  static const String tmdbKey = "02f7a3e84e6acce9ce0b5583deffb717";

  int aktifTab = 0;
  bool loading = true;

  List listelerim = [];
  List favorilerim = [];
  List dahaSonra = [];

  final adCtrl = TextEditingController();
  final aciklamaCtrl = TextEditingController();
  final aramaCtrl = TextEditingController();

  bool gorunur = true;
  String secilenTur = "film";
  List aramaSonuc = [];
  List secilenler = [];

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    setState(() => loading = true);
    await Future.wait([
      _get("/liste/user/${widget.benimID}", (d) => listelerim = d),
      _get("/film/favoriler/${widget.benimID}", (d) => favorilerim = d),
      _get("/film/dahasonra/${widget.benimID}", (d) => dahaSonra = d),
    ]);
    if (mounted) setState(() => loading = false);
  }

  Future<void> _get(String path, Function(List) onOk) async {
    try {
      final res = await http.get(
        Uri.parse("$apiBase$path"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      if (res.statusCode == 200 && mounted) {
        onOk(jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  Future<void> ara(String q) async {
    if (q.isEmpty) return;
    final url =
        "https://api.themoviedb.org/3/search/${secilenTur == "film" ? "movie" : "tv"}"
        "?api_key=$tmdbKey&language=tr-TR&query=${Uri.encodeComponent(q)}";
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      setState(() {
        aramaSonuc = json["results"] ?? [];
      });
    }
  }

  Future<void> kaydet() async {
    if (adCtrl.text.trim().isEmpty) return;
    await http.post(
      Uri.parse("$apiBase/liste/olustur"),
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
      body: jsonEncode({
        "kullaniciID": widget.benimID,
        "listeAdi": adCtrl.text,
        "aciklama": aciklamaCtrl.text,
        "gorunurluk": gorunur,
        "filmlerJson": jsonEncode(secilenler),
        "kapakFoto":
            secilenler.isNotEmpty ? secilenler.first["posterPath"] : null,
        "isCommon": false,
      }),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Liste oluşturuldu")));
    setState(() {
      adCtrl.clear();
      aciklamaCtrl.clear();
      aramaCtrl.clear();
      aramaSonuc.clear();
      secilenler.clear();
      aktifTab = 0;
    });
    _verileriYukle();
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

      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFB3D9)),
              )
              : Column(
                children: [
                  _tabBar(),
                  const Divider(color: Colors.white24),
                  Expanded(child: _icerik()),
                ],
              ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
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

  Widget _topItem(String t, int i, {IconData? icon}) {
    bool isSelected = (i == 4);
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
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

  Widget _tabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _tab("Listelerim", 0),
          _tab("Favorilerim", 1),
          _tab("Daha Sonra", 2),
          _tab("Liste Oluştur", 3),
        ],
      ),
    );
  }

  Widget _tab(String t, int i) {
    final aktif = aktifTab == i;
    return GestureDetector(
      onTap: () => setState(() => aktifTab = i),
      child: Text(
        t,
        style: TextStyle(
          color: aktif ? const Color(0xFFFFB3D9) : Colors.white54,
          fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _icerik() {
    switch (aktifTab) {
      case 0:
        return _listelerim();
      case 1:
        return _grid(favorilerim);
      case 2:
        return _grid(dahaSonra);
      case 3:
        return _listeOlustur();
      default:
        return const SizedBox();
    }
  }

  Widget _listelerim() {
    if (listelerim.isEmpty) {
      return const Center(
        child: Text(
          "Henüz listen yok",
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return ListView.builder(
      itemCount: listelerim.length,
      itemBuilder: (context, index) {
        final l = listelerim[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: const Color(0xFF262626),
          child: ListTile(
            leading: const Icon(Icons.list, color: Color(0xFFFFB3D9)),
            title: Text(
              l["listeAdi"] ?? "",
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              l["aciklama"] ?? "",
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white30),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ListeDetayScreen(
                        benimID: widget.benimID,
                        listeId: l["id"],
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _grid(List list) {
    if (list.isEmpty) {
      return const Center(
        child: Text("Liste boş", style: TextStyle(color: Colors.white38)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        final f = list[i];

        final String path = f["posterPath"] ?? f["poster"] ?? "";

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FilmSayfasi(benimID: widget.benimID, film: f),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                path.isNotEmpty
                    ? Image.network(
                      "$tmdbImg$path",
                      fit: BoxFit.cover,
                      errorBuilder:
                          (c, e, s) => Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white24,
                            ),
                          ),
                    )
                    : Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.movie, color: Colors.white24),
                    ),
          ),
        );
      },
    );
  }

  Widget _listeOlustur() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _input("Liste Adı", adCtrl),
          _input("Açıklama", aciklamaCtrl, max: 2),
          SwitchListTile(
            value: gorunur,
            onChanged: (v) => setState(() => gorunur = v),
            title: const Text(
              "Herkese Açık",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            activeThumbColor: const Color(0xFFFFB3D9),
          ),
          Row(
            children: [
              ChoiceChip(
                label: const Text("Film"),
                selected: secilenTur == "film",
                onSelected: (_) => setState(() => secilenTur = "film"),
                selectedColor: const Color(0xFFFFB3D9),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text("Dizi"),
                selected: secilenTur == "dizi",
                onSelected: (_) => setState(() => secilenTur = "dizi"),
                selectedColor: const Color(0xFFFFB3D9),
              ),
            ],
          ),
          TextField(
            controller: aramaCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Film / Dizi ara...",
              hintStyle: TextStyle(color: Colors.white30),
            ),
            onChanged:
                (value) =>
                    value.length > 2
                        ? ara(value)
                        : setState(() => aramaSonuc.clear()),
          ),
          ...aramaSonuc
              .take(5)
              .map(
                (f) => ListTile(
                  title: Text(
                    f["title"] ?? f["name"],
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.add, color: Color(0xFFFFB3D9)),
                  onTap:
                      () => setState(
                        () => secilenler.add({
                          "type": secilenTur,
                          "id": f["id"],
                          "title": f["title"] ?? f["name"],
                          "posterPath": f["poster_path"],
                        }),
                      ),
                ),
              ),
          const Divider(color: Colors.white12),
          Wrap(
            spacing: 8,
            children:
                secilenler
                    .map(
                      (f) => Chip(
                        backgroundColor: const Color(0xFF262626),
                        label: Text(
                          f["title"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        onDeleted: () => setState(() => secilenler.remove(f)),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB3D9),
              ),
              onPressed: kaydet,
              child: const Text(
                "Kaydet",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController c, {int max = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: max,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white12),
          ),
        ),
      ),
    );
  }
}
