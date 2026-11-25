class DokumenModel {
  final int? id;
  final int userId;
  final int nomorDokumen;
  final String namaDokumen;
  final String penanggungJawab;
  final String statusKelengkapan;
  final String? tanggalDisiapkan;
  final String? catatan;

  DokumenModel({
    this.id,
    required this.userId,
    required this.nomorDokumen,
    required this.namaDokumen,
    required this.penanggungJawab,
    required this.statusKelengkapan,
    this.tanggalDisiapkan,
    this.catatan,
  });

  bool get isComplete =>
      statusKelengkapan == 'Sudah Disiapkan' || statusKelengkapan == 'Sudah Lengkap';

  factory DokumenModel.fromJson(Map<String, dynamic> json) {
    return DokumenModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      nomorDokumen: int.tryParse(json['nomor_dokumen']?.toString() ?? '1') ?? 1,
      namaDokumen: json['nama_dokumen'] ?? '',
      penanggungJawab: json['penanggung_jawab'] ?? 'Keduanya',
      statusKelengkapan: json['status_kelengkapan'] ?? 'Belum Disiapkan',
      tanggalDisiapkan: json['tanggal_disiapkan'],
      catatan: json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nomor_dokumen': nomorDokumen,
      'nama_dokumen': namaDokumen,
      'penanggung_jawab': penanggungJawab,
      'status_kelengkapan': statusKelengkapan,
      'tanggal_disiapkan': tanggalDisiapkan,
      'catatan': catatan ?? '',
    };
  }

  DokumenModel copyWith({
    int? id,
    int? userId,
    int? nomorDokumen,
    String? namaDokumen,
    String? penanggungJawab,
    String? statusKelengkapan,
    String? tanggalDisiapkan,
    String? catatan,
  }) {
    return DokumenModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nomorDokumen: nomorDokumen ?? this.nomorDokumen,
      namaDokumen: namaDokumen ?? this.namaDokumen,
      penanggungJawab: penanggungJawab ?? this.penanggungJawab,
      statusKelengkapan: statusKelengkapan ?? this.statusKelengkapan,
      tanggalDisiapkan: tanggalDisiapkan ?? this.tanggalDisiapkan,
      catatan: catatan ?? this.catatan,
    );
  }
}
