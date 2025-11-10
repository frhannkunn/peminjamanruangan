// lib/models/workspace.dart

// ➕ 1. IMPORT MODEL LAIN YANG DIBUTUHKAN
import 'room.dart';
import 'workspace_detail.dart';

class Workspace {
  final int id;
  // ♻️ 2. DISESUAIKAN DENGAN API CONTROLLER
  final String nomorWs;       // <-- Dari 'code' di JSON
  final String availability;  // <-- Dari 'availability_text' di JSON
  final String tipeWs;        // <-- Dari 'type_text' di JSON
  
  // ➕ 3. FIELD TAMBAHAN UNTUK DETAIL (bisa null)
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

  // ♻️ 4. FACTORY CONSTRUCTOR DIPERBARUI TOTAL
  factory Workspace.fromJson(Map<String, dynamic> json) {
    
    // 4a. Parse 'room' jika ada
    Room? parsedRoom;
    if (json['room'] != null) {
      parsedRoom = Room.fromJson(json['room'] as Map<String, dynamic>);
    }

    // 4b. Parse 'details' jika ada (sesuai model workspace_detail.dart Anda)
    List<WorkspaceDetail>? parsedDetails;
    if (json['details'] != null) {
      parsedDetails = (json['details'] as List)
          .map((detailJson) => WorkspaceDetail.fromJson(detailJson as Map<String, dynamic>))
          .toList();
    }

    // 4c. Kembalikan object Workspace
    return Workspace(
      id: json['id'],
      
      // ♻️ Sesuai dengan ApiWorkspaceController.php
      nomorWs: json['code'] ?? 'N/A', 
      availability: json['availability_text'] ?? 'Unknown',
      tipeWs: json['type_text'] ?? 'N/A', 
      
      // ➕ Kembalikan data yang sudah diparsing
      room: parsedRoom,
      details: parsedDetails,
    );
  }
}