import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- DIKEMBALIKAN: Class Pengguna kembali sederhana ---
class Pengguna {
  final String workspace;
  final String role;
  final String nama;
  final String nim;

  Pengguna({
    required this.workspace,
    required this.role,
    required this.nama,
    required this.nim,
  });
}


class TambahPenggunaDialog extends StatefulWidget {
  const TambahPenggunaDialog({Key? key}) : super(key: key);

  @override
  _TambahPenggunaDialogState createState() => _TambahPenggunaDialogState();
}

class _TambahPenggunaDialogState extends State<TambahPenggunaDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedWorkspace;
  String? _selectedRole;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  final List<String> _workspaceList = [
    'WS.TA.12.3B.02 | NON PC', 'WS.GU.601.01 | NON PC', 'WS.GU.604.02 | NON PC',
    'WS.GU.604.03 | NON PC', 'WS.GU.604.04 | NON PC', 'WS.GU.604.05 | NON PC',
  ];
  final List<String> _roleList = ['Dosen', 'Laboran', 'Mahasiswa', 'Umum'];

  @override
  void dispose() {
    _namaController.dispose();
    _idController.dispose();
    super.dispose();
  }

  // --- DISESUAIKAN: Menggunakan constructor yang sederhana ---
  void _submit() {
    if (_formKey.currentState!.validate()) {
      final penggunaBaru = Pengguna(
        workspace: _selectedWorkspace!,
        role: _selectedRole!,
        nama: _namaController.text,
        nim: _idController.text,
      );
      Navigator.of(context).pop(penggunaBaru);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Tambah Pengguna Ruangan", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 16),
                _buildLabel("Workspace Ruangan"),
                _buildDropdown(value: _selectedWorkspace, hint: 'Pilih Workspace', items: _workspaceList, onChanged: (value) => setState(() => _selectedWorkspace = value), validator: (v) => v == null ? 'Wajib diisi' : null),
                const SizedBox(height: 20),
                _buildLabel("Jenis Pengguna"),
                _buildDropdown(value: _selectedRole, hint: 'Pilih Role', items: _roleList, onChanged: (value) => setState(() => _selectedRole = value), validator: (v) => v == null ? 'Wajib diisi' : null),
                if (_selectedRole != null) ...[
                  const SizedBox(height: 20),
                  _buildLabel("Nama Pengguna"),
                  _buildTextField(controller: _namaController, hintText: 'Contoh: Kim Jisoo', validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 20),
                  _buildLabel("ID Card / NIM"),
                  _buildTextField(controller: _idController, hintText: 'Contoh: 4342411059', keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),
                  _buildInstructionText("Apabila Pengguna bersifat umum, silahkan mengisi NIK KTP"),
                ],
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(backgroundColor: Colors.pink.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Text("Batal", style: GoogleFonts.poppins(color: Colors.pink.shade700, fontWeight: FontWeight.w600)))),
                    const SizedBox(width: 12),
                    ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Text("Tambah", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper...
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)));
  Widget _buildInstructionText(String text) => Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(text, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])));
  Widget _buildTextField({required TextEditingController controller, required String hintText, TextInputType keyboardType = TextInputType.text, FormFieldValidator<String>? validator}) => TextFormField(controller: controller, keyboardType: keyboardType, style: GoogleFonts.poppins(fontSize: 14), decoration: InputDecoration(hintText: hintText, hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]), filled: true, fillColor: Colors.grey.shade100, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), validator: validator);
  Widget _buildDropdown({required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged, FormFieldValidator<String>? validator}) => DropdownButtonFormField<String>(value: value, decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]), filled: true, fillColor: Colors.grey.shade100, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: GoogleFonts.poppins(fontSize: 14)))).toList(), onChanged: onChanged, validator: validator);
}