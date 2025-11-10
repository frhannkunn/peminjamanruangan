//peminjaman/profil.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:penru_mobile/logout.dart'; // pastikan path sesuai
// ➕ 1. IMPORT USER SESSION
import 'package:penru_mobile/services/user_session.dart';

// ➖ 2. HAPUS 'UserProfile' DAN 'mockUserProfile' DARI SINI
// (Class dan data mock sudah dipindah ke user_session.dart)

// ✏️ 3. UBAH JADI STATEFUL WIDGET
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  // ➕ 4. TAMBAHKAN STATE UNTUK LOADING DAN DATA PROFIL
  UserProfile? _userProfile;
  bool _isLoading = true;

  // ➕ 5. PANGGIL FUNGSI INI SAAT HALAMAN DIBUKA
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // ➕ 6. FUNGSI UNTUK MENGAMBIL DATA DARI UserSession
  Future<void> _loadUserProfile() async {
    final profile = await UserSession.getUserProfile();

    // Update UI setelah data didapat
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        // (AppBar Anda tidak berubah)
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Profil",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      // ✏️ 7. TAMBAHKAN LOGIKA LOADING
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Tampilkan loading
          : _userProfile == null
              ? const Center(child: Text("Gagal memuat profil.")) // Tampilkan jika data tidak ada
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // (CircleAvatar Anda tidak berubah)
                        const CircleAvatar(
                          radius: 60,
                          backgroundColor: Color.fromARGB(255, 97, 221, 93),
                          child: Text(
                            "VT", // TODO: Bisa diganti inisial
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ✏️ 8. GANTI DATA MOCK DENGAN DATA ASLI
                        _buildInfoField(
                          label: "NIK / NIM",
                          // Gunakan 'nikOrNim' dari UserSession
                          value: _userProfile!.nikOrNim, 
                        ),
                        const SizedBox(height: 20),
                        _buildInfoField(
                          label: "Nama",
                          value: _userProfile!.nama,
                        ),
                        const SizedBox(height: 20),
                        _buildInfoField(
                          label: "Email",
                          value: _userProfile!.email,
                        ),
                        const SizedBox(height: 40),

                        LogoutWidget(),
                      ],
                    ),
                  ),
                ),
    );
  }

  // (Widget helper _buildInfoField Anda TIDAK BERUBAH SAMA SEKALI)
  Widget _buildInfoField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          // Tambahkan key agar refresh saat data berubah
          key: Key(value), 
          controller: TextEditingController(text: value),
          readOnly: true,
          style: GoogleFonts.poppins(color: Colors.black87),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            fillColor: Colors.grey.shade50,
            filled: true,
          ),
        ),
      ],
    );
  }
}