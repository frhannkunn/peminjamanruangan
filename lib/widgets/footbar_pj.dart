// File: lib/widgets/footbar_pj.dart (CORRECTED AGAIN)

import 'package:flutter/material.dart';
import '../pj/home_pj.dart';
import '../pj/detail_pengajuan_pj.dart'; // Halaman Detail
import '../pj/approval_pj.dart'; // Halaman Approval
import '../pj/notification_pj.dart';
import '../pj/profile_pj.dart';

// Enum dengan 3 state
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

  // --- Logika pemilihan view: SELALU ke showingDetail ---
  void _handlePeminjamanSelected(PeminjamanPj peminjaman) {
    setState(() {
      _selectedPeminjaman = peminjaman;
      // Selalu arahkan ke halaman detail terlebih dahulu
      _currentView = PjViewState.showingDetail;
    });
  }
  // -----------------------------------------------------------

  // --- Fungsi untuk pindah ke halaman Approval ---
  void _showApprovalPage() {
    if (_selectedPeminjaman != null) {
      // Pastikan ada peminjaman yang dipilih
      setState(() {
        _currentView = PjViewState.showingApproval;
      });
    }
  }
  // ---------------------------------------------

  // Fungsi kembali ke list (tidak berubah)
  void _showListPage() {
    setState(() {
      _selectedPeminjaman = null;
      _currentView = PjViewState.showingList;
    });
  }

  // Fungsi pindah tab (tidak berubah)
  void _onItemTapped(int index) {
    setState(() {
      // Jika user sudah di halaman detail/approval dan tap tab yg sama, kembali ke list
      if (_currentView != PjViewState.showingList && _selectedIndex == index) {
        _showListPage();
      }
      // Jika user pindah ke tab lain, selalu kembali ke list
      else if (_selectedIndex != index) {
        _showListPage();
        _selectedIndex = index; // Update index HANYA jika pindah tab
      }
    });
  }

  Widget _buildNavItem(IconData iconData, String label, int index) {
    // Kode _buildNavItem tidak berubah
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

  // --- Logika _buildBody diupdate ---
  Widget _buildBody() {
    switch (_currentView) {
      case PjViewState.showingDetail:
        // Tampilkan halaman detail dan teruskan callback _showApprovalPage
        return DetailPengajuanPjPage(
          peminjaman: _selectedPeminjaman!,
          onBack: _showListPage, // Tombol back di header detail kembali ke list
          onApproveTap: _showApprovalPage, // <-- TAMBAHKAN KEMBALI ARGUMEN INI
        );
      case PjViewState.showingApproval:
        // Tampilkan halaman approval
        return ApprovalPjPage(
          peminjaman: _selectedPeminjaman!,
          onBack:
              _showListPage, // Tombol back/simpan di approval kembali ke list
        );
      case PjViewState.showingList:
        return IndexedStack(
          index: _selectedIndex,
          children: [
            HomePjPage(onPeminjamanSelected: _handlePeminjamanSelected),
            const NotificationPjPage(),
            const ProfilePjPage(),
          ],
        );
    }
  }
  // -------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      // Bottom bar selalu tampil
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 85,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
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
              _buildNavItem(Icons.notifications_none_outlined, 'Notifikasi', 1),
              _buildNavItem(Icons.account_circle_outlined, 'Profil', 2),
            ],
          ),
        ),
      ),
    );
  }
}
