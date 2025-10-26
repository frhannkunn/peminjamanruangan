// lib/pic/profile_pic.dart (IMPORT DIPERBAIKI)

import 'package:flutter/material.dart'; // <-- Diperbaiki di sini
import 'package:google_fonts/google_fonts.dart';
import 'package:penru_mobile/logout.dart'; // Pastikan path ini benar

class ProfilePicPage extends StatelessWidget {
  const ProfilePicPage({super.key});

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProfileAvatar(),
            const SizedBox(height: 40),
            _buildInfoTextField(label: 'NIK', value: '222331'),
            const SizedBox(height: 20),
            _buildInfoTextField(label: 'Nama', value: 'Gilang Bagus Ramadhan'),
            const SizedBox(height: 20),
            _buildInfoTextField(
              label: 'Email',
              value: 'gilang@polibatam.ac.id',
            ),
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
              value: 'Teknik Informatika',
            ),
            const SizedBox(height: 20),
            _buildInfoTextField(label: 'Kode Dosen', value: 'GL'),
            const SizedBox(height: 20),
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

  // Widget untuk Avatar Profil (LINGKARAN BIRU DIHAPUS)
  Widget _buildProfileAvatar() {
    return Center(
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.pink.shade100, // Hanya lingkaran pink muda
          border: Border.all(color: Colors.white, width: 4), // Border putih
        ),
        child: Center(
          child: Text(
            'GL',
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
          initialValue: '81212345678',
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
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇮🇩', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    value,
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
