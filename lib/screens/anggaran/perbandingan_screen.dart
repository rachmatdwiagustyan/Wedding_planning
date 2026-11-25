import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../models/perbandingan_model.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import 'perbandingan_form_screen.dart';

class PerbandinganScreen extends StatefulWidget {
  const PerbandinganScreen({super.key});

  @override
  State<PerbandinganScreen> createState() => _PerbandinganScreenState();
}

class _PerbandinganScreenState extends State<PerbandinganScreen> {
  List<PerbandinganModel> _items = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getPerbandingan();
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _items = (res.data!['items'] as List<PerbandinganModel>?) ?? [];
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

  Future<void> _deleteItem(PerbandinganModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Perbandingan?', style: TextStyle(fontFamily: 'serif', fontSize: 16)),
        content: Text('Hapus penawaran "${item.namaVendor}" untuk ${item.namaKebutuhan}?'),
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
      final res = await ApiService.deletePerbandingan(item.id!);
      if (res.success) {
        _loadData();
      }
    }
  }

  Widget _buildSummaryCards() {
    final termurah = double.tryParse(_summary['termurah']?.toString() ?? '0') ?? 0.0;
    final termahal = double.tryParse(_summary['termahal']?.toString() ?? '0') ?? 0.0;
    final total = _summary['total_perbandingan'] ?? _items.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('Total Penawaran', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text('$total Vendor', style: const TextStyle(fontFamily: 'serif', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
            ],
          ),
          Container(width: 1, height: 32, color: AppColors.divider),
          Column(
            children: [
              const Text('Penawaran Termurah', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(Formatters.rupiah(termurah), style: const TextStyle(fontFamily: 'serif', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success)),
            ],
          ),
          Container(width: 1, height: 32, color: AppColors.divider),
          Column(
            children: [
              const Text('Penawaran Tertinggi', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(Formatters.rupiah(termahal), style: const TextStyle(fontFamily: 'serif', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart() {
    if (_items.isEmpty) return const SizedBox.shrink();

    // Group items by nama_kebutuhan
    final Map<String, List<PerbandinganModel>> groups = {};
    for (var item in _items) {
      groups.putIfAbsent(item.namaKebutuhan, () => []).add(item);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.mochaBrown.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bar_chart, size: 20, color: AppColors.deepBurgundy),
              SizedBox(width: 8),
              Text(
                'Grafik Perbandingan Penawaran Vendor',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Visualisasi perbandingan penawaran harga vendor terhadap estimasi biaya.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ...groups.entries.map((entry) {
            final kebutuhanName = entry.key;
            final vendorList = entry.value;

            // Find highest price for scaling bars
            double maxPrice = 1.0;
            for (var v in vendorList) {
              if (v.hargaPenawaran > maxPrice) maxPrice = v.hargaPenawaran;
              if (v.estimasiBiaya > maxPrice) maxPrice = v.estimasiBiaya;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warmIvory.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider.withOpacity(0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kebutuhanName,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...vendorList.map((v) {
                    final ratio = maxPrice > 0 ? (v.hargaPenawaran / maxPrice).clamp(0.05, 1.0) : 0.5;
                    final isSaving = v.selisihHarga >= 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                v.namaVendor,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                              ),
                              Text(
                                Formatters.rupiah(v.hargaPenawaran),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Stack(
                            children: [
                              Container(
                                height: 12,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.divider.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: ratio,
                                child: Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isSaving
                                          ? [AppColors.success, const Color(0xFF68B27F)]
                                          : [AppColors.deepBurgundy, const Color(0xFF8E4A5E)],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Estimasi: ${Formatters.rupiah(v.estimasiBiaya)}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                              Text(
                                isSaving
                                    ? 'Lebih hemat ${Formatters.rupiah(v.selisihHarga)}'
                                    : 'Lebih mahal ${Formatters.rupiah(-v.selisihHarga)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSaving ? AppColors.success : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    if (_items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(Icons.table_chart_outlined, size: 20, color: AppColors.deepBurgundy),
                SizedBox(width: 8),
                Text(
                  'Tabel Rincian Perbandingan',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Kebutuhan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                DataColumn(label: Text('Vendor / Toko', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                DataColumn(label: Text('Penawaran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                DataColumn(label: Text('Estimasi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                DataColumn(label: Text('Selisih', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
              ],
              rows: _items.map((v) {
                final isSaving = v.selisihHarga >= 0;

                return DataRow(
                  cells: [
                    DataCell(Text(v.namaKebutuhan, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    DataCell(Text(v.namaVendor, style: const TextStyle(fontSize: 12))),
                    DataCell(Text(Formatters.rupiah(v.hargaPenawaran), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy))),
                    DataCell(Text(Formatters.rupiah(v.estimasiBiaya), style: const TextStyle(fontSize: 12))),
                    DataCell(
                      Text(
                        Formatters.rupiah(v.selisihHarga),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSaving ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.mochaBrown),
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => PerbandinganFormScreen(initialData: v)),
                              );
                              if (updated != null) _loadData();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                            onPressed: () => _deleteItem(v),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
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
          'Perbandingan Anggaran',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.deepBurgundy),
            tooltip: 'Tambah Penawaran Vendor',
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerbandinganFormScreen()),
              );
              if (added != null) _loadData();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.deepBurgundy))
            : _items.isEmpty
                ? EmptyState(
                    icon: Icons.compare_arrows_outlined,
                    title: 'Belum Ada Perbandingan',
                    message: 'Bandingkan penawaran dari beberapa vendor untuk mendapatkan harga dan kualitas terbaik.',
                    buttonText: 'Tambah Perbandingan',
                    onButtonPressed: () async {
                      final added = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PerbandinganFormScreen()),
                      );
                      if (added != null) _loadData();
                    },
                  )
                : RefreshIndicator(
                    color: AppColors.deepBurgundy,
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSummaryCards(),
                          _buildComparisonChart(),
                          _buildDataTable(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
