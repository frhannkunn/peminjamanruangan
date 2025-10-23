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

// Class RuanganData (tidak diubah)
class RuanganData {
  final String title;
  final String code;
  final String type;
  final String imageUrl;

  RuanganData({
    required this.title,
    required this.code,
    required this.type,
    required this.imageUrl,
  });
}

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
  RuanganData? _selectedRoom; // State ini hanya untuk tab Home

  // Fungsi ini HANYA untuk navigasi di dalam tab Home
  void _handleRoomTap(RuanganData roomData) {
    setState(() {
      _selectedRoom = roomData;
    });
  }

  void _handleDetailBack() {
    setState(() {
      _selectedRoom = null;
    });
  }

  // --- 👇 PERUBAHAN DIMULAI DI SINI 👇 ---

  // 1. BUAT FUNGSI BARU INI
  // Fungsi ini akan menangani callback 'onBack' dari FormPeminjamanScreen
  // saat dibuka dari alur Home.
  void _handleFormBackFromHome(String? message) {
    // 1. Tutup FormPeminjamanScreen
    Navigator.of(context).pop();

    // 2. Tampilkan SnackBar jika ada pesan
    if (message != null && message.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: GoogleFonts.poppins(
                  color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            // Salin desain SnackBar dari peminjaman.dart agar konsisten
            backgroundColor: const Color(0xFFE6F4EA),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.green)),
            elevation: 0,
          ),
        );
      }

      // 3. Jika pengajuan berhasil, pindah ke tab Peminjaman
      if (message.contains('berhasil diajukan')) {
        _onItemTapped(1); // Pindah ke tab Peminjaman (index 1)
      }
    }
    // Jika message == null (hanya menekan 'Kembali'), kita hanya menutup
    // form dan tetap di halaman Detail Ruangan, yang sudah benar.
  }

  // 2. MODIFIKASI FUNGSI INI
  // Fungsi ini HANYA untuk navigasi di dalam tab Home
  void _handleShowFormFromDetail(String roomName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FormPeminjamanScreen(
          preSelectedRoom: roomName,
          onBack: _handleFormBackFromHome, // <--- BERIKAN CALLBACK DI SINI
        ),
      ),
    );
  }

  // --- 👆 PERUBAHAN SELESAI DI SINI 👆 ---

  void _onItemTapped(int index) {
    setState(() {
      // Selalu reset state detail ruangan jika berpindah tab
      _selectedRoom = null;
      _selectedIndex = index;
    });
  }

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

  Widget _buildPeminjamanTab() {
    // Tidak perlu diubah. Alur PeminjamanScreen -> Form sudah benar.
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
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      // DESAIN ANDA TIDAK SAYA UBAH SAMA SEKALI
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
                  icon: FontAwesomeIcons.houseLock, label: "Home", index: 0),
              _buildNavItem(
                  icon: Icons.airplay_outlined,
                  label: "Peminjaman",
                  index: 1),
              _buildNavItem(
                  icon: FontAwesomeIcons.bell, label: "Notifikasi", index: 2),
              _buildNavItem(
                  icon: FontAwesomeIcons.user, label: "Profil", index: 3),
            ],
          ),
        ),
      ),
    );
  }

  // DESAIN ANDA TIDAK SAYA UBAH SAMA SEKALI
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    final Color activeColor = const Color(0xFF1565C0);
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