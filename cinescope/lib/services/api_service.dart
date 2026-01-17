import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kullanici.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:5000/api/kullanici";

  Future<List<Kullanici>> getKullanicilar() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => Kullanici.fromJson(e)).toList();
    } else {
      throw Exception("Kullanıcılar alınamadı");
    }
  }

  Future<Kullanici?> login(String kullaniciAdi, String sifre) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"kullaniciAdi": kullaniciAdi, "sifre": sifre}),
    );

    if (response.statusCode == 200) {
      return Kullanici.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 401) {
      return null;
    }
    throw Exception("Sunucu hatası: ${response.statusCode}");
  }

  Future<bool> register({
    required String isim,
    required String email,
    required String kullaniciAdi,
    required String sifre,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "isim": isim,
        "email": email,
        "kullaniciAdi": kullaniciAdi,
        "sifre": sifre,
        "rol": "Kullanici",
        "hakkimda": "",
      }),
    );

    return response.statusCode == 201;
  }
}
