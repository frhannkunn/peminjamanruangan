// lib/services/room_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import '../models/room.dart'; 
// ➕ 1. TAMBAHKAN IMPORT INI
import '../models/workspace.dart'; 

class RoomService {
  
  final String baseUrl = 'http://10.0.2.2:8000/api'; 

  // --- FUNGSI LAMA ANDA (SUDAH BENAR) ---
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

  // --- 👇 2. TAMBAHKAN FUNGSI BARU INI (YANG HILANG) 👇 ---
  
  Future<List<Workspace>> getWorkspacesForRoom(int roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    // 💡 Endpoint ini disesuaikan dengan ApiWorkspaceController.php Anda
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
      final body = json.decode(response.body);
      
      // 'data' dari API adalah List<dynamic>
      final List listJson = body['data'] as List;

      return listJson.map((json) {
        return Workspace.fromJson(json as Map<String, dynamic>);
      }).toList();

    } else {
      try {
        final body = json.decode(response.body);
        throw Exception('Gagal memuat workspace: ${body['message']}');
      } catch (e) {
        throw Exception('Gagal memuat workspace. Status code: ${response.statusCode}');
      }
    }
  }
  // --- 👆 BATAS AKHIR FUNGSI BARU 👆 ---
}