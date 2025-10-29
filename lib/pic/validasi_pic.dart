// File: lib/pic/validasi_pic.dart (FINAL - FIX MODEL ERROR + UPDATE FACTORY + FIX UNDEFINED IDENTIFIERS)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import model Peminjaman yang benar dari home_pic
import 'home_pic.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

// Model PeminjamanDetailModel (Tidak Berubah)
class PeminjamanDetailModel {
  String jenisKegiatan;
  String namaKegiatan;
  String penanggungJawab;
  String nimNip;
  String namaPengaju;
  String emailPengaju;
  String ruangan;
  String tanggalPenggunaan;
  String jamMulai;
  String jamSelesai;
  List<Map<String, String>> listPengguna;
  String status;
  Color statusColor;

  PeminjamanDetailModel({
    required this.jenisKegiatan,
    required this.namaKegiatan,
    required this.penanggungJawab,
    required this.nimNip,
    required this.namaPengaju,
    required this.emailPengaju,
    required this.ruangan,
    required this.tanggalPenggunaan,
    required this.jamMulai,
    required this.jamSelesai,
    required this.listPengguna,
    required this.status,
    required this.statusColor,
  });

  // --- FACTORY METHOD DIPERBARUI ---
  factory PeminjamanDetailModel.fromPeminjaman(Peminjaman p) {
    // Menerima model Peminjaman PIC
    const defaultPenanggungJawab = 'DL | Gilang Bagus Ramadhan, A.Md.Kom';

    return PeminjamanDetailModel(
      jenisKegiatan: p.jenisKegiatan,
      namaKegiatan: "PBL TRPL 3I8",
      penanggungJawab: defaultPenanggungJawab,
      nimNip: "123456789",
      namaPengaju: "Rayan",
      emailPengaju: "rayan12@gmail.com",
      ruangan: "GU.601 - Workspace Multimedia",
      tanggalPenggunaan: "18 Oktober 2025",
      jamMulai: "07.50",
      jamSelesai: "12.00",
      // --- PERBAHAN 1: MENGGUNAKAN KUNCI BARU ---
      listPengguna: [
        {
          "ID": "1",
          "Jenis Pengguna": "Mahasiswa",
          "NIM": "43424111", // <-- Kunci NIM
          "Nama": "Ahmad Sharoni", // <-- Kunci Nama
          "Nomor Workspace": "GU.601.WM.01",
        },
      ],
      // --- AKHIR PERBAHAN 1 ---
      status: p.status,
      statusColor: p.statusColor,
    );
  }
  // --- AKHIR FACTORY METHOD ---
}

// --- HALAMAN UTAMA: VALIDASI PIC PAGE ---
class ValidasiPicPage extends StatefulWidget {
  // --- PERBAIKAN 1: Menggunakan model Peminjaman PIC yang benar ---
  final Peminjaman peminjamanData;

  const ValidasiPicPage({super.key, required this.peminjamanData});

  @override
  State<ValidasiPicPage> createState() => _ValidasiPicPageState();
}

class _ValidasiPicPageState extends State<ValidasiPicPage> {
  late PeminjamanDetailModel _dataDetail;

  final _formKey = GlobalKey<FormState>();
  String? _approvalValue;
  final TextEditingController _komentarController = TextEditingController();

  final TextEditingController _searchPenggunaController =
      TextEditingController();
  String _searchPenggunaQuery = '';

  @override
  void initState() {
    super.initState();
    // Gunakan factory method yang sudah diperbarui
    _dataDetail = PeminjamanDetailModel.fromPeminjaman(widget.peminjamanData);
    _searchPenggunaController.addListener(() {
      setState(() {
        _searchPenggunaQuery = _searchPenggunaController.text;
      });
    });
  }

  @override
  void dispose() {
    _komentarController.dispose();
    _searchPenggunaController.dispose();
    super.dispose();
  }

  // --- FUNGSI HELPER ---

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
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
                    // --- PERBAIKAN: icons.check -> Icons.check ---
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 40,
                    ),
                    // --- AKHIR PERBAIKAN ---
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Approval PIC\nberhasil disimpan.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
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

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      await _showSuccessDialog();
      Navigator.pop(context, _approvalValue);
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

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // --- PERBAIKAN: icons.arrow_back -> Icons.arrow_back ---
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          // --- AKHIR PERBAIKAN ---
          onPressed: () {
            Navigator.pop(context, widget.peminjamanData.status);
          },
        ),
        title: Text(
          'Validasi Detail',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildSectionFormUtama(),
                const SizedBox(height: 24),
                _buildSectionDetailKegiatan(),
                const SizedBox(height: 20),
                _buildSectionPeminjam(),
                const SizedBox(height: 20),
                _buildSectionPenggunaan(),
                const SizedBox(height: 20),
                _buildSectionListPengguna(),
                if (_dataDetail.status.contains("Menunggu Persetujuan")) ...[
                  const SizedBox(height: 20),
                  _buildSectionApproval(),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER LIST PENGGUNA ---
  Widget _buildPenggunaInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
            ),
          ),
          Text(
            ' : ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionListPengguna() {
    final List<Map<String, String>> allUsersInData = _dataDetail.listPengguna;

    // Filter berdasarkan query pencarian (jika ada)
    final List<Map<String, String>> filteredList = allUsersInData.where((
      pengguna,
    ) {
      final query = _searchPenggunaQuery.toLowerCase();
      if (query.isEmpty) return true;
      return pengguna.values.any(
        (value) => value.toLowerCase().contains(query),
      );
    }).toList();

    return _buildSectionCard(
      title: 'List Pengguna Ruangan',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'search : ',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _searchPenggunaController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Cari...",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: InputBorder.none,
                        // --- PERBAIKAN: icons.search -> Icons.search ---
                        suffixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        // --- AKHIR PERBAIKAN ---
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 30),

          if (filteredList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  _searchPenggunaQuery.isEmpty
                      ? 'Tidak ada data pengguna.'
                      // --- PERBAIKAN: colors.grey -> Colors.grey ---
                      : 'Tidak ada hasil pencarian.',
                  style: GoogleFonts.poppins(color: Colors.grey),
                  // --- AKHIR PERBAIKAN ---
                ),
              ),
            )
          else
            // Tampilkan detail pengguna dari filteredList
            ...filteredList.map((pengguna) {
              // --- Logic untuk memetakan key display ---
              final displayData = {
                'ID': pengguna['ID'] ?? '-',
                'Jenis Pengguna': pengguna['Jenis Pengguna'] ?? '-',
                'NIM / NIK': pengguna['NIM'] ?? '-', // Menggunakan kunci "NIM"
                'Nama': pengguna['Nama'] ?? '-', // Menggunakan kunci "Nama"
                'No. Workspace': pengguna['Nomor Workspace'] ?? '-',
              };

              // Tampilkan baris data
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  children: displayData.entries.map((entry) {
                    return _buildPenggunaInfoRow(entry.key, entry.value);
                  }).toList(),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  // --- METHOD HEADER DIPERBARUI ---
  Widget _buildSectionFormUtama() {
    String status = _dataDetail.status;
    Color statusColor = _dataDetail.statusColor;
    String chipText = status;

    if (status == "Menunggu Persetujuan PIC Ruangan") {
      chipText = "Menunggu\nPersetujuan\nPIC Ruangan";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1c36d2),
        borderRadius: BorderRadius.circular(15),
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
          Expanded(
            child: Text(
              'Form\nPengajuan\nPenggunaan\nRuangan',
              style: GoogleFonts.poppins(
                // --- PERBAIKAN: colors.white -> Colors.white ---
                color: Colors.white,
                // --- AKHIR PERBAIKAN ---
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: const BoxConstraints(minWidth: 130),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              chipText,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                // --- PERBAIKAN: colors.white -> Colors.white ---
                color: Colors.white,
                // --- AKHIR PERBAIKAN ---
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // --- AKHIR METHOD HEADER ---

  // --- DROPDOWN MENJADI TEXTFIELD ---
  Widget _buildSectionDetailKegiatan() {
    return _buildSectionCard(
      title: 'Detail Kegiatan dan Tanggung Jawab',
      content: Column(
        children: [
          _buildFormTextField('Jenis Kegiatan', _dataDetail.jenisKegiatan),
          _buildFormTextField('Nama Kegiatan', _dataDetail.namaKegiatan),
          _buildFormTextField('Penanggung Jawab', _dataDetail.penanggungJawab),
        ],
      ),
    );
  }

  Widget _buildSectionPeminjam() {
    return _buildSectionCard(
      title: 'Detail Peminjaman Ruangan',
      content: Column(
        children: [
          _buildFormTextField('NIM / NIK / Unit Pengaju', _dataDetail.nimNip),
          _buildFormTextField('Nama Pengaju', _dataDetail.namaPengaju),
          _buildFormTextField(
            'Alamat E-mail Pengaju',
            _dataDetail.emailPengaju,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionPenggunaan() {
    return _buildSectionCard(
      title: 'Detail Penggunaan Ruangan',
      content: Column(
        children: [
          _buildFormTextField('Ruangan', _dataDetail.ruangan),
          _buildDatePicker('Tanggal Penggunaan', _dataDetail.tanggalPenggunaan),
          Row(
            children: [
              Expanded(
                child: _buildFormTextField('Jam Mulai', _dataDetail.jamMulai),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildFormTextField(
                  'Jam Selesai',
                  _dataDetail.jamSelesai,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // --- AKHIR PERUBAHAN DROPDOWN ---

  Widget _buildSectionApproval() {
    return _buildSectionCard(
      title: 'Form Approval PIC',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Approval PIC",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField2<String>(
            value: _approvalValue,
            hint: Text(
              "Pilih status approval",
              // --- PERBAIKAN: colors.grey -> Colors.grey ---
              style: GoogleFonts.poppins(color: Colors.grey),
              // --- AKHIR PERBAIKAN ---
            ),
            // --- PERBAIKAN: colors.black -> Colors.black ---
            style: GoogleFonts.poppins(color: Colors.black),
            // --- AKHIR PERBAIKAN ---
            decoration: InputDecoration(
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
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 0,
              ),
            ),
            items: const [
              DropdownMenuItem(value: "Disetujui", child: Text("Disetujui")),
              DropdownMenuItem(value: "Ditolak", child: Text("Ditolak")),
            ],
            onChanged: (value) {
              setState(() => _approvalValue = value);
            },
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
              offset: const Offset(0, -5),
            ),
            buttonStyleData: const ButtonStyleData(
              height: 50,
              padding: EdgeInsets.only(left: 16, right: 10),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            iconStyleData: const IconStyleData(
              // --- PERBAIKAN: icons.arrow_drop_down -> Icons.arrow_drop_down ---
              icon: Icon(Icons.arrow_drop_down),
              // --- AKHIR PERBAIKAN ---
              iconSize: 24,
            ),
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
            // --- PERBAIKAN: colors.black -> Colors.black ---
            style: GoogleFonts.poppins(color: Colors.black),
            // --- AKHIR PERBAIKAN ---
            decoration: InputDecoration(
              hintText: "Masukkan komentar...",
              // --- PERBAIKAN: colors.grey -> Colors.grey ---
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              // --- AKHIR PERBAIKAN ---
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
              if (_approvalValue == "Ditolak" &&
                  (value == null || value.isEmpty)) {
                return "Komentar wajib diisi jika menolak";
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              _buildButton("Simpan", const Color(0xFF1c36d2), _simpanData),
            ],
          ),
        ],
      ),
    );
  }

  // --- FUNGSI TextField (TIDAK PERLU DIUBAH) ---
  Widget _buildFormTextField(String label, String value, {Widget? suffixIcon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              // --- PERBAIKAN: colors.black87 -> Colors.black87 ---
              color: Colors.black87,
              // --- AKHIR PERBAIKAN ---
            ),
          ),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              // --- PERBAIKAN: colors.transparent -> Colors.transparent ---
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              // --- AKHIR PERBAIKAN ---
            ),
            child: TextFormField(
              initialValue: value,
              readOnly: true,
              maxLines: null,
              // --- PERBAIKAN: colors.black -> Colors.black ---
              style: GoogleFonts.poppins(color: Colors.black),
              // --- AKHIR PERBAIKAN ---
              decoration: InputDecoration(
                filled: true,
                // --- PERBAIKAN: colors.grey[100] -> Colors.grey[100] ---
                fillColor: Colors.grey[100],
                // --- AKHIR PERBAIKAN ---
                suffixIcon: suffixIcon,
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
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, String value) {
    return _buildFormTextField(
      label,
      value,
      // --- PERBAIKAN: icons.calendar_today_outlined -> Icons.calendar_today_outlined ---
      suffixIcon: Icon(
        Icons.calendar_today_outlined,
        color: Colors.grey[600],
        size: 20,
      ),
      // --- AKHIR PERBAIKAN ---
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        // --- PERBAIKAN: colors.white -> Colors.white ---
        color: Colors.white,
        // --- AKHIR PERBAIKAN ---
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
              color: Color(0xFF1c36d2), // Warna header card
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                // --- PERBAIKAN: colors.white -> Colors.white ---
                color: Colors.white,
                // --- AKHIR PERBAIKAN ---
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
}
