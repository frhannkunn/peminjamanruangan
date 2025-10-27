// File: lib/pic/home_pic.dart (WARNA KUNING DIUBAH + TEKS PUTIH)

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';

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

class ValidasiPage extends StatefulWidget {
  final Function(Peminjaman peminjaman) onPeminjamanSelected;
  final Function(Function(String, String)) onDataUpdated;

  const ValidasiPage({
    super.key,
    required this.onPeminjamanSelected,
    required this.onDataUpdated,
  });

  @override
  State<ValidasiPage> createState() => _ValidasiPageState();
}

class _ValidasiPageState extends State<ValidasiPage> {
  List<Peminjaman> _peminjamanList = [
    Peminjaman(
      id: 6608,
      kodeBooking: "GU.601.WM.01",
      tanggalPinjam: "18 Oktober 2025",
      jamKegiatan: "07.50 - 12.00",
      namaKegiatan: "Perkuliahan",
      jenisKegiatan: "Organisasi",
      status: "Menunggu Persetujuan PIC Ruangan",
      // --- PERUBAHAN WARNA KUNING ---
      statusColor: const Color(0xFFFFC037),
    ),
    Peminjaman(
      id: 6608, // ID Duplikat
      kodeBooking: "GU.602.WM.01",
      tanggalPinjam: "19 Oktober 2025",
      jamKegiatan: "7.50 - 12.00",
      namaKegiatan: "Perkuliahan",
      jenisKegiatan: "Organisasi",
      status: "Disetujui",
      statusColor: const Color(0xFF00D800),
    ),
  ];

  @override
  void initState() {
    super.initState();
    widget.onDataUpdated(_updatePeminjamanStatus);
  }

  void _updatePeminjamanStatus(String id, String newStatus) {
    if (mounted) {
      setState(() {
        final intId = int.tryParse(id);
        if (intId == null) return;

        final index = _peminjamanList.indexWhere((p) => p.id == intId);
        if (index != -1) {
          final oldPeminjaman = _peminjamanList[index];

          Color newColor;
          String newStatusText;

          if (newStatus == "Disetujui") {
            newStatusText = "Disetujui";
            newColor = const Color(0xFF00D800);
          } else {
            newStatusText = "Ditolak PIC";
            newColor = Colors.red;
          }

          _peminjamanList[index] = oldPeminjaman.copyWith(
            status: newStatusText,
            statusColor: newColor,
          );

          _peminjamanList = List.from(_peminjamanList);
        }
      });
    }
  }

  String? _selectedRuangan = '- Hanya Tampilkan Ruangan Saya -';
  String? _selectedStatus = '- Semua Status -';
  String _searchQuery = '';

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
    // 'Sedang Dipakai', // Dihapus
    'Selesai',
  ];

  List<Peminjaman> get _filteredPeminjamanList {
    List<Peminjaman> filteredByStatus = _peminjamanList;
    if (_selectedStatus != null && _selectedStatus != '- Semua Status -') {
      if (_selectedStatus == 'Menunggu Persetujui') {
        filteredByStatus = _peminjamanList
            .where(
              (p) => p.status.toLowerCase().contains('menunggu persetujuan'),
            )
            .toList();
      } else {
        filteredByStatus = _peminjamanList
            .where((p) => p.status == _selectedStatus)
            .toList();
      }
    }

    final filteredBySearch = filteredByStatus.where((peminjaman) {
      final query = _searchQuery.toLowerCase();
      if (query.isEmpty) return true;
      return peminjaman.kodeBooking.toLowerCase().contains(query) ||
          peminjaman.namaKegiatan.toLowerCase().contains(query) ||
          peminjaman.jenisKegiatan.toLowerCase().contains(query) ||
          peminjaman.status.toLowerCase().contains(query);
    }).toList();

    return filteredBySearch;
  }

  void _goToProsesValidasi(Peminjaman peminjaman) {
    widget.onPeminjamanSelected(peminjaman);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                    _buildFilters(),
                    const SizedBox(height: 20),
                    _buildDataList(),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildHeaderAndCards(),
      ],
    );
  }

  Widget _buildFilters() {
    final shadowDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          spreadRadius: 0,
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter Ruangan:',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          isExpanded: true,
          value: _selectedRuangan,
          items: _ruanganOptions.map((item) {
            if (item['isHeader'] as bool) {
              return DropdownMenuItem<String>(
                enabled: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Text(
                    item['value'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Text(item['value'], style: GoogleFonts.poppins()),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRuangan = value;
            });
          },
          buttonStyleData: ButtonStyleData(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: shadowDecoration,
          ),
          dropdownStyleData: DropdownStyleData(
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
            offset: const Offset(0, -10),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
            iconSize: 24,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Filter Status Peminjaman:',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          isExpanded: true,
          value: _selectedStatus,
          items: _statusOptions
              .map(
                (String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Text(item, style: GoogleFonts.poppins()),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedStatus = value;
            });
          },
          buttonStyleData: ButtonStyleData(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: shadowDecoration,
          ),
          dropdownStyleData: DropdownStyleData(
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
            offset: const Offset(0, -10),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
            iconSize: 24,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              'search :',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 45,
                decoration: shadowDecoration.copyWith(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  style: GoogleFonts.poppins(),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Cari...",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                    suffixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataList() {
    final listToShow = _filteredPeminjamanList;

    if (listToShow.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Tidak ada data peminjaman yang cocok.',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: listToShow.map((p) => _buildPeminjamanCard(p)).toList(),
    );
  }

  Widget _buildPeminjamanCard(Peminjaman peminjaman) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(38),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
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
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${peminjaman.id}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: _buildStatusBadge(
                  peminjaman.status,
                  peminjaman.statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailInfoRow('Tanggal Pinjam', peminjaman.tanggalPinjam),
          const SizedBox(height: 8),
          _buildDetailInfoRow('Jam Kegiatan', peminjaman.jamKegiatan),
          const SizedBox(height: 8),
          _buildDetailInfoRow('Nama Kegiatan', peminjaman.namaKegiatan),
          const SizedBox(height: 8),
          _buildDetailInfoRow('Jenis Kegiatan', peminjaman.jenisKegiatan),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _goToProsesValidasi(peminjaman),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Detail Peminjaman',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Text(':', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // --- FUNGSI INI DIMODIFIKASI (HAPUS LOGIKA KONDISIONAL WARNA TEKS) ---
  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        softWrap: true,
        style: GoogleFonts.poppins(
          color: Colors.white, // <-- Selalu putih
          fontSize: 12,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    );
  }
  // --- AKHIR MODIFIKASI ---

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
              bottomLeft: Radius.circular(17),
              bottomRight: Radius.circular(17),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 50, left: 20),
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
                _summaryCard('Menunggu PIC', '3'),
                _summaryCard('Ditolak PIC', '3'),
                _summaryCard('Disetujui', '8'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String count) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
