import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/footbar_peminjaman.dart';
// Hapus import form_peminjaman karena tidak akan melakukan navigasi dari sini
// import 'form_peminjaman.dart';

// ... (Sisa kode Workspace tetap sama) ...
class Workspace {
  final String id;
  final String nomorWs;
  final String availability;
  final String tipeWs;

  Workspace({
    required this.id,
    required this.nomorWs,
    required this.availability,
    required this.tipeWs,
  });
}

final List<Workspace> workspaceList = [
  Workspace(id: "391", nomorWs: "WS.TA.12.3B.01", availability: "Tersedia", tipeWs: "NON PC"),
  Workspace(id: "392", nomorWs: "WS.TA.12.3B.02", availability: "Tersedia", tipeWs: "NON PC"),
  Workspace(id: "393", nomorWs: "WS.TA.12.3B.03", availability: "Tersedia", tipeWs: "NON PC"),
  Workspace(id: "394", nomorWs: "WS.TA.12.3B.04", availability: "Tersedia", tipeWs: "NON PC"),
  Workspace(id: "395", nomorWs: "WS.TA.12.3B.05", availability: "Tersedia", tipeWs: "NON PC"),
  Workspace(id: "396", nomorWs: "WS.TA.12.3B.06", availability: "Tersedia", tipeWs: "NON PC"),
];


class DetailRuanganScreen extends StatelessWidget {
  final RuanganData ruanganData;
  // PERBAIKAN 1: Jadikan 'onBack' required
  final VoidCallback onBack;
  final Function(String)? onShowForm;

  const DetailRuanganScreen({
    Key? key,
    required this.ruanganData,
    required this.onBack,
    this.onShowForm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
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
            // ... (Bagian gambar dan info ruangan tetap sama) ...
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                ruanganData.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
            const SizedBox(height: 16),
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
                  _buildInfo("Lokasi Ruangan", ruanganData.title),
                  _buildInfo("Kode Ruangan", ruanganData.code),
                  _buildInfo("Tipe Ruangan", ruanganData.type),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          // PERBAIKAN 2: Hapus Navigator.push, cukup panggil callback
                          onPressed: () {
                            if (onShowForm != null) {
                              onShowForm!(ruanganData.title);
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
                        // ... Tombol Cek Ketersediaan
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Tambahkan logika untuk cek ketersediaan
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
            // ... (Sisa kode untuk PIC dan List Workspace tetap sama) ...
            Container(
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
                  Text(
                    "Iqbal Afif, A.Md.Kom",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "iqbal@polibatam.ac.id",
                    style: GoogleFonts.poppins(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "WA: 82176549521",
                    style: GoogleFonts.poppins(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                    "Pilih workspace sesuai kebutuhan dan jadwalkan pemakaianmu sekarang.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWorkspaceHeader(),
                  const Divider(),
                  ...workspaceList.map((ws) => _buildWorkspaceRow(ws, context)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ... (Sisa fungsi helper _buildInfo, _buildWorkspaceRow, dll tetap sama) ...
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(ws.id, style: GoogleFonts.poppins(fontSize: 12)),
          Text(ws.nomorWs, style: GoogleFonts.poppins(fontSize: 12)),
          _buildStatusChip(ws.availability, Colors.green.shade100, Colors.green.shade800),
          _buildStatusChip(ws.tipeWs, Colors.purple.shade100, Colors.purple.shade800),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                // DI SINI JUGA JANGAN GUNAKAN NAVIGATOR.PUSH
                // Mungkin bisa diubah untuk menampilkan detail workspace atau langsung ke form
                // Untuk sekarang, kita samakan dengan tombol utama: panggil onShowForm
                if (onShowForm != null) {
                  onShowForm!(ruanganData.title);
                }
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