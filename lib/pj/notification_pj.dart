// File: lib/pj/notification_pj.dart

import 'package:flutter/material.dart';

class NotificationPjPage extends StatelessWidget {
  const NotificationPjPage({super.key});

  // Data dummy untuk notifikasi
  static final List<Map<String, String>> _notifications = [
    {
      'title': 'Anda memiliki pengajuan peminjaman ruangan',
      'detail':
          'Pengajuan dari budi santoso untuk pengajuan Ruangan Tower A 11.3B pada 19 Sep, 07.00-12.00\nMenunggu keputusan Anda.',
    },
    {
      'title': 'Anda memiliki pengajuan peminjaman ruangan',
      'detail':
          'Pengajuan dari Shafwah Khansa untuk pengajuan Ruangan Tower A 12.3C pada 20 Okt, 07.00-12.00\nMenunggu keputusan Anda.',
    },
    {
      'title': 'Anda memiliki pengajuan peminjaman ruangan',
      'detail':
          'Pengajuan dari Angelina Maria untuk pengajuan Ruangan Gedung Utama 601 pada 11 Nov, 07.00-12.00\nMenunggu keputusan Anda.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Desain AppBar untuk tampilan "Notifikasi"
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
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
          return _buildNotificationItem(
            notification['title']!,
            notification['detail']!,
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(String title, String detail) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikon Lonceng Kuning
              const Padding(
                padding: EdgeInsets.only(top: 4.0, right: 12.0),
                child: Icon(
                  Icons.notifications_none_outlined,
                  color: Color(0xFFFFC107), // Warna Kuning/Oranye
                  size: 30,
                ),
              ),
              // Detail Notifikasi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: TextStyle(
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
        // Garis pemisah tipis
        const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20),
      ],
    );
  }
}
