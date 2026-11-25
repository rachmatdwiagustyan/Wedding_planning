import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/responsible_tag.dart';
import '../../widgets/empty_state.dart';
import '../../models/dokumen_model.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import 'administrasi_form_screen.dart';

class AdministrasiScreen extends StatefulWidget {
  const AdministrasiScreen({super.key});

  @override
  State<AdministrasiScreen> createState() => _AdministrasiScreenState();
}

class _AdministrasiScreenState extends State<AdministrasiScreen> {
  List<DokumenModel> _items = [];
  int _total = 0;
  int _selesai = 0;
  int _belumSelesai = 0;
  double _persentase = 0.0;
  String _selectedFilter = 'Semua';
  bool _isLoading = true;

  final List<String> _filterOptions = [
    'Semua',
    'Calon Pengantin Wanita',
    'Calon Pengantin Pria',
    'Keduanya',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatPersentase(double val) {
    if (val == val.roundToDouble()) {
      return '${val.toInt()}%';
    }
    return '${val.toStringAsFixed(2).replaceAll('.', ',')}%';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getDokumen(penanggungJawab: _selectedFilter);
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _items = (res.data!['items'] as List<DokumenModel>?) ?? [];
        _total = res.data!['total'] ?? 0;
        _selesai = res.data!['selesai'] ?? 0;
        _belumSelesai = res.data!['belum_selesai'] ?? 0;
        _persentase = double.tryParse(res.data!['persentase']?.toString() ?? '0') ?? 0.0;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _toggleStatus(DokumenModel item) async {
    final index = _items.indexWhere((d) => d.id == item.id);
    if (index == -1) return;

    final oldItem = _items[index];
    final wasComplete = oldItem.isComplete;
    final newStatus = wasComplete ? 'Belum Disiapkan' : 'Sudah Disiapkan';
    final nowStr = DateTime.now().toIso8601String().split('T')[0];

    // Optimistic local update for this specific document item only
    final updatedItem = oldItem.copyWith(
      statusKelengkapan: newStatus,
      tanggalDisiapkan: newStatus == 'Sudah Disiapkan' ? nowStr : null,
    );

    final oldSelesai = _selesai;
    final oldBelumSelesai = _belumSelesai;
    final oldPersentase = _persentase;

    final newSelesai = wasComplete ? (_selesai > 0 ? _selesai - 1 : 0) : _selesai + 1;
    final newBelumSelesai = _total >= newSelesai ? _total - newSelesai : 0;
    final newPersentase = _total > 0 ? (newSelesai / _total) * 100 : 0.0;

    setState(() {
      _items[index] = updatedItem;
      _selesai = newSelesai;
      _belumSelesai = newBelumSelesai;
      _persentase = newPersentase;
    });

    final res = await ApiService.toggleDokumen(item.id!, newStatus);
    if (!mounted) return;

    if (res.success) {
      if (res.data != null) {
        final serverTgl = res.data!['tanggal_disiapkan'] as String?;
        final serverStatus = res.data!['status_kelengkapan'] as String? ?? newStatus;
        setState(() {
          _items[index] = _items[index].copyWith(
            statusKelengkapan: serverStatus,
            tanggalDisiapkan: serverTgl,
          );
        });
      }
      // Synchronize with server calculated summary if available
      if (res.data != null && res.data!['summary'] != null) {
        final summary = res.data!['summary'];
        setState(() {
          _total = summary['total'] ?? _total;
          _selesai = summary['selesai'] ?? _selesai;
          _belumSelesai = summary['belum_selesai'] ?? _belumSelesai;
          _persentase = double.tryParse(summary['persentase']?.toString() ?? '0') ?? _persentase;
        });
      }
    } else {
      // Rollback to previous state if saving failed
      setState(() {
        _items[index] = oldItem;
        _selesai = oldSelesai;
        _belumSelesai = oldBelumSelesai;
        _persentase = oldPersentase;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan perubahan: ${res.message}. Status dikembalikan.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _deleteItem(DokumenModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Dokumen?', style: TextStyle(fontFamily: 'serif', fontSize: 16)),
        content: Text('Apakah Anda yakin ingin menghapus "${item.namaDokumen}"?'),
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
      final res = await ApiService.deleteDokumen(item.id!);
      if (res.success) {
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dokumen berhasil dihapus.'), backgroundColor: AppColors.success),
          );
        }
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
                  const Text('Kelengkapan Dokumen', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    '$_selesai dari $_total Selesai',
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
                  _formatPersentase(_persentase),
                  style: const TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _total > 0 ? (_selesai / _total) : 0,
              minHeight: 8,
              backgroundColor: AppColors.warmIvory,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.deepBurgundy),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_selesai Sudah Disiapkan', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
              Text('$_belumSelesai Belum Disiapkan', style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600)),
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
          'Administrasi Pernikahan',
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
            tooltip: 'Tambah Dokumen',
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdministrasiFormScreen()),
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
            // Filter Penanggung Jawab
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: _filterOptions.map((opt) {
                  final isSelected = _selectedFilter == opt;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppColors.pureWhite : AppColors.charcoal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.deepBurgundy,
                      backgroundColor: AppColors.pureWhite,
                      side: BorderSide(
                        color: isSelected ? AppColors.deepBurgundy : AppColors.divider,
                      ),
                      onSelected: (val) {
                        setState(() {
                          _selectedFilter = opt;
                        });
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
                          icon: Icons.assignment_outlined,
                          title: 'Belum Ada Dokumen',
                          message: 'Dokumen untuk kategori ini belum tersedia.',
                          buttonText: 'Tambah Dokumen',
                          onButtonPressed: () async {
                            final added = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdministrasiFormScreen()),
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
                              final doc = _items[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.pureWhite,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: doc.isComplete ? AppColors.success.withOpacity(0.3) : AppColors.divider,
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  onTap: () => _toggleStatus(doc),
                                  leading: Checkbox(
                                    value: doc.isComplete,
                                    activeColor: AppColors.success,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (_) => _toggleStatus(doc),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${doc.nomorDokumen}. ${doc.namaDokumen}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: doc.isComplete ? AppColors.textMuted : AppColors.charcoal,
                                            decoration: doc.isComplete ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (doc.isComplete ? AppColors.success : AppColors.danger).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          doc.isComplete ? 'Sudah Disiapkan' : 'Belum Disiapkan',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: doc.isComplete ? AppColors.success : AppColors.danger,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 8,
                                      children: [
                                        ResponsibleTag(penanggungJawab: doc.penanggungJawab, isSmall: true),
                                        if (doc.tanggalDisiapkan != null && doc.tanggalDisiapkan!.isNotEmpty)
                                          Text(
                                            Formatters.tanggalSingkat(doc.tanggalDisiapkan),
                                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          ),
                                        if (doc.catatan != null && doc.catatan!.isNotEmpty)
                                          Text(
                                            '• ${doc.catatan}',
                                            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                                          ),
                                      ],
                                    ),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 18, color: AppColors.softTaupe),
                                    onSelected: (val) async {
                                      if (val == 'edit') {
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AdministrasiFormScreen(initialData: doc),
                                          ),
                                        );
                                        if (updated != null) _loadData();
                                      } else if (val == 'delete') {
                                        _deleteItem(doc);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit Dokumen')),
                                      const PopupMenuItem(value: 'delete', child: Text('Hapus Dokumen', style: TextStyle(color: AppColors.danger))),
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
