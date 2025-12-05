// File: lib/widgets/footbar_pic.dart (REVISI - Menggunakan IndexedStack)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pic/home_pic.dart'; 
import '../pic/notification_pic.dart'; 
import '../pic/profile_pic.dart';


class FootbarPic extends StatefulWidget {
  const FootbarPic({super.key});

  @override
  State<FootbarPic> createState() => _FootbarPicState();
}

class _FootbarPicState extends State<FootbarPic> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      
      const HomePicPage(), // Halaman Home/Validasi List
      const NotifikasiPicPage(), // Halaman Notifikasi
      const ProfilePicPage(), // Halaman Profil
      
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Logika _navigateToHome() dihapus dari sini
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // --- PERUBAHAN: Gunakan IndexedStack ---
      body: IndexedStack(index: _selectedIndex, children: _pages),
      // --- AKHIR PERUBAHAN ---
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

  // Widget _buildNavItem tidak berubah
  Widget _buildNavItem(IconData iconData, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color activeColor = const Color(0xFF1C36D2);
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
}
