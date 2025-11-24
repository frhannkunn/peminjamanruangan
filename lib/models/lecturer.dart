// lib/models/lecturer.dart

class Lecturer {
  final String code;
  final String nik;
  final String name;

  Lecturer({
    required this.code,
    required this.nik,
    required this.name,
  });

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      code: json['code'],
      nik: json['nik'],
      name: json['name'],
    );
  }
}