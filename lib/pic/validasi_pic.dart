// File: lib/pic/validasi_pic.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
// IMPORT MODEL YANG DIBUTUHKAN
import '../../models/pic.dart'; 
import '../../models/loan_user.dart'; // <--- PERBAIKAN ERROR 1: Import LoanUser
import '../../services/pic_service.dart';

class ValidasiPicPage extends StatefulWidget {
  final String loanId; 

  const ValidasiPicPage({super.key, required this.loanId});

  @override
  State<ValidasiPicPage> createState() => _ValidasiPicPageState();
}

class _ValidasiPicPageState extends State<ValidasiPicPage> {
  final PicService _picService = PicService();
  
  PeminjamanPicDetailModel? _dataDetail;
  bool _isLoading = true;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  String? _approvalValue;
  final TextEditingController _komentarController = TextEditingController();

  final TextEditingController _searchPenggunaController = TextEditingController();
  String _searchPenggunaQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _searchPenggunaController.addListener(() {
      setState(() {
        _searchPenggunaQuery = _searchPenggunaController.text;
      });
    });
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _picService.getApprovalDetail(widget.loanId);
      if (mounted) {
        setState(() {
          _dataDetail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _komentarController.dispose();
    _searchPenggunaController.dispose();
    super.dispose();
  }

  // --- FUNGSI HELPER & SUBMIT ---
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
                    child: const Icon(Icons.check, color: Colors.green, size: 40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Approval PIC\nberhasil disimpan.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 150,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF00D800),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero,
                        elevation: 3,
                      ),
                      child: Text('OK', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      try {
        int statusInt = (_approvalValue == "Disetujui") ? 1 : 0;
        await _picService.submitApproval(
          loanId: widget.loanId,
          status: statusInt,
          comment: _komentarController.text,
        );
        if (mounted) Navigator.pop(context);
        await _showSuccessDialog();
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengirim data: $e")));
        }
      }
    }
  }

  Widget _buildButton(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 2,
          ),
          onPressed: onTap,
          child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Pengajuan',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : (_errorMessage != null)
            ? Center(child: Text("Error: $_errorMessage"))
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        _buildSectionFormUtama(),
                        const SizedBox(height: 24),
                        _buildSectionDetailKegiatan(),
                        const SizedBox(height: 20),
                        _buildSectionPeminjam(),
                        const SizedBox(height: 20),
                        _buildSectionPenggunaan(),
                        const SizedBox(height: 20),
                        _buildSectionListPengguna(), 
                        
                        // --- PERBAIKAN ERROR KOMA DI SINI ---
                        if (_dataDetail!.rawStatus == '3') ...[
                          const SizedBox(height: 20),
                          _buildSectionApproval(),
                        ], // <--- KOMA DISINI

                        if (['4', '5'].contains(_dataDetail!.rawStatus) && _dataDetail!.picComment != null) ...[
                          const SizedBox(height: 20),
                          _buildSectionHistory(),
                        ], // <--- KOMA DISINI
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  // --- WIDGET SECTIONS ---
  Widget _buildSectionHistory() {
     return _buildSectionCard(
       title: 'Status Approval PIC',
       content: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            _buildDetailRow('Status', _dataDetail!.status),
            const SizedBox(height: 10),
            _buildDetailRow('Komentar PIC', _dataDetail!.picComment ?? '-'),
         ],
       )
     );
  }

  // LIST PENGGUNA 
  Widget _buildSectionListPengguna() {
    final listApi = _dataDetail!.listPengguna;

    // Helper Function 
    String getValue(LoanUser user, String key) {
      switch (key) {
        case 'ID': 
        return user.id.toString();
        case 'Jenis Pengguna': 
        return user.jenisPengguna;
        case 'ID Pengguna': 
        return user.idCardPengguna;
        case 'Nama': 
        return user.namaPengguna;
        case 'Nomor Workspace': 
        return user.workspaceCode ?? '-';
        case 'Tipe Workspace':
          String rawType = user.workspaceType?.toString() ?? '-';
          if (rawType == '1') return 'With PC';    
          if (rawType == '2') return 'Non-PC';     
          return rawType == '-' ? '-' : rawType;   
        default: return '-';
      }
    }

    final List<String> displayKeys = [
      'ID', 'Jenis Pengguna', 'ID Pengguna', 'Nama', 'Nomor Workspace', 'Tipe Workspace',
    ];

    // Filter Search
    final filteredList = listApi.where((user) {
      final query = _searchPenggunaQuery.toLowerCase();
      if (query.isEmpty) return true;
      for (var key in displayKeys) {
        final value = getValue(user, key).toLowerCase();
        if (value.contains(query)) return true;
      }
      return false;
    }).toList();

    return _buildSectionCard(
      title: 'List Pengguna Ruangan',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('search : ', style: GoogleFonts.poppins(color: Colors.black54)),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _searchPenggunaController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Cari...",
                        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 30),

          if (filteredList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  _searchPenggunaQuery.isEmpty ? 'Tidak ada data pengguna.' : 'Tidak ada hasil pencarian.',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            )
          else
            ...filteredList.map((user) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  children: displayKeys.map((key) {
                    return _buildPenggunaInfoRow(key, getValue(user, key));
                  }).toList(),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPenggunaInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
          ),
          Text(' : ', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // --- SISA WIDGET BUILDER ---
  Widget _buildSectionFormUtama() {
    String status = _dataDetail!.status;
    Color statusColor = _dataDetail!.statusColor;
    String chipText = status;
    if (status.contains("Menunggu Persetujuan")) {
       chipText = status.replaceAll(" ", "\n");
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1c36d2),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text('Form\nPengajuan\nPenggunaan\nRuangan', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.3))),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: const BoxConstraints(minWidth: 130),
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
            child: Text(chipText, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13, height: 1.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDetailKegiatan() {
    return _buildSectionCard(
      title: 'Detail Kegiatan dan Penganggung Jawab',
      content: Column(
        children: [
          _buildFormTextField('Jenis Kegiatan', _dataDetail!.jenisKegiatan),
          _buildFormTextField('Nama Kegiatan', _dataDetail!.namaKegiatan),
          _buildFormTextField('Penanggung Jawab', _dataDetail!.penanggungJawab),
        ],
      ),
    );
  }

  Widget _buildSectionPeminjam() {
    return _buildSectionCard(
      title: 'Detail Peminjaman Ruangan',
      content: Column(
        children: [
          _buildFormTextField('NIM / NIK / Unit Pengaju', _dataDetail!.nimNip),
          _buildFormTextField('Nama Pengaju', _dataDetail!.namaPengaju),
          _buildFormTextField('Alamat E-mail Pengaju', _dataDetail!.emailPengaju),
        ],
      ),
    );
  }

  Widget _buildSectionPenggunaan() {
    return _buildSectionCard(
      title: 'Detail Penggunaan Ruangan',
      content: Column(
        children: [
          _buildFormTextField('Ruangan', _dataDetail!.ruangan),
          _buildDatePicker('Tanggal Penggunaan', _dataDetail!.tanggalPenggunaan),
          Row(
            children: [
              Expanded(child: _buildFormTextField('Jam Mulai', _dataDetail!.jamMulai)),
              const SizedBox(width: 15),
              Expanded(child: _buildFormTextField('Jam Selesai', _dataDetail!.jamSelesai)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionApproval() {
    return _buildSectionCard(
      title: 'Form Approval PIC',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Approval PIC", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField2<String>(
            value: _approvalValue,
            hint: Text("Pilih status approval", style: GoogleFonts.poppins(color: Colors.grey)),
            style: GoogleFonts.poppins(color: Colors.black),
            decoration: InputDecoration(
              filled: true, fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            items: const [
              DropdownMenuItem(value: "Disetujui", child: Text("Disetujui")),
              DropdownMenuItem(value: "Ditolak", child: Text("Ditolak")),
            ],
            onChanged: (value) => setState(() => _approvalValue = value),
            validator: (value) => value == null ? "Harap pilih status approval" : null,
          ),
          const SizedBox(height: 20),
          Text("Komentar", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _komentarController,
            maxLines: 4,
            style: GoogleFonts.poppins(color: Colors.black),
            decoration: InputDecoration(
              hintText: "Masukkan komentar...", hintStyle: GoogleFonts.poppins(color: Colors.grey),
              filled: true, fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            validator: (value) {
              if (_approvalValue == "Ditolak" && (value == null || value.isEmpty)) return "Komentar diisi!";
              return null;
            },
          ),
          const SizedBox(height: 30),
          Row(children: [_buildButton("Simpan", const Color(0xFF1c36d2), _simpanData)]),
        ],
      ),
    );
  }

  Widget _buildFormTextField(String label, String value, {Widget? suffixIcon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            key: Key(value), initialValue: value, readOnly: true, maxLines: null,
            style: GoogleFonts.poppins(color: Colors.black),
            decoration: InputDecoration(
              filled: true, fillColor: Colors.grey[100], suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, String value) {
    return _buildFormTextField(label, value, suffixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey[600], size: 20));
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: const Color(0x1A000000), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: const BoxDecoration(color: Color(0xFF1c36d2), borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
            child: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Padding(padding: const EdgeInsets.all(15.0), child: content),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: GoogleFonts.poppins(color: Colors.grey[700]))),
        Text(': ', style: GoogleFonts.poppins()),
        Expanded(child: Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      ],
    );
  }
}