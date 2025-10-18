// File: lib/pj/profile_pj.dart

import 'package:flutter/material.dart';
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
        title: const Text(
          'Profil',
          style: TextStyle(
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
            _buildReadOnlyField(label: 'NIK', value: '222331'),
            const SizedBox(height: 16),
            _buildReadOnlyField(
                label: 'Nama', value: 'Gilang Bagus Ramadhan'),
            const SizedBox(height: 16),
            _buildReadOnlyField(
                label: 'Email', value: 'gilang@polibatam.ac.id'),
            const SizedBox(height: 30),
            
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Data Tenaga Pendidik / Tenaga Kependidikan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildReadOnlyField(label: 'Unit Kerja', value: 'Teknik Informatika'),
            const SizedBox(height: 16),
            _buildReadOnlyField(label: 'Kode Dosen', value: 'GL'),
            const SizedBox(height: 16),
            
            _buildWhatsAppField(),
            const SizedBox(height: 40),

            // PERUBAHAN 2: Gunakan LogoutWidget yang sudah Anda buat
            const LogoutWidget(), 
            
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
        color: const Color(0xFFF7D5E5),
        border: Border.all(
          color: const Color(0xFFC3A3C3),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: const Text(
        'KV',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          'WhatsApp',
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
                child: const Row(
                  children: [
                    Text('🇮🇩', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text('+62', style: TextStyle(fontWeight: FontWeight.w600)),
                    Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '81212345678',
                    style: TextStyle(fontWeight: FontWeight.w600),
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