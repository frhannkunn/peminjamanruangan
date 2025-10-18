// lib/pic/profile_pic.dart

import 'package:flutter/material.dart';
// PERUBAHAN 1: Import widget logout yang sudah Anda buat
// Pastikan path ini sesuai dengan struktur folder Anda.
import 'package:penru_mobile/logout.dart'; // pastikan path sesuai

class ProfilePicPage extends StatelessWidget {
  const ProfilePicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Profil",
          style: TextStyle(
            color: Colors.black87,
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
            _buildInfoTextField(
              label: 'NIK',
              value: '222331',
            ),
            const SizedBox(height: 20),
            _buildInfoTextField(
              label: 'Nama',
              value: 'Gilang Bagus Ramadhan',
            ),
            const SizedBox(height: 20),
            _buildInfoTextField(
              label: 'Email',
              value: 'gilang@polibatam.ac.id',
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Data Tenaga Pendidik / Tenaga Kependidikan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoTextField(
              label: 'Unit Kerja',
              value: 'Teknik Informatika',
            ),
            const SizedBox(height: 20),
            _buildInfoTextField(
              label: 'Kode Dosen',
              value: 'GL',
            ),
            const SizedBox(height: 20),
            _buildWhatsAppField(
              label: 'WhatsApp',
              value: '+62',
            ),
            const SizedBox(height: 40),

            // PERUBAHAN 2: Tambahkan Divider dan LogoutWidget di sini
            const Divider(),
            const SizedBox(height: 10),
            const LogoutWidget(),
            const SizedBox(height: 20), // Jarak di paling bawah
          ],
        ),
      ),
    );
  }

  // Widget untuk Avatar Profil
  Widget _buildProfileAvatar() {
    return Center(
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.shade300,
          border: Border.all(color: Colors.blue.shade300, width: 4),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.pink.shade100,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: const Center(
            child: Text(
              'RY',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
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
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          style: const TextStyle(color: Colors.black54, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: '81212345678', // Nomornya ditaruh di sini
          readOnly: true,
          style: const TextStyle(color: Colors.black54, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  const Text(
                    '🇮🇩',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value, // Menampilkan "+62"
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
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