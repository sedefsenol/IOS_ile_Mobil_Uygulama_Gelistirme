import 'package:cinescope/screens/FilmlerScreen.dart';
import 'package:cinescope/screens/aramascreen.dart';
import 'package:cinescope/screens/bildirimscreen.dart';
import 'package:cinescope/screens/dizilerscreen.dart';
import 'package:cinescope/screens/elestirilerscreen.dart';
import 'package:cinescope/screens/hesapscreen.dart';
import 'package:cinescope/screens/mesajscreen.dart';
import 'package:flutter/material.dart';

import '../screens/home_screen.dart';

class CineScopeScaffold extends StatelessWidget {
  final Widget body;
  final int benimID;

  final int topIndex;

  final int bottomIndex;

  const CineScopeScaffold({
    super.key,
    required this.body,
    required this.benimID,
    required this.topIndex,
    required this.bottomIndex,
  });

  static const Color pink = Color(0xFFFFB3D9);
  static const Color bg = Color(0xFF1F1F1F);

  void _goReplace(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: Row(
            children: [
              const Text(
                "CineScope",
                style: TextStyle(
                  color: pink,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 24),

              _topItem(context, "Filmler", 0, FilmlerScreen(benimID: benimID)),
              const SizedBox(width: 16),

              _topItem(context, "Diziler", 1, DizilerScreen(benimID: benimID)),
              const SizedBox(width: 16),

              _topItem(
                context,
                "Eleştiriler",
                2,
                ElestirilerScreen(benimID: benimID),
              ),

              const Spacer(),

              _topItem(
                context,
                "Arama",
                3,
                AramaScreen(benimID: benimID),
                icon: Icons.search,
              ),
            ],
          ),
        ),
      ),

      body: body,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomIndex,
        backgroundColor: bg,
        selectedItemColor: pink,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          switch (i) {
            case 0:
              _goReplace(context, HomeScreen(benimID: benimID));
              break;
            case 1:
              _goReplace(context, MesajScreen(benimID: benimID));
              break;
            case 2:
              _goReplace(context, BildirimScreen(benimID: benimID));
              break;
            case 3:
              _goReplace(context, HesapScreen(benimID: benimID));
              break;
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

  Widget _topItem(
    BuildContext context,
    String title,
    int index,
    Widget page, {
    IconData? icon,
  }) {
    final bool active = topIndex == index;

    return GestureDetector(
      onTap: () {
        if (active) return;
        _goReplace(context, page);
      },
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, size: 18, color: active ? pink : Colors.white70),
          if (icon != null) const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: active ? pink : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
