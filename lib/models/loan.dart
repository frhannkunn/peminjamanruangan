import 'loan_user.dart';

class Loan {
  final int id;
  final int roomsId;
  
  // Kolom-kolom String
  final String lecturesNik;
  final String activityName;
  final String activityOther; 
  final String loanDate;
  final String startTime;
  final String endTime;
  final String studentId;
  final String studentName;
  final String studentEmail;
  
  // Kolom-kolom Integer
  final int activityType;
  final int status;
  
  // Relasi
  final List<LoanUser>? loanUsers;

  Loan({
    required this.id,
    required this.roomsId,
    required this.lecturesNik,
    required this.activityType,
    required this.activityName,
    required this.activityOther,
    required this.loanDate,
    required this.startTime,
    required this.endTime,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.status,
    this.loanUsers,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    // 1. Handle Relasi Users
    var usersList = json['loan_users'] as List?;
    List<LoanUser>? users;
    if (usersList != null) {
      users = usersList.map((i) => LoanUser.fromJson(i)).toList();
    }

    return Loan(
      // ✅ 2. Handle ANGKA (Mencegah error jika API kirim String "1" atau Null)
      id: int.tryParse(json['id'].toString()) ?? 0,
      roomsId: int.tryParse(json['rooms_id'].toString()) ?? 0,
      activityType: int.tryParse(json['activity_type'].toString()) ?? 0,
      status: int.tryParse(json['status'].toString()) ?? 0,

      // ✅ 3. Handle STRING (KUNCI PERBAIKAN ERROR ANDA)
      // Logika: json['key']?.toString() ?? ''
      // Artinya: Jika datanya NULL, ganti dengan string kosong ''
      
      lecturesNik: json['lectures_nik']?.toString() ?? '',
      activityName: json['activity_name']?.toString() ?? '',
      activityOther: json['activity_other']?.toString() ?? '', 
      loanDate: json['loan_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      studentEmail: json['student_email']?.toString() ?? '',
      
      loanUsers: users,
    );
  }
}