import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'validasi_pic.dart'; 

// --- MODEL DATA ---
class Peminjaman {
  int id;
  String kodeBooking;
  String tanggalPinjam;
  String jamKegiatan;
  String jenisKegiatan;
  String namaKegiatan;
  String status;
  Color statusColor;

  Peminjaman({
    required this.id,
    required this.kodeBooking,
    required this.tanggalPinjam,
    required this.jamKegiatan,
    required this.jenisKegiatan,
    required this.namaKegiatan,
    required this.status,
    required this.statusColor,
  });
}

class HomePicPage extends StatefulWidget {
  const HomePicPage({super.key});

  @override
  State<HomePicPage> createState() => _HomePicPageState();
}

class _HomePicPageState extends State<HomePicPage> {
  // --- DATA DUMMY ---
  final List<Peminjaman> _peminjamanList = [
    Peminjaman(
      id: 6608,
      kodeBooking: "GU.601.WM.01",
      tanggalPinjam: "18 Oktober 2025",
      jamKegiatan: "07.50 - 12.00",
      jenisKegiatan: "Perkuliahan",
      namaKegiatan: "PBL TRPL 318",
      status: "Menunggu Persetujuan PIC Ruangan",
      statusColor: const Color(0xFFFFC037), // Kuning
    ),
  ];

  // Variabel Filter
  String? _selectedRuangan = '- Hanya Tampilkan Ruangan Saya -';
  String? _selectedStatus = '- Semua Status -';

  final List<String> _ruanganOptions = [
    '- Hanya Tampilkan Ruangan Saya -',
    'GU.601 - Workspace Virtual Reality',
    'GU.602 - Workspace Multimedia',
    'GU.603 - Workspace Rendering',
    'GU.604 - Workspace Software Development',
    'GU.605 - Workspace Animation Production',
  ];

  final List<String> _statusOptions = [
    '- Semua Status -',
    'Menunggu Persetujuan',
    'Disetujui',
    'Ditolak',
    'Selesai',
    "Peminjaman Expired",
  ];

  // --- LOGIKA UPDATE STATUS ---
  void _updatePeminjamanStatus(int id, String hasilValidasi) {
    setState(() {
      var data = _peminjamanList.firstWhere((p) => p.id == id);
      if (hasilValidasi == "Disetujui") {
        // Status Utama (Pill Atas) berubah jadi Hijau
        data.status = "Disetujui";
        data.statusColor = const Color(0xFF00D800);
      } else if (hasilValidasi == "Ditolak") {
        // Status Utama (Pill Atas) berubah jadi Merah
        data.status = "Ditolak PIC";
        data.statusColor = Colors.red;
      }
    });
  }

  // --- NAVIGASI ---
  Future<void> _navigateToDetail(Peminjaman peminjaman) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ValidasiPicPage(peminjamanData: peminjaman),
      ),
    );

    if (result != null && result is String) {
      _updatePeminjamanStatus(peminjaman.id, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // LAYER 1: KONTEN SCROLLABLE
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 150), // Ruang untuk header biru
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 75,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilters(), // Widget Filter (Shadow Halus)
                      const SizedBox(height: 20),

                      // List Data
                      if (_peminjamanList.isEmpty)
                        const Center(child: Text("Tidak ada data."))
                      else
                        ..._peminjamanList.asMap().entries.map((entry) {
                          return _buildPeminjamanGroup(
                            entry.value,
                            entry.key + 1,
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // LAYER 2: HEADER BIRU & KARTU SUMMARY
          _buildHeaderAndCards(),
        ],
      ),
    );
  }

  // --- WIDGET HEADER ---
  Widget _buildHeaderAndCards() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          decoration: const BoxDecoration(
            color: Color(0xFF1c36d2),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          padding: const EdgeInsets.only(top: 60, left: 20),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Hai, Fajri!',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          top: 130,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryCard('Menunggu PIC', '5'),
                _summaryCard('Disetujui', '8'),
                _summaryCard('Ditolak', '3'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String count) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
            ),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D47A1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET ITEM PEMINJAMAN ---
  Widget _buildPeminjamanGroup(Peminjaman peminjaman, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 20.0),
          child: Text(
            'Peminjam Ruangan $index',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildPeminjamanCard(peminjaman),
      ],
    );
  }

  Widget _buildPeminjamanCard(Peminjaman peminjaman) {
    // Logika text tombol
    String buttonText =
        (peminjaman.status == "Menunggu Persetujuan PIC Ruangan")
        ? "Detail Peminjaman"
        : "Detail";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        // SHADOW HALUS (CARD)
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.50), // Transparan halus
            blurRadius: 10, // Blur lembut
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            peminjaman.kodeBooking,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // --- STATUS UTAMA (PILL ATAS - DINAMIS) ---
          Row(
            children: [
              Text(
                'ID: ${peminjaman.id}',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        peminjaman.statusColor, // Warna berubah sesuai logika
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    peminjaman.status, // Text berubah sesuai logika
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // --- STATUS PJ (PILL BAWAH - STATIS HIJAU) ---
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  'Status PJ', // LABEL DIUBAH
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                ':  ',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  // WARNA STATIS HIJAU (DISETUJUI)
                  color: const Color(0xFF00D800),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Disetujui', // TEXT STATIS DISETUJUI
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          _buildDetailRow('Tanggal Pinjam', peminjaman.tanggalPinjam),
          _buildDetailRow('Jam Kegiatan', peminjaman.jamKegiatan),
          _buildDetailRow('Jenis Kegiatan', peminjaman.jenisKegiatan),
          _buildDetailRow('Nama Kegiatan', peminjaman.namaKegiatan),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => _navigateToDetail(peminjaman),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4150FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          Text(
            ':  ',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    // Style Button Dropdown (Ada Border + Shadow Halus)
    final buttonStyle = ButtonStyleData(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        // SHADOW HALUS (DROPDOWN)
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter Ruangan:',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          isExpanded: true,
          value: _selectedRuangan,
          underline: const SizedBox(), // Hapus garis bawah default
          items: _ruanganOptions.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedRuangan = val),
          buttonStyleData: buttonStyle,
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Filter Status Peminjaman:',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          isExpanded: true,
          value: _selectedStatus,
          underline: const SizedBox(), // Hapus garis bawah default
          items: _statusOptions
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: GoogleFonts.poppins(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedStatus = val),
          buttonStyleData: buttonStyle,
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Search Bar (Ada Border + Shadow Halus)
        Row(
          children: [
            Text(
              'Search:',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                  // SHADOW HALUS (SEARCH)
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    // Border Tetap Ada
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Color(0xFF1c36d2)),
                    ),
                    suffixIcon: const Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
