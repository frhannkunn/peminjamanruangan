// File: lib/pj/detail_pengajuan_pj.dart (SYNC STATUS BOX STYLE WITH PIC)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'home_pj.dart'; // Import model PeminjamanPj

class DetailPengajuanPjPage extends StatefulWidget {
  final PeminjamanPj peminjaman;
  final Function(String id, String status) onFinish;

  const DetailPengajuanPjPage({
    super.key,
    required this.peminjaman,
    required this.onFinish,
  });

  @override
  State<DetailPengajuanPjPage> createState() => _DetailPengajuanPjPageState();
}

class _DetailPengajuanPjPageState extends State<DetailPengajuanPjPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedApproval;
  final _komentarController = TextEditingController();

  final Map<String, String> _userData = const {
    'ID': '32461',
    'NIM': '5353544',
    'Nama': 'usb',
    'Nomor Workspace': 'WS.GU.601.01',
    'Tipe Workspace': 'NON PC',
  };

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  // --- FUNGSI HELPER ---

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
                        Navigator.of(dialogContext).pop();
                        widget.onFinish(widget.peminjaman.id, updatedStatus);
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

  Widget _buildButton(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
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

  Widget _buildSectionCard({required String title, required Widget content}) {
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
            decoration: const BoxDecoration(
              color: Color(0xFF1c36d2), // Warna biru PJ
              borderRadius: BorderRadius.only(
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

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    final bool needsApproval =
        widget.peminjaman.status == "Menunggu Persetujuan Penanggung Jawab";
    final bool isApproved = widget.peminjaman.status == "Disetujui";
    final String displayStatus =
        widget.peminjaman.status ?? 'Status Tidak Diketahui';
    final Color statusColor = needsApproval
        ? Colors.orange.shade400
        : (isApproved ? Colors.green : Colors.red);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => widget.onFinish(
            widget.peminjaman.id,
            widget.peminjaman.status ?? 'Menunggu Persetujuan Penanggung Jawab',
          ),
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
              _buildFormHeaderCard(
                displayStatus,
                statusColor,
              ), //<- Perubahan di sini
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

  // --- WIDGET BUILD HELPERS LAINNYA ---

  // FUNGSI INI YANG DIUBAH (STYLE STATUS BOX DISAMAKAN DENGAN PIC)
  Widget _buildFormHeaderCard(String status, Color statusColor) {
    String chipText = status;
    // Pindah baris manual HANYA jika statusnya panjang (seperti di PIC)
    if (status == "Menunggu Persetujuan Penanggung Jawab") {
      chipText = "Menunggu\nPersetujuan\nPenanggung\nJawab"; // Gunakan \n lagi
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              'Form\nPengajuan\nPenggunaan\nRuangan', // Tetap pakai \n
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // --- STYLE KOTAK STATUS DISAMAKAN DENGAN PIC ---
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ), // Padding horizontal 24
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(15), // Radius 15
            ),
            child: Text(
              chipText, // Gunakan chipText yang mungkin punya '\n'
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600, // w600
                fontSize: 12, // size 12
                height: 1.3, // height 1.3
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          // --- AKHIR PERUBAHAN STYLE ---
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
          _buildReadOnlyField(
            label: "Jenis Kegiatan",
            value: widget.peminjaman.jenisKegiatan,
          ),
          _buildReadOnlyField(
            label: "Nama Kegiatan",
            value: widget.peminjaman.namaKegiatan,
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

  Widget _buildUserListCard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1c36d2), // Warna Biru PJ
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
                  Text(
                    'Show',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
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
                                  style: GoogleFonts.poppins(
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
                  Text(
                    'entries',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 150,
                    height: 35,
                    child: TextField(
                      style: GoogleFonts.poppins(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        prefixIcon: const Icon(Icons.search, size: 18),
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
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {},
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
                  children: _userData.entries.map((entry) {
                    String label = entry.key;
                    if (!label.contains(' ')) {
                      label = label
                          .replaceAllMapped(
                            RegExp(r'[A-Z]'),
                            (match) => ' ${match.group(0)}',
                          )
                          .trim();
                    }
                    return _buildUserDetailRow(label, entry.value);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
            children: [_buildButton("Simpan", Colors.green, _submitApproval)],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
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
