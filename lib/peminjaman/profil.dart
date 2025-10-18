import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:penru_mobile/logout.dart'; // pastikan path sesuai

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 🔹 AppBar diubah sesuai desain baru
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
      // 🔹 Body diubah total sesuai desain baru
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar dengan Inisial
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color.fromARGB(255, 97, 221, 93), // Warna pink muda
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

              // Info Fields
              _buildInfoField(
                label: "NIK / NIM",
                value: "434241155",
              ),
              const SizedBox(height: 20),
              _buildInfoField(
                label: "Nama",
                value: "VERON TAMPAN",
              ),
              const SizedBox(height: 20),
              _buildInfoField(
                label: "Email",
                value: "veron@gmail.com",
              ),
              const SizedBox(height: 40),

              // 🔹 Logout Widget tetap ada sesuai permintaan
              LogoutWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk membuat label dan text field
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
          readOnly: true, // Membuat field tidak bisa diedit
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