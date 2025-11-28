import 'package:flutter/material.dart';
import 'loan_user.dart'; 

// --- EXISTING MODEL (JANGAN DIHAPUS) ---
class Pic {
  final String nik;
  final String name;
  final String email;
  final String? whatsapp;

  Pic({
    required this.nik,
    required this.name,
    required this.email,
    this.whatsapp,
  });

  factory Pic.fromJson(Map<String, dynamic> json) {
    return Pic(
      nik: json['nik'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      whatsapp: json['whatsapp'] as String?,
    );
  }
}

// --- NEW MODEL: UNTUK LIST DI HALAMAN APPROVAL PIC ---
// Nama Class diganti dari PeminjamanPj -> PeminjamanPic
class PeminjamanPic {
  String id;
  String ruangan;
  String status;
  String rawStatus;
  String tanggalPinjam;
  String jamKegiatan;
  String jenisKegiatan;
  String namaKegiatan;
  String namaPeminjam;

  PeminjamanPic({
    required this.id,
    required this.ruangan,
    required this.status,
    required this.rawStatus,
    required this.tanggalPinjam,
    required this.jamKegiatan,
    required this.jenisKegiatan,
    required this.namaKegiatan,
    required this.namaPeminjam,
  });

  factory PeminjamanPic.fromJson(Map<String, dynamic> json) {
    String mapActivity(dynamic type) {
      int t = int.tryParse(type.toString()) ?? 99;
      switch (t) {
        case 0: return 'Perkuliahan';
        case 1: return 'PBL';
        case 3: return 'Lainnya';
        default: return 'Lainnya';
      }
    }

    String mapStatus(dynamic s) {
      int statusId = int.tryParse(s.toString()) ?? 0;
      switch (statusId) {
        case 1: return "Menunggu Persetujuan Penanggung Jawab";
        case 2: return "Ditolak Penanggung Jawab";
        case 3: return "Menunggu Persetujuan PIC"; 
        case 4: return "Ditolak PIC";
        case 5: return "Disetujui";
        case 6: return "Selesai";
        case 7: return "Bermasalah";
        case 8: return "Expired";
        default: return "Status Tidak Diketahui";
      }
    }

    return PeminjamanPic(
      id: json['id'].toString(),
      ruangan: json['room'] != null 
          ? "${json['room']['code'] ?? ''} ${json['room']['name'] ?? ''}" 
          : "Unknown Room",
      status: mapStatus(json['status']),
      rawStatus: json['status'].toString(),
      tanggalPinjam: json['formatted_date'] ?? json['loan_date'] ?? '-',
      jamKegiatan: "${json['start_time']} - ${json['end_time']}",
      jenisKegiatan: mapActivity(json['activity_type']),
      namaKegiatan: json['activity_name'] ?? json['activity_description'] ?? '-',
      namaPeminjam: json['user'] != null ? json['user']['name'] : '-',
    );
  }

  Color get statusColor {
    if (['1', '3'].contains(rawStatus)) return const Color(0xFFFFC037); 
    if (['2', '4', '7'].contains(rawStatus)) return Colors.red; 
    if (rawStatus == '8') return Colors.grey; 
    if (['5', '6'].contains(rawStatus)) return const Color(0xFF00D800); 
    return Colors.blue; 
  }
}

// --- NEW MODEL: UNTUK DETAIL PAGE PIC ---
// Nama Class diganti dari PeminjamanPjDetailModel -> PeminjamanPicDetailModel
class PeminjamanPicDetailModel {
  String id;
  String jenisKegiatan;
  String namaKegiatan;
  String nimNip;
  String namaPengaju;
  String emailPengaju;
  String penanggungJawab;
  String tanggalPenggunaan;
  String ruangan;
  String jamMulai;
  String jamSelesai;
  
  List<LoanUser> listPengguna; 
  
  String status;
  String rawStatus; 
  
  String? picComment;
  String? picApprovalStatus;

  PeminjamanPicDetailModel({
    required this.id,
    required this.jenisKegiatan,
    required this.namaKegiatan,
    required this.nimNip,
    required this.namaPengaju,
    required this.emailPengaju,
    required this.penanggungJawab,
    required this.tanggalPenggunaan,
    required this.ruangan,
    required this.jamMulai,
    required this.jamSelesai,
    required this.listPengguna,
    required this.status,
    required this.rawStatus,
    this.picComment,
    this.picApprovalStatus,
  });

  factory PeminjamanPicDetailModel.fromJson(Map<String, dynamic> json) {
    String mapActivity(dynamic type) {
      int t = int.tryParse(type.toString()) ?? 99;
      switch (t) {
        case 0: return 'Perkuliahan';
        case 1: return 'PBL';
        case 3: return 'Lainnya';
        default: return 'Lainnya';
      }
    }

    String mapStatus(dynamic s) {
      int statusId = int.tryParse(s.toString()) ?? 0;
      switch (statusId) {
        case 1: return "Menunggu Persetujuan Penanggung Jawab";
        case 2: return "Ditolak Penanggung Jawab";
        case 3: return "Menunggu Persetujuan PIC";
        case 4: return "Ditolak PIC";
        case 5: return "Disetujui";
        case 6: return "Selesai";
        case 7: return "Peminjaman Bermasalah";
        case 8: return "Peminjaman Expired";
        default: return "Status Tidak Diketahui";
      }
    }
    
    return PeminjamanPicDetailModel(
      id: json['id'].toString(),
      jenisKegiatan: mapActivity(json['activity_type']),
      namaKegiatan: json['activity_name'] ?? json['activity_description'] ?? '-',
      nimNip: json['user']?['nik_nim'] ?? '-',
      namaPengaju: json['user']?['name'] ?? '-',
      emailPengaju: json['user']?['email'] ?? '-',
      penanggungJawab: json['lecture']?['name'] ?? '-', 
      tanggalPenggunaan: json['formatted_date'] ?? json['loan_date'] ?? '-',
      ruangan: json['room'] != null 
          ? "${json['room']['code'] ?? ''} ${json['room']['name'] ?? ''}" 
          : '-',
      jamMulai: json['start_time'] ?? '-',
      jamSelesai: json['end_time'] ?? '-',
      
      listPengguna: (json['loan_users'] as List?)
          ?.map((e) => LoanUser.fromJson(e)) 
          .toList() ?? [], 
          
      status: mapStatus(json['status']),
      rawStatus: json['status'].toString(),
      picComment: json['pic_comment'], 
      picApprovalStatus: json['pic_approval']?.toString(), 
    );
  }

  Color get statusColor {
    if (['1', '3'].contains(rawStatus)) return const Color(0xFFFFC037); 
    if (['2', '4', '7'].contains(rawStatus)) return Colors.red; 
    if (rawStatus == '8') return Colors.grey; 
    if (['5', '6'].contains(rawStatus)) return const Color(0xFF00D800); 
    return Colors.blue; 
  }
}