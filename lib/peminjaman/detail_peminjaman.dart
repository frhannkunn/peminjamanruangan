// lib/peminjaman/detail_peminjaman.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'peminjaman.dart'; // Import untuk mendapatkan class PeminjamanData

class DetailPeminjamanScreen extends StatelessWidget {
  final PeminjamanData peminjaman;

  const DetailPeminjamanScreen({super.key, required this.peminjaman});

  @override
  Widget build(BuildContext context) {
    // Data Mock/Hardcoded untuk field yang tidak ada di PeminjamanData
    const String mockNim = "3223321";
    const String mockEmail = "gilang@polibatam.ac.id";
    const String mockTanggal = "09/18/2025"; // Data dari gambar

    // Warna dari desain
    const Color darkYellow = Color(0xFFF9A825); // Kuning tua
    const Color chipBlue = Color(0xFF2962FF); // Biru di header form

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // ✏️ TIDAK ADA APPBAR, body dimulai dari paling atas
      body: Column(
        children: [
          // === HEADER BIRU (PENGGANTI APPBAR) ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: const BoxDecoration(
              color: chipBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            // ✏️ SafeArea untuk melindungi konten dari status bar di atas
            child: SafeArea(
              bottom: false, // Hanya pedulikan padding atas
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✏️ Baris 1: Tombol Kembali (Chip Dihapus)
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      // Beri padding agar area tap pas
                      padding: EdgeInsets.fromLTRB(0, 8, 16, 8),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),

                  // ✏️ Spasi antara baris 1 dan teks judul
                  const SizedBox(height: 12),

                  // Teks Judul
                  Center( // ✏️ REVISI 1: Dibungkus Center
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // ✏️ REVISI 1: Dibuat center
                      children: [
                        Text(
                          "Detail Pengajuan",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Penggunaan Ruangan",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // === KONTEN YANG BISA DI-SCROLL ===
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === APPROVAL SECTION ===
                  Text(
                    "Approval Penanggung Jawab",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ✏️ Chip ini tetap ada sesuai desain
                  _buildStatusChip(
                    text: "Menunggu Persetujuan Penanggung Jawab",
                    backgroundColor: darkYellow,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: "Belum ada komentar",
                    readOnly: true,
                    maxLines: 4,
                    decoration: _inputDecoration(hint: "Belum ada komentar"),
                  ),
                  const SizedBox(height: 24),

                  // === FORM READ-ONLY ===
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildReadOnlyField(
                          "Jenis Kegiatan",
                          peminjaman.jenisKegiatan,
                        ),
                        _buildReadOnlyField(
                          "Nama Kegiatan",
                          peminjaman.namaKegiatan,
                        ),
                        _buildReadOnlyField(
                          "Nim / Nik / Unit Pengaju",
                          mockNim,
                          subtitle:
                              "Jika tidak memiliki NIM, dapat diisi dengan NIK KTP",
                        ),
                        _buildReadOnlyField(
                          "Nama Pengaju",
                          peminjaman.namaPengaju,
                        ),
                        _buildReadOnlyField(
                          "Alamat E-Mail Pengaju",
                          mockEmail,
                        ),
                        _buildReadOnlyField(
                          "Penanggung Jawab",
                          peminjaman.penanggungJawab,
                        ),
                        _buildReadOnlyField(
                          "Tanggal Pengunaan",
                          mockTanggal,
                        ),
                        _buildReadOnlyField(
                          "Ruangan",
                          peminjaman.ruangan,
                        ),
                        _buildReadOnlyField(
                          "Jam Mulai",
                          peminjaman.jamMulai,
                        ),
                        _buildReadOnlyField(
                          "Jam Selesai",
                          peminjaman.jamSelesai,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // === LIST PENGGUNA RUANGAN ===
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: chipBlue, // Menyamai header
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "List Pengguna Ruangan",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          decoration: _inputDecoration(
                            hint: "Search...",
                            suffixIcon: const Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Data Pengguna Mock
                        _buildPenggunaRow("ID", "32461"),
                        _buildPenggunaRow("Nim", "5353544"),
                        _buildPenggunaRow("Nama", "usb"),
                        _buildPenggunaRow("Nomor Workspace", "WS.GU.601.01"),
                        _buildPenggunaRow("Tipe Workspace", "WS.GU.601.01"),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk chip status
  Widget _buildStatusChip({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    bool isDoubleLine = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isDoubleLine ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isDoubleLine ? 12 : 20),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
      ),
      child: Text(
        text,
        textAlign: isDoubleLine ? TextAlign.center : TextAlign.left,
        style: GoogleFonts.poppins(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper untuk field read-only
  Widget _buildReadOnlyField(String label, String value,
      {String? subtitle, bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextFormField(
          initialValue: value,
          readOnly: true,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 4, bottom: 8),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        if (!isLast) const Divider(height: 24),
      ],
    );
  }

  // Helper untuk list pengguna
  Widget _buildPenggunaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Text(
            ":",
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk dekorasi input
  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
          borderSide: const BorderSide(color: Color(0xFF0D47A1)),
        ));
  }
}