// File: lib/services/pic_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pic.dart';
// 1. Import UserSession
import 'user_session.dart'; 

class PicService {
  // ⚠️ PASTIKAN IP INI SUDAH BENAR SESUAI LAPTOP ANDA
  final String baseUrl = 'http://10.0.2.2:8000/api'; 

  // 2. Gunakan UserSession untuk ambil token agar kuncinya cocok
  Future<String?> _getToken() async {
    return await UserSession.getToken();
  }

  // --- 1. GET LIST APPROVAL PIC ---
  Future<List<PeminjamanPic>> getApprovalList({
    String? roomsId, 
    String? statusFilter
  }) async {
    String? token = await _getToken();
    
    // Debugging: Cek di console apakah token ada
    print("Token yang dikirim: $token"); 

    Map<String, String> queryParams = {};
    if (roomsId != null && roomsId != 'All') {
      queryParams['rooms_id'] = roomsId;
    }
    if (statusFilter != null && statusFilter != 'All') {
      queryParams['status_filter'] = statusFilter;
    }

    Uri uri = Uri.parse('$baseUrl/pic/approval/ruangan')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Token wajib ada
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['success'] == true) {
        List<dynamic> dataList = jsonResponse['data']['data'];
        return dataList.map((e) => PeminjamanPic.fromJson(e)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Gagal mengambil data approval');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Sesi habis (401). Silakan logout dan login ulang.');
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode}');
    }
  }

  // --- 2. GET DETAIL APPROVAL PIC ---
  Future<PeminjamanPicDetailModel> getApprovalDetail(String loanId) async {
    String? token = await _getToken();
    final url = '$baseUrl/pic/approval/ruangan/$loanId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['success'] == true) {
        return PeminjamanPicDetailModel.fromJson(jsonResponse['data']);
      } else {
         throw Exception(jsonResponse['message'] ?? 'Data tidak ditemukan');
      }
    } else if (response.statusCode == 403) {
      throw Exception('Unauthorized: Anda bukan PIC ruangan ini.');
    } else if (response.statusCode == 401) {
      throw Exception('Sesi habis (401). Silakan logout dan login ulang.');
    } else {
      throw Exception('Gagal memuat detail: ${response.statusCode}');
    }
  }

  // --- 3. POST APPROVE/REJECT ---
  Future<bool> submitApproval({
    required String loanId,
    required int status, 
    required String comment,
  }) async {
    String? token = await _getToken();
    final url = '$baseUrl/pic/approval/ruangan/$loanId';

    final body = jsonEncode({
      'pic_approval': status, 
      'pic_comment': comment, 
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['success'] == true;
    } else if (response.statusCode == 422) {
      final jsonResponse = jsonDecode(response.body);
      throw Exception(jsonResponse['message'] ?? 'Data tidak valid');
    } else if (response.statusCode == 401) {
       throw Exception('Sesi habis (401). Silakan logout dan login ulang.');
    } else {
      throw Exception('Gagal mengirim approval: ${response.statusCode}');
    }
  }
}