import 'package:flutter/material.dart';
// Pastikan import ini benar
import '../../models/loan_user.dart'; 

// --- MODEL UNTUK LIST DI HOME ---
class PeminjamanPj {
  String id;
  String ruangan;
  String status;
  String rawStatus;
  String tanggalPinjam;
  String jamKegiatan;
  String jenisKegiatan;
  String namaKegiatan;

  PeminjamanPj({
    required this.id,
    required this.ruangan,
    required this.status,
    required this.rawStatus,
    required this.tanggalPinjam,
    required this.jamKegiatan,
    required this.jenisKegiatan,
    required this.namaKegiatan,
  });

  factory PeminjamanPj.fromJson(Map<String, dynamic> json) {
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
        case 2: return "Ditolak";
        case 3: return "Menunggu Persetujuan PIC"; 
        case 4: return "Disetujui PIC";
        case 5: return "Disetujui";
        case 6: return "Digunakan";
        case 8: return "Peminjaman Expired";
        default: return "Status Tidak Diketahui";
      }
    }

    return PeminjamanPj(
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
    );
  }
}

// --- MODEL UNTUK DETAIL PAGE ---
class PeminjamanPjDetailModel {
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
  
  // PERBAIKAN 1: Ubah tipe data jadi List<LoanUser>
  List<LoanUser> listPengguna; 
  
  String status;
  String rawStatus; 
  
  PeminjamanPjDetailModel({
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
  });

  factory PeminjamanPjDetailModel.fromJson(Map<String, dynamic> json) {
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

    
    return PeminjamanPjDetailModel(
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
      
      // Logic Parsing yang Benar
      listPengguna: (json['loan_users'] as List?)
          ?.map((e) => LoanUser.fromJson(e)) // Panggil model LoanUser
          .toList() ?? [], 
          
      status: mapStatus(json['status']),
      rawStatus: json['status'].toString(),
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