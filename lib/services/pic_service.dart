import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pic.dart'; // Import model yang baru

class PicService {
  // Ganti dengan IP Address Laravel kamu
  final String baseUrl = 'http://192.168.1.x:8000/api'; 

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); 
  }

  // --- 1. GET LIST APPROVAL PIC ---
  // Return List<PeminjamanPic>
  Future<List<PeminjamanPic>> getApprovalList({
    String? roomsId, 
    String? statusFilter
  }) async {
    String? token = await _getToken();
    
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
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['success'] == true) {
        List<dynamic> dataList = jsonResponse['data']['data'];
        // Menggunakan PeminjamanPic
        return dataList.map((e) => PeminjamanPic.fromJson(e)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Gagal mengambil data approval');
      }
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode}');
    }
  }

  // --- 2. GET DETAIL APPROVAL PIC ---
  // Return PeminjamanPicDetailModel
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
        // Menggunakan PeminjamanPicDetailModel
        return PeminjamanPicDetailModel.fromJson(jsonResponse['data']);
      } else {
         throw Exception(jsonResponse['message'] ?? 'Data tidak ditemukan');
      }
    } else if (response.statusCode == 403) {
      throw Exception('Unauthorized: Anda bukan PIC ruangan ini.');
    } else {
      throw Exception('Gagal memuat detail: ${response.statusCode}');
    }
  }

  // --- 3. POST APPROVE/REJECT ---
  Future<bool> submitApproval({
    required String loanId,
    required int status, // 1 = Setuju, 0 = Tolak
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
    } else {
      throw Exception('Gagal mengirim approval: ${response.statusCode}');
    }
  }
}