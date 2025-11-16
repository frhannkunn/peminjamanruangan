// lib/models/loan.dart

import 'loan_user.dart';

class Loan {
  final int id;
  final int roomsId;
  final String lecturesNik;
  final int activityType;
  final String activityName;
  final String loanDate; // Format "Y-m-d"
  final String startTime; // Format "H:i:s"
  final String endTime; // Format "H:i:s"
  final String studentId;
  final String studentName;
  final String studentEmail;
  final int status;
  final List<LoanUser>? loanUsers; // Hanya ada saat memanggil getLoanDetail

  Loan({
    required this.id,
    required this.roomsId,
    required this.lecturesNik,
    required this.activityType,
    required this.activityName,
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
    // Cek jika ada relasi 'loan_users' (dari fungsi 'show')
    var usersList = json['loan_users'] as List?;
    List<LoanUser>? users;
    if (usersList != null) {
      users = usersList.map((i) => LoanUser.fromJson(i)).toList();
    }

    return Loan(
      id: json['id'],
      roomsId: json['rooms_id'],
      lecturesNik: json['lectures_nik'],
      activityType: json['activity_type'],
      activityName: json['activity_name'],
      loanDate: json['loan_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      studentEmail: json['student_email'],
      status: json['status'],
      loanUsers: users,
    );
  }
}