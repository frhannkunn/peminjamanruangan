// File: lib/pj/approval_pj.dart

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'home_pj.dart';

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

  // --- FUNGSI BARU UNTUK MENAMPILKAN DIALOG SUKSES (SUDAH DIBAGUSKAN) ---
  void _showSuccessDialog() {
    // TODO: Implement save logic here before showing the dialog
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
            padding: const EdgeInsets.all(30.0), // Padding lebih luas
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Custom dengan Border dan Warna Konsisten
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFFDCF8DD,
                    ), // Latar belakang lingkaran hijau muda
                    border: Border.all(
                      color: const Color(0xFFC3E6CB), // Border hijau
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check, // Ikon centang yang lebih tebal
                    color: Color(0xFF28A745), // Hijau tua
                    size: 40,
                  ),
                ),
                const SizedBox(height: 30), // Jarak lebih lebar
                // Text Pemberitahuan
                const Text(
                  'Approval Penanggung Jawab berhasil disimpan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700, // Lebih tebal
                    color: Color(0xFF333333),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 30),
                // Tombol OK dengan Warna Ungu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // Menggunakan warna ungu terang yang konsisten (#794AFF)
                      backgroundColor: const Color(0xFF794AFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0, // Menghilangkan bayangan agar lebih flat
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Tutup dialog
                      widget.onBack(); // Kembali ke halaman list
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
  // --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F7FC),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 150, 20, 100),
            child: Column(
              children: [
                _buildFormCard(),
                const SizedBox(height: 24),
                _buildSimpanButton(),
              ],
            ),
          ),
          _buildHeader(),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black54,
                size: 28,
              ),
              onPressed: widget.onBack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 80,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1A39D9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Text(
          'Approval Penanggung Jawab Terhadap Peminjaman Ruangan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Approval Penanggung Jawab'),
          const SizedBox(height: 8),
          DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            hint: const Text(
              '-- Pilih Approval --',
              style: TextStyle(fontSize: 14),
            ),
            value: _selectedApproval,
            items: ['Diterima', 'Ditolak']
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedApproval = value;
              });
            },
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              offset: const Offset(0, -10),
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('Komentar'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _komentarController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Masukkan komentar... (opsional)',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showSuccessDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF28A745), // Warna hijau
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0, // Tambahkan ini agar konsisten
        ),
        child: const Text(
          'Simpan Approval',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.grey[700], fontSize: 14),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
