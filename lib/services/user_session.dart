// lib/services/user_session.dart
import 'package:shared_preferences/shared_preferences.dart';

// Class ini sekarang menyimpan SEMUA kemungkinan data
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
    // PENTING: Key di bawah ('nik', 'nim', 'unit_kerja', 'kode_dosen', 'whatsapp')
    // harus SAMA dengan key JSON yang Anda kirim dari Laravel
    return UserProfile(
      // Cek apakah API mengirim 'nik' (Dosen) atau 'nim' (Mahasiswa)
      nikOrNim: map['nik_nim'] ?? '',  // ⬅️ Ganti dari 'nik' ?? 'nim'
      nama: map['name'] ?? '',      // ⬅️ Ganti dari 'nama'
      email: map['email'] ?? '',
      unitKerja: map['unit_kerja'] ?? '', // Akan kosong jika Mahasiswa
      kodeDosen: map['kode_dosen'] ?? '', // Akan kosong jika Mahasiswa
      whatsapp: map['whatsapp'] ?? '',   // Akan kosong jika Mahasiswa
    );
  }
}

// 2. REVISI UserSession Class
class UserSession {
  // Mengganti 'nim' menjadi 'nikOrNim'
  static const String _nikOrNimKey = 'user_nik_or_nim'; 
  static const String _namaKey = 'user_nama';
  static const String _emailKey = 'user_email';
  // Tambah key baru
  static const String _unitKerjaKey = 'user_unit_kerja'; 
  static const String _kodeDosenKey = 'user_kode_dosen'; 
  static const String _whatsappKey = 'user_whatsapp';  

  // 1. Fungsi untuk MENYIMPAN data user saat login
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Gunakan fromMap yang sudah direvisi
    final profile = UserProfile.fromMap(userData);

    await prefs.setString(_nikOrNimKey, profile.nikOrNim); 
    await prefs.setString(_namaKey, profile.nama);
    await prefs.setString(_emailKey, profile.email);
    // Simpan data baru
    await prefs.setString(_unitKerjaKey, profile.unitKerja); 
    await prefs.setString(_kodeDosenKey, profile.kodeDosen); 
    await prefs.setString(_whatsappKey, profile.whatsapp);  
  }

  // 2. Fungsi untuk MENGAMBIL data user
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

  // 3. Fungsi untuk MENGHAPUS data (saat logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nikOrNimKey); 
    await prefs.remove(_namaKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_unitKerjaKey); 
    await prefs.remove(_kodeDosenKey); 
    await prefs.remove(_whatsappKey);  
    // Juga hapus token
    await prefs.remove('auth_token');
  }
}