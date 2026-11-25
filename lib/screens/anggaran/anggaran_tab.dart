import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/responsible_tag.dart';
import '../../widgets/empty_state.dart';
import '../../models/anggaran_model.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import 'anggaran_form_screen.dart';
import 'perbandingan_screen.dart';

class AnggaranTab extends StatefulWidget {
  const AnggaranTab({super.key});

  @override
  State<AnggaranTab> createState() => _AnggaranTabState();
}

class _AnggaranTabState extends State<AnggaranTab> {
  List<AnggaranModel> _items = [];
  double _totalEstimasi = 0;
  double _totalAktual = 0;
  double _selisih = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getAnggaran();
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _items = (res.data!['items'] as List<AnggaranModel>?) ?? [];
        _totalEstimasi = res.data!['total_estimasi'] ?? 0.0;
        _totalAktual = res.data!['total_aktual'] ?? 0.0;
        _selisih = res.data!['selisih'] ?? 0.0;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _deleteItem(AnggaranModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pos Anggaran?', style: TextStyle(fontFamily: 'serif', fontSize: 16)),
        content: Text('Apakah Anda yakin ingin menghapus "${item.namaKebutuhan}"?'),
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

    if (confirm == true && item.id != null) {
      final res = await ApiService.deleteAnggaran(item.id!);
      if (res.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message), backgroundColor: AppColors.success),
          );
        }
        _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message), backgroundColor: AppColors.danger),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Lunas':
        return AppColors.success;
      case 'Uang Muka':
        return AppColors.warning;
      case 'Belum Dibayar':
      default:
        return AppColors.danger;
    }
  }

  IconData _getKategoriIcon(String kategori) {
    switch (kategori) {
      case 'Venue & Gedung':
        return Icons.apartment_outlined;
      case 'Katering & Konsumsi':
        return Icons.restaurant_outlined;
      case 'Dekorasi':
        return Icons.palette_outlined;
      case 'Busana & Rias Pengantin':
        return Icons.checkroom_outlined;
      case 'Fotografi & Videografi':
        return Icons.photo_camera_outlined;
      case 'Undangan & Souvenir':
        return Icons.card_giftcard_outlined;
      case 'Hiburan':
        return Icons.music_note_outlined;
      case 'Transportasi':
        return Icons.directions_car_outlined;
      case 'Lainnya':
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildSummaryCard() {
    final isPositive = _selisih >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.mochaBrown.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Estimasi Anggaran', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.rupiah(_totalEstimasi),
                    style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Aktual', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.rupiah(_totalAktual),
                    style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPositive ? 'Selisih / Sisa Anggaran:' : 'Melebihi Anggaran:',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.mochaBrown),
              ),
              Text(
                Formatters.rupiah(_selisih),
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isPositive ? AppColors.success : AppColors.danger,
                ),
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
        centerTitle: false,
        title: const Text(
          'Anggaran Pernikahan',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows_outlined, color: AppColors.deepBurgundy),
            tooltip: 'Perbandingan Harga Vendor',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerbandinganScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.deepBurgundy),
            tooltip: 'Tambah Anggaran',
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnggaranFormScreen()),
              );
              if (added == true) _loadData();
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
            // Tombol Navigasi ke Perbandingan Anggaran & Grafik
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PerbandinganScreen()),
                  );
                },
                icon: const Icon(Icons.bar_chart, size: 18, color: AppColors.deepBurgundy),
                label: const Text(
                  'Buka Perbandingan Harga Vendor & Grafik',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.deepBurgundy),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.champagne),
                  backgroundColor: AppColors.pureWhite,
                  minimumSize: const Size(double.infinity, 38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.deepBurgundy))
                  : _items.isEmpty
                      ? EmptyState(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Belum Ada Anggaran',
                          message: 'Catat pos anggaran venue, katering, dekorasi, dan busana pernikahan.',
                          buttonText: 'Tambah Anggaran',
                          onButtonPressed: () async {
                            final added = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AnggaranFormScreen()),
                            );
                            if (added == true) _loadData();
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
                              final statusColor = _getStatusColor(item.statusPembayaran);
                              final kategoriIcon = _getKategoriIcon(item.kategori);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.pureWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Baris Judul & Status Pembayaran
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.namaKebutuhan,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.charcoal,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              // Label / Badge Kategori Pengeluaran
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.warmIvory,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: AppColors.champagne.withValues(alpha: 0.7), width: 1),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(kategoriIcon, size: 12, color: AppColors.mochaBrown),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      item.kategori,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.mochaBrown,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1),
                                          ),
                                          child: Text(
                                            item.statusPembayaran,
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (item.namaVendor != null && item.namaVendor!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.storefront_outlined, size: 13, color: AppColors.mochaBrown),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Vendor: ${item.namaVendor!}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.mochaBrown),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    // Rincian Biaya: Estimasi, Aktual, Selisih
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.warmIvory.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Estimasi:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  Formatters.rupiah(item.estimasiBiaya),
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Biaya Aktual:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  Formatters.rupiah(item.biayaAktual),
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                const Text('Selisih:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  Formatters.rupiah(item.selisih),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: item.selisih >= 0 ? AppColors.success : AppColors.danger,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Baris Penanggung Jawab & Aksi Edit / Hapus
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ResponsibleTag(penanggungJawab: item.penanggungJawab, isSmall: true),
                                        Row(
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.mochaBrown),
                                              tooltip: 'Edit Anggaran',
                                              onPressed: () async {
                                                final updated = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => AnggaranFormScreen(initialData: item)),
                                                );
                                                if (updated == true) _loadData();
                                              },
                                            ),
                                            const SizedBox(width: 14),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                              tooltip: 'Hapus Anggaran',
                                              onPressed: () => _deleteItem(item),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (item.catatan != null && item.catatan!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'Catatan: ${item.catatan}',
                                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                                      ),
                                    ],
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
