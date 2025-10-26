// File: lib/pj/home_pj.dart (HEADER BARU DITERAPKAN)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- Import Google Fonts
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// Model data (Tidak berubah)
class PeminjamanPj {
  final String id;
  final String ruangan;
  String? status;
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

  PeminjamanPj copyWith({String? status}) {
    return PeminjamanPj(
      id: id,
      ruangan: ruangan,
      status: status ?? this.status,
      tanggalPinjam: tanggalPinjam,
      jamKegiatan: jamKegiatan,
      namaKegiatan: namaKegiatan,
      jenisKegiatan: jenisKegiatan,
    );
  }
}

class HomePjPage extends StatefulWidget {
  final Function(PeminjamanPj peminjaman) onPeminjamanSelected;
  final Function(Function(String, String)) onDataUpdated;

  const HomePjPage({
    super.key,
    required this.onPeminjamanSelected,
    required this.onDataUpdated,
  });

  @override
  State<HomePjPage> createState() => _HomePjPageState();
}

class _HomePjPageState extends State<HomePjPage> {
  List<PeminjamanPj> _peminjamanList = [
    PeminjamanPj(
      id: "6608",
      ruangan: "WS.TA.12.3B.02",
      status: "Menunggu Persetujuan Penanggung Jawab",
      tanggalPinjam: DateTime(2025, 10, 18),
      jamKegiatan: "07.50 - 12.00",
      namaKegiatan: "Perkuliahan",
      jenisKegiatan: "PBL TRPL 213",
    ),
  ];

  @override
  void initState() {
    super.initState();
    widget.onDataUpdated(_updatePeminjamanStatus);
    initializeDateFormatting('id_ID', null);
  }

  void _updatePeminjamanStatus(String id, String newStatus) {
    if (mounted) {
      setState(() {
        final index = _peminjamanList.indexWhere((p) => p.id == id);
        if (index != -1) {
          final oldPeminjaman = _peminjamanList[index];
          _peminjamanList[index] = oldPeminjaman.copyWith(status: newStatus);
          _peminjamanList = List.from(_peminjamanList);
        }
      });
    }
  }

  // --- BUILD UTAMA (DIUBAH) ---
  @override
  Widget build(BuildContext context) {
    // Mengganti Scaffold lama dengan struktur Stack + SingleChildScrollView
    return Scaffold(
      backgroundColor: Colors.white, // Background putih untuk konten
      body: Stack(
        children: [
          // Lapisan 1: Konten Scrollable
          SingleChildScrollView(
            child: Column(
              children: [
                // Jarak seukuran header + sedikit overlap kartu
                const SizedBox(height: 150),
                // Container putih untuk konten (filter, list, etc.)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 75, // Padding atas agar tidak tertutup kartu summary
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white, // Warna background konten
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildControls(), // Filter & Search
                      const SizedBox(height: 20),
                      // Membangun list peminjaman (ambil dari _buildSliverContent)
                      ...List.generate(_peminjamanList.length, (index) {
                        return _buildPeminjamanGroup(
                          _peminjamanList[index],
                          index + 1,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lapisan 2: Header Biru Melengkung dan Kartu Summary
          _buildHeaderAndCardsPJ(), // Fungsi header baru
        ],
      ),
    );
  }
  // --- AKHIR BUILD UTAMA ---

  // --- FUNGSI HEADER BARU (Diadaptasi dari home_pic.dart) ---
  Widget _buildHeaderAndCardsPJ() {
    return Stack(
      clipBehavior: Clip.none, // Penting agar kartu bisa keluar
      alignment: Alignment.topCenter,
      children: [
        // Header Biru Melengkung
        Container(
          height: 180, // Tinggi header
          decoration: const BoxDecoration(
            color: Color(0xFF1c36d2), // Warna biru solid
            borderRadius: BorderRadius.only(
              // Melengkung di bawah
              bottomLeft: Radius.circular(15), // Sesuaikan radius jika perlu
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Padding(
            // Padding untuk teks sapaan
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
            ), // Sesuaikan top padding
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Hai, Kevin!', // Teks sapaan sesuai gambar
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // Kartu summary diposisikan agar "mengambang"
        Positioned(
          top: 130, // Posisi vertikal kartu (sesuaikan jika perlu)
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gunakan _summaryCard yang sudah ada di file ini
                // Pastikan parameternya (title, count) atau (count, title)
                // Di kode Anda: _summaryCard(String title, String count)
                _summaryCard('Perlu Divalidasi', '5'),
                _summaryCard('Akan Dipakai', '4'),
                _summaryCard('Total Aktif', '7'),
              ],
            ),
          ),
        ),
      ],
    );
  }
  // --- AKHIR FUNGSI HEADER BARU ---

  // --- FUNGSI BAWAAN (SEDikit Modifikasi Font) ---

  // Fungsi ini dipanggil dari _buildHeaderAndCardsPJ
  // Tambahkan GoogleFonts jika belum
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tukar posisi sesuai gambar baru
            Text(
              title,
              textAlign: TextAlign.center,
              // Terapkan Poppins dan warna hitam
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              // Terapkan Poppins
              style: GoogleFonts.poppins(
                fontSize: 20, // Ukuran font angka
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D47A1), // Warna angka
              ),
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
          padding: EdgeInsets.only(
            bottom: 12.0,
            top: index == 1 ? 0 : 20.0,
          ), // Adjust top padding
          child: Text(
            'Peminjam Ruangan $index',
            // Terapkan Poppins
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildPeminjamanCard(peminjaman),
      ],
    );
  }

  Widget _buildPeminjamanCard(PeminjamanPj peminjaman) {
    final String formattedDate = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(peminjaman.tanggalPinjam);
    final bool isApproved = peminjaman.status == "Disetujui";
    String displayStatus = peminjaman.status ?? 'Status Tidak Diketahui';
    Color statusColor =
        (peminjaman.status == "Menunggu Persetujuan Penanggung Jawab")
        ? Colors.orange.shade400
        : (isApproved
              ? Colors.green
              : Colors.red); // Ganti abu jadi merah jika ditolak
    String buttonText =
        (peminjaman.status == "Menunggu Persetujuan Penanggung Jawab")
        ? 'Detail Approval'
        : (isApproved ? 'Detail' : 'Ditolak'); // Teks tombol jika ditolak

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
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${peminjaman.id}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (peminjaman.status != null)
                Flexible(
                  // Bungkus dengan Flexible agar bisa wrap jika teks panjang
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      displayStatus,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        height: 1.2,
                      ),
                      softWrap: true, // Izinkan wrap
                      overflow: TextOverflow.visible, // Tampilkan jika overflow
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
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
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    // Terapkan Poppins di sini juga
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Show',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
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
                  items: ['10', '25', '50']
                      .map(
                        (String v) => DropdownMenuItem<String>(
                          value: v,
                          child: Text(
                            v,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {},
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'entries',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Search:',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 45,
                child: TextField(
                  style: GoogleFonts.poppins(), // Font input search
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
                  onChanged: (value) {},
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    // Terapkan Poppins
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          Text(
            ':  ',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
