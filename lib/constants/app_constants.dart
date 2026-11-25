import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static const String appName = 'TALENTA EVENT ORGANIZER';
  static const String appTagline = 'Every Moment, Beautifully Planned.';

  // Default Base URL
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost/talenta_api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2/talenta_api';
      }
    } catch (_) {}
    return 'http://localhost/talenta_api';
  }

  // Kategori Anggaran
  static const List<String> kategoriAnggaran = [
    'Venue & Gedung',
    'Katering & Konsumsi',
    'Dekorasi',
    'Busana & Rias Pengantin',
    'Fotografi & Videografi',
    'Undangan & Souvenir',
    'Hiburan',
    'Transportasi',
    'Lainnya',
  ];

  // Kategori Kebutuhan
  static const List<String> kategoriKebutuhan = [
    'Semua',
    'Administrasi',
    'Pakaian & Rias',
    'Dekorasi & Perlengkapan',
    'Souvenir & Undangan',
    'Hantaran & Seserahan',
    'Logistik Acara',
    'Lainnya',
  ];

  // Kategori Vendor
  static const List<String> kategoriVendor = [
    'Katering',
    'Dekorasi',
    'Fotografer',
    'Gedung',
    'Makeup',
    'Busana',
    'Wedding Organizer',
    'Lainnya',
  ];

  // Status Vendor
  static const List<String> statusVendor = [
    'Belum Dipesan',
    'Sudah Dipesan',
    'Dibatalkan',
  ];

  // Kategori Tamu
  static const List<String> kategoriTamu = [
    'Semua',
    'Keluarga',
    'Sahabat & Teman',
    'Rekan Kerja',
    'VIP & Tokoh',
    'Tetangga',
    'Lainnya',
  ];

  // Penanggung Jawab
  static const List<String> penanggungJawab = [
    'Calon Pengantin Wanita',
    'Calon Pengantin Pria',
    'Keduanya',
  ];

  // Status Pembayaran
  static const List<String> statusPembayaran = [
    'Belum Dibayar',
    'Uang Muka',
    'Lunas',
  ];

  // Status Tugas
  static const List<String> statusTugas = [
    'Belum Selesai',
    'Selesai',
  ];

  // Status Dokumen
  static const List<String> statusDokumen = [
    'Belum Disiapkan',
    'Sudah Disiapkan',
  ];

  // Status Undangan
  static const List<String> statusUndangan = [
    'Belum Diundang',
    'Sudah Diundang',
  ];

  // Status Konfirmasi Kehadiran
  static const List<String> konfirmasiKehadiran = [
    'Belum Konfirmasi',
    'Hadir',
    'Tidak Hadir',
  ];
}
