// lib/pic/notifikasi_pic.dart

import 'package:flutter/material.dart';

// 1. Buat Model Data untuk Notifikasi
class Notifikasi {
  // --- PERBAIKAN 1: Jadikan semua field 'final' ---
  final String namaPengaju;
  final String namaRuangan;
  final String tanggal;
  final String jam;

  // --- PERBAIKAN 2: Tambahkan 'const' pada constructor ---
  const Notifikasi({
    required this.namaPengaju,
    required this.namaRuangan,
    required this.tanggal,
    required this.jam,
  });
}

// 2. Buat Halaman Utama Notifikasi
class NotifikasiPicPage extends StatelessWidget {
  // Constructor sekarang bisa tetap 'const' karena field di bawah sudah benar-benar const
  const NotifikasiPicPage({super.key});

  // 3. Buat Data Mock Sesuai Gambar
  // Sekarang ini adalah list yang valid karena Notifikasi(...) sudah const
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
        title: const Text(
          "Notifikasi",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
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
                const Text(
                  "Anda memiliki pengajuan peminjaman ruangan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Pengajuan dari ${notifikasi.namaPengaju} untuk pengajuan Ruangan ${notifikasi.namaRuangan} pada ${notifikasi.tanggal}, ${notifikasi.jam}\nMenunggu keputusan Anda.",
                  style: TextStyle(
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
