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

class NotifikasiScreen extends StatefulWidget {
  // 1. Tambahkan parameter ini agar sinkron dengan main.dart
  final String? message; 

  const NotifikasiScreen({
    super.key, 
    this.message, // Bisa null jika dibuka manual lewat menu
  });

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  // Data dummy (bisa diganti data dari API/Database nantinya)
  List<NotificationItem> notifications = [
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

  @override
  void initState() {
    super.initState();
    // 2. Logika: Jika ada pesan dari Push Notification, masukkan ke paling atas list
    if (widget.message != null && widget.message != "No Message") {
      notifications.insert(0, NotificationItem(
        isApproved: true, // Default true (atau sesuaikan logika Anda)
        title: "Pesan Baru Masuk",
        description: widget.message!, // Isi pesan dari FCM
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        // Tombol back manual (opsional, agar bisa balik ke home)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Notifikasi",
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
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

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