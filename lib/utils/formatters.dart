import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String rupiah(num value) {
    return _currencyFormat.format(value);
  }

  static String tanggal(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(dateStr);
      final List<String> bulan = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      return '${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  static String tanggalSingkat(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(dateStr);
      final List<String> bulan = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  static String jam(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '-';
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]} WIB';
      }
      return timeStr;
    } catch (_) {
      return timeStr;
    }
  }
}
