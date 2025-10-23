// File: lib/pj/detail_pengajuan_pj.dart (ONLY Asterisk Removed)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'home_pj.dart'; // Untuk class PeminjamanPj

class DetailPengajuanPjPage extends StatelessWidget {
  final PeminjamanPj peminjaman;
  final VoidCallback onBack;
  final VoidCallback onApproveTap; // Callback untuk tombol kecil

  const DetailPengajuanPjPage({
    super.key,
    required this.peminjaman,
    required this.onBack,
    required this.onApproveTap,
  });

  // Data pengguna statis
  final Map<String, String> _userData = const {
    'ID': '32461',
    'NIM': '5353544',
    'Nama': 'usb',
    'Nomor Workspace': 'WS.GU.601.01',
    'Tipe Workspace': 'NON PC',
  };

  @override
  Widget build(BuildContext context) {
    // Tentukan warna status dan teks status untuk chip
    final bool needsApproval =
        peminjaman.status == "Menunggu Persetujuan Penanggung Jawab";
    final bool isApproved = peminjaman.status == "Disetujui";
    final String displayStatus = peminjaman.status ?? 'Status Tidak Diketahui';
    final Color statusColor = needsApproval
        ? Colors.orange.shade400
        : (isApproved ? Colors.green : Colors.grey);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Background abu-abu muda
      body: Column(
        // Column utama
        children: [
          _buildHeader(
            displayStatus,
            statusColor,
          ), // Header biru (TETAP DI SINI)
          Expanded(
            // Expanded agar konten scroll mengisi ruang
            child: SingleChildScrollView(
              // Konten bisa di-scroll
              padding: const EdgeInsets.all(
                20.0,
              ), // Padding sekeliling konten scroll
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Agar Align bekerja
                children: [
                  // const SizedBox(height: 20), // Jarak dari header sudah diatur padding SingleChildScrollView
                  _buildFormCard(
                    displayStatus,
                    statusColor,
                  ), // Kartu detail form
                  const SizedBox(height: 24),
                  _buildUserListCard(), // Kartu list pengguna
                  const SizedBox(height: 30), // Jarak sebelum tombol
                  // --- TOMBOL APPROVAL DI DALAM SCROLL ---
                  Align(
                    // Align ke kanan
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: onApproveTap, // Panggil callback onApproveTap
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
                        'Approval',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  // --- AKHIR TOMBOL APPROVAL ---
                  const SizedBox(
                    height: 20,
                  ), // Beri sedikit ruang di bawah tombol
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDER ---

  Widget _buildHeader(String status, Color statusColor) {
    // Kode _buildHeader TIDAK BERUBAH dari versi asli Anda
    String chipText = status;
    if (status == "Menunggu Persetujuan Penanggung Jawab") {
      chipText =
          "Menunggu Persetujuan\nPenanggung Jawab"; // <- Perbaikan wrap dari sebelumnya
    }
    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF1A39D9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: onBack,
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                'Form\nPengajuan\nPenggunaan\nRuangan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                chipText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  height: 1.2,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(String status, Color statusColor) {
    // Kode _buildFormCard TIDAK BERUBAH
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReadOnlyField(
            label: "Jenis Kegiatan",
            value: peminjaman.jenisKegiatan,
          ),
          _buildReadOnlyField(
            label: "Nama Kegiatan",
            value: peminjaman.namaKegiatan,
          ),
          _buildReadOnlyField(
            label: "NIM / NIK / Unit Pengaju",
            value: "222331",
            helperText: "Jika tidak memiliki NIM, dapat diisi dengan NIK KTP",
          ),
          _buildReadOnlyField(
            label: "Nama Pengaju",
            value: "Gilang bagus Ramadhan",
          ),
          _buildReadOnlyField(
            label: "Alamat E-Mail Pengaju",
            value: "gilang@polibatam.ac.id",
          ),
          _buildReadOnlyField(
            label: "Penanggung Jawab",
            value: "GL | Gilang Bagus Ramadhan, A.Md.Kom",
          ),
          _buildReadOnlyField(
            label: "Tanggal Penggunaan",
            value: DateFormat('MM/dd/yyyy').format(peminjaman.tanggalPinjam),
          ),
          _buildReadOnlyField(
            label: "Ruangan",
            value: "GU.601 - Workspace Virtual Reality",
          ),
          Row(
            children: [
              Expanded(
                child: _buildReadOnlyField(
                  label: "Jam Mulai",
                  value: peminjaman.jamKegiatan.split(' - ')[0],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildReadOnlyField(
                  label: "Jam Selesai",
                  value: peminjaman.jamKegiatan.split(' - ')[1],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserListCard() {
    // Kode _buildUserListCard TIDAK BERUBAH
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A39D9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              'List Pengguna Ruangan',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Show',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: '10',
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                        items: ['10', '25', '50']
                            .map(
                              (String v) => DropdownMenuItem<String>(
                                value: v,
                                child: Text(
                                  v,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'entries',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 150,
                    height: 35,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildUserDetailRow("ID", _userData['ID']!),
                    _buildUserDetailRow("NIM", _userData['NIM']!),
                    _buildUserDetailRow("Nama", _userData['Nama']!),
                    _buildUserDetailRow(
                      "Nomor Workspace",
                      _userData['Nomor Workspace']!,
                    ),
                    _buildUserDetailRow(
                      "Tipe Workspace",
                      _userData['Tipe Workspace']!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper _buildReadOnlyField DENGAN LABEL TANPA ASTERISK ---
  Widget _buildReadOnlyField({
    required String label,
    required String value,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hanya Text biasa, tanpa RichText atau '*'
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            readOnly: true,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 2.0),
              child: Text(
                helperText,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }
  // --- AKHIR PERUBAHAN LABEL ---

  Widget _buildUserDetailRow(String label, String value) {
    // Kode _buildUserDetailRow TIDAK BERUBAH
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
