// lib/services/user_session.dart
import 'package:shared_preferences/shared_preferences.dart';

// 1. CLASS USERPROFILE LENGKAP (YANG SEBELUMNYA HILANG)
class UserProfile {
  final String nikOrNim;
  final String nama;
  final String email;
  final String unitKerja;
  final String kodeDosen;
  final String whatsapp;

  UserProfile({
    required this.nikOrNim,
    required this.nama,
    required this.email,
    required this.unitKerja,
    required this.kodeDosen,
    required this.whatsapp,
  });

  // Factory constructor untuk membuat UserProfile dari Map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      nikOrNim: map['nik_nim'] ?? '',
      nama: map['name'] ?? '',
      email: map['email'] ?? '',
      unitKerja: map['unit_kerja'] ?? '',
      kodeDosen: map['code'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
    );
  }
}

// 2. CLASS USERSESSION LENGKAP (DENGAN FUNGSI TOKEN)
class UserSession {
  // Key untuk profil
  static const String _nikOrNimKey = 'user_nik_or_nim';
  static const String _namaKey = 'user_nama';
  static const String _emailKey = 'user_email';
  static const String _unitKerjaKey = 'user_unit_kerja';
  static const String _kodeDosenKey = 'user_kode_dosen';
  static const String _whatsappKey = 'user_whatsapp';

  // Key untuk token
  static const String _tokenKey = 'auth_token';

  // Fungsi untuk MENYIMPAN data user saat login
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    final profile = UserProfile.fromMap(userData);

    await prefs.setString(_nikOrNimKey, profile.nikOrNim);
    await prefs.setString(_namaKey, profile.nama);
    await prefs.setString(_emailKey, profile.email);
    await prefs.setString(_unitKerjaKey, profile.unitKerja);
    await prefs.setString(_kodeDosenKey, profile.kodeDosen);
    await prefs.setString(_whatsappKey, profile.whatsapp);
  }

  // Fungsi untuk MENYIMPAN TOKEN
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Fungsi untuk MENGAMBIL TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Fungsi untuk MENGAMBIL data user
  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final nikOrNim = prefs.getString(_nikOrNimKey);
    final nama = prefs.getString(_namaKey);
    final email = prefs.getString(_emailKey);
    final unitKerja = prefs.getString(_unitKerjaKey);
    final kodeDosen = prefs.getString(_kodeDosenKey);
    final whatsapp = prefs.getString(_whatsappKey);

    // Jika NIK/NIM tidak ada, berarti user belum login
    if (nikOrNim == null || nikOrNim.isEmpty) {
      return null;
    }

    return UserProfile(
      nikOrNim: nikOrNim,
      nama: nama ?? '',
      email: email ?? '',
      unitKerja: unitKerja ?? '',
      kodeDosen: kodeDosen ?? '',
      whatsapp: whatsapp ?? '',
    );
  }

  // Fungsi untuk MENGHAPUS data (saat logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nikOrNimKey);
    await prefs.remove(_namaKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_unitKerjaKey);
    await prefs.remove(_kodeDosenKey);
    await prefs.remove(_whatsappKey);
    // Juga hapus token
    await prefs.remove(_tokenKey);
  }
}