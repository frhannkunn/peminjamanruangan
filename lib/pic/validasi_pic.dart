// File: lib/pic/validasi_pic.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_pic.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

// Model PeminjamanDetailModel
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

  // --- FACTORY METHOD (DATA HARDCODE) ---
  factory PeminjamanDetailModel.fromPeminjaman(Peminjaman p) {
    return PeminjamanDetailModel(
      jenisKegiatan: "Perkuliahan",
      namaKegiatan: "PBL TRPL 3I8",
      penanggungJawab: "DL | Gilang Bagus Ramadhan, A.Md.Kom",
      nimNip: "123456789",
      namaPengaju: "Rayan",
      emailPengaju: "rayan12@gmail.com",
      ruangan: "GU.601 - Workspace Multimedia",
      tanggalPenggunaan: "18 Oktober 2025",
      jamMulai: "07.50",
      jamSelesai: "12.00",

      listPengguna: [
        {
          'ID': '1',
          'Jenis Pengguna': 'Mahasiswa',
          'ID Pengguna': '123456789',
          'Pengguna Ruangan': 'Rayan',
          'Nomor Workspace': 'GU.601.WM.01',
          'Tipe Workspace': 'NON PC',
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
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 40,
                    ),
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, widget.peminjamanData.status);
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
                _buildSectionListPengguna(), // SUDAH DIPERBAIKI DI BAWAH
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

  // --- PERBAIKAN: LOGIKA MAPPING KUNCI SUDAH SAMA DENGAN FILE PJ ---
  Widget _buildSectionListPengguna() {
    final List<Map<String, String>> allUsersInData = _dataDetail.listPengguna;

    // Filter search
    final List<Map<String, String>> filteredList = allUsersInData.where((
      pengguna,
    ) {
      final query = _searchPenggunaQuery.toLowerCase();
      if (query.isEmpty) return true;
      return pengguna.values.any(
        (value) => value.toLowerCase().contains(query),
      );
    }).toList();

    // DAFTAR KUNCI YANG INGIN DITAMPILKAN (SAMA SEPERTI PJ)
    final List<String> displayKeys = [
      'ID',
      'Jenis Pengguna',
      'ID Pengguna',
      'Pengguna Ruangan',
      'Nomor Workspace',
      'Tipe Workspace',
    ];

    return _buildSectionCard(
      title: 'List Pengguna Ruangan',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
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
                        suffixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 30),

          // List Data
          if (filteredList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  _searchPenggunaQuery.isEmpty
                      ? 'Tidak ada data pengguna.'
                      : 'Tidak ada hasil pencarian.',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            )
          else
            // LOOPING DATA MENGGUNAKAN DISPLAY KEYS (AGAR MATCH DENGAN FACTORY)
            ...filteredList.map((pengguna) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  children: displayKeys.map((key) {
                    // Panggil helper row dengan key & value yang sesuai
                    return _buildPenggunaInfoRow(key, pengguna[key] ?? '-');
                  }).toList(),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
  // --- AKHIR PERBAIKAN ---

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
                color: Colors.white,
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
                color: Colors.white,
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

  Widget _buildSectionDetailKegiatan() {
    return _buildSectionCard(
      title: 'Detail Kegiatan dan Penganggung Jawab',
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
            onChanged: (value) => setState(() => _approvalValue = value),
            validator: (value) =>
                value == null ? "Harap pilih status approval" : null,
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
              icon: Icon(Icons.arrow_drop_down),
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
            style: GoogleFonts.poppins(color: Colors.black),
            decoration: InputDecoration(
              hintText: "Masukkan komentar...",
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
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
                return "Komentar diisi!";
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
                fillColor: Colors.grey[100],
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
      suffixIcon: Icon(
        Icons.calendar_today_outlined,
        color: Colors.grey[600],
        size: 20,
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
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
              color: Color(0xFF1c36d2),
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
