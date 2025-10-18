// File: lib/widgets/footbar_pj.dart

import 'package:flutter/material.dart';
import '../pj/home_pj.dart';
import '../pj/detail_pengajuan_pj.dart';
import '../pj/approval_pj.dart';
import '../pj/notification_pj.dart';
import '../pj/profile_pj.dart';

// Enum untuk mengelola state halaman yang sedang ditampilkan
enum PjViewState { showingList, showingDetail, showingApproval }

class FootbarPj extends StatefulWidget {
  const FootbarPj({super.key});

  @override
  State<FootbarPj> createState() => _FootbarPjState();
}

class _FootbarPjState extends State<FootbarPj> {
  int _selectedIndex = 0;
  PeminjamanPj? _selectedPeminjaman;
  PjViewState _currentView = PjViewState.showingList;

  // Fungsi untuk menentukan apakah menampilkan Detail atau Approval
  void _handlePeminjamanSelected(PeminjamanPj peminjaman) {
    setState(() {
      _selectedPeminjaman = peminjaman;
      if (peminjaman.status == "Disetujui") {
        _currentView = PjViewState.showingDetail;
      } else {
        _currentView = PjViewState.showingApproval;
      }
    });
  }

  // Fungsi untuk kembali ke halaman daftar (list)
  void _showListPage() {
    setState(() {
      _selectedPeminjaman = null;
      _currentView = PjViewState.showingList;
    });
  }

  // Fungsi untuk mengubah tab pada bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _showListPage(); // Selalu kembali ke list jika pindah tab
      _selectedIndex = index;
    });
  }

  // Widget untuk membangun setiap item navigasi di bottom bar (TETAP SAMA)
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

  // Fungsi untuk membangun body secara dinamis
  Widget _buildBody() {
    switch (_currentView) {
      case PjViewState.showingDetail:
        return DetailPengajuanPjPage(
          peminjaman: _selectedPeminjaman!,
          onBack: _showListPage,
        );
      case PjViewState.showingApproval:
        return ApprovalPjPage(
          peminjaman: _selectedPeminjaman!,
          onBack: _showListPage,
        );
      case PjViewState.showingList:
        return IndexedStack(
          index: _selectedIndex,
          children: [
            HomePjPage(onPeminjamanSelected: _handlePeminjamanSelected),
            const NotificationPjPage(), // Halaman Notifikasi
            const ProfilePjPage(), // Halaman Profil
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      // Tampilkan bottom navigation bar hanya jika di halaman list
      bottomNavigationBar: _currentView == PjViewState.showingList
          ? SafeArea(
              child: Container(
                height: 85,
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    // <--- SUDAH DIPERBAIKI
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.fact_check_outlined, 'Validasi', 0),
                    _buildNavItem(
                      Icons.notifications_none_outlined,
                      'Notifikasi',
                      1,
                    ),
                    _buildNavItem(Icons.account_circle_outlined, 'Profil', 2),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
