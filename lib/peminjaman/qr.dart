import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import package QR
import 'package:dotted_border/dotted_border.dart'; // Import package border
import 'peminjaman.dart'; // Import class PeminjamanData

class QrScreen extends StatelessWidget {
  final PeminjamanData peminjaman;

  const QrScreen({super.key, required this.peminjaman});

  @override
  Widget build(BuildContext context) {
    // Menggabungkan tanggal dan waktu dari data
    final String waktuPinjam =
        "${DateFormat('dd MMMM yyyy').format(peminjaman.tanggalPinjam)} | ${peminjaman.jamMulai} - ${peminjaman.jamSelesai}";

    // --- Data Hardcoded ---
    // Data ini tidak ada di class PeminjamanData Anda.
    // Ganti string hardcoded ini dengan data asli jika sudah Anda miliki.
    const String peminjamHardcoded = "18646 - Jtsoo";
    const String picRuanganHardcoded = "Gilang Bagus Ramadhan, A.Md.Kom";
    // ----------------------------

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "QR CODE",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black), // Tombol back
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Kontainer dengan border putus-putus
            DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              padding: const EdgeInsets.all(20),
              color: Colors.grey.shade400,
              strokeWidth: 2,
              dashPattern: const [8, 4], // Pola putus-putus
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // QR Code
                  Center(
                    child: QrImageView(
                      data: peminjaman.id, // Data QR code (contoh: ID)
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detail Peminjaman
                  _buildQrInfoRow("ID Peminjam:", peminjaman.id),
                  _buildQrInfoRow("Peminjam:", peminjamHardcoded), // Data hardcoded
                  _buildQrInfoRow("Waktu Pinjam:", waktuPinjam),
                  _buildQrInfoRow("Ruangan:", peminjaman.ruangan),
                  _buildQrInfoRow("Nama Kegiatan:", peminjaman.namaKegiatan),
                  
                  const Divider(height: 32),

                  // Detail Persetujuan
                  Text(
                    "Persetujuan PIC dan Penanggung Jawab",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQrInfoRow("Penanggung Jawab:", peminjaman.penanggungJawab),
                  _buildQrInfoRow("Persetujuan Penanggung Jawab:", "Disetujui", isStatus: true), // Hardcoded
                  _buildQrInfoRow("PIC Ruangan:", picRuanganHardcoded), // Data hardcoded
                  _buildQrInfoRow("Persetujuan PIC Ruangan:", "Disetujui", isStatus: true), // Hardcoded
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Silakan Unduh atau Screenshot QR Code ini sebagai Bukti Peminjaman.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Implementasi fungsi Unduh QR Code
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Unduh",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke halaman sebelumnya
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Kembali",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper widget untuk baris info di halaman QR
  Widget _buildQrInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Lebar label
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: isStatus
                ? // Tampilkan sebagai chip hijau jika ini status
                Chip(
                    label: Text(
                      value,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
                : // Tampilkan sebagai teks biasa
                Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}