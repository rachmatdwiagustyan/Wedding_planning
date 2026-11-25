class PasanganModel {
  final int? id;
  final int userId;
  final String namaWanita;
  final String namaPria;
  final String? fotoPasangan;
  final String tanggalPernikahan;
  final String lokasiPernikahan;
  final String alamatAcara;

  PasanganModel({
    this.id,
    required this.userId,
    required this.namaWanita,
    required this.namaPria,
    this.fotoPasangan,
    required this.tanggalPernikahan,
    required this.lokasiPernikahan,
    required this.alamatAcara,
  });

  factory PasanganModel.fromJson(Map<String, dynamic> json) {
    return PasanganModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      namaWanita: json['nama_wanita'] ?? '',
      namaPria: json['nama_pria'] ?? '',
      fotoPasangan: json['foto_pasangan'],
      tanggalPernikahan: json['tanggal_pernikahan'] ?? '',
      lokasiPernikahan: json['lokasi_pernikahan'] ?? '',
      alamatAcara: json['alamat_acara'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nama_wanita': namaWanita,
      'nama_pria': namaPria,
      'foto_pasangan': fotoPasangan ?? '',
      'tanggal_pernikahan': tanggalPernikahan,
      'lokasi_pernikahan': lokasiPernikahan,
      'alamat_acara': alamatAcara,
    };
  }
}
