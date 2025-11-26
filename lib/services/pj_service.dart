import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';
import '../models/pj_models.dart';

class PjService {
  // GANTI IP SESUAI PERANGKAT
  final String _baseUrl = 'http://10.0.2.2:8000/api'; 

  Future<Map<String, String>> _getHeaders() async {
    String? token = await UserSession.getToken();
    if (token == null) throw Exception("Unauthorized");
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. GET LIST APPROVAL (HOME)
  // Pastikan route di Laravel: Route::get('/pj/loans', [ApiPenanggungJawabController::class, 'index']);
  Future<List<PeminjamanPj>> getApprovals() async {
    try {
      // Endpoint sesuai controller index()
      // Saya asumsi Anda membuat route khusus untuk PJ, misal /pj/loans
      final response = await http.get(
        Uri.parse('$_baseUrl/penanggung-jawab/approval/ruangan'), 
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          List data = body['data']['data']; // Karena pakai paginate, data ada di dalam data.data
          return data.map((json) => PeminjamanPj.fromJson(json)).toList();
        }
      }
      throw Exception('Gagal memuat data approval');
    } catch (e) {
      rethrow;
    }
  }

  // 2. GET DETAIL (DETAIL PAGE)
  // Pastikan route di Laravel: Route::get('/pj/loans/{id}', [ApiPenanggungJawabController::class, 'show']);
  Future<PeminjamanPjDetailModel> getDetail(String loanId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/penanggung-jawab/approval/ruangan/$loanId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
return PeminjamanPjDetailModel.fromJson(body['data']);        }
      }
      throw Exception('Gagal memuat detail');
    } catch (e) {
      rethrow;
    }
  }

  // 3. SUBMIT APPROVAL
  // Pastikan route di Laravel: Route::post('/pj/loans/{id}', [ApiPenanggungJawabController::class, 'store']);
  Future<bool> submitApproval(String loanId, int status, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/penanggung-jawab/approval/ruangan/$loanId'),
        headers: await _getHeaders(),
        body: json.encode({
          'lecture_approval': status, // 1: Setuju, 0: Tolak
          'lecture_comment': comment,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        final body = json.decode(response.body);
        throw Exception(body['message'] ?? 'Gagal menyimpan approval');
      }
    } catch (e) {
      rethrow;
    }
  }
}