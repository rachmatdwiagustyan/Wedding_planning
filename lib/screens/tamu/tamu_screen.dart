import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/empty_state.dart';
import '../../models/tamu_model.dart';
import '../../services/api_service.dart';
import 'tamu_form_screen.dart';

class TamuScreen extends StatefulWidget {
  const TamuScreen({super.key});

  @override
  State<TamuScreen> createState() => _TamuScreenState();
}

class _TamuScreenState extends State<TamuScreen> {
  List<TamuModel> _items = [];
  Map<String, dynamic> _summary = {};
  String _searchQuery = '';
  String _selectedKategori = 'Semua';
  String _selectedKonfirmasi = 'Semua';
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getTamu(
      search: _searchQuery,
      kategori: _selectedKategori,
      konfirmasi: _selectedKonfirmasi,
    );
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _items = (res.data!['items'] as List<TamuModel>?) ?? [];
        _summary = (res.data!['summary'] as Map<String, dynamic>?) ?? {};
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _deleteItem(TamuModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tamu?', style: TextStyle(fontFamily: 'serif', fontSize: 16)),
        content: Text('Hapus "${item.namaTamu}" dari daftar tamu?'),
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
      final res = await ApiService.deleteTamu(item.id!);
      if (res.success) _loadData();
    }
  }

  Color _getKonfirmasiColor(String status) {
    switch (status) {
      case 'Hadir':
        return AppColors.success;
      case 'Tidak Hadir':
        return AppColors.danger;
      case 'Belum Konfirmasi':
      default:
        return AppColors.warning;
    }
  }

  Widget _buildSummaryCard() {
    final totalUndangan = _summary['total_undangan'] ?? 0;
    final totalTamu = _summary['total_tamu'] ?? 0;
    final totalHadir = _summary['total_hadir'] ?? 0;
    final totalTidakHadir = _summary['total_tidak_hadir'] ?? 0;
    final totalBelumKonfirmasi = _summary['total_belum_konfirmasi'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Total Undangan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text('$totalUndangan', style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                  const Text('Undangan terdata', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
              Container(width: 1, height: 36, color: AppColors.divider),
              Column(
                children: [
                  const Text('Total Jiwa / Tamu', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text('$totalTamu Orang', style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy)),
                  Text('$totalHadir orang hadir', style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('$totalHadir Hadir', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('$totalTidakHadir Tidak Hadir', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.danger)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('$totalBelumKonfirmasi Belum Konfirmasi', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
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
          'Daftar Tamu Undangan',
          style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.deepBurgundy),
            tooltip: 'Tambah Tamu',
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TamuFormScreen()),
              );
              if (added != null) _loadData();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _buildSummaryCard(),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama tamu atau nomor telepon...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.softTaupe),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.mochaBrown),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _loadData();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.pureWhite,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
                ),
                onSubmitted: (val) {
                  setState(() => _searchQuery = val.trim());
                  _loadData();
                },
              ),
            ),
            // Filter Kategori
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: AppConstants.kategoriTamu.map((cat) {
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
            // Filter Status Konfirmasi
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: ['Semua', ...AppConstants.konfirmasiKehadiran].map((st) {
                  final isSelected = _selectedKonfirmasi == st;
                  Color activeColor = AppColors.deepBurgundy;
                  if (st == 'Hadir') activeColor = AppColors.success;
                  if (st == 'Tidak Hadir') activeColor = AppColors.danger;
                  if (st == 'Belum Konfirmasi') activeColor = AppColors.warning;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        st,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppColors.pureWhite : AppColors.charcoal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: activeColor,
                      backgroundColor: AppColors.pureWhite,
                      side: BorderSide(color: isSelected ? activeColor : AppColors.divider),
                      onSelected: (val) {
                        setState(() => _selectedKonfirmasi = st);
                        _loadData();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.deepBurgundy))
                  : _items.isEmpty
                      ? EmptyState(
                          icon: Icons.people_outline,
                          title: 'Belum Ada Tamu',
                          message: 'Tambahkan keluarga, sahabat, dan relasi Anda ke dalam daftar undangan.',
                          buttonText: 'Tambah Tamu',
                          onButtonPressed: () async {
                            final added = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TamuFormScreen()),
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
                              final tamu = _items[index];
                              final konfirmasiColor = _getKonfirmasiColor(tamu.konfirmasiKehadiran);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.pureWhite,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.champagne.withOpacity(0.3),
                                      child: Text(
                                        tamu.namaTamu.isNotEmpty ? tamu.namaTamu[0].toUpperCase() : 'T',
                                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.deepBurgundy),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  tamu.namaTamu,
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: konfirmasiColor.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  tamu.konfirmasiKehadiran,
                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: konfirmasiColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${tamu.kategori} • ${tamu.jumlahOrang} Orang • ${tamu.statusUndangan}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                          if (tamu.nomorTelepon != null && tamu.nomorTelepon!.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              'Telp: ${tamu.nomorTelepon}',
                                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.softTaupe),
                                      onSelected: (val) async {
                                        if (val == 'edit') {
                                          final updated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => TamuFormScreen(initialData: tamu)),
                                          );
                                          if (updated != null) _loadData();
                                        } else if (val == 'delete') {
                                          _deleteItem(tamu);
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem(value: 'edit', child: Text('Edit Tamu')),
                                        const PopupMenuItem(value: 'delete', child: Text('Hapus Tamu', style: TextStyle(color: AppColors.danger))),
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
