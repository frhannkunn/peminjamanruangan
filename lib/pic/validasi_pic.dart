// pic/validasi_pic.dart

import 'package:flutter/material.dart';
import 'home_pic.dart';

// --- MODEL DATA (tetap sama) ---
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
    final mappedJenisKegiatan =
        validJenisKegiatan.contains(p.jenisKegiatan) ? p.jenisKegiatan : 'Perkuliahan';
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
  final VoidCallback onNavigateToApproval; // Callback untuk navigasi

  const ValidasiPicPage({
    super.key,
    required this.peminjamanData,
    required this.onBack,
    required this.onNavigateToApproval, // Tambahkan di constructor
  });

  @override
  State<ValidasiPicPage> createState() => _ValidasiPicPageState();
}

class _ValidasiPicPageState extends State<ValidasiPicPage> {
  late PeminjamanDetailModel _dataDetail;

  @override
  void initState() {
    super.initState();
    _dataDetail = PeminjamanDetailModel.fromPeminjaman(widget.peminjamanData);
  }

  final List<String> _listJenisKegiatan = ['Perkuliahan', 'Rapat', 'Seminar'];
  final List<String> _listPJ = [
    'DL | Gilang Bagus Ramadhan, A.Md.Kom',
    'Lainnya',
  ];
  final List<String> _listRuangan = [
    'GU.601 - Workspace Virtual Reality',
    'GU.604 - Workspace Multimedia',
  ];
  final List<String> _listJam = ['07.50', '09.00', '12.00'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Validasi Detail',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildSectionFormUtama(),
            _buildSectionDetailKegiatan(),
            _buildSectionPeminjam(),
            _buildSectionPenggunaan(),
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 40,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  // Menggunakan callback, bukan Navigator.push
                  onPressed: widget.onNavigateToApproval,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D79FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Approval',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Semua widget helper _build... lainnya tetap sama, tidak perlu diubah) ...
  // ... (Saya akan sertakan di sini agar lengkap) ...

  Widget _buildSectionFormUtama() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Flexible(
            child: Text(
              'Form\nPengajuan\nPenggunaan\nRuangan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9A825),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              'Menunggu\nPersetujuan PIC\nRuangan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
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
          _buildFormDropdown(
            'Jenis Kegiatan *',
            _dataDetail.jenisKegiatan,
            _listJenisKegiatan,
            (newValue) {
              setState(() => _dataDetail.jenisKegiatan = newValue!);
            },
          ),
          _buildFormTextField('Nama Kegiatan *', _dataDetail.namaKegiatan),
          _buildFormDropdown(
            'Penanggung Jawab *',
            _dataDetail.penanggungJawab,
            _listPJ,
            (newValue) {
              setState(() => _dataDetail.penanggungJawab = newValue!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionPeminjam() {
    return _buildSectionCard(
      title: 'Detail Peminjaman Ruangan',
      content: Column(
        children: [
          _buildFormTextField('NIM / NIK / Unit Pengaju *', _dataDetail.nimNip),
          _buildFormTextField('Nama Pengaju *', _dataDetail.namaPengaju),
          _buildFormTextField(
            'Alamat E-mail Pengaju *',
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
          _buildFormDropdown('Ruangan *', _dataDetail.ruangan, _listRuangan,
              (
            newValue,
          ) {
            setState(() => _dataDetail.ruangan = newValue!);
          }),
          _buildDatePicker(
            'Tanggal Penggunaan *',
            _dataDetail.tanggalPenggunaan,
          ),
          Row(
            children: [
              Expanded(
                child: _buildFormDropdown(
                  'Jam Mulai *',
                  _dataDetail.jamMulai,
                  _listJam,
                  (newValue) {
                    setState(() => _dataDetail.jamMulai = newValue!);
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildFormDropdown(
                  'Jam Selesai *',
                  _dataDetail.jamSelesai,
                  _listJam,
                  (newValue) {
                    setState(() => _dataDetail.jamSelesai = newValue!);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormTextField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildFormDropdown(
    String label,
    String selectedValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: items.map((String value) {
          return DropdownMenuItem(value: value, child: Text(value));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker(String label, String value) {
    return _buildFormTextField(label, value);
  }

  Widget _buildSectionCard({
    required String title,
    required Widget content,
    bool showStatus = false,
    bool wrapTitle = false,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 20, left: 20, right: 20),
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: wrapTitle ? null : 1,
                    overflow:
                        wrapTitle ? TextOverflow.clip : TextOverflow.ellipsis,
                  ),
                ),
                if (showStatus)
                  _buildStatusBadge(
                    _dataDetail.status,
                    _dataDetail.statusColor,
                  ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(15.0), child: content),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      constraints: const BoxConstraints(minWidth: 100),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}