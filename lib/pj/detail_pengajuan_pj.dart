import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'home_pj.dart'; // Pastikan file ini ada sesuai project Anda

// --- MODEL ---
class PeminjamanPjDetailModel {
  String jenisKegiatan;
  String namaKegiatan;
  String nimNip;
  String namaPengaju;
  String emailPengaju;
  String penanggungJawab;
  String tanggalPenggunaan;
  String ruangan;
  String jamMulai;
  String jamSelesai;
  List<Map<String, String>> listPengguna;
  String status;
  Color statusColor;

  PeminjamanPjDetailModel({
    required this.jenisKegiatan,
    required this.namaKegiatan,
    required this.nimNip,
    required this.namaPengaju,
    required this.emailPengaju,
    required this.penanggungJawab,
    required this.tanggalPenggunaan,
    required this.ruangan,
    required this.jamMulai,
    required this.jamSelesai,
    required this.listPengguna,
    required this.status,
    required this.statusColor,
  });

  // --- FACTORY METHOD ---
  factory PeminjamanPjDetailModel.fromPeminjaman(PeminjamanPj p) {
    return PeminjamanPjDetailModel(
      // --- DATA HARDCODE ---
      jenisKegiatan: "Perkuliahan",
      namaKegiatan: "PBL TRPL 318",
      nimNip: "123456789",
      namaPengaju: "Rayan",
      emailPengaju: "rayan12@gmail.com",
      penanggungJawab: "GL | Gilang Bagus Ramadhan, A.Md.Kom",
      ruangan: "GU.601 - Workspace Multimedia",
      tanggalPenggunaan: "18 Oktober 2025",
      jamMulai: "07.50",
      jamSelesai: "12.00",

      // List Pengguna Hardcode
      listPengguna: [
        {
          'ID': '1',
          'NIM': '123456789',
          'Nama': 'Rayan',
          'Nomor Workspace': 'GU.601.WM.01',
          'Tipe Workspace': 'NON PC',
        },
      ],

      // --- DATA DINAMIS ---
      status: p.status ?? "Status Tidak Diketahui",
      statusColor: _getStatusColor(p.status ?? ""),
    );
  }

  static Color _getStatusColor(String status) {
    if (status == "Menunggu Persetujuan Penanggung Jawab") {
      return const Color(0xFFFFC037); // Kuning
    } else if (status == "Disetujui") {
      return const Color(0xFF00D800); // Hijau
    } else {
      return Colors.red; // Merah/Default
    }
  }
}

class DetailPengajuanPjPage extends StatefulWidget {
  final PeminjamanPj peminjaman;

  const DetailPengajuanPjPage({super.key, required this.peminjaman});

  @override
  State<DetailPengajuanPjPage> createState() => _DetailPengajuanPjPageState();
}

class _DetailPengajuanPjPageState extends State<DetailPengajuanPjPage> {
  late PeminjamanPjDetailModel _dataDetail;

  final _formKey = GlobalKey<FormState>();
  String? _selectedApproval;
  final _komentarController = TextEditingController();

  final TextEditingController _searchPenggunaController =
      TextEditingController();
  String _searchPenggunaQuery = '';

  @override
  void initState() {
    super.initState();
    _dataDetail = PeminjamanPjDetailModel.fromPeminjaman(widget.peminjaman);
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
                        // Mengembalikan value _selectedApproval ("Disetujui" atau "Ditolak")
                        Navigator.pop(context, _selectedApproval);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF00D800),
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

  @override
  Widget build(BuildContext context) {
    final bool needsApproval =
        _dataDetail.status == "Menunggu Persetujuan Penanggung Jawab";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, widget.peminjaman.status);
          },
        ),
        title: Text(
          'Detail Peminjaman',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormHeaderCard(),
              const SizedBox(height: 24),
              _buildFormCard(),
              const SizedBox(height: 24),
              _buildUserListCard(),
              if (needsApproval) ...[
                const SizedBox(height: 24),
                _buildApprovalSection(),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeaderCard() {
    String status = _dataDetail.status;
    Color statusColor = _dataDetail.statusColor;
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
        children: [
          Expanded(
            child: Text(
              'Form\nPengajuan\nPenggunaan\nRuangan',
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
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
            value: _dataDetail.jenisKegiatan,
          ),
          _buildReadOnlyField(
            label: "Nama Kegiatan",
            value: _dataDetail.namaKegiatan,
          ),
          _buildReadOnlyField(
            label: "NIM / NIK / Unit Pengaju",
            value: _dataDetail.nimNip,
            helperText: "Jika tidak memiliki NIM, dapat diisi dengan NIK KTP",
          ),
          _buildReadOnlyField(
            label: "Nama Pengaju",
            value: _dataDetail.namaPengaju,
          ),
          _buildReadOnlyField(
            label: "Alamat E-Mail Pengaju",
            value: _dataDetail.emailPengaju,
          ),
          _buildReadOnlyField(
            label: "Penanggung Jawab",
            value: _dataDetail.penanggungJawab,
          ),
          _buildReadOnlyField(
            label: "Tanggal Penggunaan",
            value: _dataDetail.tanggalPenggunaan,
          ),
          _buildReadOnlyField(label: "Ruangan", value: _dataDetail.ruangan),
          Row(
            children: [
              Expanded(
                child: _buildReadOnlyField(
                  label: "Jam Mulai",
                  value: _dataDetail.jamMulai,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildReadOnlyField(
                  label: "Jam Selesai",
                  value: _dataDetail.jamSelesai,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserListCard() {
    final List<Map<String, String>> allUsers = _dataDetail.listPengguna;
    final List<Map<String, String>> filteredList = allUsers.where((user) {
      final query = _searchPenggunaQuery.toLowerCase();
      if (query.isEmpty) return true;
      return user.values.any((val) => val.toLowerCase().contains(query));
    }).toList();

    final List<String> displayKeys = [
      'ID',
      'NIM',
      'Nama',
      'Nomor Workspace',
      'Tipe Workspace',
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF1c36d2),
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
                children: [
                  Text(
                    'Search:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: TextField(
                        controller: _searchPenggunaController,
                        style: GoogleFonts.poppins(fontSize: 12),
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (filteredList.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Data tidak ditemukan",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              else
                ...filteredList.map((userData) {
                  return Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: displayKeys.map((key) {
                        return _buildUserDetailRow(key, userData[key] ?? '-');
                      }).toList(),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  // --- MODIFIKASI DILAKUKAN DI SINI ---
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
            ),
            hint: Text(
              'Pilih status approval',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            value: _selectedApproval,

            // --- DAFTAR ITEM DROPDOWN (MODIFIKASI) ---
            items: [
              // Opsi 1: Tampilan "Diterima", tapi Value "Disetujui"
              DropdownMenuItem<String>(
                value:
                    'Disetujui', // Value tetap "Disetujui" agar logika warna aman
                child: Text(
                  'Diterima', // User melihat teks "Diterima"
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Opsi 2: Ditolak
              DropdownMenuItem<String>(
                value: 'Ditolak',
                child: Text(
                  'Ditolak',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],

            // ----------------------------------------
            onChanged: (value) => setState(() => _selectedApproval = value),
            validator: (value) =>
                value == null ? "Harap pilih status approval" : null,
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            buttonStyleData: const ButtonStyleData(
              height: 50,
              padding: EdgeInsets.only(left: 10, right: 10),
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
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Masukkan komentar...',
              hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Komentar diisi!";
              }
              return null;
            },
          ),

          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1c36d2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _submitApproval,
                    child: Text(
                      "Simpan",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
