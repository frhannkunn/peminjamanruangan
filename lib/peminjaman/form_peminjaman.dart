import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_pengguna.dart'; // Pastikan path ini benar

enum FormStep { dataEntry, addUser }

class FormPeminjamanScreen extends StatefulWidget {
  final String? preSelectedRoom;
  final Function(String? message)? onBack;

  const FormPeminjamanScreen({Key? key, this.preSelectedRoom, this.onBack})
    : super(key: key);

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  FormStep _currentStep = FormStep.dataEntry;
  final List<Pengguna> _daftarPengguna = [];
  final _formKey = GlobalKey<FormState>();

  // Controllers & State
  final _nimController = TextEditingController();
  final _namaPengajuController = TextEditingController();
  final _emailController = TextEditingController();
  final _namaKegiatanController = TextEditingController();
  final _tanggalController = TextEditingController();
  String? _jenisKegiatan, _penanggungJawab, _ruangan, _jamMulai, _jamSelesai;
  final List<String> _jenisKegiatanList = ['Perkuliahan', 'PBL'];
  final List<String> _penanggungJawabList = ['Dosen A', 'Dosen B', 'Dosen C'];
  final List<String> _ruanganList = [
    'Workspace (TA.12.3b)',
    'Lab Komputer',
    'Ruang Seminar',
  ];
  final List<String> _jamList = [
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedRoom != null &&
        _ruanganList.contains(widget.preSelectedRoom)) {
      _ruangan = widget.preSelectedRoom;
    }
  }

  @override
  void dispose() {
    _nimController.dispose();
    _namaPengajuController.dispose();
    _emailController.dispose();
    _namaKegiatanController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 20),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: const Icon(Icons.check, color: Colors.green, size: 40),
                ),
                const SizedBox(height: 24),
                Text(
                  'Draft Peminjaman\nberhasil disimpan!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      setState(() => _currentStep = FormStep.addUser);
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _showSuccessDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentStep == FormStep.dataEntry
          ? Colors.white
          : const Color(0xFFf0f2f5),
      appBar: AppBar(
        backgroundColor: _currentStep == FormStep.dataEntry
            ? Colors.white
            : const Color(0xFFf0f2f5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => widget.onBack != null
              ? widget.onBack!(null)
              : Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Form Pengajuan Penggunaan Ruangan',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _currentStep == FormStep.dataEntry
          ? _buildDataEntryStep(context)
          : _buildAddUserStep(context),
    );
  }

  Widget _buildDataEntryStep(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Konten form (tidak diubah)
                Text(
                  'Detail Peminjaman Ruangan',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3949AB),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabel('NIM / NIK / Unit Pengaju'),
                _buildTextField(
                  controller: _nimController,
                  hintText:
                      'Jika tidak memiliki NIK, dapat di isi dengan kode KTP',
                ),
                const SizedBox(height: 16),
                _buildLabel('Nama Pengaju'),
                _buildTextField(controller: _namaPengajuController),
                const SizedBox(height: 16),
                _buildLabel('Alamat Email Pengaju'),
                _buildTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                Text(
                  'Detail Kegiatan dan Penanggung Jawab',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3949AB),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabel('Jenis Kegiatan'),
                _buildDropdown(
                  value: _jenisKegiatan,
                  hint: 'Perkuliahan',
                  items: _jenisKegiatanList,
                  onChanged: (v) => setState(() => _jenisKegiatan = v),
                ),
                const SizedBox(height: 16),
                _buildLabel('Nama Kegiatan'),
                _buildTextField(
                  controller: _namaKegiatanController,
                  hintText: 'Masukkan Nama Kegiatan. Contoh: PBL TRPL318',
                ),
                const SizedBox(height: 16),
                _buildLabel('Penanggung Jawab'),
                _buildDropdown(
                  value: _penanggungJawab,
                  hint: 'Pilih Penanggung Jawab',
                  items: _penanggungJawabList,
                  onChanged: (v) => setState(() => _penanggungJawab = v),
                ),
                const SizedBox(height: 24),
                Text(
                  'Detail Penggunaan Ruangan',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3949AB),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabel('Ruangan'),
                _buildDropdown(
                  value: _ruangan,
                  hint: 'Pilih Ruangan',
                  items: _ruanganList,
                  onChanged: (v) => setState(() => _ruangan = v),
                ),
                const SizedBox(height: 16),
                if (_ruangan != null) ...[
                  _buildLabel('Detail Ruangan'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Ruangan', 'Workspace (TA.12.3b)'),
                        _buildInfoRow('Gedung', 'Tower A'),
                        _buildInfoRow('Kapasitas', '45 Mahasiswa'),
                        const SizedBox(height: 16),
                        Text(
                          'PIC Ruangan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Iqbal Afif, A.Md.Kom',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'iqbal@polibatam.ac.id',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Hubungi via WhatsApp',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildLabel('Tanggal Penggunaan'),
                _buildTextField(
                  controller: _tanggalController,
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null)
                      _tanggalController.text =
                          '${date.day}/${date.month}/${date.year}';
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('Kalender Jadwal Penggunaan Ruangan'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4F4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE0E0)),
                  ),
                  child: Text(
                    'Silakan pilih ruangan dan tanggal terlebih dahulu.',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD32F2F),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabel('Jam Mulai'),
                _buildDropdown(
                  value: _jamMulai,
                  hint: 'Pilih Jam',
                  items: _jamList,
                  onChanged: (v) => setState(() => _jamMulai = v),
                ),
                const SizedBox(height: 16),
                _buildLabel('Jam Selesai'),
                _buildDropdown(
                  value: _jamSelesai,
                  hint: 'Pilih Jam',
                  items: _jamList,
                  onChanged: (v) => setState(() => _jamSelesai = v),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Catatan : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: 'Anda harus memilih '),
                        TextSpan(
                          text: 'Ruangan ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: 'dan '),
                        TextSpan(
                          text: 'Tanggal Penggunaan ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: 'terlebih dahulu agar dapat memilih '),
                        TextSpan(
                          text: 'Jam Mulai ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: 'dan '),
                        TextSpan(
                          text: 'Jam Selesai',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Simpan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddUserStep(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog<Pengguna>(
                      context: context,
                      builder: (BuildContext context) =>
                          const TambahPenggunaDialog(),
                    );
                    if (result != null)
                      setState(() => _daftarPengguna.add(result));
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Tambah Pengguna'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () =>
                    widget.onBack?.call('Draft Peminjaman berhasil disimpan!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 24,
                  ),
                ),
                child: const Text('Draft'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari Pengguna...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: _daftarPengguna.isEmpty
              ? Center(
                  child: Text(
                    "Belum ada pengguna ditambahkan.",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _daftarPengguna.length,
                  itemBuilder: (context, index) =>
                      _buildPenggunaCard(_daftarPengguna[index], index),
                ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          color: const Color(0xFFf0f2f5),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onBack?.call(null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kembali',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      widget.onBack?.call('Peminjaman berhasil diajukan!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Ajukan',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- KARTU PENGGUNA DENGAN DESAIN BARU ---
  Widget _buildPenggunaCard(Pengguna pengguna, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            "Pengguna Ruangan ${index + 1}",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildDetailRowCard('Pengguna Ruangan', pengguna.nama),
              _buildDetailRowCard('Jenis Pengguna', pengguna.role),
              _buildDetailRowCard('ID Pengguna', pengguna.nim),
              _buildDetailRowCard(
                'Nomor Workspace',
                pengguna.workspace,
              ), // Menampilkan string lengkap
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Delete"),
                  onPressed: () =>
                      setState(() => _daftarPengguna.removeAt(index)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          Text(
            ": ",
            style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper lama
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    ),
  );
  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    readOnly: readOnly,
    onTap: onTap,
    style: GoogleFonts.poppins(fontSize: 14),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3949AB), width: 1.5),
      ),
    ),
  );
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) => DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3949AB), width: 1.5),
      ),
    ),
    items: items
        .map(
          (String item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: GoogleFonts.poppins(fontSize: 14)),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );
  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(': ', style: GoogleFonts.poppins(fontSize: 13)),
        Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 13))),
      ],
    ),
  );
}
