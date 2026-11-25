class JadwalModel {
  final int? id;
  final int userId;
  final String namaKegiatan;
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final String lokasi;
  final String penanggungJawab;
  final bool statusSelesai;
  final String? catatan;

  JadwalModel({
    this.id,
    required this.userId,
    required this.namaKegiatan,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.lokasi,
    required this.penanggungJawab,
    required this.statusSelesai,
    this.catatan,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    final dynamic st = json['status_selesai'];
    final bool isDone = (st == 1 || st == '1' || st == true);

    return JadwalModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      namaKegiatan: json['nama_kegiatan'] ?? '',
      tanggal: json['tanggal'] ?? '',
      jamMulai: json['jam_mulai'] ?? '08:00',
      jamSelesai: json['jam_selesai'] ?? '10:00',
      lokasi: json['lokasi'] ?? '',
      penanggungJawab: json['penanggung_jawab'] ?? 'Keduanya',
      statusSelesai: isDone,
      catatan: json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nama_kegiatan': namaKegiatan,
      'tanggal': tanggal,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'lokasi': lokasi,
      'penanggung_jawab': penanggungJawab,
      'status_selesai': statusSelesai ? 1 : 0,
      'catatan': catatan ?? '',
    };
  }
}
