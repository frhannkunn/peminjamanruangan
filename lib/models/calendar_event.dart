// lib/models/calendar_event.dart
import 'package:flutter/material.dart';

class CalendarEvent {
  final String title;
  final DateTime start;
  final DateTime end;
  final Color backgroundColor;
  final String type; // 'booking' atau 'holiday'
  final bool isAllDay;

  CalendarEvent({
    required this.title,
    required this.start,
    required this.end,
    required this.backgroundColor,
    required this.type,
    this.isAllDay = false,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    String type = 'booking';
    bool allDay = json['allDay'] ?? false;
    
    // Cek apakah ini event liburan dari extendedProps
    if (json['extendedProps'] != null) {
      if (json['extendedProps']['type'] == 'holiday') {
        type = 'holiday';
      }
    }

    // Jika ini event 'daysOfWeek', kita tandai sebagai allDay
    // dan set tanggalnya ke placeholder (TableCalendar akan menanganinya)
    if(json['daysOfWeek'] != null) {
      allDay = true;
    }

    return CalendarEvent(
      title: json['title'] ?? 'Booked',
      start: DateTime.tryParse(json['start'] ?? '') ?? DateTime.now(),
      end: DateTime.tryParse(json['end'] ?? '') ?? DateTime.now(),
      backgroundColor: _hexToColor(json['backgroundColor'] ?? '#3788d8'),
      type: type,
      isAllDay: allDay,
    );
  }

  /// Helper untuk konversi string warna (misal: "#FF0000" atau "red")
  static Color _hexToColor(String hexString) {
    // Tangani nama warna umum
    String lowerHex = hexString.toLowerCase();
    if (lowerHex == 'red') return Colors.red;
    if (lowerHex == 'pink') return Colors.pink.shade100;
    if (lowerHex == '#3788d8') return Colors.blue;
    
    // Tangani kode hex
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey; // Default color jika parsing gagal
    }
  }
}