// lib/models/lecturer.dart

class Lecturer {
  final String nik;
  final String name;

  Lecturer({
    required this.nik,
    required this.name,
  });

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      nik: json['nik'],
      name: json['name'],
    );
  }
}