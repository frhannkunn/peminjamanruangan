// File: lib/pj/profile_pj.dart (FONT POPPINS DITERAPKAN)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- Import Google Fonts
// PERUBAHAN 1: Import widget logout yang sudah Anda buat
import 'package:penru_mobile/logout.dart'; // pastikan path sesuai

class ProfilePjPage extends StatelessWidget {
  const ProfilePjPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          // <-- Terapkan Poppins
          'Profil',
          style: GoogleFonts.poppins(
            // Ganti TextStyle -> GoogleFonts.poppins
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(),
            const SizedBox(height: 30),
            _buildReadOnlyField(label: 'NIK', value: '222331'), // Data dummy
            const SizedBox(height: 16),
            _buildReadOnlyField(
              label: 'Nama',
              value: 'Kevin Sanjaya',
            ), // Data dummy
            const SizedBox(height: 16),
            _buildReadOnlyField(
              label: 'Email',
              value: 'kevin@polibatam.ac.id',
            ), // Data dummy
            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                // <-- Terapkan Poppins
                'Data Tenaga Pendidik / Tenaga Kependidikan',
                style: GoogleFonts.poppins(
                  // Ganti TextStyle -> GoogleFonts.poppins
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildReadOnlyField(
              label: 'Unit Kerja',
              value: 'Teknik Informatika',
            ), // Data dummy
            const SizedBox(height: 16),
            _buildReadOnlyField(label: 'Kode Dosen', value: 'KV'), // Data dummy
            const SizedBox(height: 16),

            _buildWhatsAppField(),
            const SizedBox(height: 40),

            // PERUBAHAN 2: Gunakan LogoutWidget yang sudah Anda buat
            const LogoutWidget(), // Pastikan widget ini juga pakai Poppins

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // PERUBAHAN 3: Fungsi _buildLogoutButton sudah tidak diperlukan lagi dan bisa dihapus.

  Widget _buildAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF7D5E5), // Warna pink avatar
        border: Border.all(
          color: const Color(0xFFC3A3C3), // Warna border avatar
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        // <-- Terapkan Poppins
        'KV', // Inisial
        style: GoogleFonts.poppins(
          // Ganti TextStyle -> GoogleFonts.poppins
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF333333), // Warna teks avatar
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // <-- Terapkan Poppins
          label,
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontSize: 14,
          ), // Ganti TextStyle -> GoogleFonts.poppins
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ), // <-- Terapkan Poppins
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              // Added focusedBorder for consistency
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWhatsAppField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // <-- Terapkan Poppins
          'WhatsApp',
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontSize: 14,
          ), // Ganti TextStyle -> GoogleFonts.poppins
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Row(
                  // <-- Row ini const, jadi TextStyle di dalamnya tidak bisa pakai GoogleFonts
                  children: [
                    const Text('🇮🇩', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    // Tidak bisa pakai GoogleFonts karena parent Widget const
                    const Text(
                      '+62',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
              Expanded(
                // <-- Hapus const di sini agar bisa pakai GoogleFonts
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    // <-- Terapkan Poppins
                    '81212345678', // Nomor WA dummy
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ), // Ganti TextStyle -> GoogleFonts.poppins
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
