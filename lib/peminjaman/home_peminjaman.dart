import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ➕ IMPORT MODEL DAN SERVICE
import '../models/room.dart';
import '../services/room_service.dart';

class HomePeminjaman extends StatefulWidget {
  final String username;
  final String role;
  // ♻️ DIUBAH: Menggunakan model Room
  final Function(Room) onRoomTap;

  const HomePeminjaman({
    super.key,
    required this.username,
    required this.role,
    required this.onRoomTap,
  });

  @override
  State<HomePeminjaman> createState() => _HomePeminjamanState();
}

class _HomePeminjamanState extends State<HomePeminjaman> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGedung = 'Semua Gedung';

  // --- ➕ STATE BARU UNTUK DATA API ---
  late final RoomService _roomService;
  Map<String, List<Room>> _groupedRooms = {};
  List<Room> _allRooms = [];
  List<String> _buildingList = ['Semua Gedung'];
  bool _isLoading = true;
  String? _errorMessage;
  // --- ---------------------------- ---

  @override
  void initState() {
    super.initState();
    _roomService = RoomService(); // Inisialisasi service
    _fetchRooms(); // Ambil data saat screen dibuka
    // Tambahkan listener untuk search, agar UI update saat mengetik
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Panggil setState agar build() terpanggil ulang & filter diterapkan
    setState(() {});
  }

  Future<void> _fetchRooms() async {
    try {
      // 1. Ambil data dari service
      final data = await _roomService.getGroupedRooms();

      // 2. Proses data
      List<Room> allRooms = [];
      data.values.forEach((roomList) {
        allRooms.addAll(roomList);
      });

      List<String> buildingList = ['Semua Gedung'];
      buildingList.addAll(data.keys); // Ambil nama-nama gedung

      // 3. Update state untuk re-render UI
      setState(() {
        _groupedRooms = data;
        _allRooms = allRooms;
        _buildingList = buildingList;
        _isLoading = false;
      });
    } catch (e) {
      // 4. Tangani error jika terjadi
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // 5. Bersihkan listener
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ❌ HAPUS: List<RuanganData> daftarRuangan (data hardcode)

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔵 Header Area (Tidak berubah)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: const BoxDecoration(
                color: Color(0xFF1c36d2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hai, ${widget.username}!",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Siap pinjam ruangan hari ini?",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 🔍 Search Bar (Tidak berubah)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari Ruangan',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🧾 Deskripsi (Tidak berubah)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Temukan ruang nyaman untuk belajar, berdiskusi, dan menyalurkan kreativitasmu.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🏢 Filter Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (String value) {
                    setState(() {
                      _selectedGedung = value;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedGedung,
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                  // ♻️ DIUBAH: Membangun item dropdown dari state _buildingList
                  itemBuilder: (BuildContext context) => _buildingList
                      .map((gedung) => _buildDropdownItem(gedung))
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 🏠 GridView Ruangan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              // ♻️ DIUBAH: Menggunakan fungsi baru untuk menampilkan Grid
              child: _buildRoomGrid(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ♻️ FUNGSI BARU: Untuk logic tampilan Grid
  Widget _buildRoomGrid() {
    // 1. Tampilkan Loading
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2. Tampilkan Error
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Text(
            'Gagal memuat data:\n$_errorMessage',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.red[700]),
          ),
        ),
      );
    }

    // 3. Terapkan Filter
    List<Room> roomsToShow = [];
    if (_selectedGedung == 'Semua Gedung') {
      roomsToShow = _allRooms;
    } else {
      roomsToShow = _groupedRooms[_selectedGedung] ?? [];
    }

    // 4. Terapkan Filter Pencarian
    final String searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      roomsToShow = roomsToShow.where((room) {
        final name = room.name.toLowerCase();
        final code = room.code.toLowerCase();
        final building = room.building.toLowerCase();
        return name.contains(searchQuery) ||
               code.contains(searchQuery) ||
               building.contains(searchQuery);
      }).toList();
    }

    // 5. Tampilkan jika ruangan tidak ditemukan
    if (roomsToShow.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Text(
            'Ruangan tidak ditemukan.',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ),
      );
    }

    // 6. Tampilkan GridView jika semua OK
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.80,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: roomsToShow.length,
      itemBuilder: (context, index) {
        // ♻️ DIUBAH: Menggunakan data dari roomsToShow
        return _buildRoomCard(context, ruangan: roomsToShow[index]);
      },
    );
  }


  // Fungsi _buildDropdownItem (Tidak berubah)
  PopupMenuItem<String> _buildDropdownItem(String value) {
    bool isSelected = _selectedGedung == value;
    return PopupMenuItem<String>(
      value: value,
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          if (isSelected)
            const Icon(Icons.check, color: Color(0xFF4ADE80), size: 20),
        ],
      ),
    );
  }

  // ♻️ DIUBAH: Menggunakan model 'Room'
  Widget _buildRoomCard(BuildContext context, {required Room ruangan}) {
    return InkWell(
      // ♻️ DIUBAH: Mengirim object 'Room' saat di-tap
      onTap: () => widget.onRoomTap(ruangan),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                // ⚠️ PERHATIAN: Model 'Room' Anda tidak memiliki 'imageUrl'.
                // Saya gunakan placeholder. Ganti ini jika Anda punya URL gambar.
                "assets/room.jpg",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      // ♻️ DIUBAH: title -> name
                      ruangan.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1, // Tambahan agar rapi
                      overflow: TextOverflow.ellipsis, // Tambahan agar rapi
                    ),
                    const SizedBox(height: 2),
                    Text(
                      // ✅ SESUAI: code -> code
                      ruangan.code,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      // ♻️ DIUBAH: type -> building (atau ganti ke ruangan.capacity)
                      ruangan.building,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B4AF5),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B7BFF).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "Detail Ruangan",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}