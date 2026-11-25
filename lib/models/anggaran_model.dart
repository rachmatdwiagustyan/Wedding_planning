class AnggaranModel {
  final int? id;
  final int userId;
  final String kategori;
  final String namaKebutuhan;
  final String? namaVendor;
  final double estimasiBiaya;
  final double biayaAktual;
  final String statusPembayaran;
  final String penanggungJawab;
  final String? catatan;

  AnggaranModel({
    this.id,
    required this.userId,
    required this.kategori,
    required this.namaKebutuhan,
    this.namaVendor,
    required this.estimasiBiaya,
    required this.biayaAktual,
    required this.statusPembayaran,
    required this.penanggungJawab,
    this.catatan,
  });

  double get selisih => estimasiBiaya - biayaAktual;

  factory AnggaranModel.fromJson(Map<String, dynamic> json) {
    return AnggaranModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      kategori: json['kategori']?.toString() ?? '',
      namaKebutuhan: json['nama_kebutuhan']?.toString() ?? '',
      namaVendor: json['nama_vendor']?.toString(),
      estimasiBiaya: double.tryParse(json['estimasi_biaya']?.toString() ?? '0') ?? 0.0,
      biayaAktual: double.tryParse(json['biaya_aktual']?.toString() ?? '0') ?? 0.0,
      statusPembayaran: json['status_pembayaran']?.toString() ?? 'Belum Dibayar',
      penanggungJawab: json['penanggung_jawab']?.toString() ?? 'Keduanya',
      catatan: json['catatan']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'kategori': kategori,
      'nama_kebutuhan': namaKebutuhan,
      if (namaVendor != null) 'nama_vendor': namaVendor,
      'estimasi_biaya': estimasiBiaya,
      'biaya_aktual': biayaAktual,
      'status_pembayaran': statusPembayaran,
      'penanggung_jawab': penanggungJawab,
      if (catatan != null) 'catatan': catatan,
    };
  }

  AnggaranModel copyWith({
    int? id,
    int? userId,
    String? kategori,
    String? namaKebutuhan,
    String? namaVendor,
    double? estimasiBiaya,
    double? biayaAktual,
    String? statusPembayaran,
    String? penanggungJawab,
    String? catatan,
  }) {
    return AnggaranModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      kategori: kategori ?? this.kategori,
      namaKebutuhan: namaKebutuhan ?? this.namaKebutuhan,
      namaVendor: namaVendor ?? this.namaVendor,
      estimasiBiaya: estimasiBiaya ?? this.estimasiBiaya,
      biayaAktual: biayaAktual ?? this.biayaAktual,
      statusPembayaran: statusPembayaran ?? this.statusPembayaran,
      penanggungJawab: penanggungJawab ?? this.penanggungJawab,
      catatan: catatan ?? this.catatan,
    );
  }
}
