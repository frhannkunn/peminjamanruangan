// lib/services/room_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// Impor ini untuk mengakses token yang disimpan
import 'package:shared_preferences/shared_preferences.dart'; 
// Impor model yang baru kita buat
import '../models/room.dart'; 

class RoomService {
  
  // ⚠️ GANTI URL INI DENGAN IP KOMPUTER ANDA, BUKAN 127.0.0.1
  // Contoh: 'http://192.168.1.10:8000/api'
  final String baseUrl = 'http://127.0.0.1:8000/api'; 

  // Service ini mengembalikan PETA (Map)
  // Kunci: Nama Gedung (String), Nilai: List<Room>
  Future<Map<String, List<Room>>> getGroupedRooms() async {
    final prefs = await SharedPreferences.getInstance();
    // Pastikan key 'auth_token' ini sama dengan yang Anda simpan saat login
    final String? token = prefs.getString('auth_token'); 

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/rooms'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      // 'data' dari API adalah Map<String, dynamic>
      final data = body['data'] as Map<String, dynamic>;

      // Kita perlu konversi Map<String, dynamic> -> Map<String, List<Room>>
      Map<String, List<Room>> groupedRooms = {};
      data.forEach((buildingName, roomListJson) {
        // roomListJson adalah List<dynamic>
        List<Room> rooms = (roomListJson as List)
            .map((roomJson) => Room.fromJson(roomJson as Map<String, dynamic>))
            .toList();
        groupedRooms[buildingName] = rooms;
      });

      return groupedRooms;
    } else {
      // Coba decode body error jika ada
      try {
        final body = json.decode(response.body);
        throw Exception('Gagal memuat ruangan: ${body['message']}');
      } catch (e) {
        throw Exception('Gagal memuat ruangan. Status code: ${response.statusCode}');
      }
    }
  }
}