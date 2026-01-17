import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SohbetScreen extends StatefulWidget {
  final int benimID;
  final int hedefID;
  final String hedefAdi;
  final String? profilFoto;

  const SohbetScreen({
    super.key,
    required this.benimID,
    required this.hedefID,
    required this.hedefAdi,
    this.profilFoto,
  });

  @override
  State<SohbetScreen> createState() => _SohbetScreenState();
}

class _SohbetScreenState extends State<SohbetScreen> {
  static const String apiBase =
      "https://unfrounced-cordia-equiponderant.ngrok-free.dev";

  List mesajlar = [];
  final TextEditingController ctrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true;
  bool isSending = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    loadMesajlar();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!isSending) {
        loadMesajlar();
      }
    });
  }

  @override
  void dispose() {
    ctrl.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadMesajlar() async {
    try {
      final res = await http.get(
        Uri.parse(
          "$apiBase/api/mesaj/sohbet?benimId=${widget.benimID}&digerId=${widget.hedefID}",
        ),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            mesajlar = data is List ? data : [];
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print("Mesajlar yüklenirken hata: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> gonder() async {
    if (ctrl.text.trim().isEmpty) return;

    final mesajText = ctrl.text.trim();
    ctrl.clear();

    setState(() => isSending = true);

    try {
      final res = await http.post(
        Uri.parse("$apiBase/api/mesaj"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({
          "GonderenID": widget.benimID,
          "AliciID": widget.hedefID,
          "Metin": mesajText,
        }),
      );

      if (res.statusCode == 200) {
        await loadMesajlar();
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } else {
        ctrl.text = mesajText;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Mesaj gönderilemedi (${res.statusCode})"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      print("Mesaj gönderme hatası: $e");
      ctrl.text = mesajText;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bağlantı hatası"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFB3D9)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFFB3D9),
              child: ClipOval(
                child:
                    widget.profilFoto != null && widget.profilFoto!.isNotEmpty
                        ? Image.network(
                          "$apiBase/${widget.profilFoto}",
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Text(
                              widget.hedefAdi.isNotEmpty
                                  ? widget.hedefAdi[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        )
                        : Text(
                          widget.hedefAdi.isNotEmpty
                              ? widget.hedefAdi[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),

            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.hedefAdi,
                style: const TextStyle(
                  color: Color(0xFFFFB3D9),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFFB3D9)),
            onPressed: loadMesajlar,
            tooltip: "Yenile",
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFB3D9),
                      ),
                    )
                    : mesajlar.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Henüz mesaj yok\nİlk mesajı siz gönderin!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: mesajlar.length,
                      itemBuilder: (_, i) {
                        final m = mesajlar[mesajlar.length - 1 - i];

                        final gonderenID = m["GonderenID"] ?? m["gonderenID"];
                        final metin = m["Metin"] ?? m["metin"] ?? "";
                        final tarih = m["Tarih"] ?? m["tarih"] ?? "";

                        final benMi = gonderenID == widget.benimID;

                        String formattedTime = "";
                        if (tarih.isNotEmpty) {
                          try {
                            final dt = DateTime.parse(tarih);
                            formattedTime =
                                "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                          } catch (e) {
                            formattedTime = "";
                          }
                        }

                        return Align(
                          alignment:
                              benMi
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment:
                                benMi
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      benMi
                                          ? const Color(0xFFFFB3D9)
                                          : const Color(0xFF262626),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(benMi ? 16 : 4),
                                    bottomRight: Radius.circular(
                                      benMi ? 4 : 16,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  metin,
                                  style: TextStyle(
                                    color: benMi ? Colors.black : Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (formattedTime.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    formattedTime,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                    ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      enabled: !isSending,
                      style: const TextStyle(color: Colors.white),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => gonder(),
                      decoration: InputDecoration(
                        hintText:
                            isSending ? "Gönderiliyor..." : "Mesaj yaz...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF262626),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isSending ? Colors.grey : const Color(0xFF6EE7B7),
                      shape: BoxShape.circle,
                    ),
                    child:
                        isSending
                            ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                            : IconButton(
                              icon: const Icon(Icons.send, color: Colors.black),
                              onPressed: gonder,
                              tooltip: "Gönder",
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
