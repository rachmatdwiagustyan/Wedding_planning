import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/logo_widget.dart';

class TentangAplikasiScreen extends StatelessWidget {
  const TentangAplikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.charcoal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(fontFamily: 'serif', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mochaBrown.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: const [
                    LogoWidget(fontSize: 24, showTagline: true),
                    SizedBox(height: 20),
                    Divider(color: AppColors.divider),
                    SizedBox(height: 16),
                    Text(
                      'TALENTA EVENT ORGANIZER adalah aplikasi perencanaan dan pengelolaan pernikahan modern yang didesain secara khusus untuk membantu calon mempelai wanita dan pria mempersiapkan seluruh kebutuhan hari istimewa mereka secara terstruktur, terarah, dan elegan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.charcoal, height: 1.5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Mulai dari checklist 18 berkas administrasi KUA resmi, pencatatan dan perbandingan anggaran vendor, manajemen daftar tamu dan konfirmasi kehadiran, hingga timeline kegiatan hari pernikahan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Fitur & Layanan Utama',
                      style: TextStyle(fontFamily: 'serif', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                    ),
                    SizedBox(height: 10),
                    Text('• Pengelolaan Dokumen Administrasi KUA & Catatan Sipil', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6)),
                    Text('• Perencanaan Tugas Persiapan & Tenggat Waktu Terstruktur', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6)),
                    Text('• Manajemen Daftar Tamu Undangan & Konfirmasi Kehadiran', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6)),
                    Text('• Pengelolaan Vendor & Rekanan Pernikahan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6)),
                    Text('• Estimasi Anggaran & Jadwal Kegiatan Hari Pernikahan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6)),
                    SizedBox(height: 14),
                    Text(
                      '© 2026 TALENTA EVENT ORGANIZER. Seluruh hak cipta dilindungi.',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
