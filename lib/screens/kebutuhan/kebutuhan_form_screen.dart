import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/kebutuhan_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../utils/formatters.dart';

class KebutuhanFormScreen extends StatefulWidget {
  final KebutuhanModel? initialData;

  const KebutuhanFormScreen({super.key, this.initialData});

  @override
  State<KebutuhanFormScreen> createState() => _KebutuhanFormScreenState();
}

class _KebutuhanFormScreenState extends State<KebutuhanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController(text: '1');
  final _hargaSatuanController = TextEditingController(text: '0');
  final _catatanController = TextEditingController();

  String _kategori = 'Administrasi';
  String _penanggungJawab = 'Keduanya';
  String _statusPembelian = 'Belum Dibeli';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _namaController.text = widget.initialData!.namaBarang;
      _jumlahController.text = widget.initialData!.jumlah.toString();
      _hargaSatuanController.text = widget.initialData!.hargaSatuan.toInt().toString();
      _catatanController.text = widget.initialData!.catatan ?? '';
      _kategori = widget.initialData!.kategori;
      _penanggungJawab = widget.initialData!.penanggungJawab;
      _statusPembelian = widget.initialData!.statusPembelian;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _hargaSatuanController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  double get _calculatedTotal {
    final qty = int.tryParse(_jumlahController.text) ?? 1;
    final price = double.tryParse(_hargaSatuanController.text) ?? 0.0;
    return qty * price;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await SessionService.getUserId() ?? 0;
    final qty = int.tryParse(_jumlahController.text) ?? 1;
    final unitPrice = double.tryParse(_hargaSatuanController.text) ?? 0.0;

    setState(() => _isLoading = true);

    final model = KebutuhanModel(
      id: widget.initialData?.id,
      userId: userId,
      namaBarang: _namaController.text.trim(),
      kategori: _kategori,
      jumlah: qty,
      hargaSatuan: unitPrice,
      totalHarga: qty * unitPrice,
      penanggungJawab: _penanggungJawab,
      statusPembelian: _statusPembelian,
      catatan: _catatanController.text.trim(),
    );

    final res = widget.initialData == null
        ? await ApiService.addKebutuhan(model)
        : await ApiService.updateKebutuhan(model);

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

    final categories = AppConstants.kategoriKebutuhan.where((c) => c != 'Semua').toList();

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
          isEditing ? 'Edit Kebutuhan' : 'Tambah Kebutuhan',
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
                    label: 'Nama Barang / Kebutuhan',
                    hint: 'cth. Cincin Kawin Emas Putih',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan nama barang.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Kategori', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                        child: CustomTextField(
                          controller: _jumlahController,
                          label: 'Jumlah Barang',
                          hint: '1',
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || int.tryParse(val) == null || int.parse(val) <= 0) {
                              return 'Jumlah min. 1';
                            }
                            return null;
                          },
                          onTap: () => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          controller: _hargaSatuanController,
                          label: 'Harga Satuan (Rp)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          onTap: () => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Auto Calculated Total
                  ValueListenableBuilder(
                    valueListenable: _hargaSatuanController,
                    builder: (context, val, child) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warmIvory,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Harga (Otomatis):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mochaBrown)),
                            Text(
                              Formatters.rupiah(_calculatedTotal),
                              style: const TextStyle(fontFamily: 'serif', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy),
                            ),
                          ],
                        ),
                      );
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
                  const Text('Status Pembelian', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                        value: _statusPembelian,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'Belum Dibeli', child: Text('Belum Dibeli', style: TextStyle(fontSize: 13))),
                          DropdownMenuItem(value: 'Sudah Dibeli', child: Text('Sudah Dibeli', style: TextStyle(fontSize: 13, color: AppColors.success))),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _statusPembelian = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _catatanController,
                    label: 'Catatan (Opsional)',
                    hint: 'cth. Ukuran cincin pria 18, wanita 12',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: isEditing ? 'Simpan Perubahan' : 'Tambah Kebutuhan',
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
