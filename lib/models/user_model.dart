class UserModel {
  final int id;
  final String namaLengkap;
  final String email;
  final String? foto;

  UserModel({
    required this.id,
    required this.namaLengkap,
    required this.email,
    this.foto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      namaLengkap: json['nama_lengkap'] ?? '',
      email: json['email'] ?? '',
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'email': email,
      'foto': foto,
    };
  }
}
