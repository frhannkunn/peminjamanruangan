// File: lib/widgets/footbar_pj.dart (ICON/LABEL TAB PERTAMA DISAMAKAN DENGAN PIC)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pj/home_pj.dart';
import '../pj/detail_pengajuan_pj.dart';
import '../pj/notification_pj.dart'; // Pastikan path dan nama file benar
import '../pj/profile_pj.dart'; // Pastikan path dan nama file benar

class FootbarPj extends StatefulWidget {
  const FootbarPj({super.key});

  @override
  State<FootbarPj> createState() => _FootbarPjState();
}

class _FootbarPjState extends State<FootbarPj> {
  int _selectedIndex = 0;
  PeminjamanPj? _selectedPeminjaman;

  Function(String id, String newStatus)? _updateHomeDataCallback;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      HomePjPage(
        onPeminjamanSelected: _showDetailPage,
        onDataUpdated: _setUpdateCallback,
      ),
      const NotificationPjPage(),
      const ProfilePjPage(),
    ];
  }

  void _showDetailPage(PeminjamanPj peminjaman) {
    setState(() {
      _selectedPeminjaman = peminjaman;
    });
  }

  void _navigateToHome({String? updatedId, String? newStatus}) {
    if (updatedId != null &&
        newStatus != null &&
        _updateHomeDataCallback != null) {
      _updateHomeDataCallback!(updatedId, newStatus);
    }
    setState(() {
      _selectedPeminjaman = null;
    });
  }

  void _setUpdateCallback(Function(String id, String newStatus) callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateHomeDataCallback = callback;
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex != index) {
        _navigateToHome();
        _selectedIndex = index;
      } else {
        _navigateToHome();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _selectedPeminjaman != null
          ? DetailPengajuanPjPage(
              peminjaman: _selectedPeminjaman!,
              onFinish: (id, status) =>
                  _navigateToHome(updatedId: id, newStatus: status),
            )
          : IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 85,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // --- PERUBAHAN DI SINI ---
              _buildNavItem(
                Icons.fact_check_outlined,
                'Validasi',
                0,
              ), // Icon dan label diubah
              // --- AKHIR PERUBAHAN ---
              _buildNavItem(Icons.notifications_none_outlined, 'Notifikasi', 1),
              _buildNavItem(Icons.account_circle_outlined, 'Profil', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData iconData, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color activeColor = const Color(0xFF4D79FF);
    final Color inactiveColor = Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              color: isSelected ? activeColor : inactiveColor,
              size: 30,
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Text(
                label,
                style: GoogleFonts.poppins(color: inactiveColor, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
} // Penutup class _FootbarPjState
