import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/perbandingan_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class PerbandinganFormScreen extends StatefulWidget {
  final PerbandinganModel? initialData;

  const PerbandinganFormScreen({super.key, this.initialData});

  @override
  State<PerbandinganFormScreen> createState() => _PerbandinganFormScreenState();
}

class _PerbandinganFormScreenState extends State<PerbandinganFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kebutuhanController = TextEditingController();
  final _vendorController = TextEditingController();
  final _penawaranController = TextEditingController(text: '0');
  final _estimasiController = TextEditingController(text: '0');
  final _aktualController = TextEditingController(text: '0');
  final _catatanController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _kebutuhanController.text = widget.initialData!.namaKebutuhan;
      _vendorController.text = widget.initialData!.namaVendor;
      _penawaranController.text = widget.initialData!.hargaPenawaran.toInt().toString();
      _estimasiController.text = widget.initialData!.estimasiBiaya.toInt().toString();
      _aktualController.text = widget.initialData!.hargaAktual.toInt().toString();
      _catatanController.text = widget.initialData!.catatan ?? '';
    }
  }

  @override
  void dispose() {
    _kebutuhanController.dispose();
    _vendorController.dispose();
    _penawaranController.dispose();
    _estimasiController.dispose();
    _aktualController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await SessionService.getUserId() ?? 0;
    final penawaran = double.tryParse(_penawaranController.text) ?? 0.0;
    final estimasi = double.tryParse(_estimasiController.text) ?? 0.0;
    final aktual = double.tryParse(_aktualController.text) ?? 0.0;
    final selisih = estimasi - penawaran;

    setState(() => _isLoading = true);

    final model = PerbandinganModel(
      id: widget.initialData?.id,
      userId: userId,
      namaKebutuhan: _kebutuhanController.text.trim(),
      namaVendor: _vendorController.text.trim(),
      hargaPenawaran: penawaran,
      estimasiBiaya: estimasi,
      hargaAktual: aktual,
      selisihHarga: selisih,
      catatan: _catatanController.text.trim(),
    );

    final res = widget.initialData == null
        ? await ApiService.addPerbandingan(model)
        : await ApiService.updatePerbandingan(model);

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
          isEditing ? 'Edit Perbandingan' : 'Tambah Perbandingan Harga',
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
                    controller: _kebutuhanController,
                    label: 'Nama Kebutuhan',
                    hint: 'cth. Katering 500 Porsi, Gedung Resepsi',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan nama kebutuhan.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _vendorController,
                    label: 'Nama Vendor / Toko',
                    hint: 'cth. Diamond Wedding Organizer, Katering Bu Mimin',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan nama vendor atau toko.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _penawaranController,
                          label: 'Harga Penawaran (Rp)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || double.tryParse(val) == null) {
                              return 'Format harga salah';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _estimasiController,
                          label: 'Estimasi Biaya (Rp)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || double.tryParse(val) == null) {
                              return 'Format harga salah';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _aktualController,
                    label: 'Harga Aktual / Disepakati (Rp)',
                    hint: '0 (jika sudah deal)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _catatanController,
                    label: 'Catatan Penawaran (Opsional)',
                    hint: 'cth. Termasuk bonus 2 stall kambing guling, free test food',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: isEditing ? 'Simpan Perubahan' : 'Tambah Perbandingan',
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
