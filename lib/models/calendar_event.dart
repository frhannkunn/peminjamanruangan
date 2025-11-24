// lib/models/calendar_event.dart
import 'package:flutter/material.dart';

class CalendarEvent {
  final String title;
  final DateTime start;
  final DateTime end;
  final Color backgroundColor;
  final String type; 
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

    if (json['extendedProps'] != null) {
      if (json['extendedProps']['type'] == 'holiday') {
        type = 'holiday';
      }
    }
    if (json['daysOfWeek'] != null) {
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

  /// Helper konversi warna yang LEBIH KUAT
  static Color _hexToColor(String hexString) {
    String lowerHex = hexString.toLowerCase();
    
    // ✅ UPDATE: Tambahkan daftar warna teks
    if (lowerHex == 'red') return Colors.red;
    if (lowerHex == 'pink') return Colors.pink.shade100;
    if (lowerHex == 'orange') return Colors.orange; // Tambahan
    if (lowerHex == 'green') return Colors.green;   // Tambahan
    if (lowerHex == 'blue') return Colors.blue;
    if (lowerHex == '#3788d8') return Colors.blue;

    // Parsing Hex Code (#FF0000)
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));

    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.blue; // Default biru jika gagal parsing
    }
  }
}