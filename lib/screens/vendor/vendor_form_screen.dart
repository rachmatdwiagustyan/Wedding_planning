import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/vendor_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class VendorFormScreen extends StatefulWidget {
  final VendorModel? initialData;

  const VendorFormScreen({super.key, this.initialData});

  @override
  State<VendorFormScreen> createState() => _VendorFormScreenState();
}

class _VendorFormScreenState extends State<VendorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _hargaController = TextEditingController(text: '0');
  final _catatanController = TextEditingController();

  String _kategori = 'Katering';
  String _statusPemesanan = 'Belum Dipesan';
  bool _isLoading = false;

  final List<String> _statusOptions = [
    'Belum Dipesan',
    'Sudah Dipesan',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _namaController.text = widget.initialData!.namaVendor;
      _teleponController.text = widget.initialData!.nomorTelepon ?? '';
      _alamatController.text = widget.initialData!.alamat ?? '';
      _hargaController.text = widget.initialData!.hargaPenawaran.toInt().toString();
      _catatanController.text = widget.initialData!.catatan ?? '';
      _kategori = widget.initialData!.kategori;
      final st = widget.initialData!.statusPemesanan;
      if (_statusOptions.contains(st)) {
        _statusPemesanan = st;
      } else {
        _statusPemesanan = 'Belum Dipesan';
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _hargaController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await SessionService.getUserId() ?? 0;
    final harga = double.tryParse(_hargaController.text) ?? 0.0;

    setState(() => _isLoading = true);

    final model = VendorModel(
      id: widget.initialData?.id,
      userId: userId,
      namaVendor: _namaController.text.trim(),
      kategori: _kategori,
      nomorTelepon: _teleponController.text.trim(),
      alamat: _alamatController.text.trim(),
      hargaPenawaran: harga,
      statusPemesanan: _statusPemesanan,
      catatan: _catatanController.text.trim(),
    );

    final res = widget.initialData == null
        ? await ApiService.addVendor(model)
        : await ApiService.updateVendor(model);

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
          isEditing ? 'Edit Data Vendor' : 'Tambah Rekanan Vendor',
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
                    label: 'Nama Vendor / Rekanan',
                    hint: 'cth. Akasya Catering, The Bride Story',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan nama vendor.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Kategori Vendor', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                        value: AppConstants.kategoriVendor.contains(_kategori) ? _kategori : AppConstants.kategoriVendor.first,
                        isExpanded: true,
                        items: AppConstants.kategoriVendor.map((cat) {
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
                          controller: _teleponController,
                          label: 'No. Telepon / PIC',
                          hint: '081298765432',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _hargaController,
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
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Status Pemesanan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                        value: _statusOptions.contains(_statusPemesanan) ? _statusPemesanan : _statusOptions.first,
                        isExpanded: true,
                        items: _statusOptions.map((st) {
                          return DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _statusPemesanan = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _alamatController,
                    label: 'Alamat / Studio Vendor',
                    hint: 'cth. Jl. Radio Dalam Raya No. 45, Kebayoran Baru',
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _catatanController,
                    label: 'Catatan Paket & Fasilitas',
                    hint: 'cth. Paket All-in, 8 jam liputan, 2 album kolase, cinematic video',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: isEditing ? 'Simpan Perubahan' : 'Tambah Vendor',
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
