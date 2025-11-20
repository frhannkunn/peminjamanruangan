// File: lib/pic/home_pic.dart (FIX BUTTON TEXT: Detail Peminjaman -> Detail)

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'validasi_pic.dart'; // Pastikan path ini benar

// Model Peminjaman (Tidak Berubah)
class Peminjaman {
  final int id;
  final String kodeBooking;
  final String tanggalPinjam;
  final String jamKegiatan;
  final String namaKegiatan;
  final String jenisKegiatan;
  String status;
  Color statusColor;

  Peminjaman({
    required this.id,
    required this.kodeBooking,
    required this.tanggalPinjam,
    required this.jamKegiatan,
    required this.namaKegiatan,
    required this.jenisKegiatan,
    required this.status,
    required this.statusColor,
  });

  Peminjaman copyWith({String? status, Color? statusColor}) {
    return Peminjaman(
      id: id,
      kodeBooking: kodeBooking,
      tanggalPinjam: tanggalPinjam,
      jamKegiatan: jamKegiatan,
      namaKegiatan: namaKegiatan,
      jenisKegiatan: jenisKegiatan,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
    );
  }
}

class HomePicPage extends StatefulWidget {
  const HomePicPage({super.key});

  @override
  State<HomePicPage> createState() => _HomePicPageState();
}

class _HomePicPageState extends State<HomePicPage> {
  // --- DATA DUMMY (SINGLE DATA) ---
  final List<Peminjaman> _peminjamanList = [
    Peminjaman(
      id: 6608,
      kodeBooking: "GU.601.WM.01",
      tanggalPinjam: "18 Oktober 2025",
      jamKegiatan: "07.50 - 12.00",
      namaKegiatan: "PBL TRPL 318",
      jenisKegiatan: "Perkuliahan",
      status: "Menunggu Persetujuan PIC Ruangan",
      statusColor: const Color(0xFFFFC037), // Kuning
    ),
  ];

  // State filter
  String? _selectedRuangan = '- Hanya Tampilkan Ruangan Saya -';
  String? _selectedStatus = '- Semua Status -';

  final List<Map<String, dynamic>> _ruanganOptions = [
    {'value': '- Hanya Tampilkan Ruangan Saya -', 'isHeader': false},
    {'value': 'Gedung Utama', 'isHeader': true},
    {'value': 'GU.601 - Workspace Virtual Reality', 'isHeader': false},
    {'value': 'GU.602 - Workspace Multimedia', 'isHeader': false},
    {'value': 'GU.603 - Workspace Rendering', 'isHeader': false},
    {'value': 'GU.604 - Workspace Rendering', 'isHeader': false},
  ];

  final List<String> _statusOptions = [
    '- Semua Status -',
    'Menunggu Persetujuan',
    'Disetujui',
    'Ditolak PIC',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
  }

  // --- NAVIGASI & UPDATE STATUS ---
  void _updatePeminjamanStatus(int id, String newStatusResult) {
    setState(() {
      final index = _peminjamanList.indexWhere((p) => p.id == id);
      if (index != -1) {
        final oldPeminjaman = _peminjamanList[index];
        Color newColor;
        String newStatusText;

        // Logika Update Status & Warna
        if (newStatusResult == "Disetujui") {
          newStatusText = "Disetujui";
          newColor = const Color(0xFF00D800); // Hijau
        } else if (newStatusResult == "Ditolak") {
          newStatusText = "Ditolak PIC";
          newColor = Colors.red; // Merah
        } else {
          newStatusText = oldPeminjaman.status;
          newColor = oldPeminjaman.statusColor;
        }

        if (newStatusText != oldPeminjaman.status) {
          _peminjamanList[index] = oldPeminjaman.copyWith(
            status: newStatusText,
            statusColor: newColor,
          );
        }
      }
    });
  }

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

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Lapisan 1: Konten Scrollable
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 150),
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
                      _buildFilters(),
                      const SizedBox(height: 20),

                      if (_peminjamanList.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Tidak ada data peminjaman.',
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...List.generate(_peminjamanList.length, (index) {
                          return _buildPeminjamanGroup(
                            _peminjamanList[index],
                            index + 1,
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lapisan 2: Header Biru & Summary Card
          _buildHeaderAndCards(),
        ],
      ),
    );
  }

  // --- HEADER & CARDS ---
  Widget _buildHeaderAndCards() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
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
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Hai, Rayan!',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
            ),
            const SizedBox(height: 4),
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

  Widget _buildPeminjamanGroup(Peminjaman peminjaman, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.0, top: index == 1 ? 0 : 20.0),
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

  // --- _buildPeminjamanCard ---
  Widget _buildPeminjamanCard(Peminjaman peminjaman) {
    // Logic Warna & Text
    bool isApproved = peminjaman.status == "Disetujui";

    // 1. Status Lengkap (Badge Atas)
    String fullStatus = peminjaman.status;

    // 2. Status Pendek (Badge Bawah)
    String shortStatus = fullStatus;
    if (fullStatus == "Menunggu Persetujuan PIC Ruangan") {
      shortStatus = "Menunggu Persetujuan";
    } else if (fullStatus == "Ditolak PIC") {
      shortStatus = "Ditolak";
    }

    // Warna
    Color badgeColor;
    if (isApproved) {
      badgeColor = const Color(0xFF00D800);
    } else if (fullStatus.contains("Ditolak")) {
      badgeColor = Colors.red;
    } else {
      badgeColor = const Color(0xFFFFC037); // Kuning
    }

    // --- LOGIKA TEXT TOMBOL (FIXED) ---
    String buttonText;
    if (fullStatus == "Menunggu Persetujuan PIC Ruangan") {
      buttonText = "Detail Peminjaman"; // SEBELUM APPROVE
    } else {
      buttonText = "Detail"; // SETELAH APPROVE/REJECT
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(40),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Kode Booking (Title)
          Text(
            peminjaman.kodeBooking,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // 2. ID + BADGE ATAS (Full Text)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ID: ${peminjaman.id}',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    fullStatus,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      height: 1.2,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3. STATUS PIC + BADGE BAWAH (Short Text & Medium Size)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  'Status PIC',
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
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  shortStatus,
                  textAlign: TextAlign.center,
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
          _buildDetailRow('Nama Kegiatan', peminjaman.namaKegiatan),
          _buildDetailRow('Jenis Kegiatan', peminjaman.jenisKegiatan),

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => _navigateToDetail(peminjaman),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4150FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTROLS (FILTER & SEARCH) ---
  Widget _buildFilters() {
    final shadowDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300), // Added border like PJ
    );

    // Common dropdown style
    final buttonStyle = ButtonStyleData(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: shadowDecoration,
    );

    final dropdownStyle = DropdownStyleData(
      maxHeight: 300,
      width: MediaQuery.of(context).size.width - 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      offset: const Offset(0, 0),
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(40),
        thickness: MaterialStateProperty.all(6),
        thumbVisibility: MaterialStateProperty.all(true),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Ruangan
        Text(
          'Filter Ruangan:',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          isExpanded: true,
          value: _selectedRuangan,
          items: _ruanganOptions.map((item) {
            if (item['isHeader'] as bool) {
              return DropdownMenuItem<String>(
                enabled: false,
                child: Text(
                  item['value'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              );
            }
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(
                item['value'],
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedRuangan = value),
          buttonStyleData: buttonStyle,
          dropdownStyleData: dropdownStyle,
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            selectedMenuItemBuilder: (context, item) =>
                Container(color: Colors.blue.withOpacity(0.1), child: item),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 16),

        // Filter Status
        Text(
          'Filter Status Peminjaman:',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          isExpanded: true,
          value: _selectedStatus,
          items: _statusOptions
              .map(
                (String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: GoogleFonts.poppins(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedStatus = value),
          buttonStyleData: buttonStyle,
          dropdownStyleData: dropdownStyle,
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            selectedMenuItemBuilder: (context, item) =>
                Container(color: Colors.blue.withOpacity(0.1), child: item),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 16),

        // Search Bar
        Row(
          children: [
            Text(
              'Search:',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 45,
                child: TextField(
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    suffixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: "",
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
}
