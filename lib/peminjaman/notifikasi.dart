import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Kelas model untuk menampung data notifikasi
class NotificationItem {
  final bool isApproved;
  final String title;
  final String description;

  const NotificationItem({
    required this.isApproved,
    required this.title,
    required this.description,
  });
}

// Data dummy untuk daftar notifikasi
final List<NotificationItem> notifications = [
  const NotificationItem(
    isApproved: true,
    title: "Peminjaman Disetujui!",
    description: "Yeay! Peminjamanmu disetujui Ruangan Tower A 12.38 sudah siap kamu gunakan pada 5 Okt, 13:00–15:00.",
  ),
  const NotificationItem(
    isApproved: false,
    title: "Peminjaman Ditolak",
    description: "Maaf, pengajuan peminjaman ruanganmu tidak dapat disetujui karena alasan lain dari pihak penanggung jawab.",
  ),
];

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override // Anotasi @override ini penting untuk setiap build method
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Notifikasi",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        // Bagian ini untuk membuat garis di bawah judul AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      // Body sekarang berisi daftar notifikasi
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  // Widget untuk membuat satu kartu notifikasi
  Widget _buildNotificationCard(NotificationItem item) {
    final IconData iconData = item.isApproved ? Icons.check : Icons.close;
    final Color iconColor = item.isApproved ? const Color(0xFF1E8E3E) : const Color(0xFFD93025);
    final Color backgroundColor = item.isApproved ? const Color(0xFFE6F4EA) : const Color(0xFFFCE8E6);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 72, right: 20),
          child: Divider(
            height: 1,
            color: Colors.grey[200],
          ),
        )
      ],
    );
  }
}