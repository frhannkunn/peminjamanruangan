// File: lib/pj/approval_pj.dart (Asterisk Removed)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'home_pj.dart'; // Untuk class PeminjamanPj

class ApprovalPjPage extends StatefulWidget {
  final PeminjamanPj peminjaman;
  final VoidCallback onBack;

  const ApprovalPjPage({
    super.key,
    required this.peminjaman,
    required this.onBack,
  });

  @override
  State<ApprovalPjPage> createState() => _ApprovalPjPageState();
}

class _ApprovalPjPageState extends State<ApprovalPjPage> {
  String? _selectedApproval;
  final _komentarController = TextEditingController();

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  // Fungsi Dialog Sukses (Tidak Berubah)
  void _showSuccessDialog() {
    /* ... kode dialog sukses ... */
    // TODO: Implement save logic here
    print('Status Approval: $_selectedApproval');
    print('Komentar: ${_komentarController.text}');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFDCF8DD),
                    border: Border.all(
                      color: const Color(0xFFC3E6CB),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF28A745),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Approval Penanggung Jawab berhasil disimpan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF794AFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onBack(); // Kembali ke list setelah OK
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fungsi Reset Form (Tidak Berubah)
  void _resetForm() {
    setState(() {
      _selectedApproval = null;
      _komentarController.clear();
    });
  }

  // Fungsi Submit Approval (Tidak Berubah)
  void _submitApproval() {
    if (_selectedApproval == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih status approval.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _showSuccessDialog();
  }

  @override
  Widget build(BuildContext context) {
    // Status selalu oranye di halaman ini
    final Color statusColor = Colors.orange.shade400;
    final String displayStatus = widget.peminjaman.status ?? 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Background abu-abu muda
      body: Column(
        // Gunakan Column
        children: [
          _buildHeader(displayStatus, statusColor), // Header biru
          Expanded(
            // Expanded agar form mengisi sisa ruang
            child: SingleChildScrollView(
              // Form bisa discroll
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildApprovalForm(), // Widget form approval
                  const SizedBox(height: 30), // Jarak sebelum tombol
                  _buildActionButtons(), // Widget tombol Batal, Reset, Simpan
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDER ---
  Widget _buildHeader(String status, Color statusColor) {
    /* ... kode header ... */
    String chipText = status;
    if (status == "Menunggu Persetujuan Penanggung Jawab") {
      chipText = "Menunggu\nPersetujuan\nPenanggung\nJawab";
    }
    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF1A39D9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: widget.onBack,
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                'Approval Penanggung\nJawab Terhadap\nPeminjaman Ruangan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                chipText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  height: 1.2,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(
            'Approval Penanggung Jawab',
          ), // Panggil helper _buildLabel
          const SizedBox(height: 8),
          DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            hint: const Text(
              '-- Pilih Approval --',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            value: _selectedApproval,
            items: ['Disetujui', 'Ditolak']
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedApproval = value),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            buttonStyleData: const ButtonStyleData(
              height: 50,
              padding: EdgeInsets.only(left: 10, right: 10),
            ),
            menuItemStyleData: const MenuItemStyleData(height: 50),
          ),
          const SizedBox(height: 20),
          _buildLabel('Komentar'), // Panggil helper _buildLabel
          const SizedBox(height: 8),
          TextFormField(
            controller: _komentarController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Masukkan komentar... (opsional)',
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    /* ... kode tombol ... */
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: widget.onBack,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text(
            'Batal',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 15),
        ElevatedButton(
          onPressed: _resetForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text(
            'Reset',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 15),
        ElevatedButton(
          onPressed: _submitApproval,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text(
            'Simpan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // --- Helper _buildLabel (tanpa asterisk) ---
  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 14));
  }

  // ------------------------------------------
}
