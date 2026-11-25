class VendorModel {
  final int? id;
  final int userId;
  final String namaVendor;
  final String kategori;
  final String? nomorTelepon;
  final String? alamat;
  final double hargaPenawaran;
  final String statusPemesanan;
  final String? catatan;

  VendorModel({
    this.id,
    required this.userId,
    required this.namaVendor,
    required this.kategori,
    this.nomorTelepon,
    this.alamat,
    required this.hargaPenawaran,
    required this.statusPemesanan,
    this.catatan,
  });

  bool get isBooked =>
      statusPemesanan == 'Sudah Dipesan' ||
      statusPemesanan == 'Selesai' ||
      statusPemesanan == 'Lunas';

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      namaVendor: json['nama_vendor'] ?? '',
      kategori: json['kategori'] ?? 'Lainnya',
      nomorTelepon: json['nomor_telepon'],
      alamat: json['alamat'],
      hargaPenawaran: double.tryParse(json['harga_penawaran']?.toString() ?? '0') ?? 0.0,
      statusPemesanan: json['status_pemesanan'] ?? 'Belum Dipesan',
      catatan: json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nama_vendor': namaVendor,
      'kategori': kategori,
      'nomor_telepon': nomorTelepon ?? '',
      'alamat': alamat ?? '',
      'harga_penawaran': hargaPenawaran,
      'status_pemesanan': statusPemesanan,
      'catatan': catatan ?? '',
    };
  }

  VendorModel copyWith({
    int? id,
    int? userId,
    String? namaVendor,
    String? kategori,
    String? nomorTelepon,
    String? alamat,
    double? hargaPenawaran,
    String? statusPemesanan,
    String? catatan,
  }) {
    return VendorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaVendor: namaVendor ?? this.namaVendor,
      kategori: kategori ?? this.kategori,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      alamat: alamat ?? this.alamat,
      hargaPenawaran: hargaPenawaran ?? this.hargaPenawaran,
      statusPemesanan: statusPemesanan ?? this.statusPemesanan,
      catatan: catatan ?? this.catatan,
    );
  }
}
