class CatatanModel {
  final int? id;
  final int userId;
  final String judul;
  final String isi;
  final String kategori;
  final String? createdAt;

  CatatanModel({
    this.id,
    required this.userId,
    required this.judul,
    required this.isi,
    required this.kategori,
    this.createdAt,
  });

  factory CatatanModel.fromJson(Map<String, dynamic> json) {
    return CatatanModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      kategori: json['kategori'] ?? 'Umum',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'judul': judul,
      'isi': isi,
      'kategori': kategori,
    };
  }
}
