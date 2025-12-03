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
                              'Tidak ada Workspace',
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
              "Tidak ada PIC Ruangan, harap menghubungi Tata Usaha untuk melakukan peminjaman.",
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

  static const int _flexID = 1;
  static const int _flexNomor = 3;
  static const int _flexAvail = 3; // Diperlebar agar tidak turun baris
  static const int _flexTipe = 3;  // Diperlebar agar tidak turun baris
  static const int _flexAksi = 2;


  Widget _buildWorkspaceHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12, width: 1), // Garis pemisah header
        ),
      ),
      child: Row(
        children: [
          _headerItem("ID", _flexID, TextAlign.center),
          const SizedBox(width: 8),
          _headerItem("Nomor WS", _flexNomor, TextAlign.start), // Rata Kiri
          _headerItem("Availability", _flexAvail, TextAlign.center), // Rata Tengah
          _headerItem("Tipe WS", _flexTipe, TextAlign.center), // Rata Tengah
          _headerItem("Aksi", _flexAksi, TextAlign.center),
        ],
      ),
    );
  }

  Widget _headerItem(String text, int flex, TextAlign align) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        maxLines: 1, // 🔒 Kunci agar tetap 1 baris
        overflow: TextOverflow.visible, 
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 12, // Ukuran pas agar muat
          color: Colors.black,
        ),
      ),
    );
  }

  // ===============================================================
  // 2. BAGIAN ISI DATA (ROW)
  // ===============================================================
  Widget _buildWorkspaceRow(Workspace ws, BuildContext context) {
    // Logic Warna sesuai Gambar 2 (Hijau terang & Ungu/Pink terang)
    final bool isTersedia = ws.availability.toLowerCase() == 'tersedia';
    
    // Warna Chip Availability (Hijau Solid Teks Putih)
    final Color availBg = isTersedia ? const Color(0xFF12D41E) : Colors.red; 
    final Color availText = Colors.white;

    // Warna Chip Tipe (Pink/Ungu Solid Teks Putih)
    final bool isNonPc = ws.tipeWs.toLowerCase().contains('non');
    final Color tipeBg = isNonPc ? const Color(0xFFF096F8) : const Color(0xFF0B2A97);
    final Color tipeText = Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 1. ID
          Expanded(
            flex: _flexID,
            child: Text(
              ws.id.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),

          // 2. Nomor WS (Rata Kiri)
          Expanded(
            flex: _flexNomor,
            child: Text(
              ws.nomorWs,
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),

          // 3. Availability (Chip Hijau - Memanjang)
          Expanded(
            flex: _flexAvail,
            child: Center(
              child: _buildBadge(ws.availability, availBg, availText),
            ),
          ),

          // 4. Tipe WS (Chip Pink - Memanjang)
          Expanded(
            flex: _flexTipe,
            child: Center(
              child: _buildBadge(ws.tipeWs, tipeBg, tipeText),
            ),
          ),

          // 5. Aksi (Tombol Biru)
          Expanded(
            flex: _flexAksi,
            child: Center(
              child: SizedBox(
                height: 30,
                width: 70, // Lebar fixed agar tombol seragam
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5AA2FF), // Biru terang sesuai gambar
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Detail",
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Chip (Badge) agar teks tidak turun
  Widget _buildBadge(String text, Color bg, Color textColor) {
    return Container(
      // Lebar min/max diatur agar bentuknya lonjong memanjang
      constraints: const BoxConstraints(minWidth: 70), 
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20), // Bulat penuh
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1, // ❗PENTING: Memaksa satu baris
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}