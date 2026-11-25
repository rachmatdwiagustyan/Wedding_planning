import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/logo_widget.dart';
import '../../models/pasangan_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../utils/formatters.dart';
import '../main_nav_screen.dart';

class PasanganFormScreen extends StatefulWidget {
  final bool isOnboarding;
  final PasanganModel? initialData;

  const PasanganFormScreen({
    super.key,
    this.isOnboarding = false,
    this.initialData,
  });

  @override
  State<PasanganFormScreen> createState() => _PasanganFormScreenState();
}

class _PasanganFormScreenState extends State<PasanganFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wanitaController = TextEditingController();
  final _priaController = TextEditingController();
  final _fotoController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _alamatController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _wanitaController.text = widget.initialData!.namaWanita;
      _priaController.text = widget.initialData!.namaPria;
      _fotoController.text = widget.initialData!.fotoPasangan ?? '';
      _tanggalController.text = widget.initialData!.tanggalPernikahan;
      _lokasiController.text = widget.initialData!.lokasiPernikahan;
      _alamatController.text = widget.initialData!.alamatAcara;
      try {
        _selectedDate = DateTime.parse(widget.initialData!.tanggalPernikahan);
      } catch (_) {}
    } else {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final existing = await SessionService.getPasangan();
    if (existing != null && mounted) {
      setState(() {
        _wanitaController.text = existing.namaWanita;
        _priaController.text = existing.namaPria;
        _fotoController.text = existing.fotoPasangan ?? '';
        _tanggalController.text = existing.tanggalPernikahan;
        _lokasiController.text = existing.lokasiPernikahan;
        _alamatController.text = existing.alamatAcara;
        try {
          _selectedDate = DateTime.parse(existing.tanggalPernikahan);
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _wanitaController.dispose();
    _priaController.dispose();
    _fotoController.dispose();
    _tanggalController.dispose();
    _lokasiController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = _selectedDate ?? DateTime.now().add(const Duration(days: 90));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepBurgundy,
              onPrimary: AppColors.pureWhite,
              onSurface: AppColors.charcoal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _savePasangan() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await SessionService.getUserId() ?? 0;
    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi telah berakhir. Silakan login kembali.'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _isLoading = true);

    final model = PasanganModel(
      userId: userId,
      namaWanita: _wanitaController.text.trim(),
      namaPria: _priaController.text.trim(),
      fotoPasangan: _fotoController.text.trim().isNotEmpty ? _fotoController.text.trim() : null,
      tanggalPernikahan: _tanggalController.text.trim(),
      lokasiPernikahan: _lokasiController.text.trim(),
      alamatAcara: _alamatController.text.trim(),
    );

    final res = await ApiService.savePasangan(model);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.success),
      );

      if (widget.isOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
        );
      } else {
        Navigator.pop(context, res.data);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isOnboarding
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.charcoal),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          widget.isOnboarding ? 'Identitas Pasangan' : 'Edit Identitas Pasangan',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mochaBrown.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isOnboarding) ...[
                    const LogoWidget(fontSize: 22, showTagline: false),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.divider, thickness: 1),
                    const SizedBox(height: 12),
                  ],
                  const Text(
                    'Informasi Calon Pengantin',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lengkapi data pasangan untuk menghitung mundur hari bahagia dan mempersonalisasi dashboard Anda.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  // Nama Calon Pengantin Wanita
                  CustomTextField(
                    controller: _wanitaController,
                    label: 'Nama Calon Pengantin Wanita',
                    hint: 'cth. Anisa Rahmawati, S.Ked',
                    prefixIcon: Icons.female,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan nama calon pengantin wanita.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Nama Calon Pengantin Pria
                  CustomTextField(
                    controller: _priaController,
                    label: 'Nama Calon Pengantin Pria',
                    hint: 'cth. Dimas Pratama, S.T.',
                    prefixIcon: Icons.male,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan nama calon pengantin pria.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Tanggal Pernikahan
                  CustomTextField(
                    controller: _tanggalController,
                    label: 'Tanggal Pernikahan',
                    hint: 'Pilih tanggal pernikahan',
                    prefixIcon: Icons.calendar_month_outlined,
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap tentukan tanggal pernikahan.';
                      }
                      return null;
                    },
                  ),
                  if (_selectedDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Format: ${Formatters.tanggal(_tanggalController.text)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.mochaBrown, fontStyle: FontStyle.italic),
                    ),
                  ],
                  const SizedBox(height: 14),
                  // Lokasi Pernikahan
                  CustomTextField(
                    controller: _lokasiController,
                    label: 'Lokasi / Nama Venue Pernikahan',
                    hint: 'cth. Grand Ballroom Hotel Mulia Senayan',
                    prefixIcon: Icons.location_city_outlined,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan nama gedung/tempat acara.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Alamat Lengkap Acara
                  CustomTextField(
                    controller: _alamatController,
                    label: 'Alamat Lengkap Acara',
                    hint: 'cth. Jl. Asia Afrika, Gelora, Tanah Abang, Jakarta Pusat',
                    prefixIcon: Icons.place_outlined,
                    maxLines: 2,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan alamat tempat acara.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Foto Pasangan URL (Opsional)
                  CustomTextField(
                    controller: _fotoController,
                    label: 'Tautan Foto Pasangan (Opsional)',
                    hint: 'https://contoh.com/foto-prewedding.jpg',
                    prefixIcon: Icons.image_outlined,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Simpan Identitas Pasangan',
                    icon: Icons.check,
                    isLoading: _isLoading,
                    onPressed: _savePasangan,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
