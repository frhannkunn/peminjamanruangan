// pic/home_pic.dart

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

// --- DEFINISI CLASS PEMINJAMAN ---
class Peminjaman {
  final int id;
  final String kodeBooking;
  final String tanggalPinjam;
  final String jamKegiatan;
  final String namaKegiatan;
  final String jenisKegiatan;
  final String status;
  final Color statusColor;

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
}

// --- HALAMAN VALIDASI (DAFTAR UTAMA) ---
class ValidasiPage extends StatefulWidget {
  final Function(Peminjaman peminjaman) onPeminjamanSelected;

  const ValidasiPage({super.key, required this.onPeminjamanSelected});

  @override
  State<ValidasiPage> createState() => _ValidasiPageState();
}

class _ValidasiPageState extends State<ValidasiPage> {
  // --- DATA MOCK (Hanya satu entri) ---
  final List<Peminjaman> _peminjamanList = [
    Peminjaman(
      id: 6608,
      kodeBooking: "WS.TA.12.3B.02",
      tanggalPinjam: "18 Oktober 2025",
      jamKegiatan: "07.50 - 12.00",
      namaKegiatan: "Perkuliahan",
      jenisKegiatan: "PBL TRPL 2I3",
      status: "Menunggu Persetujuan PIC Ruangan",
      statusColor: const Color(0xFFFFCC33),
    ),
  ];

  String? _selectedRuangan = '- Hanya Tampilkan Ruangan Saya -';
  String? _selectedStatus = '- Semua Status -';
  String? _selectedEntries = '10';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _ruanganOptions = [
    {'value': '- Hanya Tampilkan Ruangan Saya -', 'isHeader': false},
    {'value': 'Gedung Utama', 'isHeader': true},
    {'value': 'GU.601 - Workspace Virtual Reality', 'isHeader': false},
    {'value': 'GU.604 - Workspace Multimedia', 'isHeader': false},
    {'value': 'GU.605 - Workspace Rendering', 'isHeader': false},
    {'value': 'GU.606 - Workspace Rendering', 'isHeader': false},
  ];

  final List<String> _statusOptions = [
    '- Semua Status -',
    'Menunggu Persetujuan',
    'Disetujui',
    'Ditolak',
    'Sedang Dipakai',
    'Selesai',
  ];

  List<Peminjaman> get _filteredPeminjamanList {
    int limit = int.tryParse(_selectedEntries ?? '10') ?? 10;

    final filteredBySearch = _peminjamanList.where((peminjaman) {
      final query = _searchQuery.toLowerCase();
      return peminjaman.kodeBooking.toLowerCase().contains(query) ||
          peminjaman.namaKegiatan.toLowerCase().contains(query) ||
          peminjaman.jenisKegiatan.toLowerCase().contains(query);
    }).toList();

    return filteredBySearch.take(limit).toList();
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
                padding: const EdgeInsets.only(
                  top: 60,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter Ruangan:',
          style: TextStyle(fontWeight: FontWeight.w600),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              );
            }
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['value']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRuangan = value;
            });
          },
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
              color: Colors.white,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 300,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          ),
          menuItemStyleData: const MenuItemStyleData(height: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'Filter Status Peminjaman:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          isExpanded: true,
          value: _selectedStatus,
          items: _statusOptions
              .map(
                (String item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedStatus = value;
            });
          },
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
              color: Colors.white,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 300,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          ),
          menuItemStyleData: const MenuItemStyleData(height: 40),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text(
              'search :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 45,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 0,
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Tidak ada data peminjaman yang cocok.',
            style: TextStyle(color: Colors.grey),
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
            // --- PERBAIKAN DARI withOpacity ---
            color: Colors.grey.withAlpha(38), // 0.15 * 255
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                peminjaman.kodeBooking,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusBadge(peminjaman.status, peminjaman.statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${peminjaman.id}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const Divider(height: 20, color: Colors.grey, thickness: 0.1),
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
                child: const Text(
                  'Detail Peminjaman',
                  style: TextStyle(
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
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        const Text(':', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        // --- PERBAIKAN DARI withOpacity ---
        color: color.withAlpha(26), // 0.1 * 255
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeaderAndCards() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 50, left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Hai, Rayan!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 120,
          child: Row(
            children: [
              _summaryCard('Perlu Divalidasi', '3'),
              const SizedBox(width: 10),
              _summaryCard('Akan Dipakai', '3'),
              const SizedBox(width: 10),
              _summaryCard('Total Aktif', '8'),
            ],
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
            color: Color(0x1A000000), // Hex color with alpha
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    var secondControlPoint = Offset(
      size.width - (size.width / 3.25),
      size.height - 65,
    );
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}