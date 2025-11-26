import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'detail_pengajuan_pj.dart';
// Import Model & Service
import '../models/pj_models.dart';
import '../services/pj_service.dart';
import '../services/user_session.dart'; // Untuk nama user

class HomePjPage extends StatefulWidget {
  const HomePjPage({super.key});

  @override
  State<HomePjPage> createState() => _HomePjPageState();
}

class _HomePjPageState extends State<HomePjPage> {
  final PjService _pjService = PjService();
  
  List<PeminjamanPj> _peminjamanList = [];
  List<PeminjamanPj> _allData = []; // Backup untuk filter/search
  bool _isLoading = true;
  String _userName = 'Dosen';

  String? _selectedStatusFilter = "Semua Status";

  final List<String> _statusOptions = [
    "-Semua Status-",
    "Menunggu Persetujuan Penanggung Jawab",
    "Disetujui",
    "Ditolak",
    "Peminjaman Expired",
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchData();
  }

  Future<void> _loadUser() async {
    final profile = await UserSession.getUserProfile();
    if(profile != null) {
      setState(() {
        _userName = profile.nama;
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _pjService.getApprovals();
      setState(() {
        _allData = data;
        _peminjamanList = data;
        _isLoading = false;
      });
      _filterData(); // Apply filter awal jika ada
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _filterData({String? searchQuery}) {
    setState(() {
      _peminjamanList = _allData.where((item) {
        bool matchesStatus = _selectedStatusFilter == "-Semua Status-" || 
                             item.status == _selectedStatusFilter;
        
        bool matchesSearch = true;
        if (searchQuery != null && searchQuery.isNotEmpty) {
           matchesSearch = item.ruangan.toLowerCase().contains(searchQuery.toLowerCase()) ||
                           item.namaKegiatan.toLowerCase().contains(searchQuery.toLowerCase());
        }
        
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  // --- NAVIGASI ---
  Future<void> _navigateToDetail(PeminjamanPj peminjaman) async {
    final newStatus = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPengajuanPjPage(peminjaman: peminjaman),
      ),
    );

    // Jika kembali dengan status baru (berhasil approve/reject), refresh data
    if (newStatus != null) {
      _fetchData(); 
    }
  }

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    // Hitung Summary Dashboard
    int pending = _allData.where((e) => e.status == "Menunggu Persetujuan Penanggung Jawab").length;
    int approved = _allData.where((e) => e.status == "Disetujui").length; // Di UI ini Approved = Pending PIC
    int rejected = _allData.where((e) => e.status == "Ditolak").length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // LAYER 1: KONTEN SCROLLABLE
          RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 150), // Ruang untuk header biru
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
                        _buildControls(), // Filter & Search
                        const SizedBox(height: 20),

                        // List Data
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_peminjamanList.isEmpty)
                          const Center(child: Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Text("Tidak ada data."),
                          ))
                        else
                          ...List.generate(_peminjamanList.length, (index) {
                            return _buildPeminjamanGroup(
                              _peminjamanList[index],
                              index + 1,
                            );
                          }),
                        
                        const SizedBox(height: 50), // Padding bawah
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LAYER 2: HEADER BIRU & KARTU SUMMARY
          _buildHeaderAndCardsPJ(pending, approved, rejected),
        ],
      ),
    );
  }

  // --- HEADER & SUMMARY ---
  Widget _buildHeaderAndCardsPJ(int pending, int approved, int rejected) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 180,
          decoration: const BoxDecoration(
            color: Color(0xFF1c36d2),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Hai, $_userName!',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryCard('Menunggu Persetujuan', '$pending'),
                _summaryCard('Disetujui', '$approved'),
                _summaryCard('Ditolak', '$rejected'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String count) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D47A1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeminjamanGroup(PeminjamanPj peminjaman, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.0, top: index == 1 ? 0 : 20.0),
          child: Text(
            'Peminjam Ruangan $index',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildPeminjamanCard(peminjaman),
      ],
    );
  }

  // --- CARD DATA ---
  // --- CARD DATA ---
  Widget _buildPeminjamanCard(PeminjamanPj peminjaman) {
    final String formattedDate = peminjaman.tanggalPinjam;

    // Ambil data status ID (rawStatus) dan text (status) dari Model
    String statusCode = peminjaman.rawStatus; 
    String displayStatus = peminjaman.status;

    // --- LOGIC WARNA & BADGE BARU ---
    String badgeAtasText;
    Color badgeAtasColor;
    String badgeBawahText;
    Color badgeBawahColor;
    String buttonText = 'Detail'; // Default tombol

    // 1. STATUS MENUNGGU PJ (Kuning)
    if (statusCode == '1') {
      badgeAtasText = displayStatus;
      badgeAtasColor = const Color(0xFFFFC037);
      
      badgeBawahText = "Menunggu Persetujuan";
      badgeBawahColor = const Color(0xFFFFC037);
      
      buttonText = 'Detail Approval'; // Tombol khusus PJ
    } 
    // 2. STATUS DITOLAK (Merah)
    else if (statusCode == '2') {
      badgeAtasText = "Ditolak";
      badgeAtasColor = Colors.red;
      
      badgeBawahText = "Ditolak";
      badgeBawahColor = Colors.red;
    } 
    // 3. STATUS EXPIRED (Abu-abu)
    else if (statusCode == '8') {
      badgeAtasText = "Peminjaman Expired";
      badgeAtasColor = Colors.grey;
      
      badgeBawahText = "Expired";
      badgeBawahColor = Colors.grey;
    } 
    // 4. STATUS SUKSES / PROSES LANJUT (3, 4, 5, 6) -> HIJAU
    else if (['3', '4', '5', '6'].contains(statusCode)) {
      // Status 3 = Menunggu PIC (Tapi sudah disetujui PJ)
      // Status 4 = Disetujui PIC
      // Status 5 = Disetujui
      
      // Badge Atas mengikuti teks status asli
      badgeAtasText = displayStatus; 
      // Jika masih 3 (nunggu PIC), warna badge atas kuning/orange, kalau sudah 4/5 hijau
      badgeAtasColor = (statusCode == '3') ? const Color(0xFFFFC037) : const Color(0xFF00D800);

      // Badge Bawah (Status PJ) -> Pasti Hijau "Disetujui"
      badgeBawahText = "Disetujui";
      badgeBawahColor = const Color(0xFF00D800);
    } 
    // 5. DEFAULT / LAINNYA
    else {
      badgeAtasText = displayStatus;
      badgeAtasColor = Colors.grey;
      badgeBawahText = statusCode;
      badgeBawahColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        // --- SHADOW SESUAI REQUEST ---
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.50), // Transparan halus 50%
            blurRadius: 10, // Blur lembut
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            peminjaman.ruangan,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // BADGE ATAS
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ID: ${peminjaman.id}',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: badgeAtasColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeAtasText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      height: 1.2,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // BADGE BAWAH (Status PJ)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  'Status PJ',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                ':  ',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBawahColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeBawahText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildDetailRow('Tanggal Pinjam', formattedDate),
          _buildDetailRow('Jam Kegiatan', peminjaman.jamKegiatan),
          _buildDetailRow('Jenis Kegiatan', peminjaman.jenisKegiatan),
          _buildDetailRow('Nama Kegiatan', peminjaman.namaKegiatan),
          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => _navigateToDetail(peminjaman),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4150FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTROLS ---
  Widget _buildControls() {
    final buttonStyle = ButtonStyleData(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter Status Peminjaman:',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          value: _selectedStatusFilter,
          isExpanded: true,
          underline: const SizedBox(),
          items: _statusOptions.map((String status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(
                status,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedStatusFilter = newValue;
              _filterData();
            });
          },
          buttonStyleData: buttonStyle,
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // SEARCH BAR
        Row(
          children: [
            Text(
              'Search:',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Color(0xFF1c36d2)),
                    ),
                    suffixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: "",
                  ),
                  onChanged: (value) {
                     _filterData(searchQuery: value);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          Text(
            ':  ',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}