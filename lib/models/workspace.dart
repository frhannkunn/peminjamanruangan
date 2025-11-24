// lib/models/workspace.dart

import 'room.dart';
import 'workspace_detail.dart';

class Workspace {
  final int id;
  final String nomorWs;      // <-- Dari 'code'
  final String availability; // <-- Dari 'availability_text'
  final String tipeWs;       // <-- Dari 'type_text'
  
  final Room? room;
  final List<WorkspaceDetail>? details;

  Workspace({
    required this.id,
    required this.nomorWs,
    required this.availability,
    required this.tipeWs,
    this.room,
    this.details,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    Room? parsedRoom;
    if (json['room'] != null) {
      parsedRoom = Room.fromJson(json['room'] as Map<String, dynamic>);
    }

    List<WorkspaceDetail>? parsedDetails;
    if (json['details'] != null) {
      parsedDetails = (json['details'] as List)
          .map((detailJson) => WorkspaceDetail.fromJson(detailJson as Map<String, dynamic>))
          .toList();
    }

    return Workspace(
      id: json['id'],
      nomorWs: json['code'] ?? 'N/A', 
      availability: json['availability_text'] ?? 'Unknown',
      tipeWs: json['type_text'] ?? 'N/A', 
      room: parsedRoom,
      details: parsedDetails,
    );
  }

  // ✅ TAMBAHAN PENTING: Getter untuk tampilan di Dropdown
  String get displayName => "$nomorWs | $tipeWs";
}