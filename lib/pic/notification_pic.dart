// lib/pic/notifikasi_pic.dart (FONT POPPINS DITERAPKAN)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- Import Google Fonts

// 1. Buat Model Data untuk Notifikasi
class Notifikasi {
  final String namaPengaju;
  final String namaRuangan;
  final String tanggal;
  final String jam;

  const Notifikasi({
    required this.namaPengaju,
    required this.namaRuangan,
    required this.tanggal,
    required this.jam,
  });
}

// 2. Buat Halaman Utama Notifikasi
class NotifikasiPicPage extends StatelessWidget {
  const NotifikasiPicPage({super.key});

  final List<Notifikasi> _notifikasiList = const [
    Notifikasi(
      namaPengaju: "budi santoso",
      namaRuangan: "Tower A 11.3B",
      tanggal: "19 Sep",
      jam: "07.00-12.00",
    ),
    Notifikasi(
      namaPengaju: "Shafwah Khansa",
      namaRuangan: "Tower A 12.3C",
      tanggal: "20 Okt",
      jam: "07.00-12.00",
    ),
    Notifikasi(
      namaPengaju: "Angelina Maria",
      namaRuangan: "Gedung Utama 601",
      tanggal: "11 Nov",
      jam: "07.00-12.00",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          // <-- Terapkan Poppins
          "Notifikasi",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _notifikasiList.length,
        itemBuilder: (context, index) {
          final notifikasi = _notifikasiList[index];
          return _buildNotifikasiItem(notifikasi);
        },
      ),
    );
  }

  // 4. Widget Helper untuk Setiap Item Notifikasi
  Widget _buildNotifikasiItem(Notifikasi notifikasi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications, color: Colors.amber, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // <-- Terapkan Poppins
                  "Anda memiliki pengajuan peminjaman ruangan",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  // <-- Terapkan Poppins
                  "Pengajuan dari ${notifikasi.namaPengaju} untuk pengajuan Ruangan ${notifikasi.namaRuangan} pada ${notifikasi.tanggal}, ${notifikasi.jam}\nMenunggu keputusan Anda.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
