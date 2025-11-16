// lib/peminjaman/peminjaman.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // 💡 Diperlukan untuk DateFormat
import 'form_peminjaman.dart';
import 'qr.dart'; // 💡 Diperlukan untuk _show...Menu
import 'detail_peminjaman.dart'; // 💡 Diperlukan untuk _show...Menu
import '../services/user_session.dart';

// 1. IMPORT SERVICE DAN MODEL LENGKAP
import '../services/loan_service.dart';
import '../models/loan.dart';
import '../models/room.dart';
import '../models/lecturer.dart';


// ... (Class PeminjamanData tetap sama) ...
class PeminjamanData {
  final String id;
  final String ruangan;
  final String status;
  final String penanggungJawab;
  final String jenisKegiatan;
  final String namaKegiatan;
  final String namaPengaju;
  final DateTime tanggalPinjam;
  final int totalPeminjam;
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
    required this.totalPeminjam,
    required this.jamMulai,
    required this.jamSelesai,
    this.isExpanded = false,
  });

  PeminjamanData copyWith({bool? isExpanded}) {
    // Implementasi sederhana
    return PeminjamanData(
      id: id,
      ruangan: ruangan,
      status: status,
      penanggungJawab: penanggungJawab,
      jenisKegiatan: jenisKegiatan,
      namaKegiatan: namaKegiatan,
      namaPengaju: namaPengaju,
      tanggalPinjam: tanggalPinjam,
      totalPeminjam: totalPeminjam,
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

  // 💡 PERBAIKAN: Variabel-variabel ini digunakan di filter, tidak 'unused'
  String? _selectedGedung;
  String? _selectedStatus = "Semua Status";
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  // --- 2. PERUBAHAN STATE ---
  List<PeminjamanData> _peminjamanList = []; // List untuk UI
  
  final LoanService _loanService = LoanService();
  bool _isLoadingList = true; // Untuk loading daftar
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  // Data cache untuk mapping ID ke Nama
  Map<int, String> _roomLookup = {};
  Map<String, String> _lecturerLookup = {};
  // -------------------------

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  /// 3. FUNGSI LOAD DATA DIMODIFIKASI
  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfile = true;
      _isLoadingList = true;
    });

    try {
      // Load data pendukung (User, Dosen, Ruangan) secara bersamaan
      final results = await Future.wait([
        UserSession.getUserProfile(),
        _loanService.getLecturers(),
        _loanService.getRooms(),
      ]);

      // --- Simpan data pendukung ---
      final profile = results[0] as UserProfile?;
      final lecturers = results[1] as List<Lecturer>;
      final roomGroups = results[2] as Map<String, List<Room>>;

      // Buat lookup map untuk konversi ID -> Nama
      _lecturerLookup = { for (var lec in lecturers) lec.nik : lec.name };
      _roomLookup = {};
      for (var roomList in roomGroups.values) {
        for (var room in roomList) {
          _roomLookup[room.id] = room.name;
        }
      }
      // --- Selesai membuat lookup map ---

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoadingProfile = false;
        });
      }

      // Setelah data pendukung siap, baru load data peminjaman
      await _loadLoans();

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          _isLoadingList = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data awal: ${e.toString()}"))
        );
      }
    }
  }
  
  /// 4. FUNGSI LOAD LOANS DIMODIFIKASI (Menggunakan Lookup Map)
  Future<void> _loadLoans() async {
    if (!mounted) return;
    setState(() => _isLoadingList = true);
    
    // Mapping statis (sampai ada API)
    // ‼️ Ganti angka 0,1,2,dst. dengan ID status yang benar dari API Anda
    Map<int, String> statusMap = {
      0: 'Draft',
      1: 'Menunggu Persetujuan PJ',
      2: 'Menunggu Persetujuan PIC',
      3: 'Disetujui',
      4: 'Ditolak',
      5: 'Peminjaman Expired',
    };
    Map<int, String> activityMap = { 1: "Perkuliahan", 2: "PBL", 3: "Lainnya" };

    try {
      final apiLoans = await _loanService.getLoans();

      // Konversi List<Loan> (dari API) ke List<PeminjamanData> (untuk UI)
      final uiPeminjamanList = apiLoans.map((Loan loan) {
        
        // Gunakan lookup map, jika tidak ada, tampilkan ID-nya
        String roomName = _roomLookup[loan.roomsId] ?? 'Ruangan ID: ${loan.roomsId}';
        String lectureName = _lecturerLookup[loan.lecturesNik] ?? 'Dosen NIK: ${loan.lecturesNik}';
        String statusText = statusMap[loan.status] ?? 'Status ID: ${loan.status}';
        String activityText = activityMap[loan.activityType] ?? 'Kegiatan ID: ${loan.activityType}';

        return PeminjamanData(
          id: loan.id.toString(),
          ruangan: roomName,
          status: statusText,
          penanggungJawab: lectureName,
          jenisKegiatan: activityText,
          namaKegiatan: loan.activityName,
          namaPengaju: loan.studentName,
          tanggalPinjam: DateTime.parse(loan.loanDate),
          totalPeminjam: 0, // ✏️ API index Anda tidak menyertakan 'loanUsers'
          jamMulai: loan.startTime.substring(0, 5), // Hapus detik
          jamSelesai: loan.endTime.substring(0, 5), // Hapus detik
          isExpanded: false,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _peminjamanList = uiPeminjamanList;
          _isLoadingList = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingList = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat peminjaman: ${e.toString()}"))
        );
      }
    }
  }


  // ... (Fungsi _showForm tetap sama) ...
  void _showForm() {
    if (_isLoadingProfile) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tunggu, data profil sedang dimuat...")),
        );
      }
      return;
    }
    if (_userProfile == null) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Gagal memuat data profil. Tidak bisa buka form.")),
        );
      }
      return;
    }
    setState(() {
      _isShowingForm = true;
    });
  }

  /// 5. FUNGSI _hideForm DIUBAH (untuk refresh list)
  void _hideForm(String? message) {
    if (message != null && message.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text( message, style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500) ),
            backgroundColor: const Color(0xFFE6F4EA),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.green)),
            elevation: 0,
          ),
        );
        
        // ✏️ REFRESH LIST setelah form ditutup
        _loadLoans(); 
      }
    }
    setState(() {
      _isShowingForm = false;
    });
  }

  // --- 💡 PERBAIKAN: Fungsi-fungsi ini sekarang dipanggil OLEH UI ---
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

  void _showDisetujuiMenu(
      BuildContext context, PeminjamanData peminjaman) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height * 2,
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
      if (value == 'detail') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailPeminjamanScreen(peminjaman: peminjaman),
          ),
        );
      } else if (value == 'qr') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrScreen(peminjaman: peminjaman),
          ),
        );
      }
    });
  }

  void _showDraftMenu(BuildContext context, PeminjamanData peminjaman) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height * 2,
      ),
      items: [
        PopupMenuItem(
          value: 'detail',
          child: Text('Detail', style: GoogleFonts.poppins()),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit', style: GoogleFonts.poppins()),
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
      if (value == 'detail') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailPeminjamanScreen(peminjaman: peminjaman),
          ),
        );
      } else if (value == 'edit') {
        print("Aksi untuk Edit (Belum dibuat)");
      } else if (value == 'qr') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrScreen(peminjaman: peminjaman),
          ),
        );
      }
    });
  }

  void _showPJMenu(BuildContext context, PeminjamanData peminjaman) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height * 2,
      ),
      items: [
        PopupMenuItem(
          value: 'detail',
          child: Text('Detail', style: GoogleFonts.poppins()),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit', style: GoogleFonts.poppins()),
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
      if (value == 'detail') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailPeminjamanScreen(peminjaman: peminjaman),
          ),
        );
      } else if (value == 'edit') {
         print("Aksi untuk Edit (Belum dibuat)");
      } else if (value == 'qr') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrScreen(peminjaman: peminjaman),
          ),
        );
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      case 'Peminjaman Expired':
        return const Color(0xFFE91E63);
      case 'Draft':
        return const Color(0xFFF9A825);
      case 'Menunggu Persetujuan PJ':
      case 'Menunggu Persetujuan PIC':
      case 'Menunggu Persetujuan':
        return const Color(0xFFFf59b17);
      default:
        return Colors.blue;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  /// 6. FUNGSI BARU UNTUK HAPUS/BATALKAN PINJAMAN
  Future<void> _cancelLoan(String loanId) async {
    // Tampilkan konfirmasi
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Pengajuan?"),
        content: const Text("Apakah Anda yakin ingin membatalkan dan menghapus pengajuan ini?"),
        actions: [
          TextButton(
            child: const Text("Jangan"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Ya, Batalkan"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() => _isLoadingList = true); // Tampilkan loading
      try {
        final message = await _loanService.deleteLoan(loanId);
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green)
        );
        await _loadLoans(); // Refresh list (otomatis matikan loading)
      } catch (e) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membatalkan: ${e.toString()}"), backgroundColor: Colors.red)
        );
        if (mounted) {
          setState(() => _isLoadingList = false); // Matikan loading jika error
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isShowingForm) {
      if (_isLoadingProfile) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      
      if (_userProfile == null) {
        return Scaffold( /* ... Tampilan Error Profil ... */ );
      }

      return FormPeminjamanScreen(
        onBack: (message) => _hideForm(message),
        userProfile: _userProfile!,
      );
    }

    // --- Tampilan Daftar Peminjaman ---
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
            _buildSearchFilterCard(), // 💡 PERBAIKAN: Fungsi ini sekarang dipanggil
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
                  backgroundColor: const Color(0xFF0B4AF5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _isLoadingList 
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ))
              : _buildPeminjamanList(),
          ],
        ),
      ),
    );
  }

  // --- 💡 PERBAIKAN: Menggunakan UI dari file statis Anda ---
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
          initialValue: _selectedGedung,
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
          initialValue: _selectedStatus,
          isExpanded: true,
          decoration: _inputDecoration(),
          items: [
            'Semua Status',
            'Draft',
            'Disetujui',
            'Ditolak',
            'Menunggu Persetujuan PJ',
            'Menunggu Persetujuan PIC',
            'Peminjaman Expired'
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
  // --- AKHIR BLOK UI YANG DIPERBAIKI ---
  
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
        Text("Search:", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
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
            return _buildPeminjamanCard(peminjaman);
          },
        ),
    ]);
  }
  
  // --- 💡 PERBAIKAN: Menggunakan UI dari file statis Anda ---
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: peminjaman.status == 'Peminjaman Expired'
                    ? const Icon(Icons.close, color: Colors.white, size: 16)
                    : null,
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
                    : '-',
              ),
              _buildCardDetailRow(
                'Tanggal Pinjam:',
                DateFormat('dd MMMM yyyy').format(peminjaman.tanggalPinjam),
              ),
              _buildCardDetailRow(
                  'Waktu:', '${peminjaman.jamMulai} - ${peminjaman.jamSelesai}'),
            ],
            const SizedBox(height: 12),
            _buildCardFooterButtons(peminjaman),
          ],
        ),
      ),
    );
  }

  // --- 💡 PERBAIKAN: Menggunakan UI dari file statis Anda ---
  Widget _buildCardDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
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


  /// 7. FUNGSI _buildCardFooterButtons DIUBAH (Tombol Batal)
  Widget _buildCardFooterButtons(PeminjamanData peminjaman) {
    switch (peminjaman.status) {
      case 'Disetujui':
      case 'Peminjaman Expired':
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Builder(
              builder: (BuildContext buttonContext) {
                return ElevatedButton(
                  onPressed: () {
                    _showDisetujuiMenu(buttonContext, peminjaman);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Detail", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                );
              },
            ),
          ],
        );

      case 'Menunggu Persetujuan PJ':
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                // ✏️ Panggil fungsi hapus
                _cancelLoan(peminjaman.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Batalkan Pengajuan",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Builder(
              builder: (BuildContext buttonContext) {
                return ElevatedButton(
                  onPressed: () {
                    _showPJMenu(buttonContext, peminjaman);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Detail", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                );
              },
            ),
          ],
        );

      case 'Draft':
      case 'Menunggu Persetujuan PIC':
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                // ✏️ Panggil fungsi hapus
                _cancelLoan(peminjaman.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Batalkan Pengajuan",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Builder(
              builder: (BuildContext buttonContext) {
                return ElevatedButton(
                  onPressed: () {
                    _showDraftMenu(buttonContext, peminjaman);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Detail", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                );
              },
            ),
          ],
        );

      case 'Ditolak':
      default:
        return const SizedBox.shrink();
    }
  }
}