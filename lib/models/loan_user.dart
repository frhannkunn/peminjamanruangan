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
      // ✅ PERBAIKAN UTAMA: Gunakan int.parse(...)
      // Ini mencegah error "String is not subtype of int"
      id: int.parse(json['id'].toString()),
      loansId: int.parse(json['loans_id'].toString()),
      workspacesId: int.parse(json['workspaces_id'].toString()),
      
      // Handle null safety untuk String
      jenisPengguna: json['jenis_pengguna'] ?? '',
      namaPengguna: json['nama_pengguna'] ?? '',
      idCardPengguna: json['id_card_pengguna'] ?? '',
    );
  }
}