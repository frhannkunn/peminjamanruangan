import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Imports Model & Service
import '../models/lecturer.dart';
import '../models/workspace.dart';
import '../services/loan_service.dart';

// Model Lokal untuk UI Form Peminjaman
class Pengguna {
  final String? id; // ID dari Database LoanUser
  final String workspace;
  final String role;
  final String nama;
  final String nim;

  Pengguna({
    this.id,
    required this.workspace,
    required this.role,
    required this.nama,
    required this.nim,
  });
}

class TambahPenggunaDialog extends StatefulWidget {
  final String loanId; 
  final String roomId; 

  const TambahPenggunaDialog({
    super.key,
    required this.loanId,
    required this.roomId,
  });

  @override
  _TambahPenggunaDialogState createState() => _TambahPenggunaDialogState();
}

class _TambahPenggunaDialogState extends State<TambahPenggunaDialog> {
  final _formKey = GlobalKey<FormState>();
  final LoanService _loanService = LoanService();

  bool _isLoading = true;
  bool _isSaving = false;

  // Data Lists
  List<Workspace> _workspaceList = [];
  List<Lecturer> _lecturerList = [];
  List<String> _lecturerStrings = []; // Untuk dropdown Dosen
  
  final List<String> _roleList = ['Dosen', 'Laboran', 'Mahasiswa', 'Umum'];

  // Pilihan User
  Workspace? _selectedWorkspace;
  String? _selectedRole;
  
  // Controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _idController = TextEditingController(); 
  final TextEditingController _dosenSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _idController.dispose();
    _dosenSearchController.dispose();
    super.dispose();
  }

  // Ambil Data Workspace (Sesuai Ruangan) & Data Dosen
  Future<void> _fetchData() async {
    try {
      final workspaces = await _loanService.getWorkspaces(widget.roomId);
      final lecturers = await _loanService.getLecturers();

      if (mounted) {
        setState(() {
          _workspaceList = workspaces;
          _lecturerList = lecturers;
          
          // Format Dosen: CODE | NAMA
          _lecturerStrings = lecturers.map((l) => 
            l.code.isNotEmpty ? "${l.code} | ${l.name}" : l.name
          ).toList();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    // Validasi Dropdown Utama
    if (_selectedWorkspace == null || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi data dropdown")));
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        String finalName = _namaController.text;
        String finalId = _idController.text;

        // JIKA DOSEN/LABORAN: Ambil Nama & NIK dari Dropdown Searchable
        if (_selectedRole == 'Dosen' || _selectedRole == 'Laboran') {
          final selectedString = _dosenSearchController.text;
          // Cari object lecturer aslinya
          try {
            final lecturer = _lecturerList.firstWhere(
              (l) => (l.code.isNotEmpty ? "${l.code} | ${l.name}" : l.name) == selectedString
            );
            finalName = lecturer.name;
            finalId = lecturer.nik; // ID Card diisi NIK
          } catch (e) {
             // Fallback jika user ngetik manual tapi ga ketemu di list
             finalName = selectedString;
             finalId = '-'; 
          }
        }

        // Data untuk dikirim ke API
        Map<String, dynamic> userData = {
          'workspaces_id': _selectedWorkspace!.id,
          'jenis_pengguna': _selectedRole,
          'nama_pengguna': finalName,
          'id_card_pengguna': finalId,
        };

        // Tembak API Simpan User
        final newLoanUser = await _loanService.addUserToLoan(widget.loanId, userData);

        if (mounted) {
          // Tutup Dialog & Kirim Data Balik ke FormPeminjaman untuk ditampilkan
          Navigator.of(context).pop(Pengguna(
            id: newLoanUser.id.toString(), // ID untuk hapus nanti
            workspace: _selectedWorkspace!.displayName, 
            role: newLoanUser.jenisPengguna,
            nama: newLoanUser.namaPengguna,
            nim: newLoanUser.idCardPengguna
          )); 
        }

      } catch (e) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal tambah: $e")));
        }
      }
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
        child: _isLoading 
          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
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

                  
                  
                  // 1. WORKSPACE (Dinamis sesuai Ruangan)
                  _buildLabel("Workspace Ruangan"),
                  // LOGIKA BARU: Cek apakah list workspace kosong
                  if (_workspaceList.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.red.shade400, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Data Workspace belum di-set oleh admin.",
                              style: GoogleFonts.poppins(
                                fontSize: 13, 
                                color: Colors.red.shade700
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<Workspace>(
                      key: ValueKey(_selectedWorkspace?.id),
                      value: _selectedWorkspace,
                      hint: Text("Pilih Workspace",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey[500])),
                      isExpanded: true,
                      menuMaxHeight: 250,
                      items: _workspaceList.map((ws) {
                        return DropdownMenuItem(
                          value: ws,
                          child: Text(ws.displayName,
                              style: GoogleFonts.poppins(fontSize: 14),
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedWorkspace = val),
                      validator: (v) => v == null ? 'Wajib diisi' : null,
                      decoration: _inputDecoration(),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // 2. JENIS PENGGUNA
                  _buildLabel("Jenis Pengguna"),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_selectedRole),
                    value: _selectedRole,
                    hint: Text("Pilih Role", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
                    items: _roleList.map((r) => DropdownMenuItem(value: r, child: Text(r, style: GoogleFonts.poppins(fontSize: 14)))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedRole = val;
                        // Reset form saat ganti role
                        _namaController.clear();
                        _idController.clear();
                        _dosenSearchController.clear();
                      });
                    },
                    validator: (v) => v == null ? 'Wajib diisi' : null,
                    decoration: _inputDecoration(),
                  ),

                  // 3. FORM DINAMIS (Dosen vs Mahasiswa)
                  if (_selectedRole != null) ...[
                    const SizedBox(height: 20),
                    
                    // JIKA DOSEN / LABORAN -> Muncul Searchable Dropdown
                    if (_selectedRole == 'Dosen' || _selectedRole == 'Laboran') ...[
                      _buildLabel("Pilih $_selectedRole *"),
                      LayoutBuilder(builder: (context, constraints) {
                        return DropdownMenu<String>(
                          width: constraints.maxWidth,
                          menuHeight: 250,
                          controller: _dosenSearchController,
                          enableFilter: true, // Bisa ketik & enter
                          requestFocusOnTap: true,
                          hintText: "Ketik Nama $_selectedRole...",
                          textStyle: GoogleFonts.poppins(fontSize: 14),
                          inputDecorationTheme: InputDecorationTheme(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          dropdownMenuEntries: _lecturerStrings.map((item) {
                            return DropdownMenuEntry<String>(
                              value: item,
                              label: item,
                              style: ButtonStyle(textStyle: WidgetStateProperty.all(GoogleFonts.poppins(fontSize: 14))),
                            );
                          }).toList(),
                          onSelected: (value) {
                            FocusScope.of(context).unfocus(); // Tutup keyboard saat dipilih
                          },
                        );
                      }),
                    ] 
                    // JIKA MAHASISWA / UMUM -> Muncul Input Manual
                    else ...[
                      _buildLabel("Nama Pengguna"),
                      _buildTextField(controller: _namaController, hintText: 'Contoh: Kim Jisoo', validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                      const SizedBox(height: 20),
                      _buildLabel("ID Card / NIM"),
                      _buildTextField(controller: _idController, hintText: 'Contoh: 4342411059', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                      const SizedBox(height: 12),
                      _buildInstructionText("Apabila Pengguna bersifat umum, silahkan mengisi NIK KTP"),
                    ],
                  ],

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(), 
                        style: TextButton.styleFrom(backgroundColor: Colors.pink.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
                        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Text("Batal", style: GoogleFonts.poppins(color: Colors.pink.shade700, fontWeight: FontWeight.w600)))
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _submit, 
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0), 
                          child: _isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                            : Text("Tambah", style: GoogleFonts.poppins(fontWeight: FontWeight.w600))
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)));
  Widget _buildInstructionText(String text) => Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(text, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])));
  Widget _buildTextField({required TextEditingController controller, required String hintText, TextInputType keyboardType = TextInputType.text, FormFieldValidator<String>? validator}) => TextFormField(controller: controller, keyboardType: keyboardType, style: GoogleFonts.poppins(fontSize: 14), decoration: _inputDecoration(hint: hintText), validator: validator);
  
  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint, hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]), filled: true, fillColor: Colors.grey.shade100, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
    );
  }
}