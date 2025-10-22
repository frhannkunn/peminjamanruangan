// File: lib/pj/home_pj.dart (Full Text Status Chip)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Model data (tidak berubah)
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
  final Function(PeminjamanPj peminjaman) onPeminjamanSelected;
  const HomePjPage({super.key, required this.onPeminjamanSelected});

  @override
  State<HomePjPage> createState() => _HomePjPageState();
}

class _HomePjPageState extends State<HomePjPage> {
  // Hanya data Peminjam 1
  final List<PeminjamanPj> _peminjamanList = [
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: CustomScrollView(
        slivers: [_buildSliverHeader(), _buildSliverContent()],
      ),
    );
  }

  Widget _buildSliverHeader() {
    // Kode _buildSliverHeader tidak berubah
    return SliverAppBar(
      expandedHeight: 180.0,
      backgroundColor: const Color(0xFF1A39D9),
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            const Positioned(
              top: 60,
              left: 20,
              child: Text(
                'Hai, Kevin!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 110,
              left: 15,
              right: 15,
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
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20.0),
        child: Container(
          height: 20.0,
          decoration: const BoxDecoration(
            color: Color(0xFFF4F7FC),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverContent() {
    // Kode _buildSliverContent tidak berubah
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
              child: _buildControls(),
            );
          }
          final peminjamanIndex = index - 1;
          if (peminjamanIndex < _peminjamanList.length) {
            return _buildPeminjamanGroup(
              _peminjamanList[peminjamanIndex],
              peminjamanIndex + 1,
            );
          }
          return null;
        }, childCount: _peminjamanList.length + 1),
      ),
    );
  }

  Widget _buildPeminjamanGroup(PeminjamanPj peminjaman, int index) {
    // Kode _buildPeminjamanGroup tidak berubah
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.0, top: index == 1 ? 10.0 : 20.0),
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
    final String formattedDate = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(peminjaman.tanggalPinjam);
    final bool needsApproval =
        peminjaman.status == "Menunggu Persetujuan Penanggung Jawab";
    final bool isApproved = peminjaman.status == "Disetujui";
    String displayStatus =
        peminjaman.status ?? 'Status Tidak Diketahui'; // Teks asli
    Color statusColor = needsApproval
        ? Colors.orange.shade400
        : (isApproved ? Colors.green : Colors.grey);
    String buttonText = needsApproval
        ? 'Detail Approval'
        : (isApproved ? 'Detail' : 'Lihat');

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
              // --- PERUBAHAN PADA STATUS CHIP ---
              if (peminjaman.status != null)
                Flexible(
                  // Gunakan Flexible agar chip bisa mengecil jika perlu
                  child: Container(
                    // constraints: const BoxConstraints(maxWidth: 130), // Constraint bisa dihapus atau disesuaikan
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      displayStatus, // Tampilkan teks asli
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        height: 1.2,
                      ),
                      softWrap: true, // Izinkan wrap
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              // --- AKHIR PERUBAHAN CHIP ---
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

  // Helper widgets (tidak berubah)
  Widget _summaryCard(String title, String count) {
    /* ... */
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

  Widget _buildControls() {
    /* ... */
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
                  items: ['10', '25', '50']
                      .map(
                        (String v) => DropdownMenuItem<String>(
                          value: v,
                          child: Text(
                            v,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {},
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

  Widget _buildDetailRow(String label, String value) {
    /* ... */
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
