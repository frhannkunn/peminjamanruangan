// widgets/footbar_pic.dart

import 'package:flutter/material.dart';
import '../pic/home_pic.dart';
import '../pic/validasi_pic.dart';
import '../pic/approval_pic.dart';
import '../pic/notification_pic.dart';
import '../pic/profile_pic.dart'; // <-- 1. TAMBAHKAN IMPORT INI

class FootbarPic extends StatefulWidget {
  const FootbarPic({super.key});

  @override
  State<FootbarPic> createState() => _FootbarPicState();
}

class _FootbarPicState extends State<FootbarPic> {
  int _selectedIndex = 0;
  Peminjaman? _selectedPeminjaman;
  bool _isShowingApprovalPage = false;

  // ... (Semua fungsi _showDetailPage, _navigateToHome, dll. tetap sama)
  void _showDetailPage(Peminjaman peminjaman) {
    setState(() {
      _selectedPeminjaman = peminjaman;
    });
  }

  void _navigateToHome() {
    setState(() {
      _selectedPeminjaman = null;
      _isShowingApprovalPage = false;
    });
  }

  void _showApprovalPage() {
    setState(() {
      _isShowingApprovalPage = true;
    });
  }

  void _hideApprovalPage() {
    setState(() {
      _isShowingApprovalPage = false;
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
    // --- 2. GANTI ISI LIST PAGES DI SINI ---
    final List<Widget> pages = <Widget>[
      ValidasiPage(onPeminjamanSelected: _showDetailPage),
      const NotifikasiPicPage(),
      const ProfilePicPage(), // <-- UBAH BARIS INI
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isShowingApprovalPage
          ? ApprovalPicPage(
              peminjamanData: _selectedPeminjaman!,
              onBack: _hideApprovalPage,
              onSave: _navigateToHome,
            )
          : _selectedPeminjaman != null
          ? ValidasiPicPage(
              peminjamanData: _selectedPeminjaman!,
              onBack: _navigateToHome,
              onNavigateToApproval: _showApprovalPage,
            )
          : pages.elementAt(_selectedIndex),

      // ... (Sisa kode bottomNavigationBar tetap sama)
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
              _buildNavItem(Icons.fact_check_outlined, 'Validasi', 0),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Text(label, style: TextStyle(color: inactiveColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
