// File: lib/pj/detail_pengajuan_pj.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_pj.dart';

class DetailPengajuanPjPage extends StatelessWidget {
  final PeminjamanPj peminjaman;
  final VoidCallback onBack;

  const DetailPengajuanPjPage({
    super.key,
    required this.peminjaman,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // --- PERUBAHAN DIMULAI DI SINI ---
    // Hapus widget Scaffold dan ganti dengan Material + Container.
    // Ini membuat halaman detail menjadi komponen, bukan layar baru,
    // sehingga dapat menerima event sentuhan dengan benar di dalam Stack.
    return Material(
      child: Container(
        color: const Color(0xFFF4F7FC), // Pindahkan backgroundColor ke sini
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 100),
              child: Column(
                children: [
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  _buildUserListCard(),
                ],
              ),
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                  size: 28,
                ),
                onPressed: onBack,
              ),
            ),
          ],
        ),
      ),
    );
    // --- AKHIR PERUBAHAN ---
  }

  // ... (Sisa kode di file ini tidak perlu diubah, tetap sama persis)
  Widget _buildFormField({
    required String label,
    required String value,
    IconData? suffixIcon,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
        TextFormField(
          initialValue: value,
          readOnly: true,
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
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey)
                : null,
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8.0),
            child: Text(
              helperText,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 50),
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildFormField(
                label: "Jenis Kegiatan",
                value: peminjaman.jenisKegiatan,
                suffixIcon: Icons.arrow_drop_down,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: "Nama Kegiatan",
                value: peminjaman.namaKegiatan,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: "NIM / NIK / Unit Pengaju",
                value: "2223331",
                helperText:
                    "Jika tidak memiliki NIM, dapat diisi dengan NIK KTP",
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: "Nama Pengaju",
                value: "Gilang Bagus Ramadhan",
                suffixIcon: Icons.arrow_drop_down,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: "Alamat E-Mail Pengaju",
                value: "gilang@polibatam.ac.id",
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: "Penanggung Jawab",
                value: "GL | Gilang Bagus Ramadhan",
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: "Tanggal Penggunaan",
                value: DateFormat(
                  'dd/MM/yyyy',
                ).format(peminjaman.tanggalPinjam),
              ),
              const SizedBox(height: 16),
              _buildFormField(label: "Ruangan", value: peminjaman.ruangan),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      label: "Jam Mulai",
                      value: peminjaman.jamKegiatan.split(' - ')[0],
                      suffixIcon: Icons.arrow_drop_down,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      label: "Jam Selesai",
                      value: peminjaman.jamKegiatan.split(' - ')[1],
                      suffixIcon: Icons.arrow_drop_down,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1A39D9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Form Pengajuan Penggunaan Ruangan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Menunggu\nPersetujuan\nPenanggung Jawab',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserListCard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A39D9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              'List Pengguna Ruangan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
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
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildUserDetailRow("ID", "32461"),
                    _buildUserDetailRow("NIM", "5353544"),
                    _buildUserDetailRow("Nama", "usb"),
                    _buildUserDetailRow("Nomor Workspace", "WS.GU.601.01"),
                    _buildUserDetailRow("Tipe Workspace", "WS.GU.601.01"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildUserDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
