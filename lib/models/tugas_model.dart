class TugasModel {
  final int? id;
  final int userId;
  final String namaTugas;
  final String kategori;
  final String tenggatWaktu;
  final String penanggungJawab;
  final String status;
  final String? catatan;

  TugasModel({
    this.id,
    required this.userId,
    required this.namaTugas,
    required this.kategori,
    required this.tenggatWaktu,
    required this.penanggungJawab,
    required this.status,
    this.catatan,
  });

  bool get isDone => status == 'Selesai';

  factory TugasModel.fromJson(Map<String, dynamic> json) {
    return TugasModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      namaTugas: json['nama_tugas'] ?? '',
      kategori: json['kategori'] ?? 'Umum',
      tenggatWaktu: json['tenggat_waktu'] ?? '',
      penanggungJawab: json['penanggung_jawab'] ?? 'Keduanya',
      status: json['status'] ?? 'Belum Selesai',
      catatan: json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nama_tugas': namaTugas,
      'kategori': kategori,
      'tenggat_waktu': tenggatWaktu,
      'penanggung_jawab': penanggungJawab,
      'status': status,
      'catatan': catatan ?? '',
    };
  }
}
