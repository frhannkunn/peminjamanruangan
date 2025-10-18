// File: lib/pj/home_pj.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Model data untuk setiap item peminjaman
class PeminjamanPj {
  final String id;
  final String ruangan;
  final String? status;
  final DateTime tanggalPinjam;
  final String jamKegiatan;
  final String namaKegiatan;
  final String jenisKegiatan;

  PeminjamanPj({
    required this.id,
    required this.ruangan,
    required this.status,
    required this.tanggalPinjam,
    required this.jamKegiatan,
    required this.namaKegiatan,
    required this.jenisKegiatan,
  });
}

class HomePjPage extends StatefulWidget {
  // Callback function untuk memberitahu parent (FootbarPj) item mana yang dipilih
  final Function(PeminjamanPj peminjaman) onPeminjamanSelected;

  const HomePjPage({super.key, required this.onPeminjamanSelected});

  @override
  State<HomePjPage> createState() => _HomePjPageState();
}

class _HomePjPageState extends State<HomePjPage> {
  // Data statis untuk contoh (TEKS ASLI TETAP PANJANG)
  final List<PeminjamanPj> _peminjamanList = [
    PeminjamanPj(
      id: "6608",
      ruangan: "WS.TA.12.3B.02",
      status: "Menunggu Persetujuan Penanggung Jawab", // <-- TEKS ASLI
      tanggalPinjam: DateTime(2025, 10, 18),
      jamKegiatan: "07.50 - 12.00",
      namaKegiatan: "Perkuliahan",
      jenisKegiatan: "PBL TRPL 213",
    ),
    PeminjamanPj(
      id: "18645",
      ruangan: "WS.TA.12.3B.03",
      status: "Disetujui",
      tanggalPinjam: DateTime(2025, 9, 20),
      jamKegiatan: "07.00 - 12.00",
      namaKegiatan: "PBL TRPL 217",
      jenisKegiatan: "PBL",
    ),
    PeminjamanPj(
      id: "18646",
      ruangan: "WS.TA.12.3B.01",
      status: "Menunggu Persetujuan Penanggung Jawab", // <-- TEKS ASLI
      tanggalPinjam: DateTime(2025, 9, 18),
      jamKegiatan: "07.50 - 12.00",
      namaKegiatan: "PBL TRPL 318",
      jenisKegiatan: "Perkuliahan",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SingleChildScrollView(
        child: Column(children: [_buildHeader(), _buildContent()]),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 150,
          decoration: const BoxDecoration(
            color: Color(0xFF1A39D9),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.only(top: 50, left: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Hai, Kevin!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 110,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryCard('Perlu Divalidasi', '5'),
              _summaryCard('Akan Dipakai', '4'),
              _summaryCard('Total Aktif', '7'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildControls(),
          const SizedBox(height: 20),
          ..._peminjamanList.asMap().entries.map((entry) {
            int index = entry.key + 1;
            PeminjamanPj peminjaman = entry.value;
            return _buildPeminjamanGroup(peminjaman, index);
          }),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Show',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(width: 10),
            Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: '10',
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  items: ['10', '25', '50'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {},
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'entries',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Search:',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 45,
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    suffixIcon: const Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String count) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeminjamanGroup(PeminjamanPj peminjaman, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 20.0),
          child: Text(
            'Peminjam Ruangan $index',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        _buildPeminjamanCard(peminjaman),
      ],
    );
  }

  Widget _buildPeminjamanCard(PeminjamanPj peminjaman) {
    // Inisialisasi locale 'id_ID' untuk format tanggal Bahasa Indonesia
    final String formattedDate = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(peminjaman.tanggalPinjam);
    final bool isApproved = peminjaman.status == "Disetujui";

    String displayStatus = peminjaman.status ?? 'Status Tidak Diketahui';

    Color statusColor;

    // Logika untuk mengatur warna dan memformat teks panjang menjadi 2 baris
    if (peminjaman.status == "Disetujui") {
      statusColor = const Color(0xFF28A745); // Hijau
    } else if (peminjaman.status == "Menunggu Persetujuan Penanggung Jawab") {
      statusColor = const Color(0xFFFFC107); // Oranye/Kuning

      // PERBAIKAN: Membagi teks status menjadi dua baris sesuai permintaan Anda
      displayStatus = 'Menunggu Persetujuan\nPenanggung Jawab';
    } else {
      statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(40),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peminjaman.ruangan,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${peminjaman.id}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayStatus, // <-- Menggunakan status yang sudah diformat
                  textAlign:
                      TextAlign.center, // <-- Memastikan teks berada di tengah
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    height: 1.2, // <-- Membantu merapikan jarak baris
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Tanggal Pinjam', formattedDate),
          _buildDetailRow('Jam Kegiatan', peminjaman.jamKegiatan),
          _buildDetailRow('Nama Kegiatan', peminjaman.namaKegiatan),
          _buildDetailRow('Jenis Kegiatan', peminjaman.jenisKegiatan),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => widget.onPeminjamanSelected(peminjaman),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A69FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: Text(
                isApproved ? 'Detail' : 'Approval',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          const Text(':  ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
