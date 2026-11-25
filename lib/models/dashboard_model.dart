import 'user_model.dart';
import 'pasangan_model.dart';
import 'jadwal_model.dart';
import 'pengingat_model.dart';

class DashboardModel {
  final UserModel? user;
  final PasanganModel? pasangan;
  final int? countdownDays;
  final int overallProgress;

  // Anggaran
  final double totalEstimasi;
  final double totalAktual;
  final double selisihAnggaran;

  // Dokumen
  final int totalDokumen;
  final int dokumenLengkap;
  final int persenDokumen;

  // Tugas
  final int totalTugas;
  final int tugasSelesai;
  final int tugasBelumSelesai;
  final int persenTugas;

  // Vendor & Tamu & Kebutuhan
  final int totalVendor;
  final int vendorDipesan;
  final int totalUndangan;
  final int totalTamu;
  final int tamuHadir;
  final int totalKebutuhan;
  final int kebutuhanDibeli;

  // Lists
  final List<JadwalModel> jadwalTerdekat;
  final List<PengingatModel> pengingatAktif;

  DashboardModel({
    this.user,
    this.pasangan,
    this.countdownDays,
    required this.overallProgress,
    required this.totalEstimasi,
    required this.totalAktual,
    required this.selisihAnggaran,
    required this.totalDokumen,
    required this.dokumenLengkap,
    required this.persenDokumen,
    required this.totalTugas,
    required this.tugasSelesai,
    required this.tugasBelumSelesai,
    required this.persenTugas,
    required this.totalVendor,
    required this.vendorDipesan,
    required this.totalUndangan,
    required this.totalTamu,
    required this.tamuHadir,
    required this.totalKebutuhan,
    required this.kebutuhanDibeli,
    required this.jadwalTerdekat,
    required this.pengingatAktif,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] ?? json;

    final uJson = data['user'];
    final pJson = data['pasangan'];
    final angJson = data['anggaran'] ?? {};
    final dokJson = data['dokumen'] ?? {};
    final tugJson = data['tugas'] ?? {};
    final venJson = data['vendor'] ?? {};
    final tamJson = data['tamu'] ?? {};
    final kebJson = data['kebutuhan'] ?? {};

    final List jList = data['jadwal_terdekat'] ?? [];
    final List pList = data['pengingat_aktif'] ?? [];

    return DashboardModel(
      user: uJson != null ? UserModel.fromJson(uJson) : null,
      pasangan: pJson != null ? PasanganModel.fromJson(pJson) : null,
      countdownDays: data['countdown_days'] != null
          ? int.tryParse(data['countdown_days'].toString())
          : null,
      overallProgress: int.tryParse(data['overall_progress']?.toString() ?? '0') ?? 0,
      totalEstimasi: double.tryParse(angJson['total_estimasi']?.toString() ?? '0') ?? 0.0,
      totalAktual: double.tryParse(angJson['total_aktual']?.toString() ?? '0') ?? 0.0,
      selisihAnggaran: double.tryParse(angJson['selisih']?.toString() ?? '0') ?? 0.0,
      totalDokumen: int.tryParse(dokJson['total']?.toString() ?? '0') ?? 0,
      dokumenLengkap: int.tryParse(dokJson['lengkap']?.toString() ?? '0') ?? 0,
      persenDokumen: int.tryParse(dokJson['persen']?.toString() ?? '0') ?? 0,
      totalTugas: int.tryParse(tugJson['total']?.toString() ?? '0') ?? 0,
      tugasSelesai: int.tryParse(tugJson['selesai']?.toString() ?? '0') ?? 0,
      tugasBelumSelesai: int.tryParse(tugJson['belum_selesai']?.toString() ?? '0') ?? 0,
      persenTugas: int.tryParse(tugJson['persen']?.toString() ?? '0') ?? 0,
      totalVendor: int.tryParse(venJson['total']?.toString() ?? '0') ?? 0,
      vendorDipesan: int.tryParse(venJson['dipesan']?.toString() ?? '0') ?? 0,
      totalUndangan: int.tryParse(tamJson['total_undangan']?.toString() ?? '0') ?? 0,
      totalTamu: int.tryParse(tamJson['total_tamu']?.toString() ?? '0') ?? 0,
      tamuHadir: int.tryParse(tamJson['tamu_hadir']?.toString() ?? '0') ?? 0,
      totalKebutuhan: int.tryParse(kebJson['total']?.toString() ?? '0') ?? 0,
      kebutuhanDibeli: int.tryParse(kebJson['dibeli']?.toString() ?? '0') ?? 0,
      jadwalTerdekat: jList.map((e) => JadwalModel.fromJson(e)).toList(),
      pengingatAktif: pList.map((e) => PengingatModel.fromJson(e)).toList(),
    );
  }
}
