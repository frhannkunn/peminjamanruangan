// lib/services/workspacedetail_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 1. Impor model Workspace LENGKAP yang baru kita perbaiki
import '../models/workspace.dart'; 

class WorkspaceDetailService {
  //hp fisik
  // final String baseUrl = 'http://10.65.235.18:8000/api';
  // 2. Pastikan IP ini sama dengan service lain
  final String baseUrl = 'http://10.0.2.2:8000/api'; 

  // 3. Fungsi ini akan mengembalikan 1 object Workspace (yang berisi 'details')
  Future<Workspace> getWorkspaceDetail(int workspaceId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    // 4. Endpoint 'show' dari ApiWorkspaceController
    final String url = '$baseUrl/workspaces/$workspaceId'; 

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
      
      // 5. 'data' adalah object 'Workspace' tunggal
      final Map<String, dynamic> workspaceJson = body['data']; 

      // 6. Parse menggunakan model Workspace (yang sudah diupdate)
      return Workspace.fromJson(workspaceJson);

    } else if (response.statusCode == 404) {
      // 7. Tangani jika 404
      throw Exception('Workspace tidak ditemukan.');
    } else {
      // 8. Tangani error server lainnya
      try {
        final body = json.decode(response.body);
        throw Exception('Gagal memuat detail: ${body['message']}');
      } catch (e) {
        throw Exception('Gagal memuat detail. Status code: ${response.statusCode}');
      }
    }
  }
}