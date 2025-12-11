import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pic.dart'; // Import Model PIC
import '../../services/pic_service.dart'; // Import Service PIC
import '../../services/user_session.dart'; // Import User Session
import 'validasi_pic.dart'; 

class HomePicPage extends StatefulWidget {
  const HomePicPage({super.key});

  @override
  State<HomePicPage> createState() => _HomePicPageState();
}

class _HomePicPageState extends State<HomePicPage> {
  final PicService _picService = PicService();
  
  // State Data
  List<PeminjamanPic> _allPeminjaman = []; // Data asli dari API
  List<PeminjamanPic> _filteredPeminjaman = []; // Data hasil filter/search
  bool _isLoading = true;
  String _userName = "PIC"; // Default name

  // Variabel Filter UI
  String? _selectedRuangan = '- Hanya Tampilkan Ruangan Saya -';
  String? _selectedStatus = '- Semua Status -';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _ruanganOptions = [
    '- Hanya Tampilkan Ruangan Saya -', // Value API: 'PIC'
    'Semua Ruangan', // Value API: 'All'
  ];

  final List<String> _statusOptions = [
    '- Semua Status -',
    'Menunggu Persetujuan PIC',
    'Disetujui',
    'Ditolak',
    'Selesai',
    "Peminjaman Expired",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _fetchData();
    
    // Listener untuk search bar
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 1. Load Nama User
  Future<void> _loadUserProfile() async {
    final profile = await UserSession.getUserProfile();
    if (profile != null && mounted) {
      setState(() {
        // GUNAKAN NAMA LENGKAP
        _userName = profile.nama; 
      });
    }
  }

  // 2. Fetch Data dari API
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Mapping Filter UI ke API Params
      String roomsIdParam = 'PIC'; // Default Ruangan Saya
      if (_selectedRuangan == 'Semua Ruangan') {
        roomsIdParam = 'All';
      }

      String statusParam = 'All';
      // Mapping Status UI ke ID API
      switch (_selectedStatus) {
        case 'Menunggu Persetujuan PIC': statusParam = '3'; break;
        case 'Disetujui': statusParam = '5'; break;
        case 'Ditolak': statusParam = '4'; break;
        case 'Selesai': statusParam = '6'; break;
        case 'Peminjaman Expired': statusParam = '8'; break;
        default: statusParam = 'All';
      }

      // Panggil Service
      final data = await _picService.getApprovalList(
        roomsId: roomsIdParam,
        statusFilter: statusParam,
      );

      if (mounted) {
        setState(() {
          _allPeminjaman = data;
          _isLoading = false;
        });
        _runFilter(); // Jalankan filter search lokal
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e")),
        );
      }
    }
  }

  // 3. Logic Filter Lokal (Search Bar)
  void _runFilter() {
    String query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredPeminjaman = List.from(_allPeminjaman);
      } else {
        _filteredPeminjaman = _allPeminjaman.where((item) {
          return item.namaKegiatan.toLowerCase().contains(query) ||
                 item.ruangan.toLowerCase().contains(query) ||
                 item.namaPeminjam.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // 4. Update Status setelah kembali dari halaman detail
  void _updateListAfterApproval() {
    _fetchData(); // Refresh data dari server agar sinkron
  }

  // --- NAVIGASI KE DETAIL ---
  Future<void> _navigateToDetail(PeminjamanPic peminjaman) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ValidasiPicPage(loanId: peminjaman.id),
      ),
    );

    // Jika ada hasil (berarti sudah di-approve/reject), refresh list
    if (result != null) {
      _updateListAfterApproval();
    }
  }

  // --- HITUNG SUMMARY CARD SECARA LOKAL ---
  Map<String, String> _calculateSummary() {
    int waiting = 0;
    int approved = 0;
    int rejected = 0;

    for (var item in _allPeminjaman) {
      if (['1', '3'].contains(item.rawStatus)) waiting++;
      if (['5', '6'].contains(item.rawStatus)) approved++;
      if (['2', '4', '7'].contains(item.rawStatus)) rejected++;
    }

    return {
      'waiting': waiting.toString(),
      'approved': approved.toString(),
      'rejected': rejected.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final summary = _calculateSummary();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: Stack(
          children: [
            // LAYER 1: KONTEN SCROLLABLE
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 150), // Ruang untuk header biru
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 150
                    ),
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
                        _buildFilters(), // Widget Filter
                        const SizedBox(height: 20),

                        // Loading State
                        if (_isLoading)
                           const Center(child: CircularProgressIndicator())
                        
                        // Empty State
                        else if (_filteredPeminjaman.isEmpty)
                           Padding(
                             padding: const EdgeInsets.only(top: 50.0),
                             child: Center(
                               child: Column(
                                 children: [
                                   Icon(Icons.inbox, size: 50, color: Colors.grey[300]),
                                   const SizedBox(height: 10),
                                   Text("Tidak ada data peminjaman.", style: GoogleFonts.poppins(color: Colors.grey)),
                                 ],
                               ),
                             ),
                           )

                        // List Data
                        else
                          ..._filteredPeminjaman.asMap().entries.map((entry) {
                            return _buildPeminjamanGroup(
                              entry.value,
                              entry.key + 1,
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // LAYER 2: HEADER BIRU & KARTU SUMMARY
            _buildHeaderAndCards(summary),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HEADER ---
  Widget _buildHeaderAndCards(Map<String, String> summary) {
    return Stack(
      clipBehavior: Clip.none,
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
          padding: const EdgeInsets.only(top: 60, left: 20),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0), // Beri jarak kanan agar tidak mentok
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8, // Batasi lebar maks 80% layar
                child: FittedBox(
                  fit: BoxFit.scaleDown, // Kunci: Teks akan mengecil jika melebihi lebar
                  alignment: Alignment.centerLeft, // Tetap rata kiri
                  child: Text(
                    'Hai, $_userName!',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24, // Ukuran default (maksimal)
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
              children: [
                _summaryCard('Menunggu PIC', summary['waiting']!),
                _summaryCard('Disetujui', summary['approved']!),
                _summaryCard('Ditolak', summary['rejected']!),
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
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 12),
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
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
            ),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D47A1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET ITEM PEMINJAMAN ---
  Widget _buildPeminjamanGroup(PeminjamanPic peminjaman, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 20.0),
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

  Widget _buildPeminjamanCard(PeminjamanPic peminjaman) {
    // Logika text tombol
    String buttonText = (peminjaman.rawStatus == "3") 
        ? "Detail Peminjaman" 
        : "Detail";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.50),
            blurRadius: 10,
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // --- 1. STATUS UTAMA (PILL ATAS - DINAMIS) ---
          Row(
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
                    horizontal: 13,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: peminjaman.statusColor, 
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    peminjaman.status, 
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // --- 2. BAGIAN YANG DITAMBAHKAN (STATUS PJ) ---
          // Ini kode yang membuat tampilan seperti Gambar 2 Anda
          Row(
            children: [
              SizedBox(
                width: 120, // Lebar label agar sejajar dengan bawahnya
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
                  // Warna Hijau Statis (Disetujui)
                  color: const Color(0xFF00D800),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Disetujui', 
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          // --------------------------------------------------

          const SizedBox(height: 6),
          
          // Row Detail Lainnya
           _buildDetailRow('Peminjam', peminjaman.namaPeminjam),
          _buildDetailRow('Tanggal Pinjam', peminjaman.tanggalPinjam),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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

  Widget _buildFilters() {
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
          'Filter Ruangan:',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          isExpanded: true,
          value: _selectedRuangan,
          underline: const SizedBox(),
          items: _ruanganOptions.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
             setState(() => _selectedRuangan = val);
             _fetchData(); // Trigger fetch saat filter berubah
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

        Text(
          'Filter Status Peminjaman:',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          isExpanded: true,
          value: _selectedStatus,
          underline: const SizedBox(),
          items: _statusOptions
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: GoogleFonts.poppins(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (val) {
             setState(() => _selectedStatus = val);
             _fetchData(); // Trigger fetch saat filter berubah
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

        // Search Bar (Filter Lokal)
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
                  controller: _searchController,
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}