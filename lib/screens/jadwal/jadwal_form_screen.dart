import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/jadwal_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class JadwalFormScreen extends StatefulWidget {
  final JadwalModel? initialData;

  const JadwalFormScreen({super.key, this.initialData});

  @override
  State<JadwalFormScreen> createState() => _JadwalFormScreenState();
}

class _JadwalFormScreenState extends State<JadwalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _jamMulaiController = TextEditingController(text: '08:00:00');
  final _jamSelesaiController = TextEditingController(text: '10:00:00');
  final _lokasiController = TextEditingController();
  final _catatanController = TextEditingController();

  DateTime? _selectedDate;
  String _penanggungJawab = 'Keduanya';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _namaController.text = widget.initialData!.namaKegiatan;
      _tanggalController.text = widget.initialData!.tanggal;
      _jamMulaiController.text = widget.initialData!.jamMulai;
      _jamSelesaiController.text = widget.initialData!.jamSelesai;
      _lokasiController.text = widget.initialData!.lokasi;
      _catatanController.text = widget.initialData!.catatan ?? '';
      _penanggungJawab = widget.initialData!.penanggungJawab;
      try {
        _selectedDate = DateTime.parse(widget.initialData!.tanggal);
      } catch (_) {}
    } else {
      final now = DateTime.now();
      _selectedDate = now;
      _tanggalController.text = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalController.dispose();
    _jamMulaiController.dispose();
    _jamSelesaiController.dispose();
    _lokasiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = _selectedDate ?? DateTime.now();
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

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
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
        controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await SessionService.getUserId() ?? 0;
    setState(() => _isLoading = true);

    final model = JadwalModel(
      id: widget.initialData?.id,
      userId: userId,
      namaKegiatan: _namaController.text.trim(),
      tanggal: _tanggalController.text.trim(),
      jamMulai: _jamMulaiController.text.trim(),
      jamSelesai: _jamSelesaiController.text.trim(),
      lokasi: _lokasiController.text.trim(),
      penanggungJawab: _penanggungJawab,
      statusSelesai: widget.initialData?.statusSelesai ?? false,
      catatan: _catatanController.text.trim(),
    );

    final res = widget.initialData == null
        ? await ApiService.addJadwal(model)
        : await ApiService.updateJadwal(model);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.success),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialData != null;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.charcoal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Jadwal Acara' : 'Tambah Jadwal Kegiatan',
          style: const TextStyle(fontFamily: 'serif', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _namaController,
                    label: 'Nama Kegiatan',
                    hint: 'cth. Akad Nikah, Resepsi Sesi 1, Fitting Gaun',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan nama kegiatan.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _tanggalController,
                    label: 'Tanggal Kegiatan',
                    hint: 'Pilih tanggal',
                    prefixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap pilih tanggal.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _jamMulaiController,
                          label: 'Jam Mulai',
                          hint: '08:00',
                          prefixIcon: Icons.access_time,
                          readOnly: true,
                          onTap: () => _pickTime(_jamMulaiController),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _jamSelesaiController,
                          label: 'Jam Selesai',
                          hint: '10:00',
                          prefixIcon: Icons.access_time,
                          readOnly: true,
                          onTap: () => _pickTime(_jamSelesaiController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _lokasiController,
                    label: 'Lokasi Acara',
                    hint: 'cth. Masjid Agung Sunda Kelapa / Gedung Serbaguna',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan lokasi acara.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Penanggung Jawab', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _penanggungJawab,
                        isExpanded: true,
                        items: AppConstants.penanggungJawab.map((pj) {
                          return DropdownMenuItem(value: pj, child: Text(pj, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _penanggungJawab = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _catatanController,
                    label: 'Catatan / Instruksi',
                    hint: 'cth. Saksi dan penghulu wajib hadir 30 menit sebelum acara',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: isEditing ? 'Simpan Perubahan' : 'Tambah ke Jadwal',
                    icon: Icons.check,
                    isLoading: _isLoading,
                    onPressed: _save,
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
