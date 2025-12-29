import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/loan.dart';
import '../models/loan_user.dart';
import '../services/loan_service.dart';
import '../services/room_service.dart';
import 'package:intl/intl.dart'; 

class DetailPeminjamanScreen extends StatefulWidget {
  final int loanId;
  final String statusStr; 

  const DetailPeminjamanScreen({super.key, required this.loanId, required this.statusStr});

  @override
  State<DetailPeminjamanScreen> createState() => _DetailPeminjamanScreenState();
}

class _DetailPeminjamanScreenState extends State<DetailPeminjamanScreen> {
  final LoanService _loanService = LoanService();
  final RoomService _roomService = RoomService();
  
  late Future<Map<String, dynamic>> _detailFuture;
  // [BARU] Variable untuk Search
  final TextEditingController _searchController = TextEditingController();
  List<LoanUser> _allUsers = [];      
  List<LoanUser> _filteredUsers = []; 
  bool _isDataInitialized = false;    

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetailData();
  }

  // [BARU] Fungsi Filter
  void _runFilter(String keyword) {
    List<LoanUser> results = [];
    if (keyword.isEmpty) {
      results = _allUsers;
    } else {
      results = _allUsers.where((user) {
        final nameLower = user.namaPengguna.toLowerCase();
        final idLower = user.idCardPengguna.toLowerCase();
        final searchLower = keyword.toLowerCase();
        return nameLower.contains(searchLower) || idLower.contains(searchLower);
      }).toList();
    }

    setState(() {
      _filteredUsers = results;
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // [BARU] Bersihkan memori
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadDetailData() async {
    try {
      // Fetch detail peminjaman
      final loan = await _loanService.getLoanDetail(widget.loanId.toString());
      
      // Fetch data lecturer untuk nama PJ
      final lecturers = await _loanService.getLecturers();
      String lecturerName = loan.lecturesNik;
      try {
        final l = lecturers.firstWhere((e) => e.nik == loan.lecturesNik);
        lecturerName = l.name;
      } catch (_) {}

      // Fetch data room untuk nama ruangan
      // Karena API getRooms mengembalikan grouping, kita cari manual
      final groupedRooms = await _roomService.getGroupedRooms();
      String roomName = "Unknown";
      String roomCode = "";
      bool found = false; 
      
      for (var list in groupedRooms.values) {
        if (found) break; 

        for (var r in list) {
          if (r.id == loan.roomsId) {
            roomName = r.name;
            roomCode = r.code; 
            found = true;      
            break;             
          }
        }
      }

      return {
        'loan': loan,
        'pjName': lecturerName,
        'roomName': roomName,
        'roomCode': roomCode,
      };
    } catch (e) {
      throw Exception("Gagal memuat detail: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Warna dari desain
    // const Color darkYellow = Color(0xFFF9A825); 
    const Color chipBlue = Color(0xFF2962FF);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;
          final Loan loan = data['loan'] as Loan;
          final String pjName = data['pjName'];
          final String roomName = data['roomName'];
          final String roomCode = data['roomCode'];
          

          // [MODIFIKASI] Inisialisasi data list hanya sekali (saat pertama load)
          if (!_isDataInitialized) {
          _allUsers = loan.loanUsers ?? <LoanUser>[];
          _filteredUsers = _allUsers;
          _isDataInitialized = true;
            }

          return Column(
            children: [
              // === HEADER BIRU ===
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                decoration: const BoxDecoration(
                  color: chipBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(0, 8, 16, 8),
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Detail Pengajuan",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            Text("Penggunaan Ruangan",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // === KONTEN SCROLL ===
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === APPROVAL SECTION ===
                      Text("Approval Penanggung Jawab",
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      
                      // ✅ TAMPILKAN TANGGAL PJ DI SINI
                      // Logic: Hanya tampilkan tanggal jika status sudah direspon (Status >= 2 atau Status == 8)
                      if (loan.status >= 2 || loan.status == 8)
                        _buildDateLabel(loan.lectureResponseDate), 

                      _buildStatusDetail(loan.status),
                      
                      const SizedBox(height: 16),

                      TextFormField(
                        // Logika: Jika lectureComment kosong/null, tampilkan "Belum ada komentar"
                        // Jika ada isinya (seperti "ya saya pj"), tampilkan isinya.
                        initialValue: (loan.lectureComment == null || loan.lectureComment!.isEmpty)
                       ? "Belum ada komentar"
                       : loan.lectureComment, 
      
                        readOnly: true,
                        maxLines: 4,
                        decoration: _inputDecoration(hint: "Belum ada komentar"),
                        ),
                      const SizedBox(height: 24),

                      if (loan.status >= 3) ...[
                        Text("Approval PIC Ruangan",
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),

                        // ✅ TAMPILKAN TANGGAL PIC DI SINI
                        // Logic: Hanya tampilkan jika status >= 4 (Ditolak/Disetujui PIC) atau Expired
                        if (loan.status >= 4 || loan.status == 8)
                           _buildDateLabel(loan.picResponseDate),

                        _buildStatusPIC(loan.status),

                        const SizedBox(height: 16),


  // Kotak Komentar PIC
  TextFormField(
    initialValue: (loan.picComment == null || loan.picComment!.isEmpty)
        ? "Belum ada komentar"
        : loan.picComment,
    readOnly: true,
    maxLines: 4,
    decoration: _inputDecoration(hint: "Belum ada komentar"),
  ),
  
  const SizedBox(height: 24),
],

                      // === FORM READ-ONLY ===
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5)],
                        ),
                        child: Column(
                          children: [
                            _buildReadOnlyField("Jenis Kegiatan", _mapActivityType(loan.activityType)),
                            if (loan.activityType == 3)
                            _buildReadOnlyField("Kegiatan (Lainnya)", loan.activityOther),
                            _buildReadOnlyField("Nama Kegiatan", loan.activityName),
                            _buildReadOnlyField("Nim / Nik / Unit Pengaju", loan.studentId),
                            _buildReadOnlyField("Nama Pengaju", loan.studentName),
                            _buildReadOnlyField("Alamat E-Mail Pengaju", loan.studentEmail),
                            _buildReadOnlyField("Penanggung Jawab", pjName),
                            _buildReadOnlyField("Tanggal Pengunaan", loan.loanDate),
                            _buildReadOnlyField("Ruangan", "$roomCode - $roomName"),
                            _buildReadOnlyField("Jam Mulai", loan.startTime),
                            _buildReadOnlyField("Jam Selesai", loan.endTime, isLast: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // === LIST PENGGUNA RUANGAN ===
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: chipBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          // [PERUBAHAN 1] Pakai _filteredUsers.length, bukan users.length
                          child: Text("List Pengguna Ruangan (${_filteredUsers.length})",
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      // Container Putih Pembungkus List
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5)],
                        ),
                        // [PERUBAHAN 2] Ganti child langsung ListView menjadi Column agar bisa menumpuk Search Bar
                        child: Column(
                          children: [
                            
                            // [BARU] WIDGET SEARCH BAR (INI YANG BELUM ADA DI KODE ANDA)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _runFilter, // Panggil fungsi filter saat mengetik
                                decoration: InputDecoration(
                                  hintText: "Cari Nama atau ID Pengguna",
                                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),

                            // [PERUBAHAN 3] Gunakan _filteredUsers (BUKAN users) untuk ListView
                            _filteredUsers.isEmpty 
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(child: Text("Data tidak ditemukan", style: GoogleFonts.poppins(color: Colors.grey))),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredUsers.length, // Pakai filtered
                                separatorBuilder: (ctx, i) => const Divider(),
                                itemBuilder: (context, index) {
                                  final u = _filteredUsers[index]; // Ambil dari filtered
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildPenggunaRow("ID", u.id.toString()),
                                      _buildPenggunaRow("Pengguna Ruangan", u.namaPengguna),
                                      _buildPenggunaRow("Jenis Pengguna", u.jenisPengguna),
                                      _buildPenggunaRow("ID Pengguna", u.idCardPengguna),
                                      _buildPenggunaRow("Nomor Workspace", u.workspaceCode ?? '-'), 
                                      _buildPenggunaRow("Tipe Workspace", _mapWorkspaceType(u.workspaceType)),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      // Memberi jarak aman di bawah agar tidak tertutup nav bar HP
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildStatusDetail(int status) {
    String text = "Menunggu Persetujuan Penanggung Jawab";
    Color bg = const Color(0xFFF9A825); // Kuning (Default)
    
    if (status == 8) {
       // Kasus Expired
       text = "Peminjaman Expired"; 
       bg = Colors.red;
    } 
    else if (status == 2) { 
       // Kasus Ditolak PJ Murni
       text = "Ditolak Penanggung Jawab";
       bg = Colors.red;
    } 
    // ✅ PERBAIKAN DI SINI:
    // Jika status >= 3 (Menunggu PIC, Ditolak PIC, Disetujui PIC, Selesai)
    // Berarti PJ SUDAH SETUJU.
    else if (status >= 3 && status != 7) { 
       text = "Disetujui Penanggung Jawab";
       bg = Colors.green;
    }

    return _buildStatusChip(
      text: text,
      backgroundColor: bg,
      textColor: Colors.white,
    );
  }

  Widget _buildStatusPIC(int status) {
    String text = "Menunggu Persetujuan PIC";
    Color bg = const Color(0xFFF9A825); // Kuning/Oranye

    if (status == 8) {
       text = "Peminjaman Expired";
       bg = Colors.red;
    } else if (status == 3) {
       text = "Menunggu Persetujuan PIC";
       bg = const Color(0xFFF59B17); // Oranye
    } else if (status == 4) {
       text = "Ditolak PIC";
       bg = Colors.red;
    } else if (status >= 5) {
       // Status 5 (Disetujui) atau 6 (Selesai)
       text = "Disetujui PIC";
       bg = Colors.green;
    }

    return _buildStatusChip(
      text: text,
      backgroundColor: bg,
      textColor: Colors.white,
    );
  }

  Widget _buildStatusChip({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  // ✅ WIDGET BARU: Menampilkan Tanggal & Jam kecil di atas status
  Widget _buildDateLabel(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return const SizedBox.shrink(); // Jangan tampilkan apa-apa jika kosong
    }

    try {
      String timeStr = dateString.endsWith('Z') ? dateString : "$dateString" "Z";
      DateTime date = DateTime.parse(timeStr);
      String formatted = DateFormat("dd MMMM yyyy, HH:mm", "id_ID").format(date.toLocal());
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0, left: 4.0),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              formatted,
              style: GoogleFonts.poppins(
                fontSize: 12, 
                color: Colors.grey[600],
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      // Jika parsing gagal, tampilkan string aslinya saja
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(dateString, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      );
    }
  }

  String _mapActivityType(int type) {
    switch (type) {
      case 0: return 'Perkuliahan'; 
      case 1: return 'PBL';         
      case 3: return 'Lainnya';     
      default: return 'Lainnya ($type)'; 
    }
  }

  String _mapWorkspaceType(String? type) {
    if (type == null) return '-';
    
    switch (type.toString()) {
      case '1':
        return 'PC'; // Jika angka 1 berarti PC
      case '0': 
      case '2':
        return 'Non-PC'; // Jika angka 2 berarti Non-PC
      default:
        return 'Lainnya ($type)'; // Tampilkan angka asli jika tidak dikenali
    }
  }

  Widget _buildReadOnlyField(String label, String value, {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
        TextFormField(
          initialValue: value,
          readOnly: true,
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.only(top: 4, bottom: 8),
            border: InputBorder.none,
          ),
        ),
        if (!isLast) const Divider(height: 24),
      ],
    );
  }

  Widget _buildPenggunaRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ganti 100 menjadi 150 agar label "Nomor Workspace" tidak terpotong
        SizedBox(width: 150, child: Text(label, style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14))),
        
        Text(":", style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14)),
        const SizedBox(width: 10),
        
        Expanded(child: Text(value, style: GoogleFonts.poppins(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500))),
      ],
    ),
  );
}

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D47A1))));
  }
}