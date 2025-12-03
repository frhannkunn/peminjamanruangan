import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Import model dan service
import '../models/loan.dart';
import '../models/room.dart';
import '../models/lecturer.dart';
import '../services/loan_service.dart';
import '../services/room_service.dart';
import '../services/user_session.dart';

// Import screen terkait
import 'form_peminjaman.dart';
import 'qr.dart';
import 'detail_peminjaman.dart';
// import 'tambah_pengguna.dart'; // Jika diperlukan

class PeminjamanScreen extends StatefulWidget {
  const PeminjamanScreen({super.key});

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  bool _isShowingForm = false;
  
  // Filter State
  String? _selectedGedung;
  String? _selectedStatus = "Semua Status";
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  // Services
  final LoanService _loanService = LoanService();
  final RoomService _roomService = RoomService();

  // Data State
  UserProfile? _userProfile;
  List<Loan> _allLoans = [];
  Map<String, List<Room>> _groupedRooms = {};
  List<Lecturer> _lecturers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await UserSession.getUserProfile();
      final groupedRooms = await _roomService.getGroupedRooms();
      final lecturers = await _loanService.getLecturers();
      final loans = await _loanService.getLoans();

      final myLoans = loans.where((loan) => 
        loan.studentId == profile?.nikOrNim
      ).toList();

      myLoans.sort((a, b) => b.id.compareTo(a.id));

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _groupedRooms = groupedRooms;
          _lecturers = lecturers;
          _allLoans = myLoans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getRoomName(int roomId) {
    for (var entry in _groupedRooms.entries) {
      for (var room in entry.value) {
        if (room.id == roomId) return room.name;
      }
    }
    return "Unknown Room ($roomId)";
  }

  String _getRoomCode(int roomId) {
    for (var entry in _groupedRooms.entries) {
      for (var room in entry.value) {
        if (room.id == roomId) return room.code;
      }
    }
    return "-";
  }

  String _getLecturerName(String nik) {
    try {
      final lecturer = _lecturers.firstWhere((l) => l.nik == nik);
      return lecturer.name;
    } catch (e) {
      return nik;
    }
  }

  // --- PERBAIKAN 1: LOGIKA STATUS UTAMA (Gambar 1) ---
  // Asumsi alur status DB:
  // 0: Draft
  // 1: Menunggu PJ
  // 2: Disetujui PJ (Sedang Menunggu PIC) <- Ini yang diperbaiki
  // 3: Final Disetujui (PIC OK)
  // 4: Ditolak
  String _mapStatusToString(int status) {
    switch (status) {
      case 0: return 'Draft';
      case 1: return 'Menunggu Persetujuan Penanggung Jawab';
      case 2: return 'Ditolak Penanggung Jawab'; // <-- Ditolak PJ
      case 3: return 'Menunggu Persetujuan PIC'; // <-- Menunggu PIC
      case 4: return 'Ditolak PIC';              // <-- Ditolak PIC
      case 5: return 'Disetujui';                // <-- Final
      case 6: return 'Selesai';
      case 7: return 'Peminjaman Bermasalah';
      case 8: return 'Peminjaman Expired';
      default: return 'Status Tidak Dikenal ($status)';
    }
  }

  String _mapActivityType(int type) {
    switch (type) {
      case 0: return 'Perkuliahan'; // Sesuai logika Form (0)
      case 1: return 'PBL';         // Sesuai logika Form (1)
      case 3: return 'Lainnya';     // Sesuai logika Form (3)
      default: return 'Lainnya ($type)'; // Debug: Tampilkan angka jika tidak dikenali
    }
  }

  List<DropdownMenuItem<String>> _buildGroupedDropdownItems() {
    List<DropdownMenuItem<String>> items = [];
    items.add(const DropdownMenuItem(
      value: null,
      child: Text("Semua Gedung"),
    ));

    _groupedRooms.forEach((building, rooms) {
      items.add(DropdownMenuItem(
        value: "HEADER_$building",
        enabled: false,
        child: Text(building, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ));

      for (var room in rooms) {
        items.add(DropdownMenuItem(
          value: room.name,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(room.name),
          ),
        ));
      }
    });
    return items;
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 5: // Disetujui
      case 6: // Selesai
        return Colors.green;
        
      case 2: // Ditolak PJ
      case 4: // Ditolak PIC
      case 7: // Bermasalah
      case 8: // Expired
        return Colors.red;
        
      case 0: // Draft (Kuning Tua)
        return const Color(0xFFF9A825);
        
      case 1: // Menunggu PJ (Oranye)
      case 3: // Menunggu PIC (Oranye)
        return const Color(0xFFF59B17);
        
      default: return Colors.grey;
    }
  }

  void _showForm() {
    if (_userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data profil belum siap.")),
      );
      return;
    }
    setState(() => _isShowingForm = true);
  }

  void _hideForm(String? message) {
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      _initializeData();
    }
    setState(() => _isShowingForm = false);
  }

  void _handleFormSubmission(Map<String, dynamic> formData, List<dynamic> pengguna) async {
  _hideForm("Peminjaman berhasil diajukan!");
}

  // --- FUNGSI INI DIHAPUS KARENA DIGANTI POPUP MENU BUTTON ---
  // void _showMenuAction(BuildContext context, Loan loan) async { ... }

  // Fungsi navigasi baru untuk PopupMenuButton
  void _handleMenuSelection(String value, Loan loan, String statusStr) {
    if (value == 'detail') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPeminjamanScreen(loanId: loan.id, statusStr: statusStr)),
      );
    } else if (value == 'edit') {
       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormPeminjamanScreen(
            userProfile: _userProfile!, // Pastikan _userProfile tidak null
            loanToEdit: loan, // <-- Parameter baru yang akan kita buat
            onSubmit: (formData, pengguna) {
               // Callback setelah edit berhasil (opsional, bisa untuk refresh list)
               _initializeData(); 
            },
            onBack: (msg) => _hideForm(msg),
          ),
        ), 
      );

    } else if (value == 'qr') {
      // Dummy data untuk QR Screen yang ada
      final dummyData = PeminjamanData(
        id: loan.id.toString(),
        ruangan: _getRoomName(loan.roomsId),
        status: statusStr,
        penanggungJawab: _getLecturerName(loan.lecturesNik),
        jenisKegiatan: _mapActivityType(loan.activityType),
        namaKegiatan: loan.activityName,
        namaPengaju: loan.studentName,
        tanggalPinjam: DateTime.parse(loan.loanDate),
        totalPeminjam: 0,
        jamMulai: loan.startTime,
        jamSelesai: loan.endTime,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QrScreen(peminjaman: dummyData)),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isShowingForm) {
      return FormPeminjamanScreen(
        onBack: (msg) => _hideForm(msg),
        userProfile: _userProfile!,
        onSubmit: _handleFormSubmission,
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("Peminjaman",
            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _initializeData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B4AF5),
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
          ),
    );
  }

  Widget _buildSearchFilterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Cari Peminjaman",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Gedung", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _buildGroupedDropdownItems().any((item) => item.value == _selectedGedung) 
                ? _selectedGedung 
                : null,
            hint: const Text("Semua Gedung"),
            isExpanded: true,
            decoration: _inputDecoration(),
            items: _buildGroupedDropdownItems(),
            onChanged: (value) {
               if (value != null && value.startsWith("HEADER_")) return;
               setState(() => _selectedGedung = value);
            }),
        ]),

        const SizedBox(height: 16),
        
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Status", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            isExpanded: true,
            decoration: _inputDecoration(),
            items: ['Semua Status', 'Draft', 'Disetujui', 'Ditolak', 'Menunggu Persetujuan Penanggung Jawab', 'Menunggu Persetujuan PIC', 'Peminjaman Expired']
                .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (value) => setState(() => _selectedStatus = value)),
        ]),
        
        const SizedBox(height: 16),
        
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Tanggal Pinjam", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: _selectedDate == null ? "Semua Tanggal" : DateFormat('dd MMMM yyyy').format(_selectedDate!)),
            readOnly: true,
            decoration: _inputDecoration(
              hint: "Semua Tanggal",
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                onPressed: () async {
                   final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030));
                  if (picked != null && picked != _selectedDate) {
                    setState(() => _selectedDate = picked);
                  }
                })),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030));
                  if (picked != null && picked != _selectedDate) {
                    setState(() => _selectedDate = picked);
                  }
            }),
        ]),
      ]),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D47A1))),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]));
  }

  Widget _buildPeminjamanList() {
    final filteredList = _allLoans.where((loan) {
      final searchLower = _searchController.text.toLowerCase();
      final roomName = _getRoomName(loan.roomsId);
      final statusStr = _mapStatusToString(loan.status);
      
      final matchesSearch = searchLower.isEmpty ||
          roomName.toLowerCase().contains(searchLower) ||
          loan.studentName.toLowerCase().contains(searchLower) ||
          loan.activityName.toLowerCase().contains(searchLower);
      
      final matchesGedung = _selectedGedung == null || roomName == _selectedGedung;
      final matchesStatus = _selectedStatus == 'Semua Status' || statusStr == _selectedStatus;
      
      bool matchesDate = true;
      if (_selectedDate != null) {
         matchesDate = loan.loanDate == DateFormat('yyyy-MM-dd').format(_selectedDate!);
      }

      return matchesSearch && matchesGedung && matchesStatus && matchesDate;
    }).toList();

    return Column(children: [
      Row(children: [
        Text("Search:", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
            child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                decoration: _inputDecoration(hint: "Cari...", suffixIcon: const Icon(Icons.search, color: Colors.grey)))),
      ]),
      const SizedBox(height: 16),
      if (filteredList.isEmpty)
        Center(child: Text("Tidak ada data peminjaman.", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])))
      else
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            return _buildPeminjamanCard(filteredList[index]);
          },
        ),
    ]);
  }

  Widget _buildPeminjamanCard(Loan loan) {
    final roomName = _getRoomName(loan.roomsId); 
    final roomCode = _getRoomCode(loan.roomsId);
    final statusStr = _mapStatusToString(loan.status);
    final lecturerName = _getLecturerName(loan.lecturesNik);
    final activityTypeStr = _mapActivityType(loan.activityType);
    
    // Logic Status PJ
    String pjStatusText = '-';
    Color pjStatusColor = Colors.transparent;
    Color pjStatusTextColor = Colors.black;

    // Status 1: Sedang Menunggu PJ
    if (loan.status == 1) { 
      pjStatusText = 'Menunggu Persetujuan';
      pjStatusColor = const Color(0xFFF59B17);
      pjStatusTextColor = Colors.white;
    } 
    // Status 2: Ditolak PJ
    else if (loan.status == 2) { 
      pjStatusText = 'Ditolak';
      pjStatusColor = Colors.red;
      pjStatusTextColor = Colors.white;
    } 
    else if (loan.status == 8) { 
      // Handle Expired (Status 8)
      pjStatusText = 'Expired'; 
      pjStatusColor = Colors.red;
      pjStatusTextColor = Colors.white;
    }
    else if (loan.status >= 3) { 
      pjStatusText = 'Disetujui';
      pjStatusColor = Colors.green;
      pjStatusTextColor = Colors.white;
    }

    // Gunakan ValueNotifier untuk mengontrol state ekspansi di dalam listview
    final isExpandedNotifier = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isExpandedNotifier,
      builder: (context, isExpanded, child) {
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
                          
                          // 2. UBAH TEXT INI: Format "Kode - Nama Panjang"
                          Text(
                            "$roomCode $roomName", // <--- KODE DULUAN, BARU NAMA
                            style: GoogleFonts.poppins(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.black87
                            ),
                            overflow: TextOverflow.ellipsis, // Agar jika kepanjangan ada titik-titik (...)
                            maxLines: 1,
                          ),

                          Text('ID: ${loan.id}',
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey[600]),
                      onPressed: () {
                        isExpandedNotifier.value = !isExpanded;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  // Chip Status Utama (Akan berwarna kuning dan bertuliskan "Menunggu Persetujuan PIC" jika statusnya 2)
                  child: Chip(
                    label: Text(statusStr,
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                    backgroundColor: _getStatusColor(loan.status),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                ),
                
                if (isExpanded) ...[
                  const Divider(height: 24),
                  _buildCardDetailRow('Penanggung Jawab:', lecturerName),
                  
                  // Status PJ Row (Akan berwarna hijau "Disetujui" jika status utamanya "Menunggu PIC")
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 130, child: Text("Status PJ:", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]))),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: pjStatusText == '-' 
                              ? const Text("-") 
                              : Chip(
                                  label: Text(pjStatusText, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: pjStatusTextColor)),
                                  backgroundColor: pjStatusColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildCardDetailRow('Jenis Kegiatan:', activityTypeStr),
                  _buildCardDetailRow('Tanggal Pinjam:', DateFormat('dd MMMM yyyy').format(DateTime.parse(loan.loanDate))),
                  _buildCardDetailRow('Waktu:', '${loan.startTime} - ${loan.endTime}'),
                ],
                const SizedBox(height: 12),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Tombol Batalkan (Hanya untuk Draft, Menunggu PJ, Menunggu PIC)
                    if (statusStr == 'Draft' || statusStr == 'Menunggu Persetujuan Penanggung Jawab' || statusStr == 'Menunggu Persetujuan PIC')
                       ElevatedButton(
                        onPressed: () {
                          // TODO: Implementasi konfirmasi hapus
                          _loanService.deleteLoan(loan.id.toString()).then((_) {
                             _hideForm("Pengajuan dibatalkan/dihapus.");
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text("Batalkan", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    const SizedBox(width: 8),

                    // --- PERBAIKAN 2 & 3: POPUP MENU BUTTON UNTUK DETAIL/EDIT/QR ---
                    // Mengganti ElevatedButton "Detail" biasa dengan PopupMenuButton
                    // agar posisi menu drop-down pas di bawah tombolnya.
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuSelection(value, loan, statusStr),
                      itemBuilder: (BuildContext context) {
                        List<PopupMenuEntry<String>> menuItems = [];
                        
                        // Menu Detail (Selalu ada)
                        menuItems.add(PopupMenuItem(
                          value: 'detail',
                          child: Text('Detail', style: GoogleFonts.poppins()),
                        ));

                        // Menu Edit (PERBAIKAN 3: Muncul jika Draft ATAU Menunggu PJ)
                        if (statusStr == 'Draft' || statusStr == 'Menunggu Persetujuan Penanggung Jawab') {
                          menuItems.add(PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit', style: GoogleFonts.poppins()),
                          ));
                        }
                        
                        // Menu QR Code (Muncul jika bukan Draft dan bukan Ditolak)
                        if (statusStr != 'Draft' && statusStr != 'Ditolak') {
                           menuItems.add(PopupMenuItem(
                            value: 'qr',
                            child: Text('QR Code', style: GoogleFonts.poppins()),
                          ));
                        }
                        
                        return menuItems;
                      },
                      // Membuat tampilan tombol pemicu seperti ElevatedButton biru
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue[800],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Detail", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildCardDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]))),
          Expanded(child: Text(value.isEmpty ? '-' : value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87))),
        ],
      ),
    );
  }
}

// Class dummy untuk kompatibilitas dengan QrScreen yang sudah ada
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
}