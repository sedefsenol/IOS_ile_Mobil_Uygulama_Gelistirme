import 'package:flutter/material.dart';

class AyarlarScreen extends StatefulWidget {
  final int benimID;
  const AyarlarScreen({super.key, required this.benimID});

  @override
  State<AyarlarScreen> createState() => _AyarlarScreenState();
}

class _AyarlarScreenState extends State<AyarlarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        title: const Text(
          "Ayarlar",
          style: TextStyle(
            color: Color(0xFFFFB3D9),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFB3D9)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ayarOgesi(Icons.person_outline, "Profili Düzenle", () {}),
          _ayarOgesi(Icons.notifications_none, "Bildirim Ayarları", () {}),
          _ayarOgesi(Icons.lock_outline, "Gizlilik ve Güvenlik", () {}),
          _ayarOgesi(Icons.help_outline, "Yardım ve Destek", () {}),
          const Divider(color: Colors.white10, height: 40),
          _ayarOgesi(Icons.logout, "Çıkış Yap", () {}, renk: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _ayarOgesi(
    IconData icon,
    String baslik,
    VoidCallback onTap, {
    Color renk = Colors.white70,
  }) {
    return ListTile(
      leading: Icon(icon, color: renk),
      title: Text(baslik, style: TextStyle(color: renk, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }
}
