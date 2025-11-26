import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/loan.dart';
import '../models/loan_user.dart';
import '../services/loan_service.dart';
import '../services/room_service.dart';

class DetailPeminjamanScreen extends StatefulWidget {
  final int loanId;
  final String statusStr; // Status string yang dibawa dari halaman sebelumnya

  const DetailPeminjamanScreen({super.key, required this.loanId, required this.statusStr});

  @override
  State<DetailPeminjamanScreen> createState() => _DetailPeminjamanScreenState();
}

class _DetailPeminjamanScreenState extends State<DetailPeminjamanScreen> {
  final LoanService _loanService = LoanService();
  final RoomService _roomService = RoomService();
  
  late Future<Map<String, dynamic>> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetailData();
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
      for (var list in groupedRooms.values) {
        for (var r in list) {
          if (r.id == loan.roomsId) roomName = r.name; roomCode = r.code;
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
          final List<LoanUser> users = loan.loanUsers ?? [];

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
                      
                      // Logic status chip di detail sama dengan di list
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

  // Chip Status PIC (Fungsi baru ada di bawah)
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
                          child: Text("List Pengguna Ruangan (${users.length})",
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5)],
                        ),
                        child: users.isEmpty 
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(child: Text("Tidak ada pengguna tambahan", style: GoogleFonts.poppins(color: Colors.grey))),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: users.length,
                            separatorBuilder: (ctx, i) => const Divider(),
                            itemBuilder: (context, index) {
  final u = users[index];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildPenggunaRow("ID", u.id.toString()),
      _buildPenggunaRow("Pengguna Ruangan", u.namaPengguna),
      _buildPenggunaRow("Jenis Pengguna", u.jenisPengguna),
      _buildPenggunaRow("ID Pengguna", u.idCardPengguna),
      
      // Tampilkan Data Workspace
      // Jika data null (belum dikirim backend), tampilkan tanda strip (-)
      _buildPenggunaRow("Nomor Workspace", u.workspaceCode ?? '-'), 
      _buildPenggunaRow("Tipe Workspace", _mapWorkspaceType(u.workspaceType)),
    ],
  );
},
                          ),
                      )
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
    Color bg = const Color(0xFFF9A825); // Kuning
    
    if (status >= 2 && status != 4) {
       text = "Disetujui Penanggung Jawab";
       bg = Colors.green;
    } else if (status == 4) {
       text = "Ditolak";
       bg = Colors.red;
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

    if (status == 3) {
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