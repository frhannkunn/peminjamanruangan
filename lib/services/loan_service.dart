import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/loan.dart';
import '../models/loan_user.dart';
import 'user_session.dart'; 
import '../models/lecturer.dart';
import '../models/room.dart';
import '../models/calendar_event.dart';
import '../models/workspace.dart';

class LoanService {
  // ⚠️ GANTI IP SESUAI PERANGKAT
  // Emulator: 10.0.2.2
  // HP Fisik: IP Laptop (Cth: 192.168.1.x)
  final String _baseUrl = 'http://10.0.2.2:8000/api'; 

  // --- HELPERS ---

  Future<Map<String, String>> _getHeaders() async {
    String? token = await UserSession.getToken();
    if (token == null) {
      throw Exception("User tidak terautentikasi.");
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body['success'] == true) {
        return body['data']; 
      } else {
        throw Exception(body['message'] ?? 'Terjadi kesalahan pada server');
      }
    } else {
      String errorMessage = body['message'] ?? 'Gagal memuat data';
      if (body['errors'] != null && body['errors'] is Map) {
        errorMessage = body['errors'].values.first[0];
      }
      throw Exception(errorMessage);
    }
  }

  // ===========================================
  // 1. KALENDER (MOBILE CALENDAR)
  // ===========================================
  Future<List<CalendarEvent>> getCalendarEvents(String roomId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rooms/$roomId/mobile-calendar'), 
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CalendarEvent.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat kalender');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ===========================================
  // 2. DATA MASTER (DROPDOWN & WORKSPACE)
  // ===========================================
  Future<List<Lecturer>> getLecturers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/lectures'), headers: await _getHeaders());
      final data = _handleResponse(response) as List;
      return data.map((json) => Lecturer.fromJson(json)).toList();
    } catch (e) { rethrow; }
  }

  Future<Map<String, List<Room>>> getRooms() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/rooms'), headers: await _getHeaders());
      final data = _handleResponse(response) as Map<String, dynamic>;
      Map<String, List<Room>> parsedMap = {};
      data.forEach((buildingName, roomList) {
        List<Room> rooms = (roomList as List).map((roomJson) => Room.fromJson(roomJson)).toList();
        parsedMap[buildingName] = rooms;
      });
      return parsedMap;
    } catch (e) { rethrow; }
  }
  
  Future<List<Workspace>> getWorkspaces(String roomId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/workspaces?rooms_id=$roomId'), headers: await _getHeaders());
      final body = json.decode(response.body);
      List<dynamic> data = (body is Map && body.containsKey('data')) ? body['data'] : body;
      return data.map((json) => Workspace.fromJson(json)).toList();
    } catch (e) { throw Exception('Gagal memuat workspace: $e'); }
  }

  // ===========================================
  // 3. CRUD LOAN (SIMPAN DRAFT)
  // ===========================================
  Future<List<Loan>> getLoans() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/loans'), headers: await _getHeaders());
      final data = _handleResponse(response) as List;
      return data.map((json) => Loan.fromJson(json)).toList();
    } catch (e) { rethrow; }
  }

  Future<Loan> createLoan(Map<String, dynamic> loanData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/loans'), 
        headers: await _getHeaders(),
        body: json.encode(loanData),
      );
      final data = _handleResponse(response);
      return Loan.fromJson(data);
    } catch (e) { rethrow; }
  }

  Future<Loan> getLoanDetail(String loanId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/loans/$loanId'), headers: await _getHeaders());
      final data = _handleResponse(response);
      return Loan.fromJson(data);
    } catch (e) { rethrow; }
  }

  Future<Loan> updateLoan(String loanId, Map<String, dynamic> loanData) async {
    try {
      final response = await http.put( // Gunakan PUT
        Uri.parse('$_baseUrl/loans/$loanId'), 
        headers: await _getHeaders(),
        body: json.encode(loanData),
      );
      final data = _handleResponse(response);
      return Loan.fromJson(data);
    } catch (e) { rethrow; }
  }

  // ===========================================
  // 4. MANAJEMEN USER (TAMBAH & HAPUS)
  // ===========================================
  Future<LoanUser> addUserToLoan(String loanId, Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/loans/$loanId/users'), 
        headers: await _getHeaders(),
        body: json.encode(userData),
      );
      final data = _handleResponse(response);
      return LoanUser.fromJson(data);
    } catch (e) { rethrow; }
  }

  Future<List<LoanUser>> getLoanUsers(String loanId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/loans/$loanId/users'), 
        headers: await _getHeaders(),
      );
      
      // Menggunakan _handleResponse yang sudah ada
      final data = _handleResponse(response);
      
      // Pastikan data berupa List sebelum di-map
      if (data is List) {
        return data.map((json) => LoanUser.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) { rethrow; }
  }

  // ✅ FUNGSI DELETE YANG BENAR (Return Bool)
  Future<bool> deleteLoanUser(String loanId, String loanUserId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/loans/$loanId/users/$loanUserId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        throw Exception('Gagal menghapus pengguna');
      }
    } catch (e) { rethrow; }
  }

  // ===========================================
  // 5. FINAL SUBMIT (AJUKAN) - ANTI CRASH
  // ===========================================
  
  // ✅ PENTING: Return Future<bool> dan TIDAK parsing data Loan
  Future<bool> submitLoan(String loanId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/loans/$loanId/submit'),
        headers: await _getHeaders(),
      );

      // Cek status code manual
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true; // SUKSES
      } else {
        final body = json.decode(response.body);
        throw Exception(body['message'] ?? 'Gagal mengajukan peminjaman');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ===========================================
  // 6. HAPUS PEMINJAMAN
  // ===========================================
  Future<String> deleteLoan(String loanId) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/loans/$loanId'), headers: await _getHeaders());
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300 && body['success'] == true) {
        return body['message'];
      } else {
        throw Exception(body['message'] ?? 'Gagal menghapus peminjaman');
      }
    } catch (e) { rethrow; }
  }
  
  // Legacy Support (Boleh dihapus jika tidak dipakai)
  Future<String> removeUserFromLoan(String loanId, String loanUserId) async {
     try {
      final response = await http.delete(Uri.parse('$_baseUrl/loans/$loanId/users/$loanUserId'), headers: await _getHeaders());
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300 && body['success'] == true) {
        return body['message'];
      } else {
        throw Exception(body['message'] ?? 'Gagal menghapus pengguna');
      }
    } catch (e) { rethrow; }
  }
}

