import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/logo_widget.dart';
import '../administrasi/administrasi_screen.dart';
import '../kebutuhan/kebutuhan_screen.dart';
import '../tamu/tamu_screen.dart';
import '../vendor/vendor_screen.dart';
import '../tugas/tugas_screen.dart';
import '../catatan/catatan_screen.dart';
import '../pengingat/pengingat_screen.dart';

class PersiapanHubTab extends StatelessWidget {
  const PersiapanHubTab({super.key});

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Widget destination,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.mochaBrown.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.divider.withOpacity(0.8), width: 1),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.softTaupe),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Pusat Persiapan',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LogoWidget(fontSize: 13, showTagline: false),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            const Text(
              'Kelola seluruh rincian administrasi, barang, vendor, tamu, dan tugas pernikahan Anda di satu tempat.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context: context,
              title: 'Administrasi Pernikahan',
              subtitle: 'Checklist 18 dokumen wajib KUA & Catatan Sipil',
              icon: Icons.assignment_outlined,
              iconColor: AppColors.iconRose,
              iconBgColor: AppColors.ivoryBg,
              destination: const AdministrasiScreen(),
            ),
            _buildMenuItem(
              context: context,
              title: 'Daftar Hadiah & Kebutuhan',
              subtitle: 'Barang, seserahan, mahar, dan perlengkapan',
              icon: Icons.card_giftcard_outlined,
              iconColor: AppColors.iconMocha,
              iconBgColor: AppColors.champagneBg,
              destination: const KebutuhanScreen(),
            ),
            _buildMenuItem(
              context: context,
              title: 'Daftar Tamu Undangan',
              subtitle: 'Daftar kontak, kategori, & konfirmasi kehadiran',
              icon: Icons.people_outline,
              iconColor: AppColors.iconSage,
              iconBgColor: AppColors.ivoryBg,
              destination: const TamuScreen(),
            ),
            _buildMenuItem(
              context: context,
              title: 'Pengelolaan Vendor',
              subtitle: 'Katering, dekorasi, busana, fotografer, & gedung',
              icon: Icons.storefront_outlined,
              iconColor: AppColors.iconBurgundy,
              iconBgColor: AppColors.champagneBg,
              destination: const VendorScreen(),
            ),
            _buildMenuItem(
              context: context,
              title: 'Daftar Tugas Pernikahan',
              subtitle: 'Checklist persiapan & tenggat waktu terstruktur',
              icon: Icons.task_alt_outlined,
              iconColor: AppColors.iconBurgundy,
              iconBgColor: AppColors.ivoryBg,
              destination: const TugasScreen(),
            ),
            _buildMenuItem(
              context: context,
              title: 'Catatan Pernikahan',
              subtitle: 'Inspirasi konsep, daftar pertanyaan, & ide penting',
              icon: Icons.note_alt_outlined,
              iconColor: AppColors.iconMocha,
              iconBgColor: AppColors.champagneBg,
              destination: const CatatanScreen(),
            ),
            _buildMenuItem(
              context: context,
              title: 'Pengingat Penting',
              subtitle: 'Notifikasi jadwal, berkas, & tenggat pembayaran',
              icon: Icons.notifications_none_outlined,
              iconColor: AppColors.iconBurgundy,
              iconBgColor: AppColors.ivoryBg,
              destination: const PengingatScreen(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
