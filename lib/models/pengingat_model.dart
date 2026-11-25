class PengingatModel {
  final int? id;
  final int userId;
  final String judul;
  final String tipe;
  final String tanggalPengingat;
  final String jamPengingat;
  final String status;
  final String? catatan;

  PengingatModel({
    this.id,
    required this.userId,
    required this.judul,
    required this.tipe,
    required this.tanggalPengingat,
    required this.jamPengingat,
    required this.status,
    this.catatan,
  });

  bool get isActive => status == 'Aktif';

  factory PengingatModel.fromJson(Map<String, dynamic> json) {
    return PengingatModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      judul: json['judul'] ?? '',
      tipe: json['tipe'] ?? 'Tenggat Waktu',
      tanggalPengingat: json['tanggal_pengingat'] ?? '',
      jamPengingat: json['jam_pengingat'] ?? '08:00:00',
      status: json['status'] ?? 'Aktif',
      catatan: json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'judul': judul,
      'tipe': tipe,
      'tanggal_pengingat': tanggalPengingat,
      'jam_pengingat': jamPengingat,
      'status': status,
      'catatan': catatan ?? '',
    };
  }
}
