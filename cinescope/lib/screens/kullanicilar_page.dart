import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/kullanici.dart';

class KullanicilarPage extends StatefulWidget {
  const KullanicilarPage({super.key});

  @override
  State<KullanicilarPage> createState() => _KullanicilarPageState();
}

class _KullanicilarPageState extends State<KullanicilarPage> {
  List<Kullanici> _kullanicilar = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKullanicilar();
  }

  Future<void> _fetchKullanicilar() async {
    final url = Uri.parse('http://10.0.2.2:5000/api/Kullanicilar');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _kullanicilar = jsonList.map((e) => Kullanici.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: ${response.statusCode}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('İstek Hatası: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcılar')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _kullanicilar.length,
                itemBuilder: (context, index) {
                  final user = _kullanicilar[index];
                  return ListTile(
                    title: Text(user.isim),
                    subtitle: Text(user.email),
                  );
                },
              ),
    );
  }
}
