// peminjaman.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'form_peminjaman.dart'; // PENTING: Untuk menampilkan form

// Class PeminjamanData tidak perlu diubah
class PeminjamanData {
  final String id;
  final String ruangan;
  final String status;
  final String penanggungJawab;
  final String jenisKegiatan;
  final String namaKegiatan;
  final String namaPengaju;
  final DateTime tanggalPinjam;
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
    required this.jamMulai,
    required this.jamSelesai,
    this.isExpanded = false,
  });

  PeminjamanData copyWith({bool? isExpanded}) {
    return PeminjamanData(
      id: id, ruangan: ruangan, status: status, penanggungJawab: penanggungJawab, 
      jenisKegiatan: jenisKegiatan, namaKegiatan: namaKegiatan, namaPengaju: namaPengaju, 
      tanggalPinjam: tanggalPinjam, jamMulai: jamMulai, jamSelesai: jamSelesai, 
      isExpanded: isExpanded ?? this.isExpanded
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

  final List<PeminjamanData> _peminjamanList = [
    PeminjamanData(
      id: '6608', ruangan: 'Workspace (TA.12.3b)', status: 'Disetujui',
      penanggungJawab: 'Dosen A', jenisKegiatan: 'Perkuliahan', namaKegiatan: 'PBL TRPL318',
      namaPengaju: 'Gilang Bagus', tanggalPinjam: DateTime(2025, 10, 16),
      jamMulai: '08:00', jamSelesai: '10:00', isExpanded: true,
    ),
    PeminjamanData(
      id: '6699', ruangan: 'Workspace (TA.12.3b)', status: 'Menunggu Persetujuan',
      penanggungJawab: 'Dosen A', jenisKegiatan: 'Perkuliahan', namaKegiatan: 'PBL TRPL318',
      namaPengaju: 'Gilang Bagus', tanggalPinjam: DateTime(2025, 10, 16),
      jamMulai: '10:00', jamSelesai: '11:00', isExpanded: true,
    ), 
  ]; 
  
  void _showForm() {
    setState(() {
      _isShowingForm = true;
    });
  }

  // --- PERUBAHAN 1: Fungsi hideForm sekarang bisa menerima pesan ---
  void _hideForm(String? message) {
    // Jika ada pesan yang dikirim dari form, tampilkan SnackBar
    if (message != null && message.isNotEmpty) {
      // Pastikan widget masih terpasang sebelum menampilkan SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFFE6F4EA), // Warna hijau muda
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Naikkan sedikit dari bottom bar
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.green)),
            elevation: 0,
          ),
        );
      }
    }

    // Tetap jalankan setState untuk kembali ke halaman list
    setState(() {
      _isShowingForm = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async { 
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }
  Color _getStatusColor(String status) { 
    switch (status) {
      case 'Disetujui': return Colors.green;
      case 'Ditolak': return Colors.red;
      case 'Draft': return Colors.grey.shade600;
      case 'Menunggu Persetujuan': return Colors.orange;
      default: return Colors.blue;
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
      // --- PERUBAHAN 2: Panggil FormPeminjamanScreen dengan callback yang baru ---
      return FormPeminjamanScreen(
        onBack: (message) => _hideForm(message),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar( 
        elevation: 0, backgroundColor: Colors.white, automaticallyImplyLeading: false,
        title: Text("Peminjaman", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
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
                label: Text("Ajukan Peminjaman", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildPeminjamanList(),
          ],
        ),
      ),
    );
  }

  // --- (TIDAK ADA PERUBAHAN PADA SEMUA WIDGET BUILDER DI BAWAH INI) ---
  Widget _buildSearchFilterCard() { return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Cari Peminjaman", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildDropdownGedung(),
        const SizedBox(height: 16),
        _buildDropdownStatus(),
        const SizedBox(height: 16),
        _buildDatePicker(),
      ]),
    );
  }

  Widget _buildDropdownGedung() { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Gedung", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700])),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(value: _selectedGedung, hint: Text("Semua Gedung"), isExpanded: true, decoration: _inputDecoration(), items: const [
          DropdownMenuItem(enabled: false, child: Text("Gedung Utama", style: TextStyle(fontWeight: FontWeight.bold))),
          DropdownMenuItem(value: "GU_SEMUA", child: Text("- Semua ruangan gedung utama")),
        ], onChanged: (value) => setState(() => _selectedGedung = value)),
      ]);
  }

  Widget _buildDropdownStatus() { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Status", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700])),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(value: _selectedStatus, isExpanded: true, decoration: _inputDecoration(), items: [
          'Semua Status', 'Draft', 'Disetujui', 'Ditolak', 'Menunggu Persetujuan'
        ].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (value) => setState(() => _selectedStatus = value)),
      ]);
  }

  Widget _buildDatePicker() { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Tanggal Pinjam", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700])),
      const SizedBox(height: 8),
      TextField(
        controller: TextEditingController(text: _selectedDate == null ? "Semua Tanggal" : DateFormat('dd MMMM yyyy').format(_selectedDate!)),
        readOnly: true, decoration: _inputDecoration(hint: "Semua Tanggal", suffixIcon: IconButton(icon: const Icon(Icons.calendar_today_outlined, color: Colors.grey), onPressed: () => _selectDate(context))),
        onTap: () => _selectDate(context)),
      ]);
  }

  Widget _buildPeminjamanList() {
    final filteredList = _peminjamanList.where((p) {
      final searchLower = _searchController.text.toLowerCase();
      final matchesSearch = searchLower.isEmpty || p.ruangan.toLowerCase().contains(searchLower) || p.namaPengaju.toLowerCase().contains(searchLower) || p.namaKegiatan.toLowerCase().contains(searchLower) || p.id.contains(searchLower);
      final matchesStatus = _selectedStatus == 'Semua Status' || p.status == _selectedStatus;
      final matchesDate = _selectedDate == null || DateFormat('yyyy-MM-dd').format(p.tanggalPinjam) == DateFormat('yyyy-MM-dd').format(_selectedDate!);
      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    return Column(children: [
      Row(children: [
        Text("Search:", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: _searchController, onChanged: (value) => setState(() {}), decoration: _inputDecoration(hint: "Cari...", suffixIcon: const Icon(Icons.search, color: Colors.grey)))),
      ]),
      const SizedBox(height: 16),
      if (filteredList.isEmpty) Center(child: Text("Tidak ada data peminjaman.", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]))) else ListView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final peminjaman = filteredList[index];
          return Card(margin: const EdgeInsets.only(bottom: 16), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: PageStorageKey(peminjaman.id), initiallyExpanded: peminjaman.isExpanded,
              onExpansionChanged: (expanded) => setState(() => peminjaman.isExpanded = expanded),
              title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(peminjaman.ruangan, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis), Text('ID: ${peminjaman.id}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])) ])), Chip(label: Text(peminjaman.status, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)), backgroundColor: _getStatusColor(peminjaman.status), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)) ]),
              children: [
                Divider(height: 1, color: Colors.grey[200]),
                Padding(padding: const EdgeInsets.all(16.0), child: Column(children: [
                    _buildDetailRow('Nama Pengaju:', peminjaman.namaPengaju),
                    _buildDetailRow('Nama Kegiatan:', peminjaman.namaKegiatan),
                    _buildDetailRow('Tanggal:', DateFormat('dd MMMM yyyy').format(peminjaman.tanggalPinjam)),
                    _buildDetailRow('Waktu:', '${peminjaman.jamMulai} - ${peminjaman.jamSelesai}'),
                  ]))
              ],
            ),
          ));
        },
      ),
    ]);
  }

  Widget _buildDetailRow(String label, String value) { return Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [ SizedBox(width: 120, child: Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]))), Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87))) ])); }
  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) { return InputDecoration(hintText: hint, suffixIcon: suffixIcon, contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D47A1))), hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])); }
}