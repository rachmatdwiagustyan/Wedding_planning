import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/dokumen_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class AdministrasiFormScreen extends StatefulWidget {
  final DokumenModel? initialData;

  const AdministrasiFormScreen({super.key, this.initialData});

  @override
  State<AdministrasiFormScreen> createState() => _AdministrasiFormScreenState();
}

class _AdministrasiFormScreenState extends State<AdministrasiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomorController = TextEditingController();
  final _namaController = TextEditingController();
  final _catatanController = TextEditingController();

  String _penanggungJawab = 'Keduanya';
  String _statusKelengkapan = 'Belum Disiapkan';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nomorController.text = widget.initialData!.nomorDokumen.toString();
      _namaController.text = widget.initialData!.namaDokumen;
      _catatanController.text = widget.initialData!.catatan ?? '';
      _penanggungJawab = widget.initialData!.penanggungJawab;
      final st = widget.initialData!.statusKelengkapan;
      _statusKelengkapan = (st == 'Sudah Lengkap' || st == 'Sudah Disiapkan')
          ? 'Sudah Disiapkan'
          : 'Belum Disiapkan';
    }
  }

  @override
  void dispose() {
    _nomorController.dispose();
    _namaController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await SessionService.getUserId() ?? 0;
    setState(() => _isLoading = true);

    final model = DokumenModel(
      id: widget.initialData?.id,
      userId: userId,
      nomorDokumen: int.tryParse(_nomorController.text) ?? 1,
      namaDokumen: _namaController.text.trim(),
      penanggungJawab: _penanggungJawab,
      statusKelengkapan: _statusKelengkapan,
      catatan: _catatanController.text.trim(),
    );

    final res = widget.initialData == null
        ? await ApiService.addDokumen(model)
        : await ApiService.updateDokumen(model);

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
          isEditing ? 'Edit Dokumen Administrasi' : 'Tambah Dokumen Administrasi',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
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
                    controller: _nomorController,
                    label: 'Nomor Urut Dokumen',
                    hint: 'cth. 19',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _namaController,
                    label: 'Nama Dokumen',
                    hint: 'cth. Surat Izin Atasan / Komandan',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan nama dokumen.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Penanggung Jawab',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                  ),
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
                  const Text(
                    'Status Kelengkapan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                  ),
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
                        value: (_statusKelengkapan == 'Sudah Lengkap' || _statusKelengkapan == 'Sudah Disiapkan')
                            ? 'Sudah Disiapkan'
                            : 'Belum Disiapkan',
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'Belum Disiapkan', child: Text('Belum Disiapkan', style: TextStyle(fontSize: 13))),
                          DropdownMenuItem(value: 'Sudah Disiapkan', child: Text('Sudah Disiapkan', style: TextStyle(fontSize: 13, color: AppColors.success))),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _statusKelengkapan = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _catatanController,
                    label: 'Catatan Tambahan (Opsional)',
                    hint: 'cth. Legalisir KUA domisili asli 3 rangkap',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: isEditing ? 'Simpan Perubahan' : 'Tambah Dokumen',
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
