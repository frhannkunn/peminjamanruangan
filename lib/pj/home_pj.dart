// File: lib/pj/home_pj.dart (CLEAN SINGLE DATA + LOGIC APPROVAL PIC)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'detail_pengajuan_pj.dart'; // Pastikan ini di-import
import 'package:dropdown_button2/dropdown_button2.dart'; // <-- Import package tambahan

// Model data (Tidak berubah)
class PeminjamanPj {
  final String id;
  final String ruangan;
  String? status;
  final DateTime tanggalPinjam;
  final String jamKegiatan;
  final String namaKegiatan;
  final String jenisKegiatan;

  PeminjamanPj({
    required this.id,
    required this.ruangan,
    required this.status,
    required this.tanggalPinjam,
    required this.jamKegiatan,
    required this.namaKegiatan,
    required this.jenisKegiatan,
  });

  PeminjamanPj copyWith({String? status}) {
    return PeminjamanPj(
      id: id,
      ruangan: ruangan,
      status: status ?? this.status,
      tanggalPinjam: tanggalPinjam,
      jamKegiatan: jamKegiatan,
      namaKegiatan: namaKegiatan,
      jenisKegiatan: jenisKegiatan,
    );
  }
}

class HomePjPage extends StatefulWidget {
  const HomePjPage({super.key});

  @override
  State<HomePjPage> createState() => _HomePjPageState();
}

class _HomePjPageState extends State<HomePjPage> {
  // --- DATA DUMMY (HANYA 1 DATA SEKARANG) ---
  List<PeminjamanPj> _peminjamanList = [
    PeminjamanPj(
      id: "6608",
      ruangan: "GU.601.WM.01",
      status: "Menunggu Persetujuan Penanggung Jawab",
      tanggalPinjam: DateTime(2025, 10, 18),
      jamKegiatan: "07.50 - 12.00",
      namaKegiatan: "PBL TRPL 318",
      jenisKegiatan: "Kerja Kelompok",
    ),
  ];

  // State untuk dropdown filter
  String? _selectedStatusFilter = "-Semua Status-";
  final List<String> _statusOptions = [
    "-Semua Status-",
    "Menunggu Persetujuan Penanggung Jawab",
    "Disetujui",
    "Ditolak",
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  // --- NAVIGASI ---
  Future<void> _navigateToDetail(PeminjamanPj peminjaman) async {
    final newStatus = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPengajuanPjPage(peminjaman: peminjaman),
      ),
    );

    if (newStatus != null) {
      _updatePeminjamanStatus(peminjaman.id, newStatus);
    }
  }

  void _updatePeminjamanStatus(String id, String newStatus) {
    setState(() {
      final index = _peminjamanList.indexWhere((p) => p.id == id);
      if (index != -1) {
        final oldPeminjaman = _peminjamanList[index];
        _peminjamanList[index] = oldPeminjaman.copyWith(status: newStatus);
        _peminjamanList = List.from(_peminjamanList);
      }
    });
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
                      _buildControls(),
                      const SizedBox(height: 20),
                      // List Data
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
          // Lapisan 2: Header Biru
          _buildHeaderAndCardsPJ(),
        ],
      ),
    );
  }

  // --- HEADER & SUMMARY ---
  Widget _buildHeaderAndCardsPJ() {
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
                'Hai, Kevin!',
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
                _summaryCard('Menunggu Persetujuan', '5'),
                _summaryCard('Disetujui', '4'),
                _summaryCard('Ditolak', '7'),
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

  Widget _buildPeminjamanGroup(PeminjamanPj peminjaman, int index) {
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

  // --- _buildPeminjamanCard (LOGIC APPROVAL BERTINGKAT) ---
  Widget _buildPeminjamanCard(PeminjamanPj peminjaman) {
    final String formattedDate = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(peminjaman.tanggalPinjam);

    // --- LOGIK BADGE ATAS (Deretan ID) ---
    // Logic: Jika Status PJ "Disetujui" -> Berubah jadi "Menunggu Persetujuan PIC" (Kuning)
    String badgeAtasText;
    Color badgeAtasColor;

    if (peminjaman.status == "Disetujui") {
      badgeAtasText = "Menunggu Persetujuan PIC"; // BERUBAH JADI MENUNGGU PIC
      badgeAtasColor = const Color(0xFFFFC037); // KUNING
    } else if (peminjaman.status == "Menunggu Persetujuan Penanggung Jawab") {
      badgeAtasText = "Menunggu Persetujuan Penanggung Jawab";
      badgeAtasColor = const Color(0xFFFFC037); // KUNING
    } else if (peminjaman.status == "Ditolak") {
      badgeAtasText = "Ditolak";
      badgeAtasColor = Colors.red;
    } else {
      badgeAtasText = peminjaman.status ?? '-';
      badgeAtasColor = Colors.grey;
    }

    // --- LOGIK BADGE BAWAH (Deretan Status PJ) ---
    // Logic: Jika Status PJ "Disetujui" -> Teks tetap "Disetujui" (Hijau)
    String badgeBawahText;
    Color badgeBawahColor;

    if (peminjaman.status == "Disetujui") {
      badgeBawahText = "Disetujui";
      badgeBawahColor = const Color(0xFF00D800); // HIJAU
    } else if (peminjaman.status == "Menunggu Persetujuan Penanggung Jawab") {
      badgeBawahText = "Menunggu Persetujuan"; // Teks Pendek
      badgeBawahColor = const Color(0xFFFFC037); // KUNING
    } else if (peminjaman.status == "Ditolak") {
      badgeBawahText = "Ditolak";
      badgeBawahColor = Colors.red;
    } else {
      badgeBawahText = peminjaman.status ?? '-';
      badgeBawahColor = Colors.grey;
    }

    // --- LOGIK TOMBOL ---
    final bool isApproved = peminjaman.status == "Disetujui";
    String buttonText =
        (peminjaman.status == "Menunggu Persetujuan Penanggung Jawab")
        ? 'Detail Approval'
        : (isApproved ? 'Detail' : 'Ditolak');

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
          // 1. Nama Ruangan
          Text(
            peminjaman.ruangan,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // 2. ID + BADGE ATAS (Menunggu PIC jika Approved)
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
              if (peminjaman.status != null)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeAtasColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeAtasText,
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

          // --- END ROW ID + BADGE 1 ---
          const SizedBox(height: 12),

          // 3. STATUS PJ + BADGE BAWAH (Disetujui jika Approved)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  'Status PJ',
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
                  horizontal: 10, // Padding proporsional (Medium)
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBawahColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeBawahText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11, // Font size proporsional (Medium)
                  ),
                ),
              ),
            ],
          ),

          // --- END ROW STATUS PJ + BADGE 2 ---
          const SizedBox(height: 6),

          _buildDetailRow('Tanggal Pinjam', formattedDate),
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
                  horizontal: 24,
                  vertical: 12,
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

  // --- CONTROLS (SEARCH & FILTER) ---
  Widget _buildControls() {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter Status Peminjaman:',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          value: _selectedStatusFilter,
          isExpanded: true,
          buttonStyleData: ButtonStyleData(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
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
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            selectedMenuItemBuilder: (context, item) =>
                Container(color: Colors.blue.withOpacity(0.1), child: item),
          ),
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            iconSize: 24,
            openMenuIcon: const Icon(
              Icons.keyboard_arrow_up,
              color: Colors.grey,
            ),
          ),
          items: _statusOptions.map((String status) {
            String shortStatus = status;
            if (status == "Menunggu Persetujuan Penanggung Jawab") {
              shortStatus = "Menunggu Persetujuan";
            }
            return DropdownMenuItem<String>(
              value: status,
              child: Text(
                shortStatus,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedStatusFilter = newValue;
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  decoration: inputDecoration.copyWith(
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
                  onChanged: (value) {},
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
