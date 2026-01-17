class Kullanici {
  final int id;
  final String isim;
  final String email;
  final String kullaniciAdi;
  final String rol;
  final String? hakkimda;

  Kullanici({
    required this.id,
    required this.isim,
    required this.email,
    required this.kullaniciAdi,
    required this.rol,
    this.hakkimda,
  });

  factory Kullanici.fromJson(Map<String, dynamic> json) {
    return Kullanici(
      id: json['id'],
      isim: json['isim'],
      email: json['email'],
      kullaniciAdi: json['kullaniciAdi'],
      rol: json['rol'],
      hakkimda: json['hakkimda'],
    );
  }
}
