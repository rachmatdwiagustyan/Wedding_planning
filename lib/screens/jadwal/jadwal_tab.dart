import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/responsible_tag.dart';
import '../../widgets/empty_state.dart';
import '../../models/jadwal_model.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import 'jadwal_form_screen.dart';

class JadwalTab extends StatefulWidget {
  const JadwalTab({super.key});

  @override
  State<JadwalTab> createState() => _JadwalTabState();
}

class _JadwalTabState extends State<JadwalTab> {
  List<JadwalModel> _items = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  bool _isTimelineView = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getJadwal();
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

  Future<void> _toggleStatus(JadwalModel item) async {
    final res = await ApiService.toggleJadwal(item.id!, !item.statusSelesai);
    if (res.success) {
      _loadData();
    }
  }

  Future<void> _deleteItem(JadwalModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Agenda Kegiatan?', style: TextStyle(fontFamily: 'serif', fontSize: 16)),
        content: Text('Hapus "${item.namaKegiatan}" dari jadwal?'),
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
      final res = await ApiService.deleteJadwal(item.id!);
      if (res.success) _loadData();
    }
  }

  Widget _buildCalendarHeader() {
    // Generate simple 7-day strip centered around _selectedDate
    final days = List.generate(14, (i) {
      return DateTime.now().subtract(const Duration(days: 3)).add(Duration(days: i));
    });

    final dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.6))),
      ),
      child: SizedBox(
        height: 64,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final dt = days[index];
            final isSelected = dt.year == _selectedDate.year &&
                dt.month == _selectedDate.month &&
                dt.day == _selectedDate.day;

            // Check if there are events on this date
            final dateStr = '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
            final hasEvents = _items.any((e) => e.tanggal == dateStr);

            return GestureDetector(
              onTap: () {
                setState(() => _selectedDate = dt);
              },
              child: Container(
                width: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.deepBurgundy : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected ? null : Border.all(color: AppColors.divider),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayNames[dt.weekday % 7],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.pureWhite.withOpacity(0.8) : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dt.day}',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.pureWhite : AppColors.charcoal,
                      ),
                    ),
                    if (hasEvents)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.champagne : AppColors.deepBurgundy,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimelineItem(JadwalModel item, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  Formatters.jam(item.jamMulai).replaceAll(' WIB', ''),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.deepBurgundy),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: item.statusSelesai ? AppColors.success : AppColors.champagne,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.pureWhite, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.divider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Event Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.statusSelesai ? AppColors.success.withOpacity(0.3) : AppColors.divider,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mochaBrown.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.namaKegiatan,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: item.statusSelesai ? AppColors.textMuted : AppColors.charcoal,
                            decoration: item.statusSelesai ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Checkbox(
                        value: item.statusSelesai,
                        activeColor: AppColors.success,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (_) => _toggleStatus(item),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.tanggal(item.tanggal),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${Formatters.jam(item.jamMulai)} - ${Formatters.jam(item.jamSelesai)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.lokasi,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ResponsibleTag(penanggungJawab: item.penanggungJawab, isSmall: true),
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.mochaBrown),
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => JadwalFormScreen(initialData: item)),
                              );
                              if (updated != null) _loadData();
                            },
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter items based on selected view mode or date
    final String selectedDateStr = '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final displayList = _isTimelineView
        ? _items
        : _items.where((e) => e.tanggal == selectedDateStr).toList();

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Jadwal Acara',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        actions: [
          // Switch Timeline / Kalender view
          IconButton(
            icon: Icon(_isTimelineView ? Icons.calendar_month : Icons.view_timeline, color: AppColors.deepBurgundy),
            tooltip: _isTimelineView ? 'Lihat Mode Kalender' : 'Lihat Mode Timeline',
            onPressed: () {
              setState(() => _isTimelineView = !_isTimelineView);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.deepBurgundy),
            tooltip: 'Tambah Jadwal',
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JadwalFormScreen()),
              );
              if (added != null) _loadData();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Calendar Strip Header
            _buildCalendarHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isTimelineView
                        ? 'Seluruh Timeline Kegiatan (${_items.length})'
                        : 'Agenda Tanggal ${Formatters.tanggal(selectedDateStr)} (${displayList.length})',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Text(
                    _isTimelineView ? 'Mode Timeline' : 'Mode Kalender',
                    style: const TextStyle(fontSize: 11, color: AppColors.deepBurgundy, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.deepBurgundy))
                  : displayList.isEmpty
                      ? EmptyState(
                          icon: Icons.event_note_outlined,
                          title: 'Belum Ada Kegiatan',
                          message: _isTimelineView
                              ? 'Tambahkan agenda pertemuan vendor, fitting pakaian, akad nikah, atau resepsi.'
                              : 'Tidak ada agenda kegiatan pada tanggal ini.',
                          buttonText: 'Tambah Jadwal Kegiatan',
                          onButtonPressed: () async {
                            final added = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const JadwalFormScreen()),
                            );
                            if (added != null) _loadData();
                          },
                        )
                      : RefreshIndicator(
                          color: AppColors.deepBurgundy,
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              return _buildTimelineItem(displayList[index], index == displayList.length - 1);
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
