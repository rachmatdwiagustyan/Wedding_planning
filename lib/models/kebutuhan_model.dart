class KebutuhanModel {
  final int? id;
  final int userId;
  final String namaBarang;
  final String kategori;
  final int jumlah;
  final double hargaSatuan;
  final double totalHarga;
  final String penanggungJawab;
  final String statusPembelian;
  final String? catatan;

  KebutuhanModel({
    this.id,
    required this.userId,
    required this.namaBarang,
    required this.kategori,
    required this.jumlah,
    required this.hargaSatuan,
    required this.totalHarga,
    required this.penanggungJawab,
    required this.statusPembelian,
    this.catatan,
  });

  bool get isPurchased => statusPembelian == 'Sudah Dibeli';

  factory KebutuhanModel.fromJson(Map<String, dynamic> json) {
    final int qty = int.tryParse(json['jumlah']?.toString() ?? '1') ?? 1;
    final double unitPrice = double.tryParse(json['harga_satuan']?.toString() ?? '0') ?? 0.0;
    final double total = double.tryParse(json['total_harga']?.toString() ?? '') ?? (qty * unitPrice);

    return KebutuhanModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      namaBarang: json['nama_barang'] ?? '',
      kategori: json['kategori'] ?? 'Umum',
      jumlah: qty,
      hargaSatuan: unitPrice,
      totalHarga: total,
      penanggungJawab: json['penanggung_jawab'] ?? 'Keduanya',
      statusPembelian: json['status_pembelian'] ?? 'Belum Dibeli',
      catatan: json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nama_barang': namaBarang,
      'kategori': kategori,
      'jumlah': jumlah,
      'harga_satuan': hargaSatuan,
      'total_harga': totalHarga,
      'penanggung_jawab': penanggungJawab,
      'status_pembelian': statusPembelian,
      'catatan': catatan ?? '',
    };
  }
}
