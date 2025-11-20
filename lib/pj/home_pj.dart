// File: lib/pj/home_pj.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import intl DIHAPUS karena kita pakai String Hardcode
import 'detail_pengajuan_pj.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

// --- MODEL DATA (VERSI HARDCORE STRING) ---
class PeminjamanPj {
  String id;
  String ruangan;
  String? status;
  String tanggalPinjam;
  String jamKegiatan;
  String jenisKegiatan;
  String namaKegiatan;

  PeminjamanPj({
    required this.id,
    required this.ruangan,
    required this.status,
    required this.tanggalPinjam,
    required this.jamKegiatan,
    required this.jenisKegiatan,
    required this.namaKegiatan,
  });
}

class HomePjPage extends StatefulWidget {
  const HomePjPage({super.key});

  @override
  State<HomePjPage> createState() => _HomePjPageState();
}

class _HomePjPageState extends State<HomePjPage> {
  final List<PeminjamanPj> _peminjamanList = [
    PeminjamanPj(
      id: "6608",
      ruangan: "GU.601.WM.01",
      status: "Menunggu Persetujuan Penanggung Jawab",
      tanggalPinjam: "18 Oktober 2025",
      jamKegiatan: "07.50 - 12.00",
      jenisKegiatan: "Perkuliahan",
      namaKegiatan: "PBL TRPL 318",
    ),
  ];

  String? _selectedStatusFilter = "-Semua Status-";

  final List<String> _statusOptions = [
    "-Semua Status-",
    "Menunggu Persetujuan Penanggung Jawab",
    "Disetujui",
    "Ditolak",
    "Peminjaman Expired",
  ];

  @override
  void initState() {
    super.initState();
    // initializeDateFormatting DIHAPUS
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

  // --- LOGIC UPDATE STATUS (SIMPLE) ---
  void _updatePeminjamanStatus(String id, String newStatus) {
    setState(() {
      final dataYangMauDiedit = _peminjamanList.firstWhere((p) => p.id == id);
      dataYangMauDiedit.status = newStatus;
    });
  }

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
                'Hai, Gilang!',
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

  // --- _buildPeminjamanCard ---
  Widget _buildPeminjamanCard(PeminjamanPj peminjaman) {
    // FORMATTING TANGGAL DIHAPUS, LANGSUNG PAKAI STRING
    final String formattedDate = peminjaman.tanggalPinjam;

    // Logic Badge Atas
    String badgeAtasText;
    Color badgeAtasColor;

    if (peminjaman.status == "Disetujui") {
      badgeAtasText = "Menunggu Persetujuan PIC";
      badgeAtasColor = const Color(0xFFFFC037);
    } else if (peminjaman.status == "Menunggu Persetujuan Penanggung Jawab") {
      badgeAtasText = "Menunggu Persetujuan Penanggung Jawab";
      badgeAtasColor = const Color(0xFFFFC037);
    } else if (peminjaman.status == "Ditolak") {
      badgeAtasText = "Ditolak";
      badgeAtasColor = Colors.red;
    } else if (peminjaman.status == "Peminjaman Expired") {
      badgeAtasText = "Peminjaman Expired";
      badgeAtasColor = Colors.grey;
    } else {
      badgeAtasText = peminjaman.status ?? '-';
      badgeAtasColor = Colors.grey;
    }

    // Logic Badge Bawah
    String badgeBawahText;
    Color badgeBawahColor;

    if (peminjaman.status == "Disetujui") {
      badgeBawahText = "Disetujui";
      badgeBawahColor = const Color(0xFF00D800);
    } else if (peminjaman.status == "Menunggu Persetujuan Penanggung Jawab") {
      badgeBawahText = "Menunggu Persetujuan";
      badgeBawahColor = const Color(0xFFFFC037);
    } else if (peminjaman.status == "Ditolak") {
      badgeBawahText = "Ditolak";
      badgeBawahColor = Colors.red;
    } else if (peminjaman.status == "Peminjaman Expired") {
      badgeBawahText = "Expired";
      badgeBawahColor = Colors.grey;
    } else {
      badgeBawahText = peminjaman.status ?? '-';
      badgeBawahColor = Colors.grey;
    }

    // Logic Tombol
    final bool isApproved = peminjaman.status == "Disetujui";
    String buttonText;

    if (peminjaman.status == "Menunggu Persetujuan Penanggung Jawab") {
      buttonText = 'Detail Approval';
    } else if (isApproved) {
      buttonText = 'Detail';
    } else if (peminjaman.status == "Ditolak") {
      buttonText = 'Ditolak';
    } else if (peminjaman.status == "Peminjaman Expired") {
      buttonText = 'Detail';
    } else {
      buttonText = 'Detail';
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
          Text(
            peminjaman.ruangan,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
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
                      horizontal: 14,
                      vertical: 7,
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
                        fontSize: 10,
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
                  horizontal: 10,
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
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildDetailRow('Tanggal Pinjam', formattedDate),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTROLS ---
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
              border: Border.all(
                color: const Color.fromARGB(255, 248, 244, 244),
              ),
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
            return DropdownMenuItem<String>(
              value: status,
              child: Text(
                status,
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
