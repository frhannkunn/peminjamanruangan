// lib/services/room_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
// Pastikan path ke model Anda sudah benar
import '../models/room.dart'; 
import '../models/workspace.dart'; 

class RoomService {
  
  // URL base untuk API (10.0.2.2 adalah untuk emulator Android)
  final String baseUrl = 'http://10.0.2.2:8000/api'; 

  
  Future<Map<String, List<Room>>> getGroupedRooms() async {
    final prefs = await SharedPreferences.getInstance();
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
      // 'data' dari API /rooms adalah Map<String, dynamic>
      final data = body['data'] as Map<String, dynamic>;

      Map<String, List<Room>> groupedRooms = {};
      data.forEach((buildingName, roomListJson) {
        List<Room> rooms = (roomListJson as List)
            .map((roomJson) => Room.fromJson(roomJson as Map<String, dynamic>))
            .toList();
        groupedRooms[buildingName] = rooms;
      });

      return groupedRooms;
    } else {
      try {
        final body = json.decode(response.body);
        throw Exception('Gagal memuat ruangan: ${body['message']}');
      } catch (e) {
        throw Exception('Gagal memuat ruangan. Status code: ${response.statusCode}');
      }
    }
  }

 
  Future<List<Workspace>> getWorkspacesForRoom(int roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    // Panggil API dengan query parameter
    final String url = '$baseUrl/workspaces?rooms_id=$roomId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Decode body
      final dynamic body = json.decode(response.body);
      
      // =============================================
      // ❗️ INI ADALAH LOGIKA YANG MEMPERBAIKI ERROR ANDA ❗️
      // =============================================
      
      List<dynamic> listJson; // Variabel untuk menampung list

      // Cek: Apakah 'body' adalah List? (Sesuai Postman Anda)
      if (body is List) {
        listJson = body;
      } 
      // Cek: Apakah 'body' adalah Map DAN punya key 'data'?
      else if (body is Map<String, dynamic> && body.containsKey('data')) {
        // Cek jika 'data'-nya null
        if (body['data'] == null) {
          return []; // Kembalikan list kosong
        }
        listJson = body['data'] as List;
      }
      // Jika 'body' null atau formatnya tidak dikenal
      else {
        return []; // Kembalikan list kosong
      }
      // =============================================
      
      // Ubah setiap item di 'listJson' menjadi objek Workspace
      return listJson.map((json) {
        return Workspace.fromJson(json as Map<String, dynamic>);
      }).toList();

    } else {
      // Jika status code bukan 200 (misal 404 atau 500)
      try {
        final body = json.decode(response.body);
        throw Exception('Gagal memuat workspace: ${body['message']}');
      } catch (e) {
        throw Exception('Gagal memuat workspace. Status code: ${response.statusCode}');
      }
    }
  }
}