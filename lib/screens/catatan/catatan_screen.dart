import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../models/catatan_model.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import 'catatan_form_screen.dart';

class CatatanScreen extends StatefulWidget {
  const CatatanScreen({super.key});

  @override
  State<CatatanScreen> createState() => _CatatanScreenState();
}

class _CatatanScreenState extends State<CatatanScreen> {
  List<CatatanModel> _items = [];
  String _selectedKategori = 'Semua';
  bool _isLoading = true;

  final List<String> _kategoriList = [
    'Semua',
    'Umum',
    'Inspirasi Konsep',
    'Pertanyaan Vendor',
    'Susunan Acara',
    'Daftar Lagu',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getCatatan(kategori: _selectedKategori);
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _items = res.data!;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _deleteItem(CatatanModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?', style: TextStyle(fontFamily: 'serif', fontSize: 16)),
        content: Text('Hapus catatan "${item.judul}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.pureWhite)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final res = await ApiService.deleteCatatan(item.id!);
      if (res.success) _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.charcoal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Catatan Pernikahan',
          style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.deepBurgundy),
            tooltip: 'Tambah Catatan',
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CatatanFormScreen()),
              );
              if (added != null) _loadData();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Kategori
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _kategoriList.map((cat) {
                  final isSelected = _selectedKategori == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppColors.pureWhite : AppColors.charcoal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.deepBurgundy,
                      backgroundColor: AppColors.pureWhite,
                      side: BorderSide(color: isSelected ? AppColors.deepBurgundy : AppColors.divider),
                      onSelected: (val) {
                        setState(() => _selectedKategori = cat);
                        _loadData();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.deepBurgundy))
                  : _items.isEmpty
                      ? EmptyState(
                          icon: Icons.note_alt_outlined,
                          title: 'Belum Ada Catatan',
                          message: 'Simpan ide konsep, daftar pertanyaan ke vendor, susunan acara, dan catatan penting lainnya.',
                          buttonText: 'Tambah Catatan',
                          onButtonPressed: () async {
                            final added = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CatatanFormScreen()),
                            );
                            if (added != null) _loadData();
                          },
                        )
                      : RefreshIndicator(
                          color: AppColors.deepBurgundy,
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final note = _items[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.pureWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            note.judul,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.warmIvory,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            note.kategori,
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mochaBrown),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      note.isi,
                                      style: const TextStyle(fontSize: 13, color: AppColors.charcoal, height: 1.4),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          note.createdAt != null ? Formatters.tanggalSingkat(note.createdAt) : '',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.mochaBrown),
                                              onPressed: () async {
                                                final updated = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => CatatanFormScreen(initialData: note)),
                                                );
                                                if (updated != null) _loadData();
                                              },
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                              onPressed: () => _deleteItem(note),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
