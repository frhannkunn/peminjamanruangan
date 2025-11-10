// File: lib/pj/detail_pengajuan_pj.dart (DIREVISI: PERBAIKAN TAMPILAN LIST PENGGUNA)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'home_pj.dart';

class DetailPengajuanPjPage extends StatefulWidget {
  final PeminjamanPj peminjaman;

  // Constructor sudah bersih, tidak lagi menerima 'onFinish'
  const DetailPengajuanPjPage({super.key, required this.peminjaman});

  @override
  State<DetailPengajuanPjPage> createState() => _DetailPengajuanPjPageState();
}

class _DetailPengajuanPjPageState extends State<DetailPengajuanPjPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedApproval;
  final _komentarController = TextEditingController();

  // --- DATA PENGGUNA BARU SESUAI PERMINTAAN (Dipastikan Konsisten) ---
  final Map<String, String> _userData = const {
    'ID': '1234',
    'Pengguna Ruangan': 'Ahmad Sahroni',
    'Jenis Pengguna': 'Mahasiswa',
    'ID Pengguna':
        '434241121', // Diubah dari 'ID pengguna' menjadi 'ID Pengguna' agar seragam dengan Label
    'Nomor Workspace': 'GU.601.WM.01',
    'Tipe Workspace': 'NON PC',
  };
  // --- AKHIR DATA PENGGUNA BARU ---

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  // Dialog dan fungsi lainnya tetap sama...
  // (Potongan kode tidak berubah)

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final updatedStatus = _selectedApproval!;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // ... (Icon check, teks, dll tidak berubah) ...
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2.5),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Approval Penanggung Jawab\nberhasil disimpan.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 150,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        // Tutup dialog
                        Navigator.of(dialogContext).pop();

                        // Langsung tutup halaman dan kirim hasil
                        Navigator.pop(context, updatedStatus);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 3,
                      ),
                      child: Text(
                        'OK',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitApproval() {
    if (_formKey.currentState!.validate()) {
      _showSuccessDialog();
    }
  }

  // --- WIDGET TOMBOL SIMPAN ---
  Widget _buildButton(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            // Warna biru solid (seperti header card)
            backgroundColor: const Color(0xFF1c36d2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 2,
          ),
          onPressed: onTap,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET SECTION CARD ---
  Widget _buildSectionCard({required String title, required Widget content}) {
    Color headerColor;
    if (title == 'Form Approval Penanggung Jawab' ||
        title == 'List Pengguna Ruangan') {
      headerColor = const Color(0xFF1c36d2);
    } else {
      headerColor = const Color(0xFF4150FF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 0, right: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(15.0), child: content),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool needsApproval =
        widget.peminjaman.status == "Menunggu Persetujuan Penanggung Jawab";
    final bool isApproved = widget.peminjaman.status == "Disetujui";
    final String displayStatus =
        widget.peminjaman.status ?? 'Status Tidak Diketahui';
    final Color statusColor = needsApproval
        ? const Color(0xFFFFC037)
        : (isApproved ? const Color(0xFF00D800) : Colors.red);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Kirim kembali status LAMA (tidak berubah) jika menekan back
            Navigator.pop(context, widget.peminjaman.status);
          },
        ),
        title: Text(
          'Detail Pengajuan',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormHeaderCard(displayStatus, statusColor),
              const SizedBox(height: 24),
              _buildFormCard(displayStatus, statusColor),
              const SizedBox(height: 24),
              _buildUserListCard(),
              if (needsApproval) ...[
                const SizedBox(height: 24),
                _buildApprovalSection(),
              ],
              if (!needsApproval) const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: null,
    );
  }

  // Fungsi lainnya (_buildFormHeaderCard, _buildFormCard) tidak berubah...

  Widget _buildFormHeaderCard(String status, Color statusColor) {
    String chipText = status;
    if (status == "Menunggu Persetujuan Penanggung Jawab") {
      chipText = "Menunggu\nPersetujuan\nPenanggung\nJawab";
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Form\nPengajuan\nPenggunaan\nRuangan',
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            constraints: const BoxConstraints(minHeight: 50),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                chipText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.3,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(String status, Color statusColor) {
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
          _buildReadOnlyField(label: "Nama Kegiatan", value: "PBL TRPL 318"),
          _buildReadOnlyField(label: "Jenis Kegiatan", value: "Kerja Kelompok"),
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
            value: DateFormat(
              'dd MMMM yyyy',
              'id_ID',
            ).format(widget.peminjaman.tanggalPinjam),
          ),
          _buildReadOnlyField(
            label: "Ruangan",
            value: widget.peminjaman.ruangan,
          ),
          Row(
            children: [
              Expanded(
                child: _buildReadOnlyField(
                  label: "Jam Mulai",
                  value: widget.peminjaman.jamKegiatan.split(' - ')[0],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildReadOnlyField(
                  label: "Jam Selesai",
                  value: widget.peminjaman.jamKegiatan.split(' - ')[1],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- PERBAIKAN: WIDGET LIST PENGGUNA DIPERBARUI (Logika Disederhanakan) ---
  Widget _buildUserListCard() {
    // 1. Definisikan Kunci yang Ingin Ditampilkan (Urutan dan Label)
    // Kunci di sini HARUS sama persis dengan kunci di Map _userData.
    final List<String> displayKeys = [
      'ID',
      'Pengguna Ruangan',
      'Jenis Pengguna',
      'ID Pengguna',
      'Nomor Workspace',
      'Tipe Workspace',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ... (Container Header dan Search/TextField tidak berubah) ...
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF1c36d2), // Warna Biru PJ
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 5),
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
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Vertically center items in Row
                children: [
                  // --- LABEL "Search" ---
                  Text(
                    'Search:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // --- KOTAK SEARCH MEMANJANG (Expanded) ---
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: TextField(
                        style: GoogleFonts.poppins(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: "", // HINT TEXT DIHAPUS
                          suffixIcon: const Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                ],
              ),
              // --- JARAK DARI PAGINATION/SEARCH KE LIST DATA ---
              const SizedBox(height: 20),

              // --- TAMPILAN DATA BARU (Mapping Langsung) ---
              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: displayKeys.map((key) {
                    return _buildUserDetailRow(
                      key, // Key juga berfungsi sebagai Label
                      _userData[key] ?? '-', // Ambil nilai dari map
                    );
                  }).toList(),
                ),
              ),
              // --- AKHIR TAMPILAN DATA ---
            ],
          ),
        ),
      ],
    );
  }
  // --- AKHIR PERBAIKAN LIST PENGGUNA ---

  // Fungsi _buildApprovalSection, _buildReadOnlyField, _buildUserDetailRow tidak berubah...

  Widget _buildApprovalSection() {
    return _buildSectionCard(
      title: 'Form Approval Penanggung Jawab',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Approval Penanggung Jawab",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            hint: Text(
              'Pilih status approval',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            value: _selectedApproval,
            items: ['Disetujui', 'Ditolak']
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedApproval = value),
            validator: (value) {
              if (value == null) {
                return "Harap pilih status approval";
              }
              return null;
            },
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            buttonStyleData: const ButtonStyleData(
              height: 50,
              padding: EdgeInsets.only(left: 10, right: 10),
            ),
            menuItemStyleData: const MenuItemStyleData(height: 50),
          ),
          const SizedBox(height: 20),
          Text(
            "Komentar",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _komentarController,
            maxLines: 4,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Masukkan komentar (opsional)',
              hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              return null; // Komentar boleh kosong
            },
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              _buildButton("Simpan", const Color(0xFF1c36d2), _submitApproval),
            ],
          ),
        ],
      ),
    );
  }

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
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
          ),
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
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
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
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String value) {
    String displayLabel = label;
    if (label == 'ID Pengguna') {
      displayLabel = 'ID Pengguna';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              displayLabel,
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
