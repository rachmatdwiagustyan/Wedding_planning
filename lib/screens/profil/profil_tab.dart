import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/logo_widget.dart';
import '../../models/user_model.dart';
import '../../models/pasangan_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../utils/formatters.dart';
import '../auth/login_screen.dart';
import '../pasangan/pasangan_form_screen.dart';
import 'edit_profil_screen.dart';
import 'tentang_aplikasi_screen.dart';

class ProfilTab extends StatefulWidget {
  const ProfilTab({super.key});

  @override
  State<ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> {
  UserModel? _user;
  PasanganModel? _pasangan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getProfile();
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _user = res.data!['user'] as UserModel?;
        _pasangan = res.data!['pasangan'] as PasanganModel?;
        _isLoading = false;
      });
    } else {
      // Fallback local session
      final u = await SessionService.getUser();
      final p = await SessionService.getPasangan();
      setState(() {
        _user = u;
        _pasangan = p;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar Akun?', style: TextStyle(fontFamily: 'serif', fontSize: 16)),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: AppColors.pureWhite)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildCoupleCard() {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.favorite, size: 16, color: AppColors.deepBurgundy),
                  SizedBox(width: 6),
                  Text(
                    'Identitas Pasangan',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PasanganFormScreen(initialData: _pasangan)),
                  );
                  if (updated != null) _loadProfile();
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.deepBurgundy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _pasangan != null && _pasangan!.namaWanita.isNotEmpty
                ? '${_pasangan!.namaWanita} & ${_pasangan!.namaPria}'
                : 'Belum diatur',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 13, color: AppColors.mochaBrown),
              const SizedBox(width: 6),
              Text(
                _pasangan != null ? Formatters.tanggal(_pasangan!.tanggalPernikahan) : '-',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 13, color: AppColors.mochaBrown),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _pasangan != null && _pasangan!.lokasiPernikahan.isNotEmpty
                      ? _pasangan!.lokasiPernikahan
                      : '-',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (_pasangan != null && _pasangan!.alamatAcara.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _pasangan!.alamatAcara,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.mochaBrown, size: 22),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.charcoal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.softTaupe),
        onTap: onTap,
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
          'Profil Pengguna',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.deepBurgundy))
            : RefreshIndicator(
                color: AppColors.deepBurgundy,
                onRefresh: _loadProfile,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.deepBurgundy,
                            child: Text(
                              _user != null && _user!.namaLengkap.isNotEmpty
                                  ? _user!.namaLengkap[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(fontFamily: 'serif', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.pureWhite),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user?.namaLengkap ?? 'Pengguna',
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _user?.email ?? '',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.warmIvory,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Akun Calon Pengantin', style: TextStyle(fontSize: 10, color: AppColors.mochaBrown, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Couple Information Card
                    _buildCoupleCard(),
                    const SizedBox(height: 16),
                    // Menu Options
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profil Saya',
                      subtitle: 'Ubah nama lengkap, email, atau kata sandi',
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProfilScreen(user: _user!)),
                        );
                        if (updated != null) _loadProfile();
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.favorite_border,
                      title: 'Edit Identitas Pasangan',
                      subtitle: 'Ubah nama pengantin, tanggal, dan lokasi acara',
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PasanganFormScreen(initialData: _pasangan)),
                        );
                        if (updated != null) _loadProfile();
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Informasi versi, developer, & visi TALENTA',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TentangAplikasiScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      iconColor: AppColors.danger,
                      textColor: AppColors.danger,
                      title: 'Keluar dari Akun',
                      subtitle: 'Selesaikan sesi dan keluar ke halaman login',
                      onTap: _handleLogout,
                    ),
                    const SizedBox(height: 20),
                    // Footer Logo
                    const Center(
                      child: LogoWidget(fontSize: 15, showTagline: true),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Versi 1.0.0 • TALENTA EVENT ORGANIZER',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
