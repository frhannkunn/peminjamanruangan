// footbar_peminjaman.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../peminjaman/home_peminjaman.dart';
import '../peminjaman/peminjaman.dart';
import '../peminjaman/notifikasi.dart';
import '../peminjaman/profil.dart';
import '../peminjaman/detail_ruangan.dart';
import '../peminjaman/form_peminjaman.dart';
import '../models/room.dart';
import '../services/user_session.dart';

class FootbarPeminjaman extends StatefulWidget {
  final String username;
  final String role;

  const FootbarPeminjaman({
    super.key,
    required this.username,
    required this.role,
  });

  @override
  State<FootbarPeminjaman> createState() => _FootbarPeminjamanState();
}

class _FootbarPeminjamanState extends State<FootbarPeminjaman> {
  int _selectedIndex = 0;
  Room? _selectedRoom;

  // ➕ 2. TAMBAHKAN STATE UNTUK PROFIL DAN LOADING
  UserProfile? _userProfile;
  bool _isLoadingProfile = true; // Kita beri nama beda agar tidak bingung

  // ➕ 3. TAMBAHKAN INITSTATE UNTUK MEMUAT DATA USER
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // ➕ 4. BUAT FUNGSI UNTUK MEMUAT DATA USER (SAMA SEPERTI DI PROFIL)
  Future<void> _loadUserProfile() async {
    final profile = await UserSession.getUserProfile();
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _isLoadingProfile = false;
      });
    }
  }

  // (Fungsi _handleRoomTap tidak berubah)
  void _handleRoomTap(Room roomData) {
    setState(() {
      _selectedRoom = roomData;
    });
  }

  // (Fungsi _handleDetailBack tidak berubah)
  void _handleDetailBack() {
    setState(() {
      _selectedRoom = null;
    });
  }

  // (Fungsi _handleFormBackFromHome tidak berubah)
  void _handleFormBackFromHome(String? message) {
    Navigator.of(context).pop();

    if (message != null && message.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFFE6F4EA),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.green),
            ),
            elevation: 0,
          ),
        );
      }

      if (message.contains('berhasil diajukan')) {
        _onItemTapped(1);
      }
    }
  }

  // ✏️ 5. FUNGSI INI SEKARANG DIPERBAIKI DENGAN NULL CHECK
  void _handleShowFormFromDetail(String roomName) {
    // Tambahkan pengecekan
    if (_isLoadingProfile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tunggu, data profil sedang dimuat...")),
      );
      return;
    }

    if (_userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat data profil. Tidak bisa buka form.")),
      );
      return;
    }

    // Jika lolos pengecekan, baru navigasi
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FormPeminjamanScreen(
          preSelectedRoom: roomName,
          onBack: _handleFormBackFromHome,
          // ✅ Sekarang aman menggunakan _userProfile!
          userProfile: _userProfile!,
        ),
      ),
    );
  }

  // (Fungsi _onItemTapped tidak berubah)
  void _onItemTapped(int index) {
    setState(() {
      _selectedRoom = null;
      _selectedIndex = index;
    });
  }

  // (Fungsi _buildHomeTab tidak berubah)
  Widget _buildHomeTab() {
    if (_selectedRoom == null) {
      return HomePeminjaman(
        username: widget.username,
        role: widget.role,
        onRoomTap: _handleRoomTap,
      );
    } else {
      return DetailRuanganScreen(
        ruanganData: _selectedRoom!,
        onBack: _handleDetailBack,
        onShowForm: _handleShowFormFromDetail,
      );
    }
  }

  // (Fungsi _buildPeminjamanTab tidak berubah)
  Widget _buildPeminjamanTab() {
    return const PeminjamanScreen();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeTab(),
      _buildPeminjamanTab(),
      const NotifikasiScreen(),
      const ProfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      
      // 
      // 👇 TIDAK ADA PERUBAHAN DESAIN APAPUN DI BAWAH INI 👇
      //
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: FontAwesomeIcons.houseLock,
                label: "Home",
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.airplay_outlined,
                label: "Peminjaman",
                index: 1,
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.bell,
                label: "Notifikasi",
                index: 2,
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.user,
                label: "Profil",
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    final Color activeColor = const Color(0xFF1C36D2);
    final Color inactiveColor = Colors.grey.shade600;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : inactiveColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : inactiveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}