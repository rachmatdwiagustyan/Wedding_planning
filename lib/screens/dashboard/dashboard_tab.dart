import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/responsible_tag.dart';
import '../../models/dashboard_model.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../pasangan/pasangan_form_screen.dart';
import '../administrasi/administrasi_screen.dart';
import '../tugas/tugas_screen.dart';
import '../tamu/tamu_screen.dart';
import '../vendor/vendor_screen.dart';

class DashboardTab extends StatefulWidget {
  final VoidCallback? onNavigateToPersiapan;
  final VoidCallback? onNavigateToAnggaran;
  final VoidCallback? onNavigateToJadwal;

  const DashboardTab({
    super.key,
    this.onNavigateToPersiapan,
    this.onNavigateToAnggaran,
    this.onNavigateToJadwal,
  });

  @override
  State<DashboardTab> createState() => DashboardTabState();
}

class DashboardTabState extends State<DashboardTab> {
  DashboardModel? _dashboard;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final res = await ApiService.getDashboard();
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _dashboard = res.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = res.message;
        _isLoading = false;
      });
    }
  }

  Widget _buildCountdownCard(DashboardModel data) {
    final pasangan = data.pasangan;
    final days = data.countdownDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepBurgundy, Color(0xFF6E3A4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBurgundy.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, size: 16, color: AppColors.champagne),
                  const SizedBox(width: 6),
                  Text(
                    'HARI BAHAGIA'.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.champagne,
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.pureWhite),
                tooltip: 'Edit Pasangan',
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PasanganFormScreen(initialData: pasangan),
                    ),
                  );
                  if (updated != null) {
                    loadDashboard();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nama Pasangan
          Text(
            pasangan != null && pasangan.namaWanita.isNotEmpty && pasangan.namaPria.isNotEmpty
                ? '${pasangan.namaWanita} & ${pasangan.namaPria}'
                : 'Pasangan Pengantin',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.pureWhite,
            ),
          ),
          const SizedBox(height: 6),
          // Tanggal & Lokasi
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 13, color: AppColors.champagne),
              const SizedBox(width: 6),
              Text(
                pasangan != null ? Formatters.tanggal(pasangan.tanggalPernikahan) : '-',
                style: const TextStyle(fontSize: 12, color: AppColors.pureWhite),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.champagne),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  pasangan != null && pasangan.lokasiPernikahan.isNotEmpty
                      ? pasangan.lokasiPernikahan
                      : '-',
                  style: const TextStyle(fontSize: 12, color: AppColors.pureWhite),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0x33FFFFFF), height: 1),
          const SizedBox(height: 14),
          // Countdown Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hitung Mundur Pernikahan',
                    style: TextStyle(fontSize: 11, color: Color(0xFFD4C2B8)),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        days != null
                            ? (days >= 0 ? '$days' : 'Hari H Telah Lewat')
                            : 'Belum Diatur',
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pureWhite,
                        ),
                      ),
                      if (days != null && days >= 0) ...[
                        const SizedBox(width: 6),
                        const Text(
                          'Hari Lagi',
                          style: TextStyle(fontSize: 13, color: AppColors.champagne),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              // Persentase Kemajuan
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Kemajuan Persiapan',
                    style: TextStyle(fontSize: 11, color: Color(0xFFD4C2B8)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: (data.overallProgress) / 100,
                              strokeWidth: 4,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.champagne),
                            ),
                            Text(
                              '${data.overallProgress}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.pureWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary(DashboardModel data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Anggaran',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              InkWell(
                onTap: widget.onNavigateToAnggaran,
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepBurgundy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Estimasi', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.rupiah(data.totalEstimasi),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.divider),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pengeluaran Aktual', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.rupiah(data.totalAktual),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sisa / Selisih Anggaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.mochaBrown)),
              Text(
                Formatters.rupiah(data.selisihAnggaran),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: data.selisihAnggaran >= 0 ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.mochaBrown.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.deepBurgundy),
              SizedBox(width: 8),
              Text(
                'TALENTA EVENT ORGANIZER',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.deepBurgundy,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'TALENTA EVENT ORGANIZER adalah aplikasi wedding planner yang membantu calon pengantin merencanakan dan mengelola persiapan pernikahan dengan lebih mudah dan terorganisir. Aplikasi ini menyediakan fitur pengelolaan dokumen administrasi, tugas persiapan, daftar tamu undangan, anggaran pernikahan, jadwal, serta vendor dalam satu aplikasi.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.warmIvory,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.deepBurgundy),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.warmIvory,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: AppColors.danger),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat dashboard',
                  style: const TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepBurgundy),
                  onPressed: loadDashboard,
                  child: const Text('Coba Lagi', style: TextStyle(color: AppColors.pureWhite)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final data = _dashboard!;
    final user = data.user;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.deepBurgundy,
          onRefresh: loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar: Logo & Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${user?.namaLengkap.split(' ').first ?? 'Calon Pengantin'}',
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Semoga persiapan pernikahan Anda berjalan lancar',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const LogoWidget(
                      fontSize: 14,
                      showTagline: false,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Card Countdown & Couple Info
                _buildCountdownCard(data),
                const SizedBox(height: 16),
                // Stat Grid (Dokumen, Tugas, Tamu, Vendor)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    StatCard(
                      title: 'Dokumen Administrasi',
                      value: '${data.dokumenLengkap} / ${data.totalDokumen > 0 ? data.totalDokumen : 18}',
                      subtitle: '${(data.totalDokumen > 0 ? data.totalDokumen : 18) - data.dokumenLengkap} Belum Disiapkan',
                      icon: Icons.assignment_turned_in_outlined,
                      iconColor: AppColors.wanita,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdministrasiScreen()),
                        );
                        loadDashboard();
                      },
                    ),
                    StatCard(
                      title: 'Tugas Persiapan',
                      value: '${data.tugasSelesai} Selesai',
                      subtitle: '${data.tugasBelumSelesai} Belum Selesai',
                      icon: Icons.checklist_outlined,
                      iconColor: AppColors.pria,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TugasScreen()),
                        );
                        loadDashboard();
                      },
                    ),
                    StatCard(
                      title: 'Tamu Undangan',
                      value: '${data.tamuHadir} Orang Hadir',
                      subtitle: 'dari total ${data.totalTamu} tamu',
                      icon: Icons.people_outline,
                      iconColor: AppColors.keduanya,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TamuScreen()),
                        );
                        loadDashboard();
                      },
                    ),
                    StatCard(
                      title: 'Vendor Dipesan',
                      value: '${data.vendorDipesan} / ${data.totalVendor}',
                      subtitle: '${data.totalVendor > data.vendorDipesan ? data.totalVendor - data.vendorDipesan : 0} Belum Dipesan',
                      icon: Icons.storefront_outlined,
                      iconColor: AppColors.deepBurgundy,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VendorScreen()),
                        );
                        loadDashboard();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Ringkasan Anggaran
                _buildBudgetSummary(data),
                const SizedBox(height: 20),
                // Jadwal Terdekat
                SectionHeader(
                  title: 'Jadwal Kegiatan Terdekat',
                  subtitle: 'Kegiatan mendatang yang perlu dihadiri',
                  actionText: 'Lihat Semua',
                  onAction: widget.onNavigateToJadwal,
                ),
                const SizedBox(height: 10),
                if (data.jadwalTerdekat.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Center(
                      child: Text(
                        'Belum ada jadwal kegiatan terdekat.\nTambahkan agenda pertemuan vendor atau fitting baju.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ),
                  )
                else
                  ...data.jadwalTerdekat.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.warmIvory,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  Formatters.tanggalSingkat(item.tanggal).split(' ').first,
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepBurgundy,
                                  ),
                                ),
                                Text(
                                  Formatters.tanggalSingkat(item.tanggal).split(' ').length > 1
                                      ? Formatters.tanggalSingkat(item.tanggal).split(' ')[1]
                                      : '',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.mochaBrown),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.namaKegiatan,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${Formatters.jam(item.jamMulai)} - ${Formatters.jam(item.jamSelesai)}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ResponsibleTag(penanggungJawab: item.penanggungJawab, isSmall: true),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 20),
                // Pengingat Aktif
                SectionHeader(
                  title: 'Pengingat Penting',
                  subtitle: 'Tenggat waktu & catatan penting',
                  actionText: 'Kelola',
                  onAction: widget.onNavigateToPersiapan,
                ),
                const SizedBox(height: 10),
                if (data.pengingatAktif.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Center(
                      child: Text(
                        'Tidak ada pengingat aktif saat ini.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ),
                  )
                else
                  ...data.pengingatAktif.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active_outlined, size: 20, color: AppColors.deepBurgundy),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.judul,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                                ),
                                if (item.catatan != null && item.catatan!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    item.catatan!,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            Formatters.tanggalSingkat(item.tanggalPengingat),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 20),
                // Deskripsi Aplikasi
                _buildAppDescriptionCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
