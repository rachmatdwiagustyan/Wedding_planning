import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/tugas_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class TugasFormScreen extends StatefulWidget {
  final TugasModel? initialData;

  const TugasFormScreen({super.key, this.initialData});

  @override
  State<TugasFormScreen> createState() => _TugasFormScreenState();
}

class _TugasFormScreenState extends State<TugasFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kategoriController = TextEditingController(text: 'Persiapan Umum');
  final _tenggatController = TextEditingController();
  final _catatanController = TextEditingController();

  DateTime? _selectedDate;
  String _penanggungJawab = 'Keduanya';
  String _status = 'Belum Selesai';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _namaController.text = widget.initialData!.namaTugas;
      _kategoriController.text = widget.initialData!.kategori;
      _tenggatController.text = widget.initialData!.tenggatWaktu;
      _catatanController.text = widget.initialData!.catatan ?? '';
      _penanggungJawab = widget.initialData!.penanggungJawab;
      _status = widget.initialData!.status;
      try {
        _selectedDate = DateTime.parse(widget.initialData!.tenggatWaktu);
      } catch (_) {}
    } else {
      final now = DateTime.now().add(const Duration(days: 14));
      _selectedDate = now;
      _tenggatController.text = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    _tenggatController.dispose();
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
        _tenggatController.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await SessionService.getUserId() ?? 0;
    setState(() => _isLoading = true);

    final model = TugasModel(
      id: widget.initialData?.id,
      userId: userId,
      namaTugas: _namaController.text.trim(),
      kategori: _kategoriController.text.trim(),
      tenggatWaktu: _tenggatController.text.trim(),
      penanggungJawab: _penanggungJawab,
      status: _status,
      catatan: _catatanController.text.trim(),
    );

    final res = widget.initialData == null
        ? await ApiService.addTugas(model)
        : await ApiService.updateTugas(model);

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
          isEditing ? 'Edit Tugas Persiapan' : 'Tambah Tugas Persiapan',
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
                    label: 'Nama Tugas',
                    hint: 'cth. Memilih vendor katering, Fitting busana',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan nama tugas.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _kategoriController,
                    label: 'Kategori Tugas',
                    hint: 'cth. Busana, Katering, Dokumen, Undangan',
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _tenggatController,
                    label: 'Tenggat Waktu (Deadline)',
                    hint: 'Pilih tenggat waktu',
                    prefixIcon: Icons.calendar_month_outlined,
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap pilih tenggat waktu.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Penanggung Jawab', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                    return DropdownMenuItem(value: pj, child: Text(pj, style: const TextStyle(fontSize: 12)));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _penanggungJawab = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status Tugas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.inputBorder),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _status,
                                  isExpanded: true,
                                  items: AppConstants.statusTugas.map((st) {
                                    return DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 12)));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _status = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _catatanController,
                    label: 'Catatan (Opsional)',
                    hint: 'cth. Pastikan mengajak orang tua saat test food',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: isEditing ? 'Simpan Perubahan' : 'Tambah Tugas',
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
