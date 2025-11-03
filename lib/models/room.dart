// lib/models/room.dart

class Room {
  final int id;
  final String code;
  final String name;
  final String building;
  final int capacity;

  Room({
    required this.id,
    required this.code,
    required this.name,
    required this.building,
    required this.capacity,
  });

  // Factory constructor untuk membuat Room dari JSON
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? 'Tanpa Nama',
      building: json['building'] ?? 'Tanpa Gedung',
      capacity: json['capacity'] ?? 0,
    );
  }
}