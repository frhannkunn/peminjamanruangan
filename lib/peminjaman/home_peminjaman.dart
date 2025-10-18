import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/footbar_peminjaman.dart';

class HomePeminjaman extends StatefulWidget {
  final String username;
  final String role;
  final Function(RuanganData) onRoomTap;

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

  @override
  Widget build(BuildContext context) {
    final List<RuanganData> daftarRuangan = [
      RuanganData(
        title: "Tower A",
        code: "12.3B",
        type: "Workspace multimedia",
        imageUrl: "assets/ruang1.jpg",
      ),
      RuanganData(
        title: "RTF",
        code: "5.4",
        type: "Workspace software development",
        imageUrl: "assets/ruang2.jpg",
      ),
      RuanganData(
        title: "Gedung Utama",
        code: "404",
        type: "Workspace rendering",
        imageUrl: "assets/ruang1.jpg",
      ),
      RuanganData(
        title: "Tower A",
        code: "703",
        type: "Workspace cyber forensic",
        imageUrl: "assets/ruang2.jpg",
      ),
      RuanganData(
        title: "Gedung Utama",
        code: "650",
        type: "Workspace data science",
        imageUrl: "assets/ruang1.jpg",
      ),
      RuanganData(
        title: "Gedung Utama",
        code: "430",
        type: "Workspace geography information system",
        imageUrl: "assets/ruang2.jpg",
      ),
      RuanganData(
        title: "Gedung Utama",
        code: "470",
        type: "Workspace remote sensing",
        imageUrl: "assets/ruang1.jpg",
      ),
      RuanganData(
        title: "Technopreneur",
        code: "372",
        type: "Mini-Theater",
        imageUrl: "assets/ruang2.jpg",
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔵 Header Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: const BoxDecoration(
                color: Color(0xFF5B7BFF),
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
                  // 🔍 Search Bar
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

            // 🧾 Deskripsi
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
                  itemBuilder: (BuildContext context) => [
                    _buildDropdownItem('Semua Gedung'),
                    _buildDropdownItem('Gedung Utama'),
                    _buildDropdownItem('Tower A'),
                    _buildDropdownItem('Tower B'),
                    _buildDropdownItem('Teaching Factory'),
                    _buildDropdownItem('Apartment'),
                    _buildDropdownItem('Technopreneur'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 🏠 GridView Ruangan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.80,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: daftarRuangan.length,
                itemBuilder: (context, index) {
                  return _buildRoomCard(context, ruangan: daftarRuangan[index]);
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

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

  Widget _buildRoomCard(BuildContext context, {required RuanganData ruangan}) {
  return InkWell(
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
              ruangan.imageUrl,
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
                crossAxisAlignment: CrossAxisAlignment.center, // 👉 teks rata tengah
                children: [
                  Text(
                    ruangan.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
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
                    ruangan.type,
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
                      color: const Color(0xFF5B7BFF),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
