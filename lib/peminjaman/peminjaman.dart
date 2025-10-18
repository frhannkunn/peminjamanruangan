import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'form_peminjaman.dart'; // PENTING: Untuk menampilkan form
import 'qr.dart'; // <-- PERUBAHAN 1: Import file qr.dart

// Class PeminjamanData dengan tambahan 'totalPeminjam'
class PeminjamanData {
  final String id;
  final String ruangan;
  final String status;
  final String penanggungJawab;
  final String jenisKegiatan;
  final String namaKegiatan;
  final String namaPengaju;
  final DateTime tanggalPinjam;
  final int totalPeminjam; // <-- Ditambahkan
  final String jamMulai;
  final String jamSelesai;
  bool isExpanded;

  PeminjamanData({
    required this.id,
    required this.ruangan,
    required this.status,
    required this.penanggungJawab,
    required this.jenisKegiatan,
    required this.namaKegiatan,
    required this.namaPengaju,
    required this.tanggalPinjam,
    required this.totalPeminjam, // <-- Ditambahkan
    required this.jamMulai,
    required this.jamSelesai,
    this.isExpanded = false,
  });

  PeminjamanData copyWith({bool? isExpanded}) {
    return PeminjamanData(
      id: id,
      ruangan: ruangan,
      status: status,
      penanggungJawab: penanggungJawab,
      jenisKegiatan: jenisKegiatan,
      namaKegiatan: namaKegiatan,
      namaPengaju: namaPengaju,
      tanggalPinjam: tanggalPinjam,
      totalPeminjam: totalPeminjam, // <-- Ditambahkan
      jamMulai: jamMulai,
      jamSelesai: jamSelesai,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class PeminjamanScreen extends StatefulWidget {
  const PeminjamanScreen({super.key});

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  bool _isShowingForm = false;

  String? _selectedGedung;
  String? _selectedStatus = "Semua Status";
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  // List data dummy yang telah diperbarui
  final List<PeminjamanData> _peminjamanList = [
    PeminjamanData(
      id: '6608',
      ruangan: 'TA.XII.4', // Sesuai gambar
      status: 'Disetujui',
      penanggungJawab: 'Gilang Bagus', // Sesuai gambar
      jenisKegiatan: 'Perkuliahan', // Sesuai gambar
      namaKegiatan: 'PBL TRPL318',
      namaPengaju: 'Gilang Bagus',
      tanggalPinjam: DateTime(2025, 10, 16),
      totalPeminjam: 2, // Sesuai gambar
      jamMulai: '08:00',
      jamSelesai: '10:00',
      isExpanded: false, // Default tertutup
    ),
    PeminjamanData(
      id: '6607',
      ruangan: 'TA.XII.3', // Sesuai gambar
      status: 'Ditolak', // Sesuai gambar
      penanggungJawab: 'Dosen B',
      jenisKegiatan: 'Rapat',
      namaKegiatan: 'Rapat Tim',
      namaPengaju: 'Dosen B',
      tanggalPinjam: DateTime(2025, 10, 15),
      totalPeminjam: 5,
      jamMulai: '13:00',
      jamSelesai: '14:00',
      isExpanded: true, // Sesuai gambar (panah ke atas)
    ),
    PeminjamanData(
      id: '6608', // ID bisa sama jika merujuk pada pengajuan yg sama
      ruangan: 'TA.XII.4', // Sesuai gambar
      status: 'Draft', // Sesuai gambar
      penanggungJawab: '', // Sesuai gambar (kosong)
      jenisKegiatan: '', // Sesuai gambar (kosong)
      namaKegiatan: 'Belum Diisi',
      namaPengaju: 'Gilang Bagus',
      tanggalPinjam: DateTime(2025, 10, 18),
      totalPeminjam: 0, // Sesuai gambar (tidak tampil)
      jamMulai: '10:00',
      jamSelesai: '11:00',
      isExpanded: false, // Default tertutup
    ),
    PeminjamanData(
      id: '6699',
      ruangan: 'Workspace (TA.12.3b)',
      status: 'Menunggu Persetujuan PJ', // Sesuai permintaan
      penanggungJawab: 'Dosen A',
      jenisKegiatan: 'Perkuliahan',
      namaKegiatan: 'PBL TRPL318',
      namaPengaju: 'Gilang Bagus',
      tanggalPinjam: DateTime(2025, 10, 17),
      totalPeminjam: 3,
      jamMulai: '10:00',
      jamSelesai: '11:00',
      isExpanded: false,
    ),
    PeminjamanData(
      id: '6700',
      ruangan: 'Lab IoT (GU.3.1)',
      status: 'Menunggu Persetujuan PIC', // Sesuai permintaan
      penanggungJawab: 'Dosen C',
      jenisKegiatan: 'Praktikum',
      namaKegiatan: 'Praktikum IoT',
      namaPengaju: 'Mahasiswa X',
      tanggalPinjam: DateTime(2025, 10, 19),
      totalPeminjam: 25,
      jamMulai: '13:00',
      jamSelesai: '15:00',
      isExpanded: false,
    ),
  ];

  void _showForm() {
    setState(() {
      _isShowingForm = true;
    });
  }

  void _hideForm(String? message) {
    if (message != null && message.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: GoogleFonts.poppins(
                  color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFFE6F4EA), // Warna hijau muda
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.green)),
            elevation: 0,
          ),
        );
      }
    }
    setState(() {
      _isShowingForm = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030));
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // --- PERUBAHAN 2: Fungsi baru untuk menampilkan menu pop-up ---
  void _showDisetujuiMenu(
      BuildContext context, PeminjamanData peminjaman) async {
    // Dapatkan posisi dan ukuran tombol yang ditekan
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    await showMenu(
      context: context,
      // Posisikan menu relatif terhadap tombol
      position: RelativeRect.fromLTRB(
        offset.dx, // Tepi kiri
        offset.dy + size.height, // Tepat di bawah tombol
        offset.dx + size.width, // Tepi kanan
        offset.dy +
            size.height * 2, // Batas bawah (asumsi)
      ),
      items: [
        PopupMenuItem(
          value: 'detail',
          child: Text('Detail', style: GoogleFonts.poppins()),
        ),
        PopupMenuItem(
          value: 'qr',
          child: Text('QR Code', style: GoogleFonts.poppins()),
        ),
      ],
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ).then((value) {
      // Tangani item yang dipilih
      if (value == 'detail') {
        // TODO: Ganti ini dengan navigasi ke halaman detail lengkap jika ada
        print("Navigasi ke Detail Screen (Belum dibuat)");
      } else if (value == 'qr') {
        // Navigasi ke QrScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrScreen(peminjaman: peminjaman),
          ),
        );
      }
    });
  }
  // --- AKHIR PERUBAHAN 2 ---


  // Fungsi status color yang diperbarui
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      case 'Draft':
        return const Color(0xFFF9A825); // Warna orange/kuning 'Draft' di gambar
      case 'Menunggu Persetujuan PJ':
      case 'Menunggu Persetujuan PIC':
      case 'Menunggu Persetujuan':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isShowingForm) {
      return FormPeminjamanScreen(
        onBack: (message) => _hideForm(message),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("Peminjaman",
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchFilterCard(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showForm,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text("Ajukan Peminjaman",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildPeminjamanList(), // <-- Widget list peminjaman
          ],
        ),
      ),
    );
  }

  // (Widget-widget filter tidak berubah)
  Widget _buildSearchFilterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Cari Peminjaman",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildDropdownGedung(),
        const SizedBox(height: 16),
        _buildDropdownStatus(),
        const SizedBox(height: 16),
        _buildDatePicker(),
      ]),
    );
  }

  Widget _buildDropdownGedung() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Gedung",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey[700])),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
          value: _selectedGedung,
          hint: const Text("Semua Gedung"),
          isExpanded: true,
          decoration: _inputDecoration(),
          items: const [
            DropdownMenuItem(
                enabled: false,
                child: Text("Gedung Utama",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DropdownMenuItem(
                value: "GU_SEMUA",
                child: Text("- Semua ruangan gedung utama")),
          ],
          onChanged: (value) => setState(() => _selectedGedung = value)),
    ]);
  }

  Widget _buildDropdownStatus() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Status",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey[700])),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
          value: _selectedStatus,
          isExpanded: true,
          decoration: _inputDecoration(),
          items: [
            'Semua Status',
            'Draft',
            'Disetujui',
            'Ditolak',
            'Menunggu Persetujuan PJ', // <-- Tambahan
            'Menunggu Persetujuan PIC' // <-- Tambahan
          ]
              .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (value) => setState(() => _selectedStatus = value)),
    ]);
  }

  Widget _buildDatePicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Tanggal Pinjam",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey[700])),
      const SizedBox(height: 8),
      TextField(
          controller: TextEditingController(
              text: _selectedDate == null
                  ? "Semua Tanggal"
                  : DateFormat('dd MMMM yyyy').format(_selectedDate!)),
          readOnly: true,
          decoration: _inputDecoration(
              hint: "Semua Tanggal",
              suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined,
                      color: Colors.grey),
                  onPressed: () => _selectDate(context))),
          onTap: () => _selectDate(context)),
    ]);
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0D47A1))),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]));
  }
  // --- (AKHIR DARI WIDGET FILTER) ---

  // Widget _buildPeminjamanList
  Widget _buildPeminjamanList() {
    final filteredList = _peminjamanList.where((p) {
      final searchLower = _searchController.text.toLowerCase();
      final matchesSearch = searchLower.isEmpty ||
          p.ruangan.toLowerCase().contains(searchLower) ||
          p.namaPengaju.toLowerCase().contains(searchLower) ||
          p.namaKegiatan.toLowerCase().contains(searchLower) ||
          p.id.contains(searchLower);
      final matchesStatus =
          _selectedStatus == 'Semua Status' || p.status == _selectedStatus;
      final matchesDate = _selectedDate == null ||
          DateFormat('yyyy-MM-dd').format(p.tanggalPinjam) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate!);
      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    return Column(children: [
      Row(children: [
        Text("Search:",
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
            child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                decoration: _inputDecoration(
                    hint: "Cari...",
                    suffixIcon: const Icon(Icons.search, color: Colors.grey)))),
      ]),
      const SizedBox(height: 16),
      if (filteredList.isEmpty)
        Center(
            child: Text("Tidak ada data peminjaman.",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])))
      else
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final peminjaman = filteredList[index];
            // Ganti ExpansionTile dengan Card kustom
            return _buildPeminjamanCard(peminjaman);
          },
        ),
    ]);
  }

  // --- Widget Kustom Kartu (DENGAN LOGIKA BARU) ---
  Widget _buildPeminjamanCard(PeminjamanData peminjaman) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Header (Judul, ID, Panah)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Mencegah overflow jika judul panjang
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peminjaman.ruangan,
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'ID: ${peminjaman.id}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Tombol Panah (Toggle)
                IconButton(
                  icon: Icon(
                    peminjaman.isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      peminjaman.isExpanded = !peminjaman.isExpanded;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Chip Status
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  peminjaman.status,
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: peminjaman.status == 'Draft'
                          ? Colors.black87
                          : Colors.white),
                ),
                backgroundColor: _getStatusColor(peminjaman.status),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
            ),

            // --- INI BAGIAN YANG DIUBAH SESUAI PERMINTAAN ANDA ---
            // Detail HANYA akan tampil jika isExpanded = true
            // dan statusnya bukan 'Ditolak'.
            if (peminjaman.isExpanded && peminjaman.status != 'Ditolak') ...[
              const Divider(height: 24),
              _buildCardDetailRow(
                  'Penanggung Jawab:', peminjaman.penanggungJawab),
              _buildCardDetailRow(
                  'Jenis Kegiatan:', peminjaman.jenisKegiatan),
              _buildCardDetailRow(
                'Total Peminjam:',
                peminjaman.totalPeminjam > 0
                    ? '${peminjaman.totalPeminjam} orang'
                    : '-', // Tampilkan '-' jika 0
              ),
              _buildCardDetailRow(
                'Tanggal Pinjam:',
                DateFormat('dd MMMM yyyy').format(peminjaman.tanggalPinjam),
              ),
              _buildCardDetailRow(
                  'Waktu:', '${peminjaman.jamMulai} - ${peminjaman.jamSelesai}'),
            ],
            // --- AKHIR PERUBAHAN LOGIKA ---

            // Bagian Footer (Tombol)
            const SizedBox(height: 12),
            _buildCardFooterButtons(peminjaman),
          ],
        ),
      ),
    );
  }

  // Widget helper baru untuk baris detail di dalam kartu
  Widget _buildCardDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130, // Lebar tetap untuk label
            child: Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value, // Tampilkan '-' jika value kosong
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // --- PERUBAHAN 3: Modifikasi _buildCardFooterButtons ---
  Widget _buildCardFooterButtons(PeminjamanData peminjaman) {
    // Terapkan logika tombol berdasarkan status
    switch (peminjaman.status) {
      case 'Disetujui':
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Gunakan Builder untuk mendapatkan context yang tepat untuk showMenu
            Builder(
              builder: (BuildContext buttonContext) {
                return ElevatedButton(
                  onPressed: () {
                    // Panggil fungsi yang menampilkan menu
                    _showDisetujuiMenu(buttonContext, peminjaman);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1), // Biru tua
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Detail",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.white)),
                );
              },
            ),
          ],
        );
      // --- AKHIR PERUBAHAN 3 ---

      case 'Draft':
      case 'Menunggu Persetujuan PJ':
      case 'Menunggu Persetujuan PIC':
        // Sesuai gambar 'Draft' dan permintaan 'Menunggu'
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                // Aksi untuk Batalkan Pengajuan
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700], // Merah
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Batalkan Pengajuan",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // Aksi untuk Edit
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800], // Biru
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Edit",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ],
        );

      case 'Ditolak':
      default:
        // Tidak ada tombol untuk status 'Ditolak' atau status lainnya
        return const SizedBox.shrink();
    }
  }
}