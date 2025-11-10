// lib/pic/profile_pic.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:penru_mobile/logout.dart'; // Pastikan path ini benar
// ➕ 1. IMPORT USER SESSION
import 'package:penru_mobile/services/user_session.dart';

// ✏️ 2. UBAH JADI STATEFUL WIDGET
class ProfilePicPage extends StatefulWidget {
  const ProfilePicPage({super.key});

  @override
  State<ProfilePicPage> createState() => _ProfilePicPageState();
}

class _ProfilePicPageState extends State<ProfilePicPage> {
  // ➕ 3. TAMBAHKAN STATE UNTUK LOADING DAN DATA USER
  UserProfile? _userProfile;
  bool _isLoading = true;

  // ➕ 4. BUAT FUNGSI UNTUK MEMUAT DATA SAAT HALAMAN DIBUKA
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await UserSession.getUserProfile();
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Profil",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        elevation: 0,
        // ➕ Tombol back otomatis ditambahkan untuk Dosen/PIC
        //    (Anda bisa hapus 'automaticallyImplyLeading' jika ini
        //     adalah bagian dari BottomNavBar)
      ),
      // ✏️ 5. TAMBAHKAN LOGIKA LOADING
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? const Center(child: Text("Gagal memuat profil."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // ✏️ 6. KIRIM DATA KE AVATAR
                      _buildProfileAvatar(),
                      const SizedBox(height: 40),
                      // ✏️ 7. GANTI SEMUA DATA HARDCODED
                      _buildInfoTextField(
                          label: 'NIK', value: _userProfile!.nikOrNim),
                      const SizedBox(height: 20),
                      _buildInfoTextField(
                          label: 'Nama', value: _userProfile!.nama),
                      const SizedBox(height: 20),
                      _buildInfoTextField(
                          label: 'Email', value: _userProfile!.email),
                      const SizedBox(height: 30),
                      const Divider(),
                      const SizedBox(height: 20),
                      Text(
                        'Data Tenaga Pendidik / Tenaga Kependidikan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoTextField(
                          label: 'Unit Kerja',
                          value: _userProfile!.unitKerja),
                      const SizedBox(height: 20),
                      _buildInfoTextField(
                          label: 'Kode Dosen',
                          value: _userProfile!.kodeDosen),
                      const SizedBox(height: 20),
                      // Panggil helper WA, value "+62" tetap
                      _buildWhatsAppField(label: 'WhatsApp', value: '+62'),
                      const SizedBox(height: 40),
                      const Divider(),
                      const SizedBox(height: 10),
                      const LogoutWidget(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  // Widget untuk Avatar Profil
  Widget _buildProfileAvatar() {
    // ✏️ Ambil inisial dari state
    String inisial = _userProfile!.kodeDosen.isNotEmpty
        ? _userProfile!.kodeDosen
        : (_userProfile!.nama.isNotEmpty ? _userProfile!.nama[0].toUpperCase() : '?');

    return Center(
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.pink.shade100,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Center(
          child: Text(
            inisial, // ✏️ Ganti 'GL' menjadi dinamis
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper untuk field info biasa
  Widget _buildInfoTextField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: Key(value), // ➕ Tambahkan key agar UI me-refresh
          initialValue: value,
          readOnly: true,
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            // ➕ Tambahkan focusedBorder agar konsisten
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }

  // Widget helper khusus untuk field WhatsApp dengan bendera
  Widget _buildWhatsAppField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          // ✏️ Ambil nomor WA dari state
          key: Key(_userProfile!.whatsapp),
          initialValue: _userProfile!.whatsapp,
          readOnly: true,
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            // ➕ Tambahkan focusedBorder agar konsisten
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇮🇩', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    value, // Ini akan menampilkan "+62"
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(height: 20, width: 1, color: Colors.grey.shade300),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}