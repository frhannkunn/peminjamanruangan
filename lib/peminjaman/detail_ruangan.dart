// peminjaman/detail_ruangan.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ➕ IMPORT PACKAGE KALENDER & FORMAT TANGGAL
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../models/room.dart';
import '../models/workspace.dart';
import '../models/calendar_event.dart'; // ➕ Model Event
import '../services/room_service.dart';
import '../services/loan_service.dart'; // ➕ Service Loan

class DetailRuanganScreen extends StatefulWidget {
  final Room ruanganData;
  final VoidCallback onBack;
  final Function(String)? onShowForm;

  const DetailRuanganScreen({
    super.key,
    required this.ruanganData,
    required this.onBack,
    this.onShowForm,
  });

  @override
  State<DetailRuanganScreen> createState() => _DetailRuanganScreenState();
}

class _DetailRuanganScreenState extends State<DetailRuanganScreen> {
  // SERVICES
  late final RoomService _roomService;
  late final LoanService _loanService; // ➕ Service untuk kalender

  // STATE DATA
  Future<List<Workspace>>? _workspacesFuture;
  List<CalendarEvent> _calendarEvents = []; // ➕ Data Event Kalender
  bool _isLoadingCalendar = true;

  // STATE KALENDER
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // ➕ CONTROLLER UNTUK SCROLL OTOMATIS
  final ScrollController _scrollController = ScrollController();
  // ➕ KEY UNTUK MENANDAI LOKASI KALENDER
  final GlobalKey _calendarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _roomService = RoomService();
    _loanService = LoanService(); // ➕ Init LoanService
    
    _loadWorkspaces();
    _loadCalendarEvents(); // ➕ Load Data Kalender
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ➕ Hapus controller saat close
    super.dispose();
  }

  void _loadWorkspaces() {
    setState(() {
      _workspacesFuture = _roomService.getWorkspacesForRoom(widget.ruanganData.id);
    });
  }

  // ➕ FUNGSI LOAD KALENDER DARI API
  Future<void> _loadCalendarEvents() async {
    try {
      final events = await _loanService.getCalendarEvents(widget.ruanganData.id.toString());
      if (!mounted) return;
      setState(() {
        _calendarEvents = events;
        _isLoadingCalendar = false;
      });
    } catch (e) {
      print("Error loading calendar: $e");
      if (mounted) {
      setState(() => _isLoadingCalendar = false);
    }
  }
  }

  // ➕ FUNGSI FILTER EVENT BERDASARKAN TANGGAL
  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _calendarEvents.where((event) {
      // Cek apakah 'day' berada di antara start dan end event
      // Normalisasi tanggal agar jam tidak berpengaruh (hanya tgl/bln/thn)
      final normalizedDay = DateTime(day.year, day.month, day.day);
      final startDate = DateTime(event.start.year, event.start.month, event.start.day);
      final endDate = DateTime(event.end.year, event.end.month, event.end.day);

      return (normalizedDay.isAtSameMomentAs(startDate) || normalizedDay.isAfter(startDate)) &&
             (normalizedDay.isAtSameMomentAs(endDate) || normalizedDay.isBefore(endDate));
    }).toList();
  }

  // ➕ FUNGSI SCROLL KE BAWAH
  void _scrollToCalendar() {
    // Scrollable.ensureVisible akan mencari widget dengan key _calendarKey
    // dan menggulung layar sampai widget itu terlihat
    Scrollable.ensureVisible(
      _calendarKey.currentContext!,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(
          "Detail Ruangan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        controller: _scrollController, // ➕ PASANG CONTROLLER DISINI
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- 1. GAMBAR RUANGAN ---
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/room.jpg",
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. INFO RUANGAN & TOMBOL ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                   BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfo("Gedung", widget.ruanganData.building),
                  _buildInfo("Nama Ruangan", widget.ruanganData.name),
                  _buildInfo("Kode Ruangan", widget.ruanganData.code),
                  _buildInfo("Kapasitas", "${widget.ruanganData.capacity} orang"),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (widget.onShowForm != null) {
                              widget.onShowForm!(widget.ruanganData.name);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "Borang Ruangan",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),

                        // ♻️ TOMBOL CEK KETERSEDIAAN (DENGAN SCROLL)
                        OutlinedButton(
                          onPressed: _scrollToCalendar, // 👈 PANGGIL FUNGSI SCROLL
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF1565C0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "Cek Ketersediaan Ruangan",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // --- 3. INFO PIC RUANGAN ---
            _buildPicInfo(),

            const SizedBox(height: 20),

            // --- 4. LIST WORKSPACE ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "List Workspace Ruangan",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Temukan workspace yang mendukung produktivitasmu.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  FutureBuilder<List<Workspace>>(
                    future: _workspacesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Gagal memuat: ${snapshot.error}'));
                      }
                      final List<Workspace> workspaces = snapshot.data ?? [];
                      if (workspaces.isEmpty) {
                        return const Center(child: Text('Tidak ada Workspace'));
                      }
                      return Column(
                        children: [
                          _buildWorkspaceHeader(),
                          const Divider(),
                          ...workspaces.map((ws) => _buildWorkspaceRow(ws, context)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =========================================================
            // ➕ 5. KALENDER KETERSEDIAAN (PALING BAWAH)
            // =========================================================
            Container(
              key: _calendarKey, // 👈 KEY PENTING UNTUK SCROLL TARGET
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Color(0xFF1565C0)),
                      const SizedBox(width: 8),
                      Text(
                        "Jadwal Pemakaian",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  
                  if (_isLoadingCalendar)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(),
                    ))
                  else
                    TableCalendar<CalendarEvent>(
                      firstDay: DateTime.utc(2020, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      
                      // 1. Memuat Event ke Kalender
                      eventLoader: _getEventsForDay,
                      
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      
                      // 2. Style Kalender
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF1565C0),
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Colors.redAccent, // Warna titik event
                          shape: BoxShape.circle,
                        ),
                      ),
                      
                      // 3. Header Style
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                      ),

                      // 4. Interaksi
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),

                  const SizedBox(height: 16),
                  
                  // 5. LIST EVENT DETAIL DI BAWAH KALENDER (Jika tanggal dipilih)
                  if (_selectedDay != null) ...[
                    Text(
                      "Jadwal pada ${DateFormat('dd MMMM yyyy').format(_selectedDay!)}:",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ..._getEventsForDay(_selectedDay!).map((event) => Card(
                      elevation: 0,
                      color: event.backgroundColor.withOpacity(0.1),
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: event.backgroundColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.access_time_filled, color: event.backgroundColor),
                        title: Text(
                          event.title,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          "${DateFormat('HH:mm').format(event.start)} - ${DateFormat('HH:mm').format(event.end)}",
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                    )),
                    if (_getEventsForDay(_selectedDay!).isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Tidak ada jadwal pada tanggal ini.",
                          style: GoogleFonts.poppins(color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                  ] else 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Pilih tanggal untuk melihat detail jam.",
                        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            
            // Memberi ruang ekstra di bawah agar scroll enak dilihat
            const SizedBox(height: 50), 
          ],
        ),
      ),
    );
  }

  // --- (Helper Widgets Lama Tetap Sama) ---
  
  Widget _buildPicInfo() {
    final bool hasPic = widget.ruanganData.pics.isNotEmpty;
    final picData = hasPic ? widget.ruanganData.pics.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PIC Ruangan",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 20),
          if (hasPic && picData != null) ...[
            Text(picData.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(picData.email, style: GoogleFonts.poppins(color: Colors.black54)),
            const SizedBox(height: 4),
            Text("WA: ${picData.whatsapp ?? '-'}", style: GoogleFonts.poppins(color: Colors.blue[600])),
          ] else ...[
            Text(
              "Tidak ada PIC Ruangan, harap menghubungi Tata Usaha untuk melakukan peminjaman.",
              style: GoogleFonts.poppins(color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ]
        ],
      ),
    );
  }
  
  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text("$label :", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14))),
          Expanded(flex: 3, child: Text(value, style: GoogleFonts.poppins(fontSize: 14))),
        ],
      ),
    );
  }

  static const int _flexID = 1;
  static const int _flexNomor = 3;
  static const int _flexAvail = 3;
  static const int _flexTipe = 3;
  static const int _flexAksi = 2;

  Widget _buildWorkspaceHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Row(
        children: [
          _headerItem("ID", _flexID, TextAlign.center),
          const SizedBox(width: 8),
          _headerItem("Nomor WS", _flexNomor, TextAlign.start),
          _headerItem("Availability", _flexAvail, TextAlign.center),
          _headerItem("Tipe WS", _flexTipe, TextAlign.center),
          _headerItem("Aksi", _flexAksi, TextAlign.center),
        ],
      ),
    );
  }

  Widget _headerItem(String text, int flex, TextAlign align) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        maxLines: 1,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
      ),
    );
  }

  Widget _buildWorkspaceRow(Workspace ws, BuildContext context) {
    final bool isTersedia = ws.availability.toLowerCase() == 'tersedia';
    final Color availBg = isTersedia ? const Color(0xFF12D41E) : Colors.red; 
    final Color availText = Colors.white;
    final bool isNonPc = ws.tipeWs.toLowerCase().contains('non');
    final Color tipeBg = isNonPc ? const Color(0xFFF096F8) : const Color(0xFF0B2A97);
    final Color tipeText = Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(flex: _flexID, child: Text(ws.id.toString(), textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
          const SizedBox(width: 8),
          Expanded(flex: _flexNomor, child: Text(ws.nomorWs, textAlign: TextAlign.start, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: _flexAvail, child: Center(child: _buildBadge(ws.availability, availBg, availText))),
          Expanded(flex: _flexTipe, child: Center(child: _buildBadge(ws.tipeWs, tipeBg, tipeText))),
          Expanded(
            flex: _flexAksi,
            child: Center(
              child: SizedBox(
                height: 30, width: 70,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5AA2FF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Detail", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color textColor) {
    return Container(
      constraints: const BoxConstraints(minWidth: 70), 
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, textAlign: TextAlign.center, maxLines: 1, style: GoogleFonts.poppins(color: textColor, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}