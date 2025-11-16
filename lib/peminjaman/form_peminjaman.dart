// form_peminjaman.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'tambah_pengguna.dart';
import '../services/user_session.dart';


enum FormStep { dataEntry, addUser }


class Booking {
  final String status;
  final String roomName;
  final String activityName;
  final String startTime;
  final String endTime;

  Booking({
    required this.status,
    required this.roomName,
    required this.activityName,
    required this.startTime,
    required this.endTime,
  });
}

class FormPeminjamanScreen extends StatefulWidget {
  final String? preSelectedRoom;
  final Function(String? message)? onBack;
  
  final UserProfile userProfile;

  // ➕ 1. TAMBAHKAN CALLBACK BARU UNTUK SUBMIT
  final Function(Map<String, dynamic> formData, List<Pengguna> pengguna)? onSubmit;

  const FormPeminjamanScreen({
    super.key,
    this.preSelectedRoom,
    this.onBack,
    required this.userProfile,
    this.onSubmit, // ⬅️ Tambahkan di constructor
  });

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  FormStep _currentStep = FormStep.dataEntry;
  final List<Pengguna> _daftarPengguna = [];
  final _formKey = GlobalKey<FormState>();

  // ➕ 2. TAMBAHKAN VARIABEL UNTUK MENYIMPAN DATA FORM DARI STEP 1
  Map<String, dynamic>? _savedFormData;

  final _nimController = TextEditingController();
  final _namaPengajuController = TextEditingController();
  final _emailController = TextEditingController();
  final _namaKegiatanController = TextEditingController();
  final _tanggalController = TextEditingController();
  String? _jenisKegiatan, _penanggungJawab, _ruangan, _jamMulai, _jamSelesai;
  final List<String> _jenisKegiatanList = ['Perkuliahan', 'PBL', 'Lainnya'];
  final List<String> _penanggungJawabList = ['Dosen A', 'Dosen B', 'Dosen C'];
  final List<String> _ruanganList = [
    'Workspace (TA.12.3b)',
    'Lab Komputer',
    'Ruang Seminar',
  ];
  final List<String> _jamMulaiList = [
    '07:50', '08:40', '09:30', '10:20', '11:10', '12:00', '12:50',
    '13:40', '14:30', '15:20', '16:10', '17:00', '18:00', '18:50',
    '19:40', '20:30', '21:20', '22:10', '23:00'
  ];
  final List<String> _jamSelesaiList = [
    '08:40', '09:30', '10:20', '11:10', '12:00', '12:50', '13:40',
    '14:30', '15:20', '16:10', '17:00', '18:00', '18:50', '19:40',
    '20:30', '21:20', '22:10', '23:00'
  ];

  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  List<Booking> _selectedDayBookings = [];

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    if (widget.preSelectedRoom != null &&
        _ruanganList.contains(widget.preSelectedRoom)) {
      _ruangan = widget.preSelectedRoom;
    }

    // ✏️ 2. REVISI BAGIAN INI
    _nimController.text = widget.userProfile.nikOrNim; // ⬅️ Ganti dari .nim
    _namaPengajuController.text = widget.userProfile.nama;
    _emailController.text = widget.userProfile.email;
  }

  // (Fungsi dispose tidak berubah)
  @override
  void dispose() {
    _nimController.dispose();
    _namaPengajuController.dispose();
    _emailController.dispose();
    _namaKegiatanController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  // (Fungsi _getBookingsForDay tidak berubah)
  List<Booking> _getBookingsForDay(DateTime day, String roomName) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);

    final Map<DateTime, List<Booking>> allBookingsMock = {
      DateTime.utc(2025, 11, 5): [
        Booking(
          status: 'PBL',
          roomName: 'Workspace (TA.12.3b)',
          activityName: 'PBL TRPL318',
          startTime: '07:50',
          endTime: '09:30',
        ),
        Booking(
          status: 'Perkuliahan',
          roomName: 'Lab Komputer',
          activityName: 'Praktikum Jaringan Komputer',
          startTime: '13:40',
          endTime: '15:20',
        ),
      ],
      DateTime.utc(2025, 11, 6): [
        Booking(
          status: 'PBL',
          roomName: 'Workspace (TA.12.3b)',
          activityName: 'KERJA KELOMPOK',
          startTime: '07:50',
          endTime: '08:40',
        ),
        Booking(
          status: 'Perkuliahan',
          roomName: 'Workspace (TA.12.3b)',
          activityName: 'Kelas Pengganti Basis Data',
          startTime: '09:30',
          endTime: '11:10',
        ),
      ],
    };

    final bookingsForDay = allBookingsMock[normalizedDay] ?? [];
    return bookingsForDay.where((b) => b.roomName == roomName).toList();
  }

  // (Fungsi _onDaySelected tidak berubah)
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDate, selectedDay)) {
      setState(() {
        _selectedDate = selectedDay;
        _focusedDay = focusedDay;
        _tanggalController.text = DateFormat('d/M/y').format(selectedDay);
        if (_ruangan != null) {
          _selectedDayBookings = _getBookingsForDay(selectedDay, _ruangan!);
        }
      });
    }
  }

  // (Fungsi _pickDate tidak berubah)
  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _focusedDay = date;
        _tanggalController.text = DateFormat('d/M/y').format(date);
        if (_ruangan != null) {
          _selectedDayBookings = _getBookingsForDay(date, _ruangan!);
        }
      });
    }
  }

  // (Fungsi _showSuccessDialog tidak berubah)
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

  // ✏️ 3. MODIFIKASI _handleSubmit UNTUK MENYIMPAN DATA
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Simpan data form ke variabel state
      setState(() {
        _savedFormData = {
          'ruangan': _ruangan!,
          'penanggungJawab': _penanggungJawab!,
          'jenisKegiatan': _jenisKegiatan!,
          'namaKegiatan': _namaKegiatanController.text,
          'namaPengaju': _namaPengajuController.text,
          'tanggalPinjam': _selectedDate!,
          'jamMulai': _jamMulai!,
          'jamSelesai': _jamSelesai!,
        };
      });

      // Tampilkan dialog sukses, yang akan mengubah step ke addUser
      _showSuccessDialog(context);
    }
  }

  // (Fungsi _showExitConfirmDialog tidak berubah)
  Future<void> _showExitConfirmDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange.shade300, width: 3)),
                  child: Icon(Icons.priority_high_rounded,
                      color: Colors.orange.shade600, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada data yang diisi',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingin menyimpan sebagai draft atau hapus pengajuan?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      widget.onBack?.call('Draft Peminjaman berhasil disimpan!');
                    },
                    child: Text('Simpan Draft',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      widget.onBack?.call(null);
                    },
                    child: Text('Hapus Pengajuan',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(),
                    child: Text('Batal Keluar',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // (Fungsi _handleBackPress tidak berubah)
  void _handleBackPress() {
    _showExitConfirmDialog();
  }

  // --- TIDAK ADA PERUBAHAN DESAIN DI BAWAH INI ---
  // (Semua widget build Anda tidak berubah)
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
          onPressed:
              _handleBackPress,
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
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Nama Pengaju'),
                _buildTextField(
                  controller: _namaPengajuController,
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Alamat Email Pengaju'),
                _buildTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
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
                  validator: (v) => v == null ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Nama / Deskripsi Kegiatan'),
                _buildTextField(
                  controller: _namaKegiatanController,
                  hintText: 'Masukkan Nama Kegiatan. Contoh: PBL TRPL318',
                  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Penanggung Jawab'),
                _buildDropdown(
                  value: _penanggungJawab,
                  hint: 'Pilih Penanggung Jawab',
                  items: _penanggungJawabList,
                  onChanged: (v) => setState(() => _penanggungJawab = v),
                  validator: (v) => v == null ? 'Wajib diisi' : null,
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
                  onChanged: (v) => setState(() {
                    _ruangan = v;
                    if (_selectedDate != null && v != null) {
                      _selectedDayBookings =
                          _getBookingsForDay(_selectedDate!, v);
                    }
                  }),
                  validator: (v) => v == null ? 'Wajib diisi' : null,
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
                  onTap: _ruangan == null ? null : () => _pickDate(context),
                  enabled: _ruangan != null,
                  hintText: _ruangan == null ? 'Pilih Ruangan terlebih dahulu' : null,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Kalender Jadwal Penggunaan Ruangan'),
                if (_ruangan != null) ...[
                  _buildCalendarSection(),
                  const SizedBox(height: 16),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE0E0)),
                    ),
                    child: Text(
                      'Silakan pilih ruangan terlebih dahulu untuk melihat kalender.',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFD32F2F),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildLabel('Jam Mulai'),
                _buildDropdown(
                  value: _jamMulai,
                  hint: 'Pilih Jam',
                  items: _jamMulaiList,
                  enabled: _ruangan != null && _selectedDate != null,
                  onChanged: (v) => setState(() => _jamMulai = v),
                  validator: (v) => v == null ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Jam Selesai'),
                _buildDropdown(
                  value: _jamSelesai,
                  hint: 'Pilih Jam',
                  items: _jamSelesaiList,
                  enabled: _ruangan != null && _selectedDate != null,
                  onChanged: (v) => setState(() => _jamSelesai = v),
                  validator: (v) => v == null ? 'Wajib diisi' : null,
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

  Widget? _buildCustomDay(BuildContext context, DateTime day, DateTime focusedDay,
      {bool isSelected = false, bool isToday = false}) {
    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    BoxDecoration? decoration;
    TextStyle textStyle = const TextStyle();

    if (isSelected) {
      decoration = BoxDecoration(
        color: isWeekend ? Colors.red : const Color(0xFFFFA726),
        shape: BoxShape.circle,
      );
      textStyle = const TextStyle(color: Colors.white);
    } else if (isToday) {
      if (isWeekend) {
        decoration = BoxDecoration(
          color: Colors.red.withOpacity(0.4),
          shape: BoxShape.circle,
        );
        textStyle =
            TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold);
      } else {
        return null;
      }
    } else if (isWeekend) {
      decoration = BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        shape: BoxShape.circle,
      );
      textStyle = TextStyle(color: Colors.red.shade700);
    } else {
      return null;
    }

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: decoration,
      child: Center(
        child: Text(
          '${day.day}',
          style: textStyle,
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    if (_ruangan == null) {
      return Container();
    }

    if (_selectedDate == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBE6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFE58F)),
        ),
        child: Text(
          'Silakan pilih tanggal penggunaan pada field di atas.',
          style: GoogleFonts.poppins(
            color: const Color(0xFFD97706),
            fontSize: 13,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: TableCalendar(
            locale: 'id_ID',
            focusedDay: _focusedDay,
            firstDay: DateTime.now().subtract(const Duration(days: 30)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: _onDaySelected,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: Color(0xFFFFA726),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: const Color(0xFFFFA726).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: Colors.black),
            ),
            calendarBuilders: CalendarBuilders(
              selectedBuilder: (context, day, focusedDay) {
                return _buildCustomDay(context, day, focusedDay,
                    isSelected: true);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildCustomDay(context, day, focusedDay, isToday: true);
              },
              defaultBuilder: (context, day, focusedDay) {
                return _buildCustomDay(context, day, focusedDay);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildBookingList(),
      ],
    );
  }

  Widget _buildBookingList() {
    final dayHeader = DateFormat('EEEE, d MMMM yyyy', 'id_ID')
        .format(_selectedDate!)
        .toUpperCase();

    final isWeekend = _selectedDate!.weekday == DateTime.saturday ||
        _selectedDate!.weekday == DateTime.sunday;

    if (_selectedDayBookings.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dayHeader,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Text(
            isWeekend
                ? "HARI LIBUR"
                : "Tidak ada jadwal booking untuk ruangan ini.",
            style: GoogleFonts.poppins(
                color: isWeekend ? Colors.red : Colors.green.shade700,
                fontSize: 13,
                fontWeight: isWeekend ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dayHeader,
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        ListView.builder(
          itemCount: _selectedDayBookings.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final booking = _selectedDayBookings[index];
            return Card(
              elevation: 0,
              color: const Color(0xFFF0F0F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFFBDBDBD)),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  booking.roomName,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 15),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: '${booking.status} : ',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: booking.activityName,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.startTime} - ${booking.endTime}',
                      style: GoogleFonts.poppins(
                          color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
                trailing: const Icon(
                  Icons.block_rounded,
                  color: Colors.black54,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ✏️ 4. MODIFIKASI _buildAddUserStep
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
                    if (result != null) {
                      setState(() => _daftarPengguna.add(result));
                    }
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
                  // ✏️ 5. GANTI onPressed UNTUK MEMANGGIL CALLBACK 'onSubmit'
                  onPressed: () {
                    // Pastikan data form sudah tersimpan
                    if (_savedFormData != null) {
                      // Panggil callback onSubmit dengan data form dan daftar pengguna
                      widget.onSubmit?.call(
                        _savedFormData!,
                        _daftarPengguna,
                      );
                    } else {
                      // Fallback jika terjadi error (seharusnya tidak terjadi)
                      widget.onBack?.call('Error: Data form tidak ditemukan.');
                    }
                  },
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
              ),
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

  Widget _buildLabel(String text) {
    return Padding(
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
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        enabled: enabled,
        validator: validator,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          suffixIcon: onTap != null
              ? Icon(Icons.calendar_today_outlined,
                  color: enabled ? Colors.grey : Colors.grey[300])
              : null,
        ),
      );

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) =>
      DropdownButtonFormField<String>(
        value: value,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        onChanged: enabled ? onChanged : null,
      );

  Widget _buildInfoRow(String label, String value) {
    return Padding(
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
}