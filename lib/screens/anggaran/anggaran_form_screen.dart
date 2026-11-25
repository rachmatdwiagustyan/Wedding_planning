import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/anggaran_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class AnggaranFormScreen extends StatefulWidget {
  final AnggaranModel? initialData;

  const AnggaranFormScreen({super.key, this.initialData});

  @override
  State<AnggaranFormScreen> createState() => _AnggaranFormScreenState();
}

class _AnggaranFormScreenState extends State<AnggaranFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _vendorController = TextEditingController();
  final _estimasiController = TextEditingController(text: '0');
  final _aktualController = TextEditingController(text: '0');
  final _catatanController = TextEditingController();

  String _kategori = 'Venue & Gedung';
  String _statusPembayaran = 'Belum Dibayar';
  String _penanggungJawab = 'Keduanya';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _namaController.text = widget.initialData!.namaKebutuhan;
      _vendorController.text = widget.initialData!.namaVendor ?? '';
      _estimasiController.text = widget.initialData!.estimasiBiaya.toInt().toString();
      _aktualController.text = widget.initialData!.biayaAktual.toInt().toString();
      _catatanController.text = widget.initialData!.catatan ?? '';
      _kategori = widget.initialData!.kategori;
      _statusPembayaran = widget.initialData!.statusPembayaran;
      _penanggungJawab = widget.initialData!.penanggungJawab;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _vendorController.dispose();
    _estimasiController.dispose();
    _aktualController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  double _parseBiaya(String text) {
    final cleaned = text.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await SessionService.getUserId() ?? 0;
    final estimasi = _parseBiaya(_estimasiController.text);
    final aktual = _parseBiaya(_aktualController.text);

    setState(() => _isLoading = true);

    final model = AnggaranModel(
      id: widget.initialData?.id,
      userId: userId,
      kategori: _kategori,
      namaKebutuhan: _namaController.text.trim(),
      namaVendor: _vendorController.text.trim().isEmpty ? null : _vendorController.text.trim(),
      estimasiBiaya: estimasi,
      biayaAktual: aktual,
      statusPembayaran: _statusPembayaran,
      penanggungJawab: _penanggungJawab,
      catatan: _catatanController.text.trim().isEmpty ? null : _catatanController.text.trim(),
    );

    final res = widget.initialData == null
        ? await ApiService.addAnggaran(model)
        : await ApiService.updateAnggaran(model);

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
          isEditing ? 'Edit Anggaran' : 'Tambah Anggaran',
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
                    label: 'Nama Kebutuhan / Pos Anggaran',
                    hint: 'cth. Sewa Gedung Resepsi',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan nama kebutuhan.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Kategori Pengeluaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                        value: AppConstants.kategoriAnggaran.contains(_kategori) ? _kategori : AppConstants.kategoriAnggaran.first,
                        isExpanded: true,
                        items: AppConstants.kategoriAnggaran.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _kategori = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _vendorController,
                    label: 'Nama Vendor (Opsional)',
                    hint: 'cth. Grand Ballroom Hotel, Catering Berkah',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _estimasiController,
                          label: 'Estimasi Biaya (Rp)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Wajib diisi';
                            }
                            final num = _parseBiaya(val);
                            if (num < 0) return 'Format biaya salah';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _aktualController,
                          label: 'Biaya Aktual (Rp)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Wajib diisi';
                            }
                            final num = _parseBiaya(val);
                            if (num < 0) return 'Format biaya salah';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Status Pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                        value: _statusPembayaran,
                        isExpanded: true,
                        items: AppConstants.statusPembayaran.map((st) {
                          return DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _statusPembayaran = val);
                        },
                      ),
                    ),
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
                    label: 'Catatan (Opsional)',
                    hint: 'cth. Sudah DP 30%, pelunasan H-14',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: isEditing ? 'Simpan Perubahan' : 'Tambah Anggaran',
                    icon: Icons.check,
                    isLoading: _isLoading,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.champagne),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Batal', style: TextStyle(color: AppColors.mochaBrown, fontWeight: FontWeight.w600)),
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
