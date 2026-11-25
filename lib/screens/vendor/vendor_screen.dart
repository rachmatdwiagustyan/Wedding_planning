import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/empty_state.dart';
import '../../models/vendor_model.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import 'vendor_form_screen.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  List<VendorModel> _items = [];
  Map<String, dynamic> _summary = {};
  List<dynamic> _perbandinganKategori = [];

  String _selectedKategori = 'Semua';
  String _selectedStatus = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  final List<String> _kategoriFilterOptions = [
    'Semua',
    'Katering',
    'Dekorasi',
    'Fotografer',
    'Gedung',
    'Makeup',
    'Busana',
    'Wedding Organizer',
  ];

  final List<String> _statusFilterOptions = [
    'Semua',
    'Belum Dipesan',
    'Sudah Dipesan',
    'Dibatalkan',
  ];

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
    final res = await ApiService.getVendor(
      kategori: _selectedKategori,
      search: _searchQuery,
      status: _selectedStatus,
    );
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _items = (res.data!['items'] as List<VendorModel>?) ?? [];
        _summary = (res.data!['summary'] as Map<String, dynamic>?) ?? {};
        _perbandinganKategori = (res.data!['perbandingan_kategori'] as List<dynamic>?) ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _updateStatus(VendorModel item, String newStatus) async {
    final res = await ApiService.updateVendorStatus(item.id!, newStatus);
    if (!mounted) return;

    if (res.success) {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status "${item.namaVendor}" diubah menjadi $newStatus.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _deleteItem(VendorModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Vendor?', style: TextStyle(fontFamily: 'serif', fontSize: 16)),
        content: Text('Apakah Anda yakin ingin menghapus "${item.namaVendor}"?'),
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
      final res = await ApiService.deleteVendor(item.id!);
      if (res.success) {
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vendor berhasil dihapus.'), backgroundColor: AppColors.success),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sudah Dipesan':
      case 'Selesai':
      case 'Lunas':
        return AppColors.success;
      case 'Belum Dipesan':
        return AppColors.deepBurgundy;
      case 'Dibatalkan':
        return AppColors.danger;
      default:
        return AppColors.mochaBrown;
    }
  }

  IconData _getCategoryIcon(String kategori) {
    switch (kategori) {
      case 'Katering':
        return Icons.restaurant_outlined;
      case 'Dekorasi':
        return Icons.local_florist_outlined;
      case 'Fotografer':
        return Icons.camera_alt_outlined;
      case 'Gedung':
        return Icons.apartment_outlined;
      case 'Makeup':
        return Icons.face_retouching_natural_outlined;
      case 'Busana':
        return Icons.checkroom_outlined;
      case 'Wedding Organizer':
        return Icons.groups_outlined;
      default:
        return Icons.storefront_outlined;
    }
  }

  void _showVendorDetail(VendorModel item) {
    final statusColor = _getStatusColor(item.statusPemesanan);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.champagneBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Icon(_getCategoryIcon(item.kategori), color: AppColors.iconBurgundy, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaVendor,
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.charcoal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.warmIvory,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.divider),
                                  ),
                                  child: Text(
                                    item.kategori,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mochaBrown),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: statusColor.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    item.statusPemesanan,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 12),
                  // Estimasi Harga
                  const Text('Estimasi Harga Penawaran', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.rupiah(item.hargaPenawaran),
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBurgundy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Kontak & Alamat
                  if (item.nomorTelepon != null && item.nomorTelepon!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warmIvory.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 18, color: AppColors.deepBurgundy),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Nomor Telepon / PIC', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                Text(item.nomorTelepon!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16, color: AppColors.mochaBrown),
                            tooltip: 'Salin Nomor',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: item.nomorTelepon!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Nomor telepon ${item.nomorTelepon} berhasil disalin.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (item.alamat != null && item.alamat!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warmIvory.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.deepBurgundy),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Alamat Studio / Kantor', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                Text(item.alamat!, style: const TextStyle(fontSize: 12, color: AppColors.charcoal, height: 1.3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (item.catatan != null && item.catatan!.isNotEmpty) ...[
                    const Text('Deskripsi Layanan & Fasilitas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        item.catatan!,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  // Ubah Status Cepat
                  const Text('Ubah Status Pemesanan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final st in ['Belum Dipesan', 'Sudah Dipesan', 'Dibatalkan'])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                backgroundColor: item.statusPemesanan == st ? _getStatusColor(st) : AppColors.pureWhite,
                                side: BorderSide(
                                  color: item.statusPemesanan == st ? _getStatusColor(st) : AppColors.divider,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _updateStatus(item, st);
                              },
                              child: Text(
                                st,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: item.statusPemesanan == st ? FontWeight.w700 : FontWeight.w500,
                                  color: item.statusPemesanan == st ? AppColors.pureWhite : AppColors.charcoal,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tombol Aksi
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Vendor'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.mochaBrown,
                            side: const BorderSide(color: AppColors.divider),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VendorFormScreen(initialData: item)),
                            );
                            if (updated != null) _loadData();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Hapus'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _deleteItem(item);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPriceComparisonModal() {
    String compKategori = _selectedKategori == 'Semua' ? 'Katering' : _selectedKategori;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final compVendors = _items.where((v) => compKategori == 'Semua' || v.kategori == compKategori).toList();
          compVendors.sort((a, b) => a.hargaPenawaran.compareTo(b.hargaPenawaran));

          double minPrice = 0;
          double maxPrice = 0;
          double selisih = 0;
          double avgPrice = 0;

          if (compVendors.isNotEmpty) {
            minPrice = compVendors.first.hargaPenawaran;
            maxPrice = compVendors.last.hargaPenawaran;
            selisih = maxPrice - minPrice;
            final sum = compVendors.fold<double>(0, (prev, e) => prev + e.hargaPenawaran);
            avgPrice = sum / compVendors.length;
          }

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: AppColors.warmIvory,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Perbandingan Harga Vendor',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text('Bandingkan penawaran terbaik antarvendor rekanan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppColors.charcoal),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Pilih Kategori Perbandingan
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _kategoriFilterOptions.map((cat) {
                      final isSel = compKategori == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                              color: isSel ? AppColors.pureWhite : AppColors.charcoal,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: AppColors.deepBurgundy,
                          backgroundColor: AppColors.pureWhite,
                          side: BorderSide(color: isSel ? AppColors.deepBurgundy : AppColors.divider),
                          onSelected: (val) {
                            setModalState(() => compKategori = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                // Ringkasan Harga
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Termurah', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(Formatters.rupiah(minPrice), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
                        ],
                      ),
                      Container(width: 1, height: 28, color: AppColors.divider),
                      Column(
                        children: [
                          const Text('Rata-rata', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(Formatters.rupiah(avgPrice), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mochaBrown)),
                        ],
                      ),
                      Container(width: 1, height: 28, color: AppColors.divider),
                      Column(
                        children: [
                          const Text('Selisih Hemat', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(Formatters.rupiah(selisih), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: compVendors.isEmpty
                      ? const Center(
                          child: Text('Belum ada data vendor untuk kategori ini.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        )
                      : ListView.builder(
                          itemCount: compVendors.length,
                          itemBuilder: (context, idx) {
                            final v = compVendors[idx];
                            final isCheapest = idx == 0 && compVendors.length > 1;
                            final stColor = _getStatusColor(v.statusPemesanan);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isCheapest ? AppColors.success.withOpacity(0.5) : AppColors.divider,
                                  width: isCheapest ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: isCheapest ? AppColors.success : AppColors.warmIvory,
                                    child: Text(
                                      '${idx + 1}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isCheapest ? AppColors.pureWhite : AppColors.charcoal,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                v.namaVendor,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                                              ),
                                            ),
                                            if (isCheapest)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.success.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text('Paling Hemat', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.success)),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          Formatters.rupiah(v.hargaPenawaran),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy),
                                        ),
                                        if (v.catatan != null && v.catatan!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            v.catatan!,
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalVendor = _summary['total_vendor'] ?? _items.length;
    final totalDipesan = _summary['total_dipesan'] ?? 0;
    final totalNilai = double.tryParse(_summary['total_nilai_penawaran']?.toString() ?? '0') ?? 0.0;

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
                  const Text('Total Rekanan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text('$totalVendor Vendor', style: const TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                  Text('$totalDipesan Sudah Dipesan', style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
                ],
              ),
              Container(width: 1, height: 36, color: AppColors.divider),
              Column(
                children: [
                  const Text('Total Penawaran', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(Formatters.rupiah(totalNilai), style: const TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy)),
                  const Text('Akumulasi kontrak', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _showPriceComparisonModal,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.champagneBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.compare_arrows_rounded, size: 16, color: AppColors.iconBurgundy),
                  SizedBox(width: 6),
                  Text(
                    'Bandingkan Harga & Layanan Antarvendor',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.iconBurgundy),
                  ),
                ],
              ),
            ),
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
          'Pengelolaan Vendor',
          style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows_rounded, color: AppColors.deepBurgundy),
            tooltip: 'Perbandingan Harga',
            onPressed: _showPriceComparisonModal,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.deepBurgundy),
            tooltip: 'Tambah Vendor',
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VendorFormScreen()),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _buildSummaryCard(),
            ),
            // Kolom Pencarian Vendor
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
                  decoration: InputDecoration(
                    hintText: 'Cari nama vendor, PIC, atau alamat...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _loadData();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _loadData();
                  },
                ),
              ),
            ),
            // Filter Kategori Vendor
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: _kategoriFilterOptions.map((cat) {
                  final isSelected = _selectedKategori == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
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
            // Filter Status Pemesanan
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: _statusFilterOptions.map((st) {
                  final isSelected = _selectedStatus == st;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        st,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected ? AppColors.pureWhite : AppColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.mochaBrown,
                      backgroundColor: AppColors.pureWhite,
                      side: BorderSide(color: isSelected ? AppColors.mochaBrown : AppColors.divider),
                      onSelected: (val) {
                        setState(() => _selectedStatus = st);
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
                          icon: Icons.storefront_outlined,
                          title: 'Vendor Tidak Ditemukan',
                          message: _searchQuery.isNotEmpty
                              ? 'Tidak ada vendor yang cocok dengan pencarian "$_searchQuery".'
                              : 'Belum ada vendor pada kategori ini. Tambahkan vendor pribadi atau reset filter.',
                          buttonText: 'Tambah Vendor',
                          onButtonPressed: () async {
                            final added = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const VendorFormScreen()),
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
                              final v = _items[index];
                              final statusColor = _getStatusColor(v.statusPemesanan);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.pureWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _showVendorDetail(v),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    v.namaVendor,
                                                    style: const TextStyle(
                                                      fontFamily: 'serif',
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.charcoal,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Icon(_getCategoryIcon(v.kategori), size: 12, color: AppColors.mochaBrown),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        v.kategori,
                                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.mochaBrown),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: statusColor.withOpacity(0.3)),
                                              ),
                                              child: Text(
                                                v.statusPemesanan,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              Formatters.rupiah(v.hargaPenawaran),
                                              style: const TextStyle(
                                                fontFamily: 'serif',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.deepBurgundy,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (v.nomorTelepon != null && v.nomorTelepon!.isNotEmpty) ...[
                                              const Icon(Icons.phone_outlined, size: 12, color: AppColors.textMuted),
                                              const SizedBox(width: 4),
                                              Text(
                                                v.nomorTelepon!,
                                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (v.catatan != null && v.catatan!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            v.catatan!,
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Ketuk untuk lihat detail & hubungi',
                                              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.mochaBrown),
                                                  tooltip: 'Edit Vendor',
                                                  onPressed: () async {
                                                    final updated = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (_) => VendorFormScreen(initialData: v)),
                                                    );
                                                    if (updated != null) _loadData();
                                                  },
                                                ),
                                                const SizedBox(width: 14),
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                                  tooltip: 'Hapus Vendor',
                                                  onPressed: () => _deleteItem(v),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
