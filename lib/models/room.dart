// lib/models/room.dart

import 'pic.dart'; // 1. PASTIKAN ANDA SUDAH IMPORT 'pic.dart'

class Room {
  final int id;
  final String name;
  final String code;
  final String building;
  final int capacity;
  final List<Pic> pics; // 2. List untuk menampung data PIC

  Room({
    required this.id,
    required this.name,
    required this.code,
    required this.building,
    required this.capacity,
    required this.pics, // 3. Tambahkan di constructor
  });

  // 4. Factory constructor untuk membuat Room dari JSON
  factory Room.fromJson(Map<String, dynamic> json) {
    
    // =============================================
    // ❗️ INI ADALAH PERBAIKANNYA ❗️
    // =============================================
    
    List<Pic> picsData = []; // 1. Buat list kosong sebagai default

    // 2. Cek apakah 'pics' di JSON tidak null
    if (json['pics'] != null) { 
      // 3. Jika tidak null, baru parsing seperti biasa
      var picList = json['pics'] as List;
      picsData = picList.map((i) => Pic.fromJson(i as Map<String, dynamic>)).toList();
    }
    // Jika 'pics' null, 'picsData' akan tetap menjadi list kosong [], 
    // sehingga aplikasi aman dan tidak crash.
    
    // =============================================

    return Room(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? 'Tanpa Nama',
      building: json['building'] ?? 'Tanpa Gedung',
      capacity: json['capacity'] ?? 0,
      pics: picsData, // 5. Masukkan data pics yang sudah aman (picsData)
    );
  }
}