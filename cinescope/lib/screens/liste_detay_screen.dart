import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'filmsayfasi.dart';
import 'dizisayfasi.dart';

class ListeDetayScreen extends StatefulWidget {
  final int benimID;
  final int listeId;

  const ListeDetayScreen({
    super.key,
    required this.benimID,
    required this.listeId,
  });

  @override
  State<ListeDetayScreen> createState() => _ListeDetayScreenState();
}

class _ListeDetayScreenState extends State<ListeDetayScreen> {
  static const String apiBase =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev/api";
  static const String tmdbImg = "https://image.tmdb.org/t/p/w500";

  bool loading = true;

  String listeAdi = "";
  String aciklama = "";
  String gorunurluk = "";
  String? kapakFoto;

  List icerikler = [];

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final res = await http.get(
      Uri.parse("$apiBase/liste/${widget.listeId}"),
      headers: {"ngrok-skip-browser-warning": "true"},
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);

      setState(() {
        listeAdi = json["listeAdi"] ?? "";
        aciklama = json["aciklama"] ?? "";
        gorunurluk = json["gorunurluk"] ?? "";
        icerikler = jsonDecode(json["filmler"] ?? "[]");
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Text(listeAdi, style: const TextStyle(color: Color(0xFFFFB3D9))),
      ),
      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFB3D9)),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kapakFoto != null && kapakFoto!.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        "$tmdbImg$kapakFoto",
                        fit: BoxFit.cover,
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listeAdi,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (aciklama.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            aciklama,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                gorunurluk == "Public"
                                    ? const Color(0xFFFFB3D9)
                                    : Colors.grey[700],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            gorunurluk == "Public" ? "Herkese Açık" : "Gizli",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white12),

                  Expanded(
                    child:
                        icerikler.isEmpty
                            ? const Center(
                              child: Text(
                                "Liste boş",
                                style: TextStyle(color: Colors.white38),
                              ),
                            )
                            : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: icerikler.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.65,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                              itemBuilder: (_, i) {
                                final f = icerikler[i];
                                final poster =
                                    f["posterPath"] ?? f["poster"] ?? "";

                                return GestureDetector(
                                  onTap: () {
                                    if (f["type"] == "dizi") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => DiziSayfasi(
                                                benimID: widget.benimID,
                                                dizi: f,
                                              ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => FilmSayfasi(
                                                benimID: widget.benimID,
                                                film: f,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        poster.isNotEmpty
                                            ? Image.network(
                                              "$tmdbImg$poster",
                                              fit: BoxFit.cover,
                                            )
                                            : Container(
                                              color: Colors.grey[900],
                                              child: const Icon(
                                                Icons.movie,
                                                color: Colors.white24,
                                              ),
                                            ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
