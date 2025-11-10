//peminjaman/profil.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:penru_mobile/logout.dart'; // pastikan path sesuai

// ➕ CLASS BARU UNTUK MENYIMPAN DATA PROFIL
class UserProfile {
  final String nim;
  final String nama;
  final String email;

  UserProfile({required this.nim, required this.nama, required this.email});
}

// ➕ DATA MOCK YANG BISA DIAKSES GLOBAL (UNTUK REQ 1)
final mockUserProfile = UserProfile(
  nim: "434241155",
  nama: "VERON TAMPAN",
  email: "veron@gmail.com",
);
// --- AKHIR PENAMBAHAN ---

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color.fromARGB(255, 97, 221, 93),
                child: Text(
                  "VT",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ✏️ Menggunakan data dari mock object
              _buildInfoField(
                label: "NIK / NIM",
                value: mockUserProfile.nim, // <-- Diubah
              ),
              const SizedBox(height: 20),
              _buildInfoField(
                label: "Nama",
                value: mockUserProfile.nama, // <-- Diubah
              ),
              const SizedBox(height: 20),
              _buildInfoField(
                label: "Email",
                value: mockUserProfile.email, // <-- Diubah
              ),
              const SizedBox(height: 40),

              LogoutWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // (Widget helper _buildInfoField tidak berubah)
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