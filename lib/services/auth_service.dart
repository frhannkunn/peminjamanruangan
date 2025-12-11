// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 🛑 GANTI DENGAN IP LAPTOP 🛑
  // static const String _ipLaptop = "10.65.235.18"; //Alamat hp fisik
  static const String _ipLaptop = "10.0.2.2"; // <-- Alamat khusus Emulator Android
  static const String _baseUrl = "http://$_ipLaptop:8000/api";

  // Fungsi login sekarang menerima username & password
  // dan mengembalikan data user jika sukses
  Future<Map<String, dynamic>> login(String username, String password) async {
    final String url = "$_baseUrl/login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // == LOGIN SUKSES ==
        final data = json.decode(response.body);
        final token = data['access_token'];

        // Simpan token di dalam service
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Kembalikan data user agar bisa dipakai di UI
        return data['user'];
      } else if (response.statusCode == 401) {
        // == USERNAME / PASSWORD SALAH ==
        // Lemparkan error agar bisa ditangkap oleh UI
        throw Exception("Username / Password salah ❌");
      } else {
        // == ERROR LAIN DARI SERVER ==
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      // == ERROR JARINGAN (HP tidak bisa konek ke IP Laptop) ==
      // Cek apakah ini error koneksi atau error dari throw di atas
      if (e is Exception && e.toString().contains('Username / Password salah')) {
        rethrow; // Lemparkan lagi error spesifik
      }
      if (e is Exception && e.toString().contains('Error:')) {
        rethrow; // Lemparkan lagi error spesifik
      }
      
      throw Exception(
          "Gagal terhubung ke server. Pastikan HP & Laptop di WiFi yang sama dan IP $_ipLaptop sudah benar.");
    }
  }

  // Anda juga bisa tambahkan fungsi lain di sini
  // Future<void> logout() async { ... }
  // Future<Map<String, dynamic>> getUserProfile() async { ... }
}