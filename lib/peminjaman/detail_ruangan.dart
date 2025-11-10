// peminjaman/detail_ruangan.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ➕ 1. IMPORT MODEL DAN SERVICE YANG KITA BUTUHKAN
import '../models/room.dart';
import '../models/workspace.dart'; // Model dari API (WS-01, WS-02)
import '../services/room_service.dart'; // Service yang mengambil list workspace

// ❌ 2. 'class Workspace' DAN 'final List<Workspace> workspaceList'
//    (Data statis dari file lama Anda sudah dihapus)


// ♻️ 3. DIUBAH MENJADI STATEFULWIDGET
class DetailRuanganScreen extends StatefulWidget {
  final Room ruanganData;
  final VoidCallback onBack;
  final Function(String)? onShowForm;

  const DetailRuanganScreen({
    super.key,
    required this.ruanganData,
    required this.onBack,
    this.onShowForm,
  });

  @override
  State<DetailRuanganScreen> createState() => _DetailRuanganScreenState();
}

// ♻️ 4. CLASS 'STATE' BARU UNTUK MENAMPUNG LOGIKA
class _DetailRuanganScreenState extends State<DetailRuanganScreen> {
  // ➕ 5. STATE UNTUK SERVICE DAN FUTURE
  late final RoomService _roomService;
  Future<List<Workspace>>? _workspacesFuture;

  // ➕ 6. FUNGSI 'initState' (DIPANGGIL SAAT WIDGET DIBUAT)
  @override
  void initState() {
    super.initState();
    _roomService = RoomService(); // Sekarang 'RoomService' dikenali
    // ➕ 7. PANGGIL API SAAT WIDGET DIBUAT
    _loadWorkspaces();
  }

  // ➕ 8. FUNGSI UNTUK MEMUAT DATA WORKSPACE
  void _loadWorkspaces() {
    setState(() {
      // Panggil service dari 'room_service.dart'
      _workspacesFuture = _roomService.getWorkspacesForRoom(widget.ruanganData.id);
    });
  }

  // ♻️ 9. FUNGSI 'build' SEKARANG ADA DI DALAM 'STATE'
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack, // Menggunakan 'widget.' untuk akses
        ),
        title: Text(
          "Detail Ruangan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- 1. GAMBAR RUANGAN ---
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/room.jpg", // Ganti dengan gambar default
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. INFO RUANGAN & TOMBOL ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfo("Gedung", widget.ruanganData.building),
                  _buildInfo("Nama Ruangan", widget.ruanganData.name),
                  _buildInfo("Kode Ruangan", widget.ruanganData.code),
                  _buildInfo("Kapasitas", "${widget.ruanganData.capacity} orang"),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // TOMBOL BORANG RUANGAN
                        ElevatedButton(
                          onPressed: () {
                            if (widget.onShowForm != null) {
                              widget.onShowForm!(widget.ruanganData.name);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "Borang Ruangan",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),

                        // ➕ TOMBOL CEK KETERSEDIAAN (DIKEMBALIKAN)
                        OutlinedButton(
                          onPressed: () {
                            // Tambahkan logika untuk cek ketersediaan
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "Cek Ketersediaan Ruangan",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // --- 3. INFO PIC RUANGAN ---
            _buildPicInfo(), // 👈 FUNGSI INI SEKARANG SUDAH DINAMIS

            const SizedBox(height: 20),

            // --- 4. LIST WORKSPACE (DINAMIS) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "List Workspace Ruangan",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Temukan workspace yang mendukung produktivitasmu.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // (Tambahkan Search bar Anda di sini jika ada)

                  // ♻️ FUTUREBUILDER UNTUK MENAMPILKAN DATA
                  FutureBuilder<List<Workspace>>(
                    future: _workspacesFuture, // Menggunakan state future
                    builder: (context, snapshot) {
                      // Tampilkan Loading
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // Tampilkan Error
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'Gagal memuat workspace:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.red[700]),
                            ),
                          ),
                        );
                      }

                      final List<Workspace> workspaces = snapshot.data ?? [];

                      // Tampilkan jika kosong
                      if (workspaces.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'Workspace belum di buat PIC ruangan',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.grey[600]),
                            ),
                          ),
                        );
                      }

                      // Bangun list jika data ada
                      return Column(
                        children: [
                          _buildWorkspaceHeader(),
                          const Divider(),
                          ...workspaces.map((ws) => _buildWorkspaceRow(ws, context)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- (Helper Widgets) ---
  
  // ❗️ INI BAGIAN YANG DIPERBARUI ❗️
  Widget _buildPicInfo() {
    // Cek apakah data PIC ada di dalam list 'pics'
    final bool hasPic = widget.ruanganData.pics.isNotEmpty;

    // Ambil data PIC pertama jika ada
    final picData = hasPic ? widget.ruanganData.pics.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PIC Ruangan",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 20),

          // Tampilkan data PIC jika ada
          if (hasPic && picData != null) ...[
            Text(
              picData.name, // 👈 DINAMIS
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              picData.email, // 👈 DINAMIS
              style: GoogleFonts.poppins(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              "WA: ${picData.whatsapp ?? '-'}", // 👈 DINAMIS (cek jika null)
              style: GoogleFonts.poppins(
                color: Colors.blue[600],
              ),
            ),
          ] 
          // Tampilkan pesan jika tidak ada PIC
          else ...[
            Text(
              "PIC belum ditugaskan",
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ]
        ],
      ),
    );
  }
  
  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label :",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _headerText("ID"),
          _headerText("Nomor WS"),
          _headerText("Availability"),
          _headerText("Tipe WS"),
          _headerText("Aksi"),
        ],
      ),
    );
  }
  
  Widget _headerText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Colors.black54,
      ),
    );
  }
  
  Widget _buildWorkspaceRow(Workspace ws, BuildContext context) {
    final bool isTersedia = ws.availability.toLowerCase() == 'tersedia';
    final Color availColor = isTersedia ? Colors.green.shade800 : Colors.red.shade800;
    final Color availBgColor = isTersedia ? Colors.green.shade100 : Colors.red.shade100;
    
    final bool isNonPc = ws.tipeWs.toLowerCase() == 'non pc';
    final Color tipeColor = isNonPc ? Colors.purple.shade800 : Colors.orange.shade800;
    final Color tipeBgColor = isNonPc ? Colors.purple.shade100 : Colors.orange.shade100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(ws.id.toString(), style: GoogleFonts.poppins(fontSize: 12)),
          Text(ws.nomorWs, style: GoogleFonts.poppins(fontSize: 12)),
          _buildStatusChip(ws.availability, availBgColor, availColor),
          _buildStatusChip(ws.tipeWs, tipeBgColor, tipeColor),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                // 💡 NANTI KITA AKAN ATUR NAVIGASI DI SINI
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                foregroundColor: Colors.blue.shade800,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("Detail", style: GoogleFonts.poppins(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}