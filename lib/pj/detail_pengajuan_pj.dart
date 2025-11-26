import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../models/pj_models.dart';
import '../services/pj_service.dart';
import '../../models/loan_user.dart';

class DetailPengajuanPjPage extends StatefulWidget {
  // Tetap menerima object dari Home (untuk data awal/transisi smooth)
  // Tapi kita akan fetch detail lengkap (termasuk user list) di initState
  final PeminjamanPj peminjaman; 

  const DetailPengajuanPjPage({super.key, required this.peminjaman});

  @override
  State<DetailPengajuanPjPage> createState() => _DetailPengajuanPjPageState();
}

class _DetailPengajuanPjPageState extends State<DetailPengajuanPjPage> {
  final PjService _pjService = PjService();
  late Future<PeminjamanPjDetailModel> _detailFuture;

  final _formKey = GlobalKey<FormState>();
  String? _selectedApproval;
  final _komentarController = TextEditingController();

  final TextEditingController _searchPenggunaController = TextEditingController();
  String _searchPenggunaQuery = '';

  @override
  void initState() {
    super.initState();
    // Load detail data lengkap dari API berdasarkan ID
    _detailFuture = _pjService.getDetail(widget.peminjaman.id);

    _searchPenggunaController.addListener(() {
      setState(() {
        _searchPenggunaQuery = _searchPenggunaController.text;
      });
    });
  }

  @override
  void dispose() {
    _komentarController.dispose();
    _searchPenggunaController.dispose();
    super.dispose();
  }

  Future<void> _submitApproval() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Tampilkan Loading Indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        // Convert dropdown value to int for API
        // "Disetujui" -> 1, "Ditolak" -> 0
        int statusInt = _selectedApproval == 'Disetujui' ? 1 : 0;
        
        await _pjService.submitApproval(
          widget.peminjaman.id,
          statusInt,
          _komentarController.text
        );

        Navigator.pop(context); // Tutup Loading
        _showSuccessDialog(); // Tampilkan Dialog Sukses
      } catch (e) {
        Navigator.pop(context); // Tutup Loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                  Text(
                    'Approval Penanggung Jawab\nberhasil disimpan.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 150,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        // Mengembalikan status baru ke Home Page agar direfresh
                        String resultStatus = _selectedApproval == 'Disetujui' ? 'Disetujui' : 'Ditolak';
                        Navigator.pop(context, resultStatus);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF00D800),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 3,
                      ),
                      child: Text(
                        'OK',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kita gunakan FutureBuilder untuk menunggu data detail (users list, dll)
    return FutureBuilder<PeminjamanPjDetailModel>(
      future: _detailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        }

        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text("Data tidak ditemukan")));
        }

        final _dataDetail = snapshot.data!;
        
        // Logic Approval Button: Hanya muncul jika status == Menunggu
        final bool needsApproval = _dataDetail.status == "Menunggu Persetujuan Penanggung Jawab";

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FC),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Detail Peminjaman',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFormHeaderCard(_dataDetail),
                  const SizedBox(height: 24),
                  _buildFormCard(_dataDetail),
                  const SizedBox(height: 24),
                  _buildUserListCard(_dataDetail),
                  if (needsApproval) ...[
                    const SizedBox(height: 24),
                    _buildApprovalSection(),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildFormHeaderCard(PeminjamanPjDetailModel data) {
    String status = data.status;
    Color statusColor = data.statusColor;
    String chipText = status;

    if (status == "Menunggu Persetujuan Penanggung Jawab") {
      chipText = "Menunggu\nPersetujuan\nPenanggung\nJawab";
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Form\nPengajuan\nPenggunaan\nRuangan',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            constraints: const BoxConstraints(minHeight: 50),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                chipText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(PeminjamanPjDetailModel data) {
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
          _buildReadOnlyField(
            label: "Jenis Kegiatan",
            value: data.jenisKegiatan,
          ),
          _buildReadOnlyField(
            label: "Nama Kegiatan",
            value: data.namaKegiatan,
          ),
          _buildReadOnlyField(
            label: "NIM / NIK / Unit Pengaju",
            value: data.nimNip,
            helperText: "Jika tidak memiliki NIM, dapat diisi dengan NIK KTP",
          ),
          _buildReadOnlyField(
            label: "Nama Pengaju",
            value: data.namaPengaju,
          ),
          _buildReadOnlyField(
            label: "Alamat E-Mail Pengaju",
            value: data.emailPengaju,
          ),
          _buildReadOnlyField(
            label: "Penanggung Jawab",
            value: data.penanggungJawab,
          ),
          _buildReadOnlyField(
            label: "Tanggal Penggunaan",
            value: data.tanggalPenggunaan,
          ),
          _buildReadOnlyField(label: "Ruangan", value: data.ruangan),
          Row(
            children: [
              Expanded(
                child: _buildReadOnlyField(
                  label: "Jam Mulai",
                  value: data.jamMulai,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildReadOnlyField(
                  label: "Jam Selesai",
                  value: data.jamSelesai,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserListCard(PeminjamanPjDetailModel data) {
    final List<LoanUser> allUsers = data.listPengguna;
    final List<LoanUser> filteredList = allUsers.where((user) {
      final query = _searchPenggunaQuery.toLowerCase();
      if (query.isEmpty) return true;
      
      // Cek field nama dan id card
      return user.namaPengguna.toLowerCase().contains(query) || 
             user.idCardPengguna.toLowerCase().contains(query);
    }).toList();

    final List<String> displayKeys = [
      'ID',
      'NIM',
      'Nama',
      'Nomor Workspace',
      'Tipe Workspace',
    ];
    String getValue(LoanUser user, String key) {
      switch (key) {
        case 'ID': return user.id.toString();
        case 'NIM': return user.idCardPengguna;
        case 'Nama': return user.namaPengguna;
        case 'Nomor Workspace': return user.workspaceCode ?? '-';
        case 'Tipe Workspace': 
          String rawType = user.workspaceType ?? '-';
          if (rawType == '1') return 'With PC';       // Jika 1, tampilkan PC
          if (rawType == '2') return 'Non-PC';   // Jika 2, tampilkan Non-PC (Sesuaikan logic DB Anda)
          return rawType; // Jika bukan 1 atau 2, tampilkan angkanya
          
        default: return '-';
      }
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF1c36d2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 5),
            ],
          ),
          child: Center(
            child: Text(
              'List Pengguna Ruangan',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Search:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: TextField(
                        controller: _searchPenggunaController,
                        style: GoogleFonts.poppins(fontSize: 12),
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (filteredList.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Data tidak ditemukan",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              else
                ...filteredList.map((user) {
                  return Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: displayKeys.map((key) {
                        return _buildUserDetailRow(key, getValue(user, key));
                      }).toList(),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalSection() {
    return _buildSectionCard(
      title: 'Form Approval Penanggung Jawab',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Approval Penanggung Jawab",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            hint: Text(
              'Pilih status approval',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            value: _selectedApproval,
            items: [
              DropdownMenuItem<String>(
                value: 'Disetujui',
                child: Text(
                  'Diterima',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              DropdownMenuItem<String>(
                value: 'Ditolak',
                child: Text(
                  'Ditolak',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _selectedApproval = value),
            validator: (value) =>
                value == null ? "Harap pilih status approval" : null,
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            buttonStyleData: const ButtonStyleData(
              height: 50,
              padding: EdgeInsets.only(left: 10, right: 10),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Komentar",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: _komentarController,
            maxLines: 4,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Masukkan komentar...',
              hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Komentar diisi!";
              }
              return null;
            },
          ),

          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1c36d2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _submitApproval,
                    child: Text(
                      "Simpan",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF1c36d2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(15.0), child: content),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            readOnly: true,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 2.0),
              child: Text(
                helperText,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}