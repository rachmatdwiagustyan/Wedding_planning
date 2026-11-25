class PerbandinganModel {
  final int? id;
  final int userId;
  final String namaKebutuhan;
  final String namaVendor;
  final double hargaPenawaran;
  final double estimasiBiaya;
  final double hargaAktual;
  final double selisihHarga;
  final String? catatan;

  PerbandinganModel({
    this.id,
    required this.userId,
    required this.namaKebutuhan,
    required this.namaVendor,
    required this.hargaPenawaran,
    required this.estimasiBiaya,
    required this.hargaAktual,
    required this.selisihHarga,
    this.catatan,
  });

  factory PerbandinganModel.fromJson(Map<String, dynamic> json) {
    return PerbandinganModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      namaKebutuhan: json['nama_kebutuhan'] ?? '',
      namaVendor: json['nama_vendor'] ?? '',
      hargaPenawaran: double.tryParse(json['harga_penawaran']?.toString() ?? '0') ?? 0.0,
      estimasiBiaya: double.tryParse(json['estimasi_biaya']?.toString() ?? '0') ?? 0.0,
      hargaAktual: double.tryParse(json['harga_aktual']?.toString() ?? '0') ?? 0.0,
      selisihHarga: double.tryParse(json['selisih_harga']?.toString() ?? '0') ?? 0.0,
      catatan: json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nama_kebutuhan': namaKebutuhan,
      'nama_vendor': namaVendor,
      'harga_penawaran': hargaPenawaran,
      'estimasi_biaya': estimasiBiaya,
      'harga_aktual': hargaAktual,
      'selisih_harga': selisihHarga,
      'catatan': catatan ?? '',
    };
  }
}
