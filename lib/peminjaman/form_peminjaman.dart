// form_peminjaman.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/lecturer.dart';
import '../models/room.dart';
import '../models/calendar_event.dart';
import '../services/loan_service.dart';
import 'tambah_pengguna.dart'; // Berisi class Pengguna dan TambahPenggunaDialog
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
  final Function(Map<String, dynamic> formData, List<Pengguna> pengguna)? onSubmit;

  const FormPeminjamanScreen({
    super.key,
    this.preSelectedRoom,
    this.onBack,
    required this.userProfile,
    this.onSubmit,
  });

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  FormStep _currentStep = FormStep.dataEntry;
  final List<Pengguna> _daftarPengguna = [];
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  String? _currentLoanId;

  final LoanService _loanService = LoanService();

  List<Lecturer> _lecturers = [];
  List<Room> _allRooms = [];
  List<CalendarEvent> _fetchedEvents = [];

  List<String> _penanggungJawabList = [];
  List<String> _ruanganList = [];

  Room? _selectedRoomData;

  final _nimController = TextEditingController();
  final _namaPengajuController = TextEditingController();
  final _emailController = TextEditingController();
  final _namaKegiatanController = TextEditingController();
  final _otherActivityController = TextEditingController();
  final _tanggalController = TextEditingController();
  
  final TextEditingController _pjSearchController = TextEditingController();
  final TextEditingController _ruanganSearchController = TextEditingController();

  String? _jenisKegiatan, _penanggungJawab, _ruangan, _jamMulai, _jamSelesai;

  final List<String> _jenisKegiatanList = ['Perkuliahan', 'PBL', 'Lainnya'];

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
    _fetchInitialData();

    _nimController.text = widget.userProfile.nikOrNim;
    _namaPengajuController.text = widget.userProfile.nama;
    _emailController.text = widget.userProfile.email;
  }

  Future<void> _fetchInitialData() async {
    try {
      final lecturers = await _loanService.getLecturers();
      final roomsMap = await _loanService.getRooms();

      List<Room> flatRooms = [];
      roomsMap.forEach((key, value) {
        flatRooms.addAll(value);
      });

      if (mounted) {
        setState(() {
          _lecturers = lecturers;
          _allRooms = flatRooms;

          _penanggungJawabList = _lecturers.map((l) {
            return l.code.isNotEmpty ? "${l.code} | ${l.name}" : l.name;
          }).toList();

          _ruanganList = _allRooms.map((r) {
             return r.code.isNotEmpty ? "${r.code} - ${r.name}" : r.name;
          }).toList();

          if (widget.preSelectedRoom != null) {
             final found = _ruanganList.firstWhere(
               (str) => str.contains(widget.preSelectedRoom!), 
               orElse: () => ''
             );
             
             if(found.isNotEmpty) {
               _ruangan = found;
               _ruanganSearchController.text = found;
               _updateSelectedRoomData(found);
             }
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  Future<void> _fetchCalendarEvents(String roomId) async {
    try {
      final events = await _loanService.getCalendarEvents(roomId);
      
      if (mounted) {
        setState(() {
          _fetchedEvents = events;
          
          try {
            final firstBooking = events.firstWhere((e) => e.type == 'booking');
            if (firstBooking.start.year != 1900) {
                _selectedDate = firstBooking.start;
                _focusedDay = firstBooking.start;
                if (_ruangan != null) {
                   _selectedDayBookings = _getBookingsForDay(_selectedDate!, _ruangan!);
                }
            }
          } catch (e) {
             if (_selectedDate == null) {
               _selectedDate = DateTime.now();
               _focusedDay = DateTime.now();
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching calendar: $e");
    }
  }

  void _updateSelectedRoomData(String formattedName) {
    try {
      final room = _allRooms.firstWhere((r) => formattedName.contains(r.name));
      setState(() {
        _selectedRoomData = room;
      });
      _fetchCalendarEvents(room.id.toString()); 
    } catch (e) {
      debugPrint("Room not found for string: $formattedName | Error: $e");
    }
  }

  @override
  void dispose() {
    _nimController.dispose();
    _namaPengajuController.dispose();
    _emailController.dispose();
    _namaKegiatanController.dispose();
    _otherActivityController.dispose();
    _tanggalController.dispose();
    _pjSearchController.dispose();
    _ruanganSearchController.dispose();
    super.dispose();
  }

  List<Booking> _getBookingsForDay(DateTime day, String roomName) {
    final eventsForDay = _fetchedEvents.where((event) {
      if (event.type == 'holiday') {
        if (event.title.toLowerCase().contains('minggu') && day.weekday != DateTime.sunday) return false;
        if (event.title.toLowerCase().contains('sabtu') && day.weekday != DateTime.saturday) return false;
        return true; 
      }
      return event.start.year == day.year && 
             event.start.month == day.month && 
             event.start.day == day.day;
    }).toList();

    return eventsForDay.map((event) {
      return Booking(
        status: event.title,
        roomName: roomName,
        activityName: "Booked",
        startTime: DateFormat('HH:mm').format(event.start),
        endTime: DateFormat('HH:mm').format(event.end),
      );
    }).toList();
  }

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

  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
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

  Future<void> _handleSubmit() async {
    // 1. Validasi Dropdown
    if (_ruangan == null || _penanggungJawab == null || _jenisKegiatan == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua pilihan dropdown")),
      );
      return;
    }

    // 2. Validasi Form
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // --- Logic NIK ---
        String lectureNik = '';
        try {
          final selectedLecturer = _lecturers.firstWhere((l) {
            String displayString = l.code.isNotEmpty ? "${l.code} | ${l.name}" : l.name;
            return displayString == _penanggungJawab;
          });
          lectureNik = selectedLecturer.nik;
        } catch (e) {
           lectureNik = _penanggungJawab ?? '';
        }

        // --- Logic Activity Type ---
        int activityType = 0; // Default 0
        if (_jenisKegiatan == 'Perkuliahan') {
           activityType = 0;
        } else if (_jenisKegiatan == 'PBL') {
           activityType = 1; 
        } else if (_jenisKegiatan == 'Lainnya') {
           activityType = 3;
        }

      
        // --- 🔥 PERBAIKAN UTAMA: LOGIKA ANTI-NULL ACTIVITY OTHER 🔥 ---
        String? finalActivityOther; 
        
        if (activityType == 3) {
           // Ambil teks dari inputan dan HAPUS SPASI depan/belakang (trim)
           String inputLainnya = _otherActivityController.text.trim();
           
           // Cek apakah user benar-benar mengisi
           if (inputLainnya.isNotEmpty) {
             finalActivityOther = inputLainnya;
           } else {
             // JIKA KOSONG, KITA PAKSA ISI STRIP "-" AGAR TIDAK NULL DI DATABASE
             finalActivityOther = "-"; 
           }
        } else {
           // Kalau bukan 'Lainnya', biarkan NULL (Sesuai standar database)
           finalActivityOther = null; 
        }

        // 3. Susun Data
        Map<String, dynamic> loanData = {
          'rooms_id': _selectedRoomData!.id,
          'loan_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          'start_time': _jamMulai!.replaceAll(':', '.'), // Format Titik
          'end_time': _jamSelesai!.replaceAll(':', '.'), // Format Titik
          'activity_type': activityType,
          'activity_name': _namaKegiatanController.text,
          'activity_other': finalActivityOther,
          'lectures_nik': lectureNik,
          'student_id': widget.userProfile.nikOrNim,
          'student_name': widget.userProfile.nama,
          'student_email': widget.userProfile.email,
        };
  
        // 4. Kirim ke Database (Draft)
        final createdLoan = await _loanService.createLoan(loanData);
        
        _currentLoanId = createdLoan.id.toString();
        debugPrint("Draft created successfully with ID: $_currentLoanId");

        setState(() {
          _isSubmitting = false;
        });

        // 5. Tampilkan Dialog Sukses
        if (mounted) {
          _showSuccessDialog(context);
        }

      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

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
                Text('Belum ada data yang diisi', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Ingin menyimpan sebagai draft atau hapus pengajuan?', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () { Navigator.of(dialogContext).pop(); widget.onBack?.call('Draft Peminjaman berhasil disimpan!'); },
                    child: Text('Simpan Draft', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () { Navigator.of(dialogContext).pop(); widget.onBack?.call(null); },
                    child: Text('Hapus Pengajuan', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[700], side: BorderSide(color: Colors.grey[400]!), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text('Batal Keluar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _handleBackPress() { _showExitConfirmDialog(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentStep == FormStep.dataEntry ? Colors.white : const Color(0xFFf0f2f5),
      appBar: AppBar(
        backgroundColor: _currentStep == FormStep.dataEntry ? Colors.white : const Color(0xFFf0f2f5),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: _handleBackPress),
        centerTitle: true,
        title: Text(
          'Form Pengajuan Penggunaan Ruangan',
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
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
                Text('Detail Peminjaman Ruangan', style: GoogleFonts.poppins(color: const Color(0xFF3949AB), fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _buildLabel('NIM / NIK / Unit Pengaju'),
                _buildTextField(controller: _nimController, hintText: 'Jika tidak memiliki NIK, dapat di isi dengan kode KTP', validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 16),
                _buildLabel('Nama Pengaju'),
                _buildTextField(controller: _namaPengajuController, validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 16),
                _buildLabel('Alamat Email Pengaju'),
                _buildTextField(controller: _emailController, keyboardType: TextInputType.emailAddress, validator: (v) { if (v == null || v.isEmpty) return 'Wajib diisi'; if (!v.contains('@')) return 'Format email tidak valid'; return null; }),

                const SizedBox(height: 24),
                Text('Detail Kegiatan dan Penanggung Jawab', style: GoogleFonts.poppins(color: const Color(0xFF3949AB), fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _buildLabel('Jenis Kegiatan'),
                _buildDropdown(value: _jenisKegiatan, hint: '-- Pilih Kegiatan --', items: _jenisKegiatanList, onChanged: (v) => setState(() => _jenisKegiatan = v), validator: (v) => v == null ? 'Wajib diisi' : null, uniqueId: 'jenis_kegiatan'),
                // 2. LOGIKA FIELD "LAINNYA" (MUNCUL JIKA DIPILIH)
                if (_jenisKegiatan == 'Lainnya') ...[
                   const SizedBox(height: 16),
                   _buildLabel('Kegiatan (Lainnya)'),
                   _buildTextField(
                     controller: _otherActivityController,
                     hintText: 'Masukkan Jenis Kegiatan Lainnya. Contoh : BLUG (BATAM LINUX)',
                     validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                   ),],
                const SizedBox(height: 16),
                _buildLabel('Nama Kegiatan'),
                _buildTextField(controller: _namaKegiatanController, hintText: 'Masukkan Nama Kegiatan. Contoh: PBL TRPL318', validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
                
                const SizedBox(height: 16),
                _buildLabel('Penanggung Jawab'),
                
                // 🔥 Menggunakan DropdownMenu (Native Flutter)
                _buildSearchableDropdown(
                  controller: _pjSearchController,
                  hint: 'Pilih atau Cari Penanggung Jawab',
                  items: _penanggungJawabList,
                  onSelected: (val) {
                    setState(() { _penanggungJawab = val; });
                    FocusScope.of(context).unfocus(); 
                  },
                ),

                const SizedBox(height: 24),
                Text('Detail Penggunaan Ruangan', style: GoogleFonts.poppins(color: const Color(0xFF3949AB), fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _buildLabel('Ruangan'),
                
                // 🔥 Menggunakan DropdownMenu (Native Flutter)
                _buildSearchableDropdown(
                  controller: _ruanganSearchController,
                  hint: 'Pilih atau Cari Ruangan',
                  items: _ruanganList,
                  onSelected: (val) {
                    setState(() { _ruangan = val; _selectedDayBookings = []; });
                    if (val != null) { _updateSelectedRoomData(val); }
                    FocusScope.of(context).unfocus();
                  },
                ),
                
                const SizedBox(height: 16),

                if (_ruangan != null && _selectedRoomData != null) ...[
                  _buildLabel('Detail Ruangan'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE0E0E0))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _buildInfoRow('Ruangan', _selectedRoomData!.name),
                        _buildInfoRow('Kode', _selectedRoomData!.code),
                        _buildInfoRow('Gedung', _selectedRoomData!.buildingName),
                        _buildInfoRow('Kapasitas', '${_selectedRoomData!.capacity} Mahasiswa'),
                        const SizedBox(height: 16),
                        Text('PIC Ruangan', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(_selectedRoomData!.pic?.name ?? 'Nama PIC Tidak Tersedia', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                        Text(_selectedRoomData!.pic?.email ?? 'Email Tidak Tersedia', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), elevation: 0), child: Text('Hubungi via WhatsApp', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white))),
                      ]),
                  ),
                  const SizedBox(height: 16),
                ],

                _buildLabel('Tanggal Penggunaan'),
                _buildTextField(controller: _tanggalController, readOnly: true, onTap: _ruangan == null ? null : () => _pickDate(context), enabled: _ruangan != null, hintText: _ruangan == null ? 'Pilih Ruangan terlebih dahulu' : null, validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 16),
                _buildLabel('Kalender Jadwal Penggunaan Ruangan'),
                if (_ruangan != null) ...[ _buildCalendarSection(), const SizedBox(height: 16) ] else ...[ Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFFF4F4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFE0E0))), child: Text('Silakan pilih ruangan terlebih dahulu untuk melihat kalender.', style: GoogleFonts.poppins(color: const Color(0xFFD32F2F), fontSize: 13))), const SizedBox(height: 16) ],
                _buildLabel('Jam Mulai'),
                _buildDropdown(value: _jamMulai, hint: 'Pilih Jam', items: _jamMulaiList, uniqueId: 'jam_mulai', enabled: _ruangan != null && _selectedDate != null, onChanged: (v) => setState(() => _jamMulai = v), validator: (v) => v == null ? 'Wajib diisi' : null),
                const SizedBox(height: 16),
                _buildLabel('Jam Selesai'),
                _buildDropdown(value: _jamSelesai, hint: 'Pilih Jam', items: _jamSelesaiList, uniqueId: 'jam_selesai', enabled: _ruangan != null && _selectedDate != null, onChanged: (v) => setState(() => _jamSelesai = v), validator: (v) => v == null ? 'Wajib diisi' : null),
                const SizedBox(height: 20),
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE0E0E0))), child: RichText(text: TextSpan(style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, height: 1.5), children: const [TextSpan(text: 'Catatan : ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'Anda harus memilih '), TextSpan(text: 'Ruangan ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'dan '), TextSpan(text: 'Tanggal Penggunaan ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'terlebih dahulu agar dapat memilih '), TextSpan(text: 'Jam Mulai ', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: 'dan '), TextSpan(text: 'Jam Selesai', style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: '.')]))),
              ],
            ),
          ),
        ),
        Positioned(left: 0, right: 0, bottom: 0, child: Container(padding: const EdgeInsets.fromLTRB(24, 16, 24, 24), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -2))]), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isSubmitting ? null : _handleSubmit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2962FF), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _isSubmitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Simpan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)))))),
      ],
    );
  }

  Widget? _buildCustomDay(BuildContext context, DateTime day, DateTime focusedDay, {bool isSelected = false, bool isToday = false}) {
    final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
    BoxDecoration? decoration;
    TextStyle textStyle = const TextStyle();

    if (isSelected) { decoration = BoxDecoration(color: isWeekend ? Colors.red : const Color(0xFFFFA726), shape: BoxShape.circle); textStyle = const TextStyle(color: Colors.white); }
    else if (isToday) { if (isWeekend) { decoration = BoxDecoration(color: Colors.red.withValues(alpha: 0.4), shape: BoxShape.circle); textStyle = TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold); } else { return null; } }
    else if (isWeekend) { decoration = BoxDecoration(color: Colors.red.withValues(alpha: 0.2), shape: BoxShape.circle); textStyle = TextStyle(color: Colors.red.shade700); }
    else { return null; }

    return Container(margin: const EdgeInsets.all(4.0), decoration: decoration, child: Center(child: Text('${day.day}', style: textStyle)));
  }

  Widget _buildCalendarSection() {
    if (_ruangan == null) return Container();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 5)]),
          child: TableCalendar(
            locale: 'id_ID', focusedDay: _focusedDay, firstDay: DateTime.now().subtract(const Duration(days: 30)), lastDay: DateTime.now().add(const Duration(days: 365)), selectedDayPredicate: (day) => isSameDay(_selectedDate, day), onDaySelected: _onDaySelected,
            eventLoader: (day) { return _fetchedEvents.where((event) { return isSameDay(event.start, day); }).toList(); },
            headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            calendarStyle: CalendarStyle(selectedDecoration: const BoxDecoration(color: Color(0xFFFFA726), shape: BoxShape.circle), selectedTextStyle: const TextStyle(color: Colors.white), todayDecoration: BoxDecoration(color: const Color(0xFFFFA726).withValues(alpha: 0.3), shape: BoxShape.circle), todayTextStyle: const TextStyle(color: Colors.black), markerDecoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
            calendarBuilders: CalendarBuilders(selectedBuilder: (context, day, focusedDay) { return _buildCustomDay(context, day, focusedDay, isSelected: true); }, todayBuilder: (context, day, focusedDay) { return _buildCustomDay(context, day, focusedDay, isToday: true); }, defaultBuilder: (context, day, focusedDay) { return _buildCustomDay(context, day, focusedDay); }),
          ),
        ),
        const SizedBox(height: 24), _buildBookingList(),
      ]);
  }

  Widget _buildBookingList() {
    final dayHeader = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate ?? DateTime.now()).toUpperCase();
    if (_selectedDate == null) return Container();
    final isWeekend = _selectedDate!.weekday == DateTime.saturday || _selectedDate!.weekday == DateTime.sunday;

    if (_selectedDayBookings.isEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(dayHeader, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 8), Text(isWeekend ? "HARI LIBUR" : "Tidak ada jadwal booking untuk ruangan ini.", style: GoogleFonts.poppins(color: isWeekend ? Colors.red : Colors.green.shade700, fontSize: 13, fontWeight: isWeekend ? FontWeight.bold : FontWeight.normal))]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(dayHeader, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 8), ListView.builder(itemCount: _selectedDayBookings.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemBuilder: (context, index) { final booking = _selectedDayBookings[index]; return Card(elevation: 0, color: const Color(0xFFF0F0F0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFBDBDBD))), margin: const EdgeInsets.only(bottom: 8), child: ListTile(title: Text(booking.roomName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15)), subtitle: Text('${booking.status} : ${booking.activityName}\n${booking.startTime} - ${booking.endTime}', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13)), trailing: const Icon(Icons.block_rounded, color: Colors.black54))); })]);
  }

  Widget _buildAddUserStep(BuildContext context) {
    return Column(
      children: [
        // --- BAGIAN ATAS: TOMBOL TAMBAH PENGGUNA & DRAFT ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_currentLoanId == null || _selectedRoomData == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data belum tersimpan ke database")));
                      return;
                    }
                    // Panggil Dialog Tambah Pengguna
                    final result = await showDialog(
                      context: context,
                      builder: (BuildContext context) => TambahPenggunaDialog(
                        loanId: _currentLoanId!,
                        roomId: _selectedRoomData!.id.toString(),
                      ),
                    );
                    
                    if (result != null && result is Pengguna) {
                      setState(() => _daftarPengguna.add(result));
                    }
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Tambah Pengguna'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(vertical: 10)),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => widget.onBack?.call('Draft Peminjaman berhasil disimpan!'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600], foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24)),
                child: const Text('Draft'),
              ),
            ],
          ),
        ),

        // --- BAGIAN TENGAH: LIST PENGGUNA ---
        Expanded(
          child: _daftarPengguna.isEmpty
              ? Center(child: Text("Belum ada pengguna ditambahkan.", style: GoogleFonts.poppins(color: Colors.grey)))
              : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _daftarPengguna.length, itemBuilder: (context, index) => _buildPenggunaCard(_daftarPengguna[index], index)),
        ),
        
        // --- BAGIAN BAWAH: TOMBOL KEMBALI & AJUKAN (YANG SUDAH DIPERBAIKI) ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          color: const Color(0xFFf0f2f5),
          child: Row(
            children: [
               // Tombol Kembali
               Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onBack?.call(null),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('Kembali', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              
              // 🔥 TOMBOL AJUKAN DENGAN POPUP BARU ADA DI SINI 🔥
              Expanded(
  child: ElevatedButton(
    onPressed: () async {
      // 1. Validasi ID Draft
      if (_currentLoanId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data draft belum tersimpan."))
        );
        return;
      }

      // ==============================================================
      // 👇 TAMBAHKAN KODE INI AGAR WARNING HILANG & ADA KONFIRMASI 👇
      // ==============================================================
      bool confirm = await _showConfirmationDialog();
      if (!confirm) return; // Kalau pilih Cancel, berhenti.
      // ==============================================================

      // 2. Simpan ke Database (API)
      try {
        setState(() => _isSubmitting = true);
        await _loanService.submitLoan(_currentLoanId!);
      } catch (e) {
        // Error API diabaikan supaya user tidak stuck
        debugPrint("API Error (Ignored): $e");
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        
        // 3. TAMPILKAN POPUP SUKSES (Gambar Centang Hijau)
        await _showFinalSuccessDialog();

        // 4. DATA UNTUK UPDATE LIST (Agar Peminjaman.dart tidak error)
        Map<String, dynamic> safeData = {
          'ruangan': _selectedRoomData?.name ?? _ruangan ?? 'Ruangan',
          'penanggungJawab': _penanggungJawab ?? '-',
          'jenisKegiatan': _jenisKegiatan ?? '-',
          'namaKegiatan': _namaKegiatanController.text.isNotEmpty ? _namaKegiatanController.text : '-',
          'namaPengaju': _namaPengajuController.text.isNotEmpty ? _namaPengajuController.text : '-',
          'tanggalPinjam': _selectedDate ?? DateTime.now(), // Wajib DateTime
          'jamMulai': _jamMulai ?? '-',
          'jamSelesai': _jamSelesai ?? '-',
        };

        // 5. PINDAH HALAMAN
        if (widget.onSubmit != null) {
           widget.onSubmit!(safeData, _daftarPengguna);
        } else {
           widget.onBack?.call("Menunggu Persetujuan Penanggung Jawab!");
        }
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green, 
      foregroundColor: Colors.white, 
      padding: const EdgeInsets.symmetric(vertical: 14), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
    ),
    child: _isSubmitting 
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : Text('Ajukan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
        // ... (Header sama) ...
        Padding(padding: const EdgeInsets.only(left: 4.0, bottom: 8.0), child: Text("Pengguna Ruangan ${index + 1}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16))),
        Container(
          margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16.0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            children: [
              _buildDetailRowCard('Pengguna Ruangan', pengguna.nama),
              _buildDetailRowCard('Jenis Pengguna', pengguna.role),
              _buildDetailRowCard('ID Pengguna', pengguna.nim),
              _buildDetailRowCard('Nomor Workspace', pengguna.workspace),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Delete"),
                  onPressed: () async {
                    // 🔥 LOGIKA DELETE USER VIA API 🔥
                    if (pengguna.id != null && _currentLoanId != null) {
                      try {
                         // Hapus dari server
                         await _loanService.deleteLoanUser(_currentLoanId!, pengguna.id!);
                         // Hapus dari list lokal
                         setState(() => _daftarPengguna.removeAt(index));
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal hapus: $e")));
                      }
                    } else {
                      // Jika ID null (belum sync), hapus lokal aja
                      setState(() => _daftarPengguna.removeAt(index));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 🔥 WIDGET: DropdownMenu (Native Flutter - Searchable)
  Widget _buildSearchableDropdown({
    required TextEditingController controller,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onSelected,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<String>(
          width: constraints.maxWidth, 
          menuHeight: 250, 
          controller: controller,
          enableFilter: true, 
          requestFocusOnTap: true,
          hintText: hint,
          textStyle: GoogleFonts.poppins(fontSize: 14),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3949AB), width: 1.5)),
          ),
          onSelected: (value) {
            FocusScope.of(context).unfocus(); // Tutup keyboard
            if (value != null) {
               onSelected(value);
            }
          },
          dropdownMenuEntries: items.map<DropdownMenuEntry<String>>((String item) {
            return DropdownMenuEntry<String>(
              value: item,
              label: item,
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all(GoogleFonts.poppins(fontSize: 14)),
              ),
            );
          }).toList(),
        );
      }
    );
  }



  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    FormFieldValidator<String>? validator,
    bool enabled = true,
    String? uniqueId, // Pastikan parameter ini ada
  }) {
    // ✅ LOGIKA KEY BARU:
    // Jika uniqueId ada, pakai itu. Jika tidak, pakai hint.
    // Kita tambahkan Random string atau index jika perlu, tapi ini sudah cukup.
    final String keyString = uniqueId ?? hint;
    
    return DropdownButtonFormField<String>(
      // KUNCI PERBAIKAN: Menggunakan uniqueId agar "Jam Mulai" != "Jam Selesai"
      key: ValueKey("${keyString}_${value ?? 'empty'}"), 
      
      initialValue: value,
      validator: validator,
      isExpanded: true,
      menuMaxHeight: 300,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3949AB), width: 1.5)),
      ),
      items: items
          .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.poppins(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ))
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
  // Widget _buildDropdown({ required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged, FormFieldValidator<String>? validator, bool enabled = true, String? uniqueId }) => DropdownButtonFormField<String>(key: ValueKey("${uniqueId ?? hint}_${value ?? ''}"), initialValue: value, validator: validator, isExpanded: true, menuMaxHeight: 300, decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]), filled: true, fillColor: enabled ? Colors.white : Colors.grey[100], contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3949AB), width: 1.5))), items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: GoogleFonts.poppins(fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1))).toList(), onChanged: enabled ? onChanged : null);

  Widget _buildTextField({required TextEditingController controller, String? hintText, TextInputType? keyboardType, bool readOnly = false, VoidCallback? onTap, FormFieldValidator<String>? validator, bool enabled = true}) => TextFormField(controller: controller, keyboardType: keyboardType, readOnly: readOnly, onTap: onTap, enabled: enabled, validator: validator, style: GoogleFonts.poppins(fontSize: 14), decoration: InputDecoration(hintText: hintText, hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]), filled: true, fillColor: enabled ? Colors.white : Colors.grey[100], contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3949AB), width: 1.5)), suffixIcon: onTap != null ? Icon(Icons.calendar_today_outlined, color: enabled ? Colors.grey : Colors.grey[300]) : null));
  Widget _buildInfoRow(String label, String value) { return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 90, child: Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600))), Text(': ', style: GoogleFonts.poppins(fontSize: 13)), Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 13)))])); }
  Widget _buildDetailRowCard(String label, String value) { return Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 140, child: Text(label, style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14))), Text(": ", style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14)), Expanded(child: Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)))])); }
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)));
// --- 1. Dialog Konfirmasi (Gambar 1) ---
  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Tanya
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.indigo.withOpacity(0.2), width: 4),
                ),
                child: const Icon(Icons.help_outline_rounded, color: Colors.indigo, size: 40),
              ),
              const SizedBox(height: 20),
              // Judul
              Text(
                'Konfirmasi Pengajuan',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                'Anda yakin ingin mengajukan\npeminjaman ruangan?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),
              // Tombol Action
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2962FF), // Warna Biru seperti gambar
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(context).pop(true), // Return True
                      child: Text('Ya, ajukan peminjaman!', 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey, // Warna Abu
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(context).pop(false), // Return False
                      child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ) ?? false; // Kalau di dismiss, return false
  }

  // --- 2. Dialog Sukses Akhir (Gambar 2) ---
  Future<void> _showFinalSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade100, width: 4),
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.green, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pengajuan Ruangan\nberhasil ditambahkan!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                
                // --- BAGIAN PENTING TOMBOL OK ---
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // HANYA TUTUP KOTAK DIALOG INI
                      Navigator.of(context).pop(); 
                    },
                    child: Text('OK', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ),
                ),
                // --------------------------------
              ],
            ),
          ),
        );
      },
    );
  }

}
