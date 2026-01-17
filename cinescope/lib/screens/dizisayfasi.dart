import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'mesajscreen.dart';
import 'hesapscreen.dart';
import 'bildirimscreen.dart';

class DiziSayfasi extends StatefulWidget {
  final int benimID;
  final Map<String, dynamic> dizi;
  final int? ustElestiriId;

  const DiziSayfasi({
    super.key,
    required this.benimID,
    required this.dizi,
    this.ustElestiriId,
  });

  @override
  State<DiziSayfasi> createState() => _DiziSayfasiState();
}

class _DiziSayfasiState extends State<DiziSayfasi> {
  static const String apiBase =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev";
  static const String tmdbImg = "https://image.tmdb.org/t/p/w500";
  static const String tmdbKey = "02f7a3e84e6acce9ce0b5583deffb717";

  bool loading = true;
  bool izlendi = false;
  bool dahaSonra = false;
  bool favori = false;
  int puan = 0;

  List<String> kategoriler = [];
  List<Map<String, dynamic>> oyuncular = [];
  List sezonlar = [];

  List<Map<String, dynamic>> benzerDiziler = [];
  List<Map<String, dynamic>> elestiriler = [];

  final TextEditingController yorumCtrl = TextEditingController();
  final TextEditingController yanitCtrl = TextEditingController();
  int? aktifYanitElestiriId;

  @override
  void initState() {
    super.initState();
    _initVerileriYukle();
  }

  Future<void> _initVerileriYukle() async {
    await Future.wait([
      loadDiziDurum(),
      loadDetay(),
      loadBenzer(),
      loadElestiriler(),
    ]);
    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    yorumCtrl.dispose();
    yanitCtrl.dispose();
    super.dispose();
  }

  Future<void> loadDiziDurum() async {
    final res = await http.get(
      Uri.parse(
        "$apiBase/api/dizi/durum?kullaniciId=${widget.benimID}&diziId=${widget.dizi["id"]}",
      ),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (res.statusCode == 200) {
      final d = jsonDecode(res.body);
      setState(() {
        izlendi = d["izlendi"] ?? false;
        dahaSonra = d["dahaSonra"] ?? false;
        favori = d["favori"] ?? false;
        puan = d["puan"] ?? 0;
      });
    }
  }

  Future<void> izleToggle() async {
    if (!izlendi) {
      await http.post(
        Uri.parse("$apiBase/api/dizi/izlendi"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "kullaniciID": widget.benimID,
          "diziID": widget.dizi["id"],
          "diziAdi": widget.dizi["name"] ?? "",
          "posterPath": widget.dizi["poster_path"] ?? "",
        }),
      );
      setState(() => izlendi = true);
    } else {
      setState(() {
        izlendi = false;
        puan = 0;
      });
    }
  }

  Future<void> dahaSonraToggle() async {
    await http.post(
      Uri.parse("$apiBase/api/dizi/dahasonra"),
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
      body: jsonEncode({
        "kullaniciID": widget.benimID,
        "diziID": widget.dizi["id"],
        "diziAdi": widget.dizi["name"] ?? "",
        "posterPath": widget.dizi["poster_path"] ?? "",
      }),
    );
    setState(() => dahaSonra = !dahaSonra);
  }

  Future<void> favoriToggle() async {
    await http.post(
      Uri.parse("$apiBase/api/dizi/favori"),
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
      body: jsonEncode({
        "kullaniciID": widget.benimID,
        "diziID": widget.dizi["id"],
        "diziAdi": widget.dizi["name"] ?? "",
        "posterPath": widget.dizi["poster_path"] ?? "",
      }),
    );
    setState(() => favori = !favori);
  }

  Future<void> puanVer(int yeniPuan) async {
    if (!izlendi) return;
    await http.put(
      Uri.parse(
        "$apiBase/api/dizi/puan?kullaniciId=${widget.benimID}&diziId=${widget.dizi["id"]}&puan=$yeniPuan",
      ),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    setState(() => puan = yeniPuan);
  }

  Future<void> loadDetay() async {
    final res = await http.get(
      Uri.parse(
        "https://api.themoviedb.org/3/tv/${widget.dizi["id"]}?api_key=$tmdbKey&language=tr-TR&append_to_response=credits",
      ),
    );
    if (res.statusCode == 200) {
      final d = jsonDecode(res.body);
      setState(() {
        kategoriler =
            (d["genres"] as List).map((e) => e["name"].toString()).toList();
        oyuncular =
            (d["credits"]["cast"] as List)
                .take(8)
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
        sezonlar = (d["seasons"] as List?) ?? [];
      });
    }
  }

  Future<void> loadBenzer() async {
    final res = await http.get(
      Uri.parse(
        "https://api.themoviedb.org/3/tv/${widget.dizi["id"]}/similar?api_key=$tmdbKey&language=tr-TR",
      ),
    );
    if (res.statusCode == 200) {
      final d = jsonDecode(res.body);
      setState(() {
        benzerDiziler =
            (d["results"] as List)
                .take(5)
                .map((e) => Map<String, dynamic>.from(e))
                .where((x) => x["poster_path"] != null)
                .toList();
      });
    }
  }

  Future<void> loadElestiriler() async {
    final res = await http.get(
      Uri.parse("$apiBase/api/dizielestiri/dizi-detay/${widget.dizi["id"]}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      setState(() {
        elestiriler = list.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> elestiriEkle() async {
    if (yorumCtrl.text.trim().isEmpty) return;
    await http.post(
      Uri.parse("$apiBase/api/dizielestiri"),
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
      body: jsonEncode({
        "kullaniciID": widget.benimID,
        "diziID": widget.dizi["id"],
        "diziAdi": widget.dizi["name"] ?? "",
        "poster": widget.dizi["poster_path"] ?? "",
        "yorum": yorumCtrl.text.trim(),
      }),
    );
    yorumCtrl.clear();
    await loadElestiriler();
  }

  Future<void> yanitEkle(int anaId) async {
    if (yanitCtrl.text.trim().isEmpty) return;
    await http.post(
      Uri.parse("$apiBase/api/dizielestiri/yanit"),
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true",
      },
      body: jsonEncode({
        "anaElestiriID": anaId,
        "kullaniciID": widget.benimID,
        "yorum": yanitCtrl.text.trim(),
      }),
    );
    yanitCtrl.clear();
    setState(() => aktifYanitElestiriId = null);
    await loadElestiriler();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1F1F1F),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Text(
          widget.dizi["name"] ?? "Dizi",
          style: const TextStyle(color: Color(0xFFFFB3D9)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFB3D9)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "$tmdbImg${widget.dizi["poster_path"]}",
                  width: 140,
                  height: 210,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.dizi["overview"] ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              filmButon("İzledim", izlendi, izleToggle),
              const SizedBox(width: 8),
              filmButon("Daha Sonra", dahaSonra, dahaSonraToggle),
              const SizedBox(width: 8),
              filmButon("Favori", favori, favoriToggle),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (i) => IconButton(
                icon: Icon(
                  i < puan ? Icons.star : Icons.star_border,
                  color: const Color(0xFFFFB3D9),
                ),
                onPressed: () => puanVer(i + 1),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                kategoriler
                    .map(
                      (k) => Chip(
                        backgroundColor: const Color(0xFF262626),
                        label: Text(
                          k,
                          style: const TextStyle(color: Color(0xFFFFB3D9)),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 40),

          if (sezonlar.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  sezonlar.map<Widget>((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF262626),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFFB3D9),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Sezon ${s["season_number"]}",
                        style: const TextStyle(
                          color: Color(0xFFFFB3D9),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
            ),

          const SizedBox(height: 20),
          const Text(
            "Oyuncular",
            style: TextStyle(
              color: Color(0xFFFFB3D9),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: oyuncular.length,
              itemBuilder: (_, i) {
                final o = oyuncular[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            o["profile_path"] == null
                                ? Container(
                                  height: 100,
                                  width: 80,
                                  color: const Color(0xFF262626),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white54,
                                  ),
                                )
                                : Image.network(
                                  "$tmdbImg${o["profile_path"]}",
                                  height: 100,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 80,
                        child: Text(
                          o["name"] ?? "",
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Text(
            "Benzer Diziler",
            style: TextStyle(
              color: Color(0xFFFFB3D9),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: benzerDiziler.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.6,
            ),
            itemBuilder:
                (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    "$tmdbImg${benzerDiziler[i]["poster_path"]}",
                    fit: BoxFit.cover,
                  ),
                ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Eleştiriler",
            style: TextStyle(
              color: Color(0xFFFFB3D9),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: yorumCtrl,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Dizi hakkında ne düşünüyorsun?",
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF262626),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: elestiriEkle,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB3D9),
            ),
            child: const Text("Gönder", style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(height: 16),
          ...elestiriler.map((e) => elestiriKarti(e)),
        ],
      ),
      bottomNavigationBar: customBottomNav(),
    );
  }

  Widget elestiriKarti(Map<String, dynamic> e) {
    final id = e["id"] ?? e["ID"] ?? 0;
    final List yanitlar = (e["yanitlar"] ?? e["Yanitlar"] ?? []);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFFFFB3D9), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 15,
                backgroundColor: Color(0xFF1F1F1F),
                child: Icon(Icons.person, size: 20, color: Colors.white70),
              ),
              const SizedBox(width: 8),
              Text(
                e["kullaniciAdi"] ?? e["KullaniciAdi"] ?? "Kullanıcı",
                style: const TextStyle(
                  color: Color(0xFFFFB3D9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            e["yorum"] ?? e["Yorum"] ?? "",
            style: const TextStyle(color: Colors.white70),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed:
                  () => setState(
                    () =>
                        aktifYanitElestiriId =
                            (aktifYanitElestiriId == id ? null : id),
                  ),
              child: const Text(
                "Yanıtla",
                style: TextStyle(color: Color(0xFFFFB3D9), fontSize: 13),
              ),
            ),
          ),
          if (aktifYanitElestiriId == id)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  TextField(
                    controller: yanitCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Yanıtınızı yazın...",
                      filled: true,
                      fillColor: const Color(0xFF1F1F1F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            () => setState(() => aktifYanitElestiriId = null),
                        child: const Text(
                          "İptal",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => yanitEkle(id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB3D9),
                        ),
                        child: const Text(
                          "Gönder",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ...yanitlar.map(
            (y) => Container(
              margin: const EdgeInsets.only(left: 20, top: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: Color(0xFFFFB3D9), width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    y["kullaniciAdi"] ?? y["KullaniciAdi"] ?? "Kullanıcı",
                    style: const TextStyle(
                      color: Color(0xFFFFB3D9),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    y["yorum"] ?? y["Yorum"] ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget filmButon(String text, bool aktif, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: aktif ? const Color(0xFFFFB3D9) : const Color(0xFF262626),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            aktif ? "$text ✓" : text,
            style: TextStyle(
              color: aktif ? Colors.black : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget customBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      backgroundColor: const Color(0xFF1F1F1F),
      selectedItemColor: const Color(0xFFFFB3D9),
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        if (i == 0) return;
        Widget p;
        if (i == 1) {
          p = MesajScreen(benimID: widget.benimID);
        } else if (i == 2) {
          p = BildirimScreen(benimID: widget.benimID);
        } else {
          p = HesapScreen(benimID: widget.benimID);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => p),
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
}
