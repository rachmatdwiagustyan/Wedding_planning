import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/responsible_tag.dart';
import '../../widgets/empty_state.dart';
import '../../models/kebutuhan_model.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import 'kebutuhan_form_screen.dart';

class KebutuhanScreen extends StatefulWidget {
  const KebutuhanScreen({super.key});

  @override
  State<KebutuhanScreen> createState() => _KebutuhanScreenState();
}

class _KebutuhanScreenState extends State<KebutuhanScreen> {
  List<KebutuhanModel> _items = [];
  int _totalItem = 0;
  double _grandTotal = 0;
  int _totalDibeli = 0;
  double _totalTerbeli = 0;
  String _selectedKategori = 'Semua';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getKebutuhan(kategori: _selectedKategori);
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _items = (res.data!['items'] as List<KebutuhanModel>?) ?? [];
        _totalItem = res.data!['total_item'] ?? 0;
        _grandTotal = res.data!['grand_total'] ?? 0.0;
        _totalDibeli = res.data!['total_dibeli'] ?? 0;
        _totalTerbeli = res.data!['total_terbeli'] ?? 0.0;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _toggleStatus(KebutuhanModel item) async {
    final newStatus = item.isPurchased ? 'Belum Dibeli' : 'Sudah Dibeli';
    final res = await ApiService.toggleKebutuhan(item.id!, newStatus);
    if (res.success) {
      _loadData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _deleteItem(KebutuhanModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kebutuhan?', style: TextStyle(fontFamily: 'serif', fontSize: 16)),
        content: Text('Hapus "${item.namaBarang}" dari daftar kebutuhan?'),
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
      final res = await ApiService.deleteKebutuhan(item.id!);
      if (res.success) {
        _loadData();
      }
    }
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Nilai Kebutuhan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.rupiah(_grandTotal),
                    style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.champagne.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_totalDibeli / $_totalItem Terbeli',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.deepBurgundy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Terbeli: ${Formatters.rupiah(_totalTerbeli)}', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
              Text('Sisa: ${Formatters.rupiah(_grandTotal - _totalTerbeli)}', style: const TextStyle(fontSize: 12, color: AppColors.mochaBrown, fontWeight: FontWeight.w600)),
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
          'Daftar Hadiah & Kebutuhan',
          style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.deepBurgundy),
            tooltip: 'Tambah Barang',
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KebutuhanFormScreen()),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildSummaryCard(),
            ),
            // Filter Kategori
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: AppConstants.kategoriKebutuhan.map((cat) {
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
                          icon: Icons.card_giftcard_outlined,
                          title: 'Belum Ada Kebutuhan',
                          message: 'Catat barang seserahan, mahar, dan perlengkapan pernikahan Anda.',
                          buttonText: 'Tambah Kebutuhan',
                          onButtonPressed: () async {
                            final added = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const KebutuhanFormScreen()),
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
                              final item = _items[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.pureWhite,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: item.isPurchased ? AppColors.success.withOpacity(0.3) : AppColors.divider,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  leading: Checkbox(
                                    value: item.isPurchased,
                                    activeColor: AppColors.success,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (_) => _toggleStatus(item),
                                  ),
                                  title: Text(
                                    item.namaBarang,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: item.isPurchased ? AppColors.textMuted : AppColors.charcoal,
                                      decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.jumlah} x ${Formatters.rupiah(item.hargaSatuan)} = ${Formatters.rupiah(item.totalHarga)}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.deepBurgundy),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.warmIvory,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(item.kategori, style: const TextStyle(fontSize: 10, color: AppColors.mochaBrown)),
                                          ),
                                          ResponsibleTag(penanggungJawab: item.penanggungJawab, isSmall: true),
                                          if (item.catatan != null && item.catatan!.isNotEmpty)
                                            Text('• ${item.catatan}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 18, color: AppColors.softTaupe),
                                    onSelected: (val) async {
                                      if (val == 'edit') {
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => KebutuhanFormScreen(initialData: item)),
                                        );
                                        if (updated != null) _loadData();
                                      } else if (val == 'delete') {
                                        _deleteItem(item);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit Kebutuhan')),
                                      const PopupMenuItem(value: 'delete', child: Text('Hapus Kebutuhan', style: TextStyle(color: AppColors.danger))),
                                    ],
                                  ),
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
