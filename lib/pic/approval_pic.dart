// pic/approval_pic.dart

import 'package:flutter/material.dart';
import 'home_pic.dart'; // Import Peminjaman

class ApprovalPicPage extends StatefulWidget {
  final Peminjaman peminjamanData;
  final VoidCallback onBack;
  final VoidCallback onSave;

  const ApprovalPicPage({
    super.key,
    required this.peminjamanData,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<ApprovalPicPage> createState() => _ApprovalPicPageState();
}

class _ApprovalPicPageState extends State<ApprovalPicPage> {
  final _formKey = GlobalKey<FormState>();
  String? _approvalValue;
  final TextEditingController _komentarController = TextEditingController();

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  // --- FUNGSI BARU UNTUK MENAMPILKAN DIALOG SUKSES ---
  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User harus menekan tombol untuk menutup
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Ikon centang
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2.5),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                // Teks
                const Text(
                  'Approval PIC\nberhasil disimpan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),
                // Tombol OK
                SizedBox(
                  width: 120,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Tutup dialog
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent, // Hilangkan warna default
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero, // Hilangkan padding default
                      elevation: 5,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A5AF9), Color(0xFFD66EFD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  // --- UBAH FUNGSI SIMPAN DATA ---
  void _simpanData() async { // Jadikan async
    if (_formKey.currentState!.validate()) {
      // Tampilkan dialog dan tunggu sampai ditutup
      await _showSuccessDialog();
      
      // Setelah dialog ditutup, panggil callback onSave untuk navigasi
      widget.onSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Seluruh isi widget build tetap SAMA seperti sebelumnya
    // ... (kode di bawah ini tidak ada perubahan) ...
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C36D2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        "Approval PIC Ruangan\nTerhadap Peminjaman Ruangan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.peminjamanData.statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          widget.peminjamanData.status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Approval PIC *",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _approvalValue,
                      hint: const Text("Pilih status approval",
                          style: TextStyle(color: Colors.grey)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: "Disetujui", child: Text("Disetujui")),
                        DropdownMenuItem(
                            value: "Ditolak", child: Text("Ditolak")),
                      ],
                      onChanged: (value) {
                        setState(() => _approvalValue = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Harap pilih status approval";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text("Komentar *",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _komentarController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Masukkan komentar",
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Komentar wajib diisi";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildButton("Batal", Colors.pinkAccent, widget.onBack),
                        const SizedBox(width: 8),
                        _buildButton("Reset", Colors.orange, () {
                          setState(() {
                            _approvalValue = null;
                            _komentarController.clear();
                            _formKey.currentState!.reset();
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildButton("Simpan", Colors.green, _simpanData),
                      ],
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

  Widget _buildButton(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 2,
          ),
          onPressed: onTap,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }
}