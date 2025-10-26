// File: lib/pj/notification_pj.dart (FONT POPPINS DITERAPKAN)

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
class NotificationPjPage extends StatelessWidget {
  // Nama kelas sudah benar
  const NotificationPjPage({super.key});

  // Data dummy untuk notifikasi
  static final List<Notifikasi> _notifications = [
    Notifikasi(
      namaPengaju: 'budi santoso',
      namaRuangan: 'Tower A 11.3B',
      tanggal: '19 Sep',
      jam: '07.00-12.00',
    ),
    Notifikasi(
      namaPengaju: 'Shafwah Khansa',
      namaRuangan: 'Tower A 12.3C',
      tanggal: '20 Okt',
      jam: '07.00-12.00',
    ),
    Notifikasi(
      namaPengaju: 'Angelina Maria',
      namaRuangan: 'Gedung Utama 601',
      tanggal: '11 Nov',
      jam: '07.00-12.00',
    ),
  ];

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
          'Notifikasi',
          style: GoogleFonts.poppins(
            // Ganti TextStyle -> GoogleFonts.poppins
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  // Helper disesuaikan untuk menerima objek Notifikasi
  Widget _buildNotificationItem(Notifikasi notification) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4.0, right: 12.0),
                child: Icon(
                  Icons.notifications_none_outlined,
                  color: Color(0xFFFFC107),
                  size: 30,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // <-- Terapkan Poppins
                      'Anda memiliki pengajuan peminjaman ruangan',
                      style: GoogleFonts.poppins(
                        // Ganti TextStyle -> GoogleFonts.poppins
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors
                            .black, // Ganti dari black87 ke black jika perlu
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // <-- Terapkan Poppins
                      'Pengajuan dari ${notification.namaPengaju} untuk pengajuan Ruangan ${notification.namaRuangan} pada ${notification.tanggal}, ${notification.jam}\nMenunggu keputusan Anda.',
                      style: GoogleFonts.poppins(
                        // Ganti TextStyle -> GoogleFonts.poppins
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20),
      ],
    );
  }
}
