// lib/models/loan_user.dart

class LoanUser {
  final int id;
  final int loansId;
  final int workspacesId;
  final String jenisPengguna;
  final String namaPengguna;
  final String idCardPengguna;

  LoanUser({
    required this.id,
    required this.loansId,
    required this.workspacesId,
    required this.jenisPengguna,
    required this.namaPengguna,
    required this.idCardPengguna,
  });

  factory LoanUser.fromJson(Map<String, dynamic> json) {
    return LoanUser(
      id: json['id'],
      loansId: json['loans_id'],
      workspacesId: json['workspaces_id'],
      jenisPengguna: json['jenis_pengguna'],
      namaPengguna: json['nama_pengguna'],
      idCardPengguna: json['id_card_pengguna'],
    );
  }
}