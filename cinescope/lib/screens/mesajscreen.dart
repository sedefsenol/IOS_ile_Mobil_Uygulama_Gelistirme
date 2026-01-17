import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'bildirimscreen.dart';
import 'hesapscreen.dart';
import 'sohbetscreen.dart';
import 'home_screen.dart';

class MesajScreen extends StatefulWidget {
  final int benimID;
  final int? digerKullaniciID;
  final String? digerKullaniciAdi;
  final String? digerProfilFoto;

  const MesajScreen({
    super.key,
    required this.benimID,
    this.digerKullaniciID,
    this.digerKullaniciAdi,
    this.digerProfilFoto,
  });

  @override
  State<MesajScreen> createState() => _MesajScreenState();
}

class _MesajScreenState extends State<MesajScreen>
    with SingleTickerProviderStateMixin {
  static const String apiBase =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev";

  late TabController _tabController;
  late Future<List> mesajlarFuture;
  late Future<List> isteklerFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    yenile();
  }

  void yenile() {
    mesajlarFuture = fetchMesajlar();
    isteklerFuture = fetchIstekler();
  }

  Future<List> fetchMesajlar() async {
    final res = await http.get(
      Uri.parse("$apiBase/api/mesaj/konusmalar/${widget.benimID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    return res.statusCode == 200 ? jsonDecode(res.body) : [];
  }

  Future<List> fetchIstekler() async {
    final res = await http.get(
      Uri.parse("$apiBase/api/mesaj/istekler/${widget.benimID}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );
    return res.statusCode == 200 ? jsonDecode(res.body) : [];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.digerKullaniciID != null && widget.digerKullaniciAdi != null) {
      return SohbetScreen(
        benimID: widget.benimID,
        hedefID: widget.digerKullaniciID!,
        hedefAdi: widget.digerKullaniciAdi!,
        profilFoto: widget.digerProfilFoto,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text(
          "CineScope",
          style: TextStyle(color: Color(0xFFFFB3D9)),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFB3D9),
          labelColor: const Color(0xFFFFB3D9),
          unselectedLabelColor: Colors.white54,
          tabs: const [Tab(text: "Mesajlar"), Tab(text: "İstekler")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_mesajListesi(), _istekListesi()],
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _mesajListesi() => FutureBuilder<List>(
    future: mesajlarFuture,
    builder: (_, s) {
      if (!s.hasData) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFB3D9)),
        );
      }

      if (s.data!.isEmpty) {
        return const Center(
          child: Text(
            "Henüz mesaj yok",
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      return ListView.builder(
        itemCount: s.data!.length,
        itemBuilder: (_, i) {
          final x = s.data![i];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFB3D9),
              child: Icon(Icons.person, color: Colors.black),
            ),
            title: Text(
              x["kullaniciAdi"],
              style: const TextStyle(color: Color(0xFFFFB3D9)),
            ),
            subtitle: Text(
              x["sonMesaj"] ?? "",
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => SohbetScreen(
                        benimID: widget.benimID,
                        hedefID: x["kullaniciID"],
                        hedefAdi: x["kullaniciAdi"],
                        profilFoto: x["profilFoto"],
                      ),
                ),
              ).then((_) => setState(() => yenile()));
            },
          );
        },
      );
    },
  );

  Widget _istekListesi() => FutureBuilder<List>(
    future: isteklerFuture,
    builder: (_, s) {
      if (!s.hasData) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFB3D9)),
        );
      }

      if (s.data!.isEmpty) {
        return const Center(
          child: Text(
            "Henüz istek yok",
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      return ListView.builder(
        itemCount: s.data!.length,
        itemBuilder: (_, i) {
          final x = s.data![i];

          return ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFFFB3D9),
              child: ClipOval(
                child:
                    x["profilFoto"] != null && x["profilFoto"].isNotEmpty
                        ? Image.network(
                          "$apiBase/${x["profilFoto"]}",
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const Icon(
                              Icons.person,
                              color: Colors.black,
                            );
                          },
                        )
                        : const Icon(Icons.person, color: Colors.black),
              ),
            ),
            title: Text(
              x["gonderenAdi"],
              style: const TextStyle(color: Color(0xFFFFB3D9)),
            ),
            subtitle: const Text(
              "Mesaj isteği",
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => SohbetScreen(
                        benimID: widget.benimID,
                        hedefID: x["gonderenID"],
                        hedefAdi: x["gonderenAdi"],
                        profilFoto: x["profilFoto"],
                      ),
                ),
              ).then((_) => setState(() => yenile()));
            },
          );
        },
      );
    },
  );

  Widget _bottomNav() => BottomNavigationBar(
    currentIndex: 1,
    backgroundColor: const Color(0xFF1F1F1F),
    selectedItemColor: const Color(0xFFFFB3D9),
    unselectedItemColor: Colors.white70,
    type: BottomNavigationBarType.fixed,
    onTap: (i) {
      if (i == 1) return;
      Widget page =
          (i == 0)
              ? HomeScreen(benimID: widget.benimID)
              : (i == 2
                  ? BildirimScreen(benimID: widget.benimID)
                  : HesapScreen(benimID: widget.benimID));
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
