import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/catatan_model.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class CatatanFormScreen extends StatefulWidget {
  final CatatanModel? initialData;

  const CatatanFormScreen({super.key, this.initialData});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();

  String _kategori = 'Umum';
  bool _isLoading = false;

  final List<String> _kategoriOptions = [
    'Umum',
    'Inspirasi Konsep',
    'Pertanyaan Vendor',
    'Susunan Acara',
    'Daftar Lagu',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _judulController.text = widget.initialData!.judul;
      _isiController.text = widget.initialData!.isi;
      _kategori = widget.initialData!.kategori;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await SessionService.getUserId() ?? 0;
    setState(() => _isLoading = true);

    final model = CatatanModel(
      id: widget.initialData?.id,
      userId: userId,
      judul: _judulController.text.trim(),
      isi: _isiController.text.trim(),
      kategori: _kategori,
    );

    final res = widget.initialData == null
        ? await ApiService.addCatatan(model)
        : await ApiService.updateCatatan(model);

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
          isEditing ? 'Edit Catatan' : 'Tulis Catatan Baru',
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
                    label: 'Judul Catatan',
                    hint: 'cth. Rencana Rundown & Susunan Lagu Akad',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Harap masukkan judul catatan.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Kategori Catatan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                        value: _kategoriOptions.contains(_kategori) ? _kategori : _kategoriOptions.first,
                        isExpanded: true,
                        items: _kategoriOptions.map((cat) {
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
                    controller: _isiController,
                    label: 'Isi Catatan',
                    hint: 'Tuliskan detail catatan, ide, susunan acara, nomor rekening, dll...',
                    maxLines: 7,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Isi catatan tidak boleh kosong.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: isEditing ? 'Simpan Perubahan' : 'Simpan Catatan',
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
