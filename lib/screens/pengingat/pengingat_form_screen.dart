import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/pengingat_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class PengingatFormScreen extends StatefulWidget {
  final PengingatModel? initialData;

  const PengingatFormScreen({super.key, this.initialData});

  @override
  State<PengingatFormScreen> createState() => _PengingatFormScreenState();
}

class _PengingatFormScreenState extends State<PengingatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _jamController = TextEditingController(text: '09:00:00');
  final _catatanController = TextEditingController();

  String _tipe = 'Tenggat Waktu';
  bool _isLoading = false;
  DateTime? _selectedDate;

  final List<String> _tipeOptions = [
    'Tenggat Waktu',
    'Pembayaran Vendor',
    'Administrasi & Dokumen',
    'Fitting & Rias',
    'Jadwal Acara',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _judulController.text = widget.initialData!.judul;
      _tanggalController.text = widget.initialData!.tanggalPengingat;
      _jamController.text = widget.initialData!.jamPengingat;
      _catatanController.text = widget.initialData!.catatan ?? '';
      _tipe = widget.initialData!.tipe;
      try {
        _selectedDate = DateTime.parse(widget.initialData!.tanggalPengingat);
      } catch (_) {}
    } else {
      final now = DateTime.now().add(const Duration(days: 7));
      _selectedDate = now;
      _tanggalController.text = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _tanggalController.dispose();
    _jamController.dispose();
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

  Future<void> _pickTime() async {
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
        _jamController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await SessionService.getUserId() ?? 0;
    setState(() => _isLoading = true);

    final model = PengingatModel(
      id: widget.initialData?.id,
      userId: userId,
      judul: _judulController.text.trim(),
      tipe: _tipe,
      tanggalPengingat: _tanggalController.text.trim(),
      jamPengingat: _jamController.text.trim(),
      status: widget.initialData?.status ?? 'Aktif',
      catatan: _catatanController.text.trim(),
    );

    final res = widget.initialData == null
        ? await ApiService.addPengingat(model)
        : await ApiService.updatePengingat(model);

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
          isEditing ? 'Edit Pengingat' : 'Tambah Pengingat Baru',
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
                    controller: _judulController,
                    label: 'Judul Pengingat',
                    hint: 'cth. Pelunasan Gedung Resepsi, Ambil Berkas N1 di RT',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan judul pengingat.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Tipe Pengingat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                        value: _tipeOptions.contains(_tipe) ? _tipe : _tipeOptions.first,
                        isExpanded: true,
                        items: _tipeOptions.map((t) {
                          return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _tipe = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _tanggalController,
                          label: 'Tanggal Pengingat',
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _jamController,
                          label: 'Jam Pengingat',
                          hint: '09:00',
                          prefixIcon: Icons.access_time,
                          readOnly: true,
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _catatanController,
                    label: 'Catatan / Instruksi',
                    hint: 'cth. Bawa bukti transfer DP sebelumnya dan materai 10.000',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: isEditing ? 'Simpan Perubahan' : 'Pasang Pengingat',
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
