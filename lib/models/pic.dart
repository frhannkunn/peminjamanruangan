// models/pic.dart
// Model ini untuk menampung data PIC dari API
class Pic {
  final String nik;
  final String name;
  final String email;
  final String? whatsapp; // Dibuat opsional (bisa null)

  Pic({
    required this.nik,
    required this.name,
    required this.email,
    this.whatsapp,
  });

  factory Pic.fromJson(Map<String, dynamic> json) {
    return Pic(
      nik: json['nik'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      whatsapp: json['whatsapp'] as String?,
    );
  }
}