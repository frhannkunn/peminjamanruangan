// File: lib/pic/validasi_pic.dart (FINAL - FIX UNUSED FIELDS)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_pic.dart'; // Pastikan path ini benar

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

  factory PeminjamanDetailModel.fromPeminjaman(Peminjaman p) {
    const validJenisKegiatan = ['Perkuliahan', 'Rapat', 'Seminar'];
    const defaultPenanggungJawab = 'DL | Gilang Bagus Ramadhan, A.Md.Kom';
    final mappedJenisKegiatan = validJenisKegiatan.contains(p.jenisKegiatan)
        ? p.jenisKegiatan
        : 'Perkuliahan';
    return PeminjamanDetailModel(
      jenisKegiatan: mappedJenisKegiatan,
      namaKegiatan: "PBL TRPL 3I8",
      penanggungJawab: defaultPenanggungJawab,
      nimNip: "123456789",
      namaPengaju: "Rayan",
      emailPengaju: "rayan12@gmail.com",
      ruangan: "GU.601 - Workspace Virtual Reality",
      tanggalPenggunaan: "09/18/2025",
      jamMulai: "07.50",
      jamSelesai: "12.00",
      listPengguna: [
        {
          "ID": "3",
          "Jenis Pengguna": "Mahasiswa",
          "ID Pengguna": "87878",
          "Pengguna Ruangan": "5353544",
          "Nomor Workspace": "WS.GU.601.01",
          "Tipe Workspace": "NON PC",
        },
        {
          "ID": "4",
          "Jenis Pengguna": "Dosen",
          "ID Pengguna": "11223",
          "Pengguna Ruangan": "998877",
          "Nomor Workspace": "WS.GU.601.02",
          "Tipe Workspace": "PC",
        },
         {
          "ID": "5",
          "Jenis Pengguna": "Mahasiswa",
          "ID Pengguna": "12345",
          "Pengguna Ruangan": "67890",
          "Nomor Workspace": "WS.GU.601.03",
          "Tipe Workspace": "PC",
        },
      ],
      status: p.status,
      statusColor: p.statusColor,
    );
  }
}

// --- HALAMAN UTAMA: VALIDASI PIC PAGE ---
class ValidasiPicPage extends StatefulWidget {
  final Peminjaman peminjamanData;
  final VoidCallback onBack;
  final Function(String id, String newStatus) onSave;

  const ValidasiPicPage({
    super.key,
    required this.peminjamanData,
    required this.onBack,
    required this.onSave,
  });

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
  // int _showEntries = 10; // <-- DIHAPUS
  // final List<int> _showEntriesOptions = [10, 25, 50, 100]; // <-- DIHAPUS

  @override
  void initState() {
    super.initState();
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
      builder: (BuildContext context) {
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
                    child: const Icon(Icons.check, color: Colors.green, size: 40),
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
                        Navigator.of(context).pop();
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
      widget.onSave(widget.peminjamanData.id.toString(), _approvalValue!);
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildSectionFormUtama(),
              _buildSectionDetailKegiatan(),
              _buildSectionPeminjam(),
              _buildSectionPenggunaan(),
              _buildSectionListPengguna(),
              _buildSectionApproval(),
              const SizedBox(height: 40),
            ],
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
          Flexible(
            flex: 2,
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
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- PERBAIKAN: SEARCH INPUT DIPERBAIKI ---
  Widget _buildSectionListPengguna() {
    final List<Map<String, String>> filteredById = _dataDetail.listPengguna
        .where((pengguna) => pengguna['ID'] == '3')
        .toList();

    final List<Map<String, String>> filteredList = filteredById.where((
      pengguna,
    ) {
      final query = _searchPenggunaQuery.toLowerCase();
      if (query.isEmpty) return true;
      return pengguna.values.any(
        (value) => value.toLowerCase().contains(query),
      );
    }).toList();

    final List<Map<String, String>> listToShow = filteredList;

    return _buildSectionCard(
      title: 'List Pengguna Ruangan',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Struktur Filter Search yang diperbaiki
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Label "search :" dikembalikan (sesuai permintaan)
                Text('search : ', style: GoogleFonts.poppins(color: Colors.black54)),
                const SizedBox(width: 8), // Sedikit jarak
                
                Expanded( // <-- EXPANDED DISINI UNTUK MEMANJANGKAN KOTAK INPUT
                  child: Container(
                    // Hapus width: 120
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
                        suffixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // --- AKHIR PERBAIKAN SEARCH INPUT ---
          
          const Divider(height: 30),

          if (listToShow.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  _searchPenggunaQuery.isEmpty
                      ? 'Pengguna dengan ID 3 tidak ditemukan.'
                      : 'Tidak ada hasil pencarian untuk pengguna ID 3.',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            )
          else
            ...listToShow.map((pengguna) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  children: [
                    _buildPenggunaInfoRow('ID', pengguna['ID'] ?? '-'),
                    _buildPenggunaInfoRow(
                      'Jenis Pengguna',
                      pengguna['Jenis Pengguna'] ?? '-',
                    ),
                    _buildPenggunaInfoRow(
                      'ID Pengguna',
                      pengguna['ID Pengguna'] ?? '-',
                    ),
                    _buildPenggunaInfoRow(
                      'Pengguna Ruangan',
                      pengguna['Pengguna Ruangan'] ?? '-',
                    ),
                    _buildPenggunaInfoRow(
                      'Nomor Workspace',
                      pengguna['Nomor Workspace'] ?? '-',
                    ),
                    _buildPenggunaInfoRow(
                      'Tipe Workspace',
                      pengguna['Tipe Workspace'] ?? '-',
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  // --- SISA WIDGET BUILD LAINNYA ---

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
          DropdownButtonFormField<String>(
            value: _approvalValue,
            hint: Text(
              "Pilih status approval",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
            style: GoogleFonts.poppins(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
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
            style: GoogleFonts.poppins(color: Colors.black),
            decoration: InputDecoration(
              hintText: "Masukkan komentar",
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Komentar wajib diisi";
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          Row(children: [_buildButton("Simpan", const Color(0xFF1c36d2), _simpanData)]),
        ],
      ),
    );
  }

  Widget _buildSectionFormUtama() {
    String displayStatus = _dataDetail.status;
    if (displayStatus == "Menunggu Persetujuan PIC Ruangan") {
      displayStatus = displayStatus.replaceAll(' ', '\n');
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1c36d2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              'Form\nPengajuan\nPenggunaan\nRuangan',
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: _dataDetail.statusColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              displayStatus,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white, // Selalu putih
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDetailKegiatan() {
    return _buildSectionCard(
      title: 'Detail Kegiatan dan Tanggung Jawab',
      content: Column(
        children: [
          _buildFormDropdown('Jenis Kegiatan', _dataDetail.jenisKegiatan),
          _buildFormTextField('Nama Kegiatan', _dataDetail.namaKegiatan),
          _buildFormDropdown('Penanggung Jawab', _dataDetail.penanggungJawab),
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
          _buildFormDropdown('Ruangan', _dataDetail.ruangan),
          _buildDatePicker('Tanggal Penggunaan', _dataDetail.tanggalPenggunaan),
          Row(
            children: [
              Expanded(
                child: _buildFormDropdown('Jam Mulai', _dataDetail.jamMulai),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildFormDropdown(
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

  // --- PERBAIKAN: HILANGKAN EFEK KLIK (SPLASH) ---
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
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Bungkus dengan Theme untuk override splash/highlight
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: TextFormField(
              initialValue: value,
              readOnly: true,
              maxLines: null,
              style: GoogleFonts.poppins(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                suffixIcon: suffixIcon,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormDropdown(String label, String value) {
    return _buildFormTextField(
      label, 
      value,
      // suffixIcon Dihapus
    );
  }

  Widget _buildDatePicker(String label, String value) {
    return _buildFormTextField(
      label,
      value,
      suffixIcon: Icon(
        Icons.calendar_today_outlined,
        color: Colors.grey[600],
        size: 20,
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
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
              color: Color(0xFF1c36d2), // Warna Baru
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
}