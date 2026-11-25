import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/tamu_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class TamuFormScreen extends StatefulWidget {
  final TamuModel? initialData;

  const TamuFormScreen({super.key, this.initialData});

  @override
  State<TamuFormScreen> createState() => _TamuFormScreenState();
}

class _TamuFormScreenState extends State<TamuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _jumlahController = TextEditingController(text: '1');
  final _alamatController = TextEditingController();

  String _kategori = 'Keluarga';
  String _statusUndangan = 'Belum Diundang';
  String _konfirmasiKehadiran = 'Belum Konfirmasi';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _namaController.text = widget.initialData!.namaTamu;
      _teleponController.text = widget.initialData!.nomorTelepon ?? '';
      _jumlahController.text = widget.initialData!.jumlahOrang.toString();
      _alamatController.text = widget.initialData!.alamat ?? '';
      _kategori = widget.initialData!.kategori;
      _statusUndangan = widget.initialData!.statusUndangan;
      _konfirmasiKehadiran = widget.initialData!.konfirmasiKehadiran;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _jumlahController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await SessionService.getUserId() ?? 0;
    final jumlah = int.tryParse(_jumlahController.text) ?? 1;

    setState(() => _isLoading = true);

    final model = TamuModel(
      id: widget.initialData?.id,
      userId: userId,
      namaTamu: _namaController.text.trim(),
      nomorTelepon: _teleponController.text.trim(),
      kategori: _kategori,
      jumlahOrang: jumlah,
      alamat: _alamatController.text.trim(),
      statusUndangan: _statusUndangan,
      konfirmasiKehadiran: _konfirmasiKehadiran,
    );

    final res = widget.initialData == null
        ? await ApiService.addTamu(model)
        : await ApiService.updateTamu(model);

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
    final categories = AppConstants.kategoriTamu.where((c) => c != 'Semua').toList();

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
          isEditing ? 'Edit Tamu Undangan' : 'Tambah Tamu Undangan',
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
                    label: 'Nama Tamu / Pasangan',
                    hint: 'cth. Bpk. Hendra & Ibu Sinta',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan nama tamu.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _teleponController,
                          label: 'No. WhatsApp / HP',
                          hint: '08123456789',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _jumlahController,
                          label: 'Jumlah Orang',
                          hint: '1',
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || int.tryParse(val) == null || int.parse(val) <= 0) {
                              return 'Min. 1 orang';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Kategori Tamu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                        value: categories.contains(_kategori) ? _kategori : categories.first,
                        isExpanded: true,
                        items: categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _kategori = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status Undangan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                                  value: _statusUndangan,
                                  isExpanded: true,
                                  items: AppConstants.statusUndangan.map((st) {
                                    return DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 12)));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _statusUndangan = val);
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
                            const Text('Konfirmasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                                  value: _konfirmasiKehadiran,
                                  isExpanded: true,
                                  items: AppConstants.konfirmasiKehadiran.map((st) {
                                    return DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 12)));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _konfirmasiKehadiran = val);
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
                    controller: _alamatController,
                    label: 'Alamat / Catatan Tamu',
                    hint: 'cth. Jakarta Barat, meja VIP 03',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: isEditing ? 'Simpan Perubahan' : 'Tambah Tamu',
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
