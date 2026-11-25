class TamuModel {
  final int? id;
  final int userId;
  final String namaTamu;
  final String? nomorTelepon;
  final String kategori;
  final int jumlahOrang;
  final String? alamat;
  final String statusUndangan;
  final String konfirmasiKehadiran;

  TamuModel({
    this.id,
    required this.userId,
    required this.namaTamu,
    this.nomorTelepon,
    required this.kategori,
    required this.jumlahOrang,
    this.alamat,
    required this.statusUndangan,
    required this.konfirmasiKehadiran,
  });

  bool get isInvited => statusUndangan == 'Sudah Diundang';
  bool get isAttending => konfirmasiKehadiran == 'Hadir';

  factory TamuModel.fromJson(Map<String, dynamic> json) {
    return TamuModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      namaTamu: json['nama_tamu'] ?? '',
      nomorTelepon: json['nomor_telepon'],
      kategori: json['kategori'] ?? 'Keluarga',
      jumlahOrang: int.tryParse(json['jumlah_orang']?.toString() ?? '1') ?? 1,
      alamat: json['alamat'],
      statusUndangan: json['status_undangan'] ?? 'Belum Diundang',
      konfirmasiKehadiran: json['konfirmasi_kehadiran'] ?? 'Belum Konfirmasi',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nama_tamu': namaTamu,
      'nomor_telepon': nomorTelepon ?? '',
      'kategori': kategori,
      'jumlah_orang': jumlahOrang,
      'alamat': alamat ?? '',
      'status_undangan': statusUndangan,
      'konfirmasi_kehadiran': konfirmasiKehadiran,
    };
  }
}
