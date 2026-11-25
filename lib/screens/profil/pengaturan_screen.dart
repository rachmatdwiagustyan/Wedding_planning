import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../services/session_service.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final url = await SessionService.getBaseUrl();
    setState(() {
      _urlController.text = url;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveUrl() async {
    final text = _urlController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);
    await SessionService.setBaseUrl(text);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan alamat server berhasil disimpan!'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    }
  }

  void _setPreset(String url) {
    setState(() {
      _urlController.text = url;
    });
  }

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
          'Pengaturan Aplikasi',
          style: TextStyle(fontFamily: 'serif', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Konfigurasi Backend XAMPP REST API',
                      style: TextStyle(fontFamily: 'serif', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sesuaikan alamat endpoint PHP backend sesuai lingkungan testing Anda:',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _urlController,
                      label: 'Base URL API',
                      hint: 'http://10.0.2.2/talenta_api',
                      prefixIcon: Icons.dns_outlined,
                    ),
                    const SizedBox(height: 14),
                    const Text('Pilihan Cepat:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mochaBrown)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('Android Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                          backgroundColor: AppColors.warmIvory,
                          onPressed: () => _setPreset('http://10.0.2.2/talenta_api'),
                        ),
                        ActionChip(
                          label: const Text('Localhost Mac (127.0.0.1)', style: TextStyle(fontSize: 11)),
                          backgroundColor: AppColors.warmIvory,
                          onPressed: () => _setPreset('http://localhost/talenta_api'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Simpan Pengaturan',
                      icon: Icons.check,
                      isLoading: _isLoading,
                      onPressed: _saveUrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Database Utama', style: TextStyle(fontFamily: 'serif', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                    SizedBox(height: 6),
                    Text('• Database: MySQL (talenta_event_organizer)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('• Server Lokal: XAMPP Apache & phpMyAdmin', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('• Komunikasi Data: JSON REST API', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
