import 'package:intl/intl.dart';

/// Utilitas pemformatan tanggal dan waktu dari respons ISO-8601 Open-Meteo.
class DateFormatter {
  DateFormatter._();

  static const List<String> _indonesianDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _indonesianMonthsShort = [
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
    'Des',
  ];

  /// Mengubah string tanggal `YYYY-MM-DD` menjadi label hari (misal: "Hari Ini", "Besok", "Rabu").
  static String formatDayName(String isoDate, {int index = -1}) {
    if (index == 0) return 'Hari Ini';
    if (index == 1) return 'Besok';

    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;
    return _indonesianDays[parsed.weekday - 1];
  }

  /// Mengubah string tanggal `YYYY-MM-DD` menjadi tanggal ringkas (misal: "25 Nov").
  static String formatShortDate(String isoDate) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;
    final month = _indonesianMonthsShort[parsed.month - 1];
    return '${parsed.day} $month';
  }

  /// Mengubah timestamp ISO Open-Meteo (misal: `2026-11-25T18:45`) menjadi format jam & tanggal.
  static String formatLastUpdated(String isoDateTime) {
    final parsed = DateTime.tryParse(isoDateTime);
    if (parsed == null) return isoDateTime;
    final dayName = _indonesianDays[parsed.weekday - 1];
    final month = _indonesianMonthsShort[parsed.month - 1];
    final time = DateFormat('HH:mm').format(parsed);
    return '$dayName, ${parsed.day} $month • $time';
  }
}
