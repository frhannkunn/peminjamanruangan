// lib/services/loan_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/loan.dart';
import '../models/loan_user.dart';
import 'user_session.dart'; 
import '../models/lecturer.dart';
import '../models/room.dart';
import '../models/calendar_event.dart';


class LoanService {
  final String _baseUrl = 'http://10.0.2.2:8000/api'; 

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
  // 3. FUNGSI BARU UNTUK KALENDER
  // ===========================================

  /// [GET] Ambil event kalender untuk 1 ruangan (ApiRoomController@calendarEvents)
  Future<List<CalendarEvent>> getCalendarEvents(String roomId) async {
    try {
      final response = await http.get(
        // Rute: GET /api/rooms/{id}/calendar-events
        Uri.parse('$_baseUrl/rooms/$roomId/calendar-events'), 
        headers: await _getHeaders(),
      );

      // PENTING: API ini mengembalikan List [ ... ] secara langsung,
      // BUKAN objek { success: true, data: [ ... ] }.
      // Jadi, kita tidak menggunakan _handleResponse.
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CalendarEvent.fromJson(json)).toList();
      } else {
        // Coba parse error jika ada
        try {
           final body = json.decode(response.body);
           throw Exception(body['message'] ?? 'Gagal memuat event kalender');
        } catch (e) {
           throw Exception('Gagal memuat event kalender (Status: ${response.statusCode})');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // ===========================================
  // 2. FUNGSI BARU UNTUK DROPDOWN
  // ===========================================

  /// [GET] Ambil semua data Dosen (ApiLectureController@index)
  Future<List<Lecturer>> getLecturers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lectures'), // GET /api/lectures
        headers: await _getHeaders(),
      );
      final data = _handleResponse(response) as List;
      return data.map((json) => Lecturer.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// [GET] Ambil semua data Ruangan (ApiRoomController@index)
  Future<Map<String, List<Room>>> getRooms() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rooms'), // GET /api/rooms
        headers: await _getHeaders(),
      );
      
      // Data dari API adalah: Map<String, dynamic>
      // {"Gedung Utama": [ ... (List<dynamic>) ... ], "Tower A": [ ... ]}
      final data = _handleResponse(response) as Map<String, dynamic>;
      
      // Kita perlu parse manual Map ini
      Map<String, List<Room>> parsedMap = {};
      data.forEach((buildingName, roomList) {
        // roomList adalah List<dynamic>, kita ubah ke List<Room>
        List<Room> rooms = (roomList as List)
            .map((roomJson) => Room.fromJson(roomJson))
            .toList();
        parsedMap[buildingName] = rooms;
      });
      
      return parsedMap;
    } catch (e) {
      rethrow;
    }
  }


  // ===========================================
  // FUNGSI LAMA (CRUD PEMINJAMAN)
  // (Tidak ada perubahan di bawah ini)
  // ===========================================

  /// 1. [GET] Ambil semua list peminjaman (ApiLoanController@index)
  Future<List<Loan>> getLoans() async {
    // ... (kode tetap sama) ...
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/loans'), 
        headers: await _getHeaders(),
      );
      final data = _handleResponse(response) as List;
      return data.map((json) => Loan.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 2. [POST] Buat peminjaman baru / draft (ApiLoanController@store)
  Future<Loan> createLoan(Map<String, dynamic> loanData) async {
    // ... (kode tetap sama) ...
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/loans'), 
        headers: await _getHeaders(),
        body: json.encode(loanData),
      );
      final data = _handleResponse(response);
      return Loan.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 3. [GET] Ambil detail 1 peminjaman (ApiLoanController@show)
  Future<Loan> getLoanDetail(String loanId) async {
    // ... (kode tetap sama) ...
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/loans/$loanId'), 
        headers: await _getHeaders(),
      );
      final data = _handleResponse(response);
      return Loan.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 4. [POST] Tambah pengguna ke peminjaman (ApiLoanController@addUserToLoan)
  Future<LoanUser> addUserToLoan(String loanId, Map<String, dynamic> userData) async {
    // ... (kode tetap sama) ...
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/loans/$loanId/users'), 
        headers: await _getHeaders(),
        body: json.encode(userData),
      );
      final data = _handleResponse(response);
      return LoanUser.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 5. [DELETE] Hapus pengguna dari peminjaman (ApiLoanController@removeUserFromLoan)
  Future<String> removeUserFromLoan(String loanId, String loanUserId) async {
    // ... (kode tetap sama) ...
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/loans/$loanId/users/$loanUserId'),
        headers: await _getHeaders(),
      );
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300 && body['success'] == true) {
        return body['message'];
      } else {
        throw Exception(body['message'] ?? 'Gagal menghapus pengguna');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 6. [POST] Ajukan/Submit peminjaman (ApiLoanController@submitLoan)
  Future<Loan> submitLoan(String loanId) async {
    // ... (kode tetap sama) ...
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/loans/$loanId/submit'),
        headers: await _getHeaders(),
      );
      final data = _handleResponse(response);
      return Loan.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 7. [DELETE] Hapus/Batalkan peminjaman (ApiLoanController@destroy)
  Future<String> deleteLoan(String loanId) async {
    // ... (kode tetap sama) ...
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/loans/$loanId'), 
        headers: await _getHeaders(),
      );
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300 && body['success'] == true) {
        return body['message'];
      } else {
        throw Exception(body['message'] ?? 'Gagal menghapus peminjaman');
      }
    } catch (e) {
      rethrow;
    }
  }
}