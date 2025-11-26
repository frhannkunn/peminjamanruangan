class LoanUser {
  final int id;
  final int loansId;
  final int workspacesId;
  final String jenisPengguna;
  final String namaPengguna;
  final String idCardPengguna;
  final String? workspaceCode;
  final String? workspaceType;

  LoanUser({
    required this.id,
    required this.loansId,
    required this.workspacesId,
    required this.jenisPengguna,
    required this.namaPengguna,
    required this.idCardPengguna,
    this.workspaceCode,
    this.workspaceType,
  });

  factory LoanUser.fromJson(Map<String, dynamic> json) {
    // Logika ambil workspace (aman jika null)
    String? code;
    String? type;

    if (json['workspace'] != null) {
      // Tambahkan .toString() di sini juga untuk jaga-jaga
      code = json['workspace']['code']?.toString() ?? json['workspace']['name']?.toString();
      type = json['workspace']['type']?.toString();
    }

    return LoanUser(
      // Parsing Integer (Sudah benar)
      id: int.parse(json['id'].toString()),
      loansId: int.parse(json['loans_id'].toString()),
      workspacesId: int.parse(json['workspaces_id'].toString()),

      // ✅ PERBAIKAN DI SINI:
      // Tambahkan .toString() pada semua field String.
      // Ini memaksa angka (misal: 5353544) diubah jadi teks "5353544" agar tidak error.
      jenisPengguna: json['jenis_pengguna']?.toString() ?? '',
      namaPengguna: json['nama_pengguna']?.toString() ?? '',
      idCardPengguna: json['id_card_pengguna']?.toString() ?? '', 

      workspaceCode: code,
      workspaceType: type,
    );
  }
}